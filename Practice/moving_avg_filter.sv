module filter (
    input  logic        clk,
    input  logic        rst,
    input  logic [15:0] data_in,
    input  logic        valid_in,
    output logic [15:0] avg_out,
    output logic        valid_out
);

    logic [15:0] samples [0:3];
    logic [1:0]  count;
    logic [17:0] sum;

    always_ff @(posedge clk) begin
        if (rst) begin
            count     <= 0;
            valid_out <= 0;
            avg_out   <= 0;
        end
        else begin
            valid_out <= 0;
            if (valid_in) begin
                samples[3] <= samples[2];
                samples[2] <= samples[1];
                samples[1] <= samples[0];
                samples[0] <= data_in;
                if (count == 2'd3) begin
                    sum       =  samples[1] + samples[2] +
                                 samples[3] + data_in;
                    avg_out   <= sum >> 2;
                    valid_out <= 1;
                    count     <= 0;
                end
                else
                    count <= count + 1;
            end
        end
    end

endmodule
