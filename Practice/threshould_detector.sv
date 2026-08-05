module detector (
    input  logic        clk,
    input  logic        rst,
    input  logic [15:0] data_in,
    input  logic [15:0] high_thresh,
    input  logic [15:0] low_thresh,
    output logic        alert
);

    always_ff @(posedge clk) begin
        if (rst)
            alert <= 0;
        else if (data_in > high_thresh)
            alert <= 1;
        else if (data_in < low_thresh)
            alert <= 0;
    end

endmodule
