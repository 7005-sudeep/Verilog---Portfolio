// so for this we just need first take input and output for both source and destination then first need to make ready 1 when reset is low 
// then we need to copy data from datain to dataout then again when ack is high we have to stop getting data means making ready 0 




module cdc_handshake #(parameter WIDTH = 32) (
    // Domain A (Source)
    input  logic             clk_a,
    input  logic             rst_n_a,
    input  logic [WIDTH-1:0] data_in,
    input  logic             send_en,
    output logic             ready_a,

    // Domain B (Destination)
    input  logic             clk_b,
    input  logic             rst_n_b,
    output logic [WIDTH-1:0] data_out,
    output logic             valid_b
);

    // 1. Domain A Logic
    logic [WIDTH-1:0] data_hold;
    logic req_a, ack_a_sync;

    always_ff @(posedge clk_a or negedge rst_n_a) begin
        if (!rst_n_a) begin
            req_a <= 1'b0;
            ready_a <= 1'b1;
        end else if (send_en && ready_a) begin
            data_hold <= data_in; // LOCK the data
            req_a     <= 1'b1;     // Start the request
            ready_a   <= 1'b0;     // Not ready for new data yet
        end else if (ack_a_sync) begin
            req_a     <= 1'b0;     // Request finished
            ready_a   <= 1'b1;     // Ready for next transfer
        end
    end

    // 2. Synchronizers (Standard 2-FF)
    // Synchronize req_a -> clk_b and ack_b -> clk_a (omitted for brevity)

    // 3. Domain B Logic
    // Logic to capture data_hold when req_sync is high and send back ack_b
endmodule



//we also write this by sva 
// just we are doing and opertion for req and ~ack and using implication opertor so we will get result in same cycle 
// Property: Data must remain stable until ACK is synchronized back to Domain A
property p_data_stability;
  @(posedge clk_a) disable iff (!rst_n_a) 
  //The disable iff (!rst_n_a) literally translates to: "Disable this assertion IF the reset signal is active (low)."
    (req_a && !ack_a_sync) |-> $stable(data_hold);
endproperty

assert_cdc_data_stable: assert property (p_data_stability)
    else $error("CDC ERROR: data_hold changed while req_a was active and ack_a_sync was low!");
