What is a Fixed Priority Arbiter?
In this logic, every input has a strict rank. If two people ask for the bus at the same time, the one with the higher rank always wins. The lower-rank request is ignored until the higher-one stops.

Priority 0 (MSB or LSB): Highest.

Priority N: Lowest.

The "Famous" RTL Tricks for Fixed Priority

  Method 1: The if-else (The Beginner Way)

  Method 1: The if-else (The Beginner Way)
This is easy to read but hard to scale if you have 64 requesters.
  always_comb begin
    if      (req[0]) gnt = 4'b0001;
    else if (req[1]) gnt = 4'b0010;
    else if (req[2]) gnt = 4'b0100;
    else if (req[3]) gnt = 4'b1000;
    else             gnt = 4'b0000;
end

The for-loop (The Scalable Way)

  always_comb begin
    gnt = 0;
    for (int i = 0; i < 4; i++) begin
        if (req[i]) begin
            gnt[i] = 1'b1;
            break; // Stop looking after finding the first '1'
        end
    end
end

Method 3: The Parallel Prefix / Two's Complement (The Expert Way)
module fixed_priority_arbiter #(parameter WIDTH = 4) (
    input  logic [WIDTH-1:0] req,
    output logic [WIDTH-1:0] gnt
);
    // The Magic Formula: req & (~req + 1)
    // This isolates the right-most (lowest) '1' bit.
    
    assign gnt = req & (~req + 1'b1);

endmodule

Starvation
Before we move to Round Robin, look at this code and tell me: What happens if req[0] is a sensor that is broken and stays 1 forever?

Answer: Requesters 1, 2, and 3 will never get a grant. They are "starved."
