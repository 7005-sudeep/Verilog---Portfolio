module shift_reg #(
    parameter WIDTH = 8
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             load,
    input  logic             shift_en,
    input  logic             sin,
    input  logic [WIDTH-1:0] din,
    output logic [WIDTH-1:0] dout,
    output logic             sout
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            dout <= 0;
        else if (load)
            dout <= din;
        else if (shift_en)
            dout <= {sin, dout[WIDTH-1:1]};
    end

    assign sout = dout[0];

endmodule
