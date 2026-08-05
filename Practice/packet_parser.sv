module packet_header (
    input  logic        clk,
    input  logic        rst,
    input  logic        data_valid,
    input  logic [7:0]  data_in,
    output logic [7:0]  pkt_type,
    output logic [7:0]  src_id,
    output logic [15:0] payload,
    output logic        pkt_done
);

    logic [1:0] byte_cnt;

    always_ff @(posedge clk) begin
        if (rst) begin
            byte_cnt <= 0;
            pkt_type <= 0;
            src_id   <= 0;
            payload  <= 0;
            pkt_done <= 0;
        end
        else begin
            pkt_done <= 0;
            if (data_valid) begin
                case (byte_cnt)
                    2'd0: pkt_type      <= data_in;
                    2'd1: src_id        <= data_in;
                    2'd2: payload[15:8] <= data_in;
                    2'd3: payload[7:0]  <= data_in;
                endcase
                if (byte_cnt == 2'd3) begin
                    byte_cnt <= 0;
                    pkt_done <= 1;
                end
                else
                    byte_cnt <= byte_cnt + 1;
            end
        end
    end

endmodule
