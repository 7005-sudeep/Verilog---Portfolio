
 */
module fsm_three_blocks (
    input wire i_clk,
    input wire i_rst_n, 
    input wire i_bit,   
    output reg o_z      
);

   
    param S0 = 2'b00; 
    param S1 = 2'b01; 
    param S2 = 2'b10; 

   
    reg [1:0] current_state;
    reg [1:0] next_state;

   
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            current_state <= S0; 
        end else begin
            current_state <= next_state;
        end
    end

  
    always @(*) begin
        
        next_state = current_state; 
        
        case (current_state)
            S0: begin
                if (i_bit) next_state = S1;
                
            end
            S1: begin
                if (i_bit) next_state = S2;
            
            end
            S2: begin
                if (i_bit) next_state = S0;
                
            end
            default: begin
                next_state = S0;
            end
        endcase
    end

    
    always @(*) begin
        case (current_state)
            S0:     o_z = 1'b1;
            S1:     o_z = 1'b0;
            S2:     o_z = 1'b0;
            default: o_z = 1'b1; 
        endcase
    end

endmodule