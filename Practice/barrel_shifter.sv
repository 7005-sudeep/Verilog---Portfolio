module barrel #(
    parameter WIDTH = 8
)(
    input  logic [WIDTH-1:0] data_in,
    input  logic [2:0]       shift_amt,
    input  logic             dir,
    output logic [WIDTH-1:0] data_out
);

    always_comb begin
        if (dir == 0)
            data_out = data_in << shift_amt;
        else
            data_out = data_in >> shift_amt;
    end

endmodule
