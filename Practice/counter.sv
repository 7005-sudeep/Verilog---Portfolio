module counter (
    input  wire        clk,
    input  wire        rst,
    input  wire        en,
    output reg  [3:0]  count,
    output reg         done
);

    always @(posedge clk) begin
        if (rst) begin
            count <= 4'd0;
            done  <= 1'b0;
        end
        else begin
            done <= 1'b0;        // default — pulse pattern
            if (en && count != 4'd15) begin
                count <= count + 1;
                if (count == 4'd14)
                    done <= 1'b1;  // pulse when reaching 15
            end
        end
    end

endmodule
