// --- RISC-V 5-Stage Pipeline Core ---

module RISCV_Top(input clk, reset);
    // Pipeline Registers
    reg [63:0] IF_ID;   
    reg [150:0] ID_EX;  
    reg [100:0] EX_MEM; 
    reg [70:0] MEM_WB;  

    // Internal Wires
    wire [31:0] pc, instr, alu_out, reg_data1, reg_data2;
    wire [4:0] rs1, rs2, rd;
    wire [3:0] alu_ctrl = 4'b0000; // Simplified for ADD demonstration
    wire stall;
    reg [31:0] pc_reg;

    assign pc = pc_reg;
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign rd  = instr[11:7];

    // 1. Instruction Memory (Where your code goes)
    InstructionMemory IMEM (
        .addr(pc),
        .instr(instr)
    );

    // 2. Register File
    RegisterFile RegFile (
        .clk(clk), .reset(reset), .reg_write(1'b1), // Simplified write-enable
        .rs1(rs1), .rs2(rs2), .rd(MEM_WB[4:0]), 
        .write_data(MEM_WB[36:5]), 
        .rd_data1(reg_data1), .rd_data2(reg_data2)
    );

    // 3. ALU
    ALU cpu_alu (
        .A(reg_data1), .B(32'h1), // Using immediate 1 for demonstration
        .ALUControl(alu_ctrl),
        .ALUResult(alu_out)
    );

    // 4. Hazard & Forwarding Units
    Hazard_Unit HU (.rs1(rs1), .rs2(rs2), .ex_rd(ID_EX[4:0]), .ex_memread(1'b0), .stall(stall));
    Forwarding_Unit FU (.ex_rs1(ID_EX[9:5]), .ex_rs2(ID_EX[14:10]), .mem_rd(EX_MEM[4:0]), .wb_rd(MEM_WB[4:0]), .forwardA(), .forwardB());

    // PC and Pipeline Register Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_reg <= 0;
            IF_ID <= 0; ID_EX <= 0; EX_MEM <= 0; MEM_WB <= 0;
        end else if (!stall) begin
            pc_reg <= pc_reg + 4;
            IF_ID  <= {pc, instr};
            ID_EX  <= {32'b0, reg_data1, reg_data2, rs1, rs2, rd};
            EX_MEM <= {alu_out, ID_EX[4:0]};
            MEM_WB <= {EX_MEM[36:5], EX_MEM[4:0]};
        end
    end
endmodule

module InstructionMemory(input [31:0] addr, output [31:0] instr);
    reg [31:0] mem [0:255]; 
    initial begin
        $display("Loading Instructions into Memory...");
        mem[0] = 32'h00108093; // addi x1, x1, 1
        mem[1] = 32'h00108093; // addi x1, x1, 1
        mem[2] = 32'h0000006f; // jal x0, -8 (loop)
        for (integer i = 3; i < 256; i = i + 1) mem[i] = 32'h00000013; // NOP
    end
    assign instr = mem[addr >> 2];
endmodule

module ALU (input [31:0] A, B, input [3:0] ALUControl, output reg [31:0] ALUResult, output Zero);
    always @(*) begin
        case (ALUControl)
            4'b0000: ALUResult = A + B;
            default: ALUResult = 32'b0;
        endcase
    end
    assign Zero = (ALUResult == 0);
endmodule

module RegisterFile(input clk, reset, reg_write, input [4:0] rs1, rs2, rd, input [31:0] write_data, output [31:0] rd_data1, rd_data2);
    reg [31:0] registers [31:0];
    assign rd_data1 = (rs1 == 0) ? 0 : registers[rs1];
    assign rd_data2 = (rs2 == 0) ? 0 : registers[rs2];
    always @(negedge clk or posedge reset) begin
        if (reset) begin
            for (integer i = 0; i < 32; i = i + 1) registers[i] <= 0;
        end else if (reg_write && rd != 0) registers[rd] <= write_data;
    end
endmodule

module Hazard_Unit(input [4:0] rs1, rs2, ex_rd, input ex_memread, output reg stall);
    always @(*) begin
        if (ex_memread && ((ex_rd == rs1) || (ex_rd == rs2))) stall = 1'b1;
        else stall = 1'b0;
    end
endmodule

module Forwarding_Unit(input [4:0] ex_rs1, ex_rs2, mem_rd, wb_rd, input mem_regwrite, wb_regwrite, output reg [1:0] forwardA, forwardB);
    always @(*) begin
        if (mem_regwrite && (mem_rd != 0) && (mem_rd == ex_rs1)) forwardA = 2'b10;
        else if (wb_regwrite && (wb_rd != 0) && (wb_rd == ex_rs1)) forwardA = 2'b01;
        else forwardA = 2'b00;
        if (mem_regwrite && (mem_rd != 0) && (mem_rd == ex_rs2)) forwardB = 2'b10;
        else if (wb_regwrite && (wb_rd != 0) && (wb_rd == ex_rs2)) forwardB = 2'b01;
        else forwardB = 2'b00;
    end
endmodule


// Testbnech_Top.v
`timescale 1ns/1ps

module tb_top;
    reg clk;
    reg reset;

    // Instantiate the CPU
    RISCV_Top dut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Required for EDA Playground EPWave
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top);

        clk = 0;
        reset = 1;
        #20 reset = 0; // Release reset

        #200; // Run for 20 cycles
        $display("Simulation Finished. Open EPWave to see results.");
        $finish;
    end
endmodule
