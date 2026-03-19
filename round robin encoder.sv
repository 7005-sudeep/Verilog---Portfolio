module round_robin_arbiter #(parameter WIDTH = 4) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic [WIDTH-1:0] req,
    output logic [WIDTH-1:0] gnt
);

    logic [WIDTH-1:0] mask;
    logic [WIDTH-1:0] mask_req;
    logic [WIDTH-1:0] mask_gnt;
    logic [WIDTH-1:0] raw_gnt;
    logic [WIDTH-1:0] last_gnt;

    // 1. Keep track of the last person granted
    always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n) last_gnt <= {{(WIDTH-1){1'b0}}, 1'b1}; // Start at bit 0 concatation so it will be like 4'b0001
        else if (|req) last_gnt <= gnt; 
    end

    // 2. Generate a mask for "who is next in line"
    // If last_gnt was bit 1 (0010), mask becomes (1100)
    assign mask = ~((last_gnt - 1'b1) | last_gnt);

    // 3. Split requests into two groups:
    // Group A: Those AFTER the last winner (Masked)
    // Group B: All requests (Raw)
    assign mask_req = req & mask;

    // 4. Use our "Magic" Fixed Priority logic on both groups
    assign mask_gnt = mask_req & (~mask_req + 1'b1);
    assign raw_gnt  = req & (~req + 1'b1);

    // 5. Final Selection:
    // If anyone in Group A is asking, they win. 
    // Otherwise, wrap around to the first person in Group B.
    assign gnt = (|mask_req) ? mask_gnt : raw_gnt;

endmodule


What changes did we make to Fixed Priority?
To turn an FPA into a Round Robin, we add two things:

Memory (The Pointer): We need a register to remember who won the last grant.

The Mask: We "mask out" everyone who just had a turn.

If Port 1 just won, we temporarily "hide" Port 0 and Port 1 from the priority logic.

This forces the FPA to look at Ports 2 and 3 first.

If no one in the "high" group (2, 3) is asking, we "unmask" and look at everyone again.

Why this code is "Famous"
In an interview, explain the Selector Logic (Step 5):

By having two priority paths (mask_gnt and raw_gnt), you eliminate the need for a complex "rotator" or "barrel shifter."

This structure is extremely fast because it’s just parallel combinational logic.

  SVA property : 
    property p_fairness;
    @(posedge clk) (gnt[0] && req[1]) |=> !gnt[0];
endproperty

3 "Magic Phrases" to say while writing:
"Dual Priority Path": Tell them you are using two paths to avoid using a Barrel Shifter (which is slow and expensive in terms of gates).

"Starvation Prevention": Mention that this design ensures Fairness because the priority rotates every time a request is serviced.

"Single-Cycle Latency": Point out that this is purely combinational logic (after the reset state), meaning the grant is issued in the same cycle the request arrives.

    "I would use a UVM Scoreboard with an associative array. I would keep a count of how many times each req[i] was granted. Over a long simulation, if the counts for all ports are roughly equal, the Round Robin is fair."
