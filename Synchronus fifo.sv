module sync_fifo #(
    parameter DEPTH = 16,        // Number of locations
    parameter DATA_WIDTH = 8     // Bits per location
)(
    input  logic                   clk,
    input  logic                   rst_n,   // Active low reset
    input  logic                   w_en,    // Write enable
    input  logic                   r_en,    // Read enable
    input  logic [DATA_WIDTH-1:0]  w_data,  // Data input
    output logic [DATA_WIDTH-1:0]  r_data,  // Data output
    output logic                   full,
    output logic                   empty
);

    // 1. Internal Parameters and Memory
    localparam ADDR_W = $clog2(DEPTH);
    logic [DATA_WIDTH-1:0] fifo_mem [DEPTH];
    
    // 2. Pointers (Note the ADDR_W size for the extra bit)
    logic [ADDR_W:0] w_ptr; 
    logic [ADDR_W:0] r_ptr;

    // 3. Write Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            w_ptr <= 0;
        end else if (w_en && !full) begin
            fifo_mem[w_ptr[ADDR_W-1:0]] <= w_data;
            w_ptr <= w_ptr + 1;
        end
    end

    // 4. Read Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_ptr <= 0;
            r_data <= 0;
        end else if (r_en && !empty) begin
            r_data <= fifo_mem[r_ptr[ADDR_W-1:0]];
            r_ptr <= r_ptr + 1;
        end
    end

    // 5. Flag Logic
    // Empty: Everything is identical
    assign empty = (w_ptr == r_ptr);
    
    // Full: MSB is different, but address bits are the same
    assign full  = (w_ptr[ADDR_W] != r_ptr[ADDR_W]) && 
                   (w_ptr[ADDR_W-1:0] == r_ptr[ADDR_W-1:0]);

endmodule





//Another method//

module sync_fifo_status #(
    parameter DEPTH = 16,
    parameter DATA_W = 8
)(
    input  logic              clk,
    input  logic              rst_n,
    input  logic              w_en,
    input  logic              r_en,
    input  logic [DATA_W-1:0] w_data,
    output logic [DATA_W-1:0] r_data,
    output logic              full,
    output logic              empty,
    output logic              threshold_met // The "Half-Full" flag
);

    logic [DATA_W-1:0] mem [DEPTH];
    logic [3:0] w_ptr, r_ptr; // 4 bits for 16 locations
    logic [4:0] count;        // 5 bits to represent 0 to 16

    // --- Counter Logic (The Brain of the Flags) ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
        end else begin
            case ({w_en && !full, r_en && !empty})
                2'b10: count <= count + 1; // Write only
                2'b01: count <= count - 1; // Read only
                default: count <= count;   // Both or None
            endcase
        end
    end

    // --- Pointer & Memory Logic ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) {w_ptr, r_ptr} <= 0;
        else begin
            if (w_en && !full)  begin 
                mem[w_ptr] <= w_data; 
                w_ptr <= w_ptr + 1; 
            end
            if (r_en && !empty) begin 
                r_data <= mem[r_ptr]; 
                r_ptr <= r_ptr + 1; 
            end
        end
    end

    // --- Flag Assignments ---
    assign empty = (count == 0);
    assign full  = (count == DEPTH);
    assign threshold_met = (count >= 8);

endmodule
