`timescale 1ns/1ps

module tb_sobel_detector;

    // --- Parameters ---
    localparam DATA_WIDTH = 8;
    localparam IMG_WIDTH  = 10; // Must match image_in.txt
    localparam IMG_HEIGHT = 7;  // Must match image_in.txt
    
    // --- DUT Signals ---
    reg i_clk;
    reg i_rst_n;
    reg i_valid_in;
    reg [DATA_WIDTH-1:0] i_data_in;
    reg i_eol_in;
    
    wire o_valid_out;
    wire [DATA_WIDTH-1:0] o_data_out;

    // --- Instantiate DUT ---
    sobel_detector #(
        .DATA_WIDTH(DATA_WIDTH),
        .LINE_WIDTH(IMG_WIDTH) // Match line buffer to image width
    ) uut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_valid_in(i_valid_in),
        .i_data_in(i_data_in),
        .i_eol_in(i_eol_in),
        .o_valid_out(o_valid_out),
        .o_data_out(o_data_out)
    );

    // --- Clock Generator ---
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk; // 10ns clock period
    end
    
    // --- Stimulus ---
    reg [DATA_WIDTH-1:0] image_mem [0:IMG_WIDTH*IMG_HEIGHT-1];
    integer file_handle_out;
    
    initial begin
        // Load the image file into our testbench memory
        $readmemh("image_in.txt", image_mem);
        
        // Open the output file for writing
        file_handle_out = $fopen("image_out.txt", "w");
        
        // 1. Assert Reset
        i_rst_n <= 0;
        i_valid_in <= 0;
        i_data_in <= 0;
        i_eol_in <= 0;
        #20;
        i_rst_n <= 1; // Release reset
        
        // 2. Stream the image
        $display("--- Starting Image Stream ---");
        for (integer y = 0; y < IMG_HEIGHT; y = y + 1) begin
            for (integer x = 0; x < IMG_WIDTH; x = x + 1) begin
                @(negedge i_clk);
                i_valid_in <= 1;
                i_data_in  <= image_mem[y*IMG_WIDTH + x];
                i_eol_in   <= (x == IMG_WIDTH - 1); // Assert EOL on last pixel
            end
        end
        
        // 3. Stop sending data
        @(negedge i_clk);
        i_valid_in <= 0;
        i_eol_in   <= 0;
        
        // 4. Wait for pipeline to flush
        #100;
        $display("--- Finished Simulation (check image_out.txt) ---");
        $fclose(file_handle_out);
        $finish;
    end
    
    // --- Monitor / File Writer ---
    // This block runs in parallel, watching for valid output
    always @(posedge i_clk) begin
        if (o_valid_out) begin
            // Write the valid output pixel to the file
            $fwrite(file_handle_out, "%h\n", o_data_out);
            
            // Also print to console
            $display("Time: %0t | Valid Pixel Out: %h", $time, o_data_out);
        end
    end

endmodule