module ALU_tb;

    reg signed [31:0] test_A;
    reg signed [31:0] test_B;
    reg [2:0] test_ALUOp;

    
    wire signed [31:0] test_Result;
    
    ALU uut (
        .A(test_A),
        .B(test_B),
        .ALUOp(test_ALUOp),
        .Result(test_Result)
    );


    initial begin
        // Test 1: ADD operation (010)
        test_A = 1; test_B = 2; test_ALUOp = 3'b010;
        #10; // Wait for 10 time units
        $display("1st Test data: input A is %d, input B is %d, ALUOp is %b, result is %d.", test_A, test_B, test_ALUOp, test_Result);

        // Test 2: SUBTRACT operation (110)
        test_A = 3; test_B = 4; test_ALUOp = 3'b110;
        #10;
        $display("2nd Test data: input A is %d, input B is %d, ALUOp is %b, result is %d.", test_A, test_B, test_ALUOp, test_Result);

        // Test 3: AND operation (000)
        test_A = 12; test_B = 10; test_ALUOp = 3'b000; // 1100 & 1010 = 1000 (8)
        #10;
        $display("3rd Test data: input A is %d, input B is %d, ALUOp is %b, result is %d.", test_A, test_B, test_ALUOp, test_Result);

        // Test 4: OR operation (001)
        test_A = 12; test_B = 10; test_ALUOp = 3'b001; // 1100 | 1010 = 1110 (14)
        #10;
        $display("4th Test data: input A is %d, input B is %d, ALUOp is %b, result is %d.", test_A, test_B, test_ALUOp, test_Result);

        // Test 5: SLT operation (111) - Case 1: A < B is true
        test_A = -5; test_B = 5; test_ALUOp = 3'b111;
        #10;
        $display("5th Test data: input A is %d, input B is %d, ALUOp is %b, result is %d.", test_A, test_B, test_ALUOp, test_Result);

        // Test 6: SLT operation (111) - Case 2: A < B is false
        test_A = 10; test_B = -2; test_ALUOp = 3'b111;
        #10;
        $display("6th Test data: input A is %d, input B is %d, ALUOp is %b, result is %d.", test_A, test_B, test_ALUOp, test_Result);

        $finish;
    end

endmodule