// ------------------------------------------------------------
// 16-bit Radix-4 Booth Multiplier
// Signed multiplication using Booth encoding
// ------------------------------------------------------------
module booth_multiplier_16bit (
    input  logic signed [15:0] M,   // Multiplicand
    input  logic signed [15:0] Q,   // Multiplier
    output logic signed [31:0] P    // Product
);

    integer i;
    logic signed [31:0] product;
    logic [16:0] Q_ext;   // Extended multiplier

    always_comb begin
        product = 0;
        Q_ext   = {Q, 1'b0}; // Append 0 for Booth recoding

        // Radix-4 Booth encoding (process 2 bits at a time)
        for (i = 0; i < 16; i = i + 2) begin
            case (Q_ext[i+2 -: 3])
                3'b001,
                3'b010: product = product + (M <<< i);        // +M
                3'b011: product = product + (M <<< (i + 1));  // +2M
                3'b100: product = product - (M <<< (i + 1));  // -2M
                3'b101,
                3'b110: product = product - (M <<< i);        // -M
                default: product = product;                   // 0
            endcase
        end
    end

    assign P = product;

endmodule
