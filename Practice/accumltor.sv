module accumulator (
    input  logic        clk,
    input  logic        rst,
    input  logic [15:0] price_in,
    input  logic        valid_in,
    input  logic [15:0] threshold,
    output logic [18:0] sum_out,
    output logic        alert,
    output logic        sum_valid
);

    logic [2:0]  count;
    logic [18:0] sum;

    always_ff @(posedge clk) begin
        if (rst) begin
            count     <= 0;
            sum       <= 0;
            sum_out   <= 0;
            alert     <= 0;
            sum_valid <= 0;
        end
        else begin
            sum_valid <= 0;
            if (valid_in) begin
                sum   <= sum + price_in;
                count <= count + 1;
                if (count == 3'd7) begin
                    sum_out   <= sum + price_in;
                    sum_valid <= 1;
                    alert     <= ((sum + price_in) > threshold);
                    sum       <= 0;
                    count     <= 0;
                end
            end
        end
    end

endmodule
