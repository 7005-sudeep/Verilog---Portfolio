module sat_counter #(
    parameter WIDTH = 4
)(
    input  logic             clk,
    input  logic             rst,
    input  logic             inc,
    input  logic             dec,
    output logic [WIDTH-1:0] count
);

    always_ff @(posedge clk) begin
        if (rst)
            count <= 0;
        else if (inc && !dec) begin
            if (count != {WIDTH{1'b1}})
                count <= count + 1;
        end
        else if (dec && !inc) begin
            if (count != 0)
                count <= count - 1;
        end
    end

endmodule
