module dff (
    input  logic clk,
    input  logic rst_n,
    input  logic en,
    input  logic d,
    output logic q
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= 0;
        else if (en)
            q <= d;
    end

endmodule
