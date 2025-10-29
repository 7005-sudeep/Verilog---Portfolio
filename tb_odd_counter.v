
`timescale 1ns/1ps

module tb_odd_counter;

    // --- Inputs to DUT ---
    reg tb_clk;
    reg tb_rst_n;
    reg tb_enable;

    // --- Output from DUT ---
    wire [7:0] tb_count;

    // --- Instantiate the DUT (Device Under Test) ---
    odd_counter uut (
        .i_clk(tb_clk),
        .i_rst_n(tb_rst_n),
        .i_enable(tb_enable),
        .o_count(tb_count)
    );

    // --- 1. Clock Generator ---
    initial begin
        tb_clk = 0;
        forever #5 tb_clk = ~tb_clk; // 10ns clock period
    end

    // --- 2. Monitor ---
    // Prints the values every time the clock rises
    always @(posedge tb_clk) begin
        if (tb_rst_n) begin // Only print when not in reset
            $strobe("Time: %0tns | Enable: %b | Count: %3d (0x%h)",
                   $time, tb_enable, tb_count, tb_count);
        end
    end

    // --- 3. Stimulus Sequence ---
    initial begin
        $display("--- Starting Testbench ---");
        $display("Time: ---ns | Resetting...");
        
        // 1. Assert Reset
        tb_rst_n = 0;
        tb_enable = 0;
        #20; // Hold reset for 2 cycles

        // 2. Release Reset and Enable
        $display("Time: %0tns | Releasing reset, enabling counter.", $time);
        tb_rst_n = 1;
        tb_enable = 1;
        #50; // Run for 5 cycles (1, 3, 5, 7, 9)

        // 3. Disable Counter
        $display("Time: %0tns | Disabling counter.", $time);
        tb_enable = 0;
        #30; // Hold for 3 cycles (should stay at 9)

        // 4. Re-enable Counter
        $display("Time: %0tns | Re-enabling counter.", $time);
        tb_enable = 1;
        #30; // Run for 3 cycles (11, 13, 15)

        // 5. Test Wraparound (255 -> 1)
        // We are at 15.
        // (255 - 15) / 2 = 120 cycles to reach 255.
        // Run for 122 cycles to see it hit 255, 1, and 3.
        $display("Time: %0tns | Running for 122 cycles to test wraparound...", $time);
        repeat (122) begin
            @(posedge tb_clk);
        end
        
        $display("Time: %0tns | --- Test Finished ---", $time);
        $finish;
    end

endmodule