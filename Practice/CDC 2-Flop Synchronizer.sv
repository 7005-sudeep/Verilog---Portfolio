module cdc (
    input  logic clk_dst,
    input  logic rst_dst,
    input  logic data_src,
    output logic data_sync
);

    logic sync_stage1;

    always_ff @(posedge clk_dst) begin
        if (rst_dst) begin
            sync_stage1 <= 0;
            data_sync   <= 0;
        end
        else begin
            sync_stage1 <= data_src;
            data_sync   <= sync_stage1;
        end
    end

endmodule
