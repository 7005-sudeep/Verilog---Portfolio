module fsm (
    input  logic clk,
    input  logic rst_n,
    input  logic din,
    output logic detect
);

    // Step 1 — define states
    typedef enum logic [2:0] {
        IDLE, S1, S10, S101, S1011
    } state_t;

    state_t curr_state, next_state;

    // Block 1 — state register (sequential)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end

    // Block 2 — next state logic (combinational)
    always_comb begin
        case (curr_state)
            IDLE  : next_state = din ? S1   : IDLE;
            S1    : next_state = din ? S1   : S10;
            S10   : next_state = din ? S101 : IDLE;
            S101  : next_state = din ? S1011: S10;
            S1011 : next_state = din ? S1   : IDLE;
            default: next_state = IDLE;
        endcase
    end

    // Block 3 — output logic (Moore — based only on current state)
    assign detect = (curr_state == S1011);

endmodule
