module mux4to1 (
    input  logic [3:0] in,
    input  logic [1:0] sel,
    output logic       out
);

    always_comb begin
        case (sel)
            2'b00:   out = in[0];
            2'b01:   out = in[1];
            2'b10:   out = in[2];
            2'b11:   out = in[3];
            default: out = 1'b0;
        endcase
    end

endmodule
