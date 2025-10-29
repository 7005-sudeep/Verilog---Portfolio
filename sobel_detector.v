`timescale 1ns/1ps

/*
 * Module: sobel_detector
 *
 * Implements a 3x3 Sobel edge detector for a streaming video feed.
 *
 * Architecture:
 * 1. Line Buffers: Two BRAMs (line_buffer_1, line_buffer_2) to store
 * the previous two rows (N-1 and N-2).
 * 2. Window Generator: A 3x3 register array (p_window) to form the
 * sliding kernel window from the 3 rows of data.
 * 3. Datapath: A 4-stage pipeline to calculate G = |Gx| + |Gy|.
 *
 * Pipeline Stages:
 * - S1 (Registers): 3x3 Window formed from line buffers + shift registers.
 * - S2 (Registers): Gx and Gy calculated.
 * - S3 (Registers): |Gx| and |Gy| calculated.
 * - S4 (Registers): Final Sum = |Gx| + |Gy|, saturated to 8 bits.
 *
 * Total Latency: 4 clock cycles from valid input to valid output.
 */
module sobel_detector #(
    parameter DATA_WIDTH = 8,
    parameter LINE_WIDTH = 640 // Width of the image in pixels
)(
    input wire i_clk,
    input wire i_rst_n,

    // Input Stream (AXI-Stream-like)
    input wire i_valid_in,
    input wire [DATA_WIDTH-1:0] i_data_in,
    input wire i_eol_in, // End of Line signal

    // Output Stream
    output reg o_valid_out,
    output reg [DATA_WIDTH-1:0] o_data_out
);

    //================================================================
    // == 1. Line Buffers and 3x3 Window Generator
    //================================================================
    
    localparam ADDR_WIDTH = $clog2(LINE_WIDTH);

    // Two Line Buffers, inferred as Simple Dual-Port BRAM
    // These store the previous two rows of pixels.
    reg [DATA_WIDTH-1:0] line_buffer_1 [0:LINE_WIDTH-1];
    reg [DATA_WIDTH-1:0] line_buffer_2 [0:LINE_WIDTH-1];
    
    reg [ADDR_WIDTH-1:0] ptr; // Read/Write pointer for the line buffers
    
    // Data from 2 lines above
    wire [DATA_WIDTH-1:0] lb1_data_out;
    wire [DATA_WIDTH-1:0] lb2_data_out;

    // We infer the BRAMs: Write to the current 'ptr' location,
    // and read from the same 'ptr' location (read-first).
    // This gives us the pixel from 1 line ago (lb1) and 2 lines ago (lb2).
    assign lb1_data_out = line_buffer_1[ptr];
    assign lb2_data_out = line_buffer_2[ptr];

    always @(posedge i_clk) begin
        if (i_valid_in) begin
            // Write new data into the buffers in a cascade
            line_buffer_1[ptr] <= i_data_in;    // Current pixel -> LB1
            line_buffer_2[ptr] <= lb1_data_out; // LB1 data -> LB2
            
            // Advance the pointer
            if (i_eol_in) begin
                ptr <= 0; // Reset pointer at the end of a line
            end else begin
                ptr <= ptr + 1'b1;
            end
        end
    end
    
    // Pixel shift registers to create the 3x3 window columns
    // We need 3 parallel shift registers, one for each line's stream.
    // This is Pipeline Stage 1 (S1)
    reg [DATA_WIDTH-1:0] p_window [0:2][0:2]; // [row][col]
    reg                  p_s1_valid;

    always @(posedge i_clk) begin
        if (i_valid_in) begin
            // Row 0 (Current Line)
            p_window[0][0] <= i_data_in;
            p_window[0][1] <= p_window[0][0];
            p_window[0][2] <= p_window[0][1];
            
            // Row 1 (Line - 1)
            p_window[1][0] <= lb1_data_out;
            p_window[1][1] <= p_window[1][0];
            p_window[1][2] <= p_window[1][1];
            
            // Row 2 (Line - 2)
            p_window[2][0] <= lb2_data_out;
            p_window[2][1] <= p_window[2][0];
            p_window[2][2] <= p_window[2][1];
        end
        // Pass the valid signal down the pipeline
        p_s1_valid <= i_valid_in;
    end
    
    // Name the 9 pixels for clarity (p0 is top-left)
    // The window is fully formed at the output of the S1 registers.
    // We reverse the column indices to match kernels (0,0 is p_window[x][2])
    wire [DATA_WIDTH-1:0] p0, p1, p2, p3, p4, p5, p6, p7, p8;
    assign p0 = p_window[2][2]; // Top-left
    assign p1 = p_window[2][1];
    assign p2 = p_window[2][0];
    
    assign p3 = p_window[1][2];
    assign p4 = p_window[1][1];
    assign p5 = p_window[1][0];
    
    assign p6 = p_window[0][2]; // Bottom-left
    assign p7 = p_window[0][1];
    assign p8 = p_window[0][0];

    //================================================================
    // == 2. Sobel Datapath Pipeline
    //================================================================
    
    // Gx = (p2 + 2*p5 + p8) - (p0 + 2*p3 + p6)
    // Gy = (p6 + 2*p7 + p8) - (p0 + 2*p1 + p2)
    
    // Pipeline Stage 2: Calculate Gx and Gy
    // Max Gx/Gy is ~1020. We need 11 bits signed.
    reg signed [10:0] p_s2_gx;
    reg signed [10:0] p_s2_gy;
    reg               p_s2_valid;

    always @(posedge i_clk) begin
        if (p_s1_valid) begin
            // Gx Calculation
            p_s2_gx <= (p2 + (p5 << 1) + p8) - (p0 + (p3 << 1) + p6);
            // Gy Calculation
            p_s2_gy <= (p6 + (p7 << 1) + p8) - (p0 + (p1 << 1) + p2);
        end
        p_s2_valid <= p_s1_valid;
    end

    // Pipeline Stage 3: Calculate Absolute Values |Gx| and |Gy|
    // Max absolute value is 1020 (10 bits unsigned)
    reg [9:0] p_s3_abs_gx;
    reg [9:0] p_s3_abs_gy;
    reg       p_s3_valid;
    
    always @(posedge i_clk) begin
        p_s3_abs_gx <= (p_s2_gx < 0) ? -p_s2_gx : p_s2_gx;
        p_s3_abs_gy <= (p_s2_gy < 0) ? -p_s2_gy : p_s2_gy;
        p_s3_valid  <= p_s2_valid;
    end

    // Pipeline Stage 4: Sum and Saturate (G = |Gx| + |Gy|)
    // Max sum is 1020 + 1020 = 2040 (11 bits)
    reg [10:0] p_s4_sum;
    
    always @(posedge i_clk) begin
        p_s4_sum    <= p_s3_abs_gx + p_s3_abs_gy;
        o_valid_out <= p_s3_valid; // Final pipeline stage valid
        
        // Saturate the 11-bit result to 8 bits
        if (p_s4_sum > 255) begin
            o_data_out <= 8'hFF;
        end else begin
            o_data_out <= p_s4_sum[7:0];
        end
    end
    
    //================================================================
    // == 3. Reset Logic
    //================================================================
    
    // Asynchronous reset for all pipeline stages and pointers
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            ptr <= 0;
            p_s1_valid <= 1'b0;
            p_s2_valid <= 1'b0;
            p_s3_valid <= 1'b0;
            o_valid_out <= 1'b0;
            o_data_out <= 8'd0;
            
            // Flush pipeline registers (optional but good practice)
            for (integer i=0; i<3; i=i+1) begin
                for (integer j=0; j<3; j=j+1) begin
                    p_window[i][j] <= 0;
                end
            end
            p_s2_gx <= 0; p_s2_gy <= 0;
            p_s3_abs_gx <= 0; p_s3_abs_gy <= 0;
            p_s4_sum <= 0;
            
            // Note: BRAM (line_buffer_1/2) content is not
            // resettable, but it will be overwritten.
        end
    end

endmodule