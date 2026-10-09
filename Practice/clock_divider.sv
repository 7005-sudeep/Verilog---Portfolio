module clk_divider #(
    parameter DIV = 4
)(
    input  logic clk_in,
    input  logic rst,
    output logic clk_out
);

    localparam HALF    = DIV / 2;
    localparam CNT_W   = $clog2(DIV);

    logic [CNT_W-1:0] counter;

    always_ff @(posedge clk_in) begin
        if (rst) begin
            counter <= 0;
            clk_out <= 0;
        end
        else if (counter == HALF - 1) begin
            counter <= 0;
            clk_out <= ~clk_out;
        end
        else
            counter <= counter + 1;
    end

endmodule
