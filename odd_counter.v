`timescale 1ns/1ps

/*
 * Module: odd_counter
 * -------------------
 * 8-bit synchronous counter that only counts odd numbers (1, 3, 5, ...).
 * - Resets asynchronously to 1.
 * - Increments by 2 when enabled.
 * - Wraps from 255 back to 1.
 */
module odd_counter (
    input wire i_clk,
    input wire i_rst_n,
    input wire i_enable,
    output reg [7:0] o_count
);

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            // Reset to 1, the first odd number
            o_count <= 8'd1;
        end else if (i_enable) begin
            // Increment by 2 to stay on odd numbers
            o_count <= o_count + 8'd2;
        end
        // If i_enable is low, the register holds its value (no 'else' needed)
    end

endmodule