module up_down_counter #(
    parameter WIDTH = 4
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,
    input  logic             up_down,
    output logic [WIDTH-1:0] count,
    output logic             overflow,
    output logic             underflow
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= 0;
        else if (en && up_down)
            count <= count + 1;
        else if (en && !up_down)
            count <= count - 1;
    end

    assign overflow  = en && up_down  && (count == {WIDTH{1'b1}});
    assign underflow = en && !up_down && (count == 0);

endmodule
