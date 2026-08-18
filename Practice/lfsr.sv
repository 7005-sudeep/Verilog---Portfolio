module lfsr #(
    parameter WIDTH = 8
)(
    input  logic             clk,
    input  logic             rst,
    input  logic             en,
    input  logic [WIDTH-1:0] seed,
    output logic [WIDTH-1:0] out
);

    logic feedback;

    always_ff @(posedge clk) begin
        if (rst)
            out <= seed;
        else if (en) begin
            feedback = out[7] ^ out[5] ^ out[4] ^ out[3];
            out      <= {feedback, out[WIDTH-1:1]};
        end
    end

endmodule
