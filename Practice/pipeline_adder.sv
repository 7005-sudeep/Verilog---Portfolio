module pipeline_adder #(
    parameter WIDTH = 8
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic             valid_in,
    output logic [WIDTH:0]   sum,
    output logic             valid_out
);

    logic [WIDTH-1:0] a_reg, b_reg;
    logic             valid_reg1;

    // Stage 1
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_reg      <= 0;
            b_reg      <= 0;
            valid_reg1 <= 0;
        end
        else begin
            a_reg      <= a;
            b_reg      <= b;
            valid_reg1 <= valid_in;
        end
    end

    // Stage 2
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum       <= 0;
            valid_out <= 0;
        end
        else begin
            sum       <= a_reg + b_reg;
            valid_out <= valid_reg1;
        end
    end

endmodule
