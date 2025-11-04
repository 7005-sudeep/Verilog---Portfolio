
module ALU(
    input signed [31:0] A, 
    input signed [31:0] B, 
    input [2:0] ALUOp, 
    output reg signed [31:0] Result
);

    always @(*) begin
        case (ALUOp)
            3'b000: Result = A & B;      
            3'b001: Result = A | B;      
            3'b010: Result = A + B;      
            3'b110: Result = A - B;      
            3'b111: Result = (A < B) ? 1 : 0;
            default: Result = 32'b0;    
        endcase
    end

endmodule