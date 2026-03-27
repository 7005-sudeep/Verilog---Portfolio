//binary to gray//
module bin_to_gray #(
    parameter WIDTH = 4
)(
    input  logic [WIDTH-1:0] bin_in,
    output logic [WIDTH-1:0] gray_out
);

    // The MSB stays the same, other bits are XORed with the bit to their left
    assign gray_out = (bin_in >> 1) ^ bin_in;

endmodule


//Gray to Binary//
module gray_to_binary #(
    parameter WIDTH = 4
)(
    input  logic [WIDTH-1:0] gray_in,
    output logic [WIDTH-1:0] bin_out
);

    always_comb begin
        // 1. The MSB is always the same
        bin_out[WIDTH-1] = gray_in[WIDTH-1];

        // 2. Iterate from MSB-1 down to LSB
        for (int i = WIDTH-2; i >= 0; i--) begin
            bin_out[i] = gray_in[i] ^ bin_out[i+1];
        end
    end

endmodule
