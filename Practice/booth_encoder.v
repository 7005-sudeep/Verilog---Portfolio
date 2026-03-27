module booth_encoder (
    input  [2:0] bits,
    output reg [2:0] booth_code
);
always @(*) begin
    case (bits)
        3'b000, 3'b111: booth_code = 3'b000; // 0
        3'b001, 3'b010: booth_code = 3'b001; // +M
        3'b011:         booth_code = 3'b010; // +2M
        3'b100:         booth_code = 3'b110; // -2M
        3'b101, 3'b110: booth_code = 3'b101; // -M
        default:        booth_code = 3'b000;
    endcase
end
endmodule
