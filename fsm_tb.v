`timescale 1ns/1ps

module tb_fsm;

    reg i_clk;
    reg i_rst_n;
    reg i_bit;

    wire o_z;

    fsm_three_blocks uut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_bit(i_bit),
        .o_z(o_z)
    );

    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk; 
    end

    
    initial begin
        
        i_rst_n = 0;
        i_bit = 0;
        
        $display("---------------------------------");
        $display("Time  Input  Output  (State)");
        $display("%0tns   ---     %b    (Reset - S0)", $time, o_z);
        
      
        @(negedge i_clk);
        i_rst_n = 1;

        
        @(negedge i_clk) i_bit = 1'b0;
        @(negedge i_clk) i_bit = 1'b1;
        @(negedge i_clk) i_bit = 1'b0;
        @(negedge i_clk) i_bit = 1'b0;
        @(negedge i_clk) i_bit = 1'b1;
        @(negedge i_clk) i_bit = 1'b1;
        @(negedge i_clk) i_bit = 1'b0;
        @(negedge i_clk) i_bit = 1'b0;
        @(negedge i_clk) i_bit = 1'b1;
        @(negedge i_clk) i_bit = 1'b0;
        @(negedge i_clk) i_bit = 1'b1;
        @(negedge i_clk) i_bit = 1'b0;
        @(negedge i_clk) i_bit = 1'b0;
        @(negedge i_clk) i_bit = 1'b1;
        @(negedge i_clk) i_bit = 1'b0;
        @(negedge i_clk) i_bit = 1'b1;
        @(negedge i_clk) i_bit = 1'b0;
        @(negedge i_clk) i_bit = 1'b1;
        @(negedge i_clk) i_bit = 1'b1;
        @(negedge i_clk) i_bit = 1'b0;
        @(negedge i_clk) i_bit = 1'b1;
        @(negedge i_clk) i_bit = 1'b1;
        @(negedge i_clk) i_bit = 1'b0;
        @(negedge i_clk) i_bit = 1'b1;
        @(negedge i_clk) i_bit = 1'b1;
        @(negedge i_clk) i_bit = 1'b0;
        @(negedge i_clk) i_bit = 1'b1;
        @(negedge i_clk) i_bit = 1'b1;

       
        @(negedge i_clk);
        $display("---------------------------------");
        $finish;
    end

    /
    initial begin
      
        @(posedge i_rst_n);
        
       
        forever @(posedge i_clk) begin
            $strobe("%0tns   %b       %b    (%b)", 
                   $time, i_bit, o_z, uut.current_state);
        end
    end

endmodule