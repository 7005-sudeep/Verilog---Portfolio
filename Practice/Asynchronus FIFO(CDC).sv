// The Task:
//Write a 2-stage Synchronizer module: It should take a Gray-coded pointer from the "Source" domain and output it safely into the "Destination" domain.

//The "Full" Logic: In the Write Clock domain, you have the w_ptr_gray and the synchronized r_ptr_gray_sync. Write the assign full logic.

//Hint: In Gray code, the "Full" condition is different from binary. For a depth of 16, the full condition is when the MSB and the second MSB are inverted, but the rest of the bits match.

// synchronizer// same as D flip flop 
module sync_2ff #(
    parameter WIDTH = 5
)(
    input  logic             clk,    // Destination clock
    input  logic             rst_n,  // Destination reset
    input  logic [WIDTH-1:0] din,    // Data from source domain
    output logic [WIDTH-1:0] dout    // Synchronized data
);

    logic [WIDTH-1:0] q1; // Stage 1 FF
    logic [WIDTH-1:0] q2; // Stage 2 FF

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q1 <= 0;
            q2 <= 0;
        end else begin
            q1 <= din; // Sample asynchronous input
            q2 <= q1;  // Pass to second stage (Stable output)
        end
    end

    assign dout = q2;

endmodule



// for full flag logic we check msb as well as msb-1 both need to be differnet from read pointer rest all be same no issue //
// just check for msb and msb-1
// Parameters: 
// ADDR_W = 4 (for DEPTH 16)
// w_ptr_gray: 5 bits [4:0] (Binary pointer converted to Gray)
// r_ptr_gray_sync: 5 bits [4:0] (Read pointer synchronized into Write Domain)

assign full = (w_ptr_gray[ADDR_W]     != r_ptr_gray_sync[ADDR_W]) &&   // MSB is different
              (w_ptr_gray[ADDR_W-1]   != r_ptr_gray_sync[ADDR_W-1]) && // 2nd MSB is different
              (w_ptr_gray[ADDR_W-2:0] == r_ptr_gray_sync[ADDR_W-2:0]); // Rest of bits match


If we only invert msb and not msb-1 then only half bits fifo will work 


//UVM fifo trnasction class//
class fifo_item extends uvm_sequence_item;
  
  // 1. Rand variables
  rand logic [7:0] data;
  rand enum {WRITE, READ} op_kind;

  // 2. UVM Factory Macros
  `uvm_object_utils_begin(fifo_item)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_enum(op_kind, UVM_ALL_ON)
  `uvm_object_utils_end

  // 3. Weighted Constraint (70% Write, 30% Read)
  constraint op_dist {
    op_kind dist { WRITE := 70, READ := 30 };
  }

  // 4. Constructor
  function new(string name = "fifo_item");
    super.new(name);
  endfunction

endclass


// scoreboard class //
class fifo_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(fifo_scoreboard)

  // 1. TLM FIFOs (Parameterized with our sequence item)
  uvm_tlm_analysis_fifo #(fifo_item) wr_fifo;
  uvm_tlm_analysis_fifo #(fifo_item) rd_fifo;

  // 2. The Golden Model Queue
  logic [7:0] expected_queue[$];

  // Standard Component Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // 3. The Build Phase (Where the Factory Magic Happens)
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Using the Factory instead of 'new'
    wr_fifo = uvm_tlm_analysis_fifo#(fifo_item)::type_id::create("wr_fifo", this);
    rd_fifo = uvm_tlm_analysis_fifo#(fifo_item)::type_id::create("rd_fifo", this);
  endfunction

  // 4. The Run Phase (Logic remains the same)
  virtual task run_phase(uvm_phase phase);
    fifo_item wr_pkt, rd_pkt;
    forever begin
      // Parallel monitoring of Write and Read FIFOs
      fork
        begin
          wr_fifo.get(wr_pkt);
          expected_queue.push_back(wr_pkt.data);
        end
        begin
          rd_fifo.get(rd_pkt);
          if (expected_queue.size() > 0) begin
            logic [7:0] tmp = expected_queue.pop_front();
            if (rd_pkt.data !== tmp)
              `uvm_error("SCB_MISMATCH", $sformatf("Exp: %h, Got: %h", tmp, rd_pkt.data))
          end
        end
      join_none
      wait fork;
    end
  endtask
endclass


        //sva fifo assertion //
        // Property Definition
property p_overflow_protection;
    @(posedge clk) disable iff (!rst_n)
    // TRIGGER: FIFO is full AND a write is attempted
    (full && w_en) 
    |=> 
    // CHECK: In the NEXT cycle, the pointer must be exactly what it was before
    (w_ptr == $past(w_ptr));
endproperty

// Assertion Statement
assert_overflow_check: assert property (p_overflow_protection)
    else begin
        $error("ASSERTION FAILED: FIFO Overflow! w_ptr incremented while FULL.");
        $fatal(1, "Stopping simulation due to data corruption risk.");
    end
