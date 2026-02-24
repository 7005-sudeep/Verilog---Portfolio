module apb_s
(
    input  pclk,
    input  presetn,
    input [31:0] paddr,
    input psel,
    input penable,
    input [7:0] pwdata,
    input pwrite,
    
    output reg [7:0] prdata,
    output reg pready,
    output     pslverr
);
 
 
 
 
  localparam [1:0] idle = 0, write = 1, read = 2;
  reg [7:0] mem[16];
  
  reg [1:0] state, nstate;
  
  bit  addr_err , addv_err, data_err;
  ////////// setup - correct apb cycles
  /////////  addr_range - should be less than 16
  /////////   addr_val - be greater than or equal to 0
  /////////   data_val - be greater than or equal to 0  
/*
Transactions that receive an error, might or might not have changed the state of the peripheral. 
This is peripheral-specific and either is acceptable. 
When a write transaction receives an error this does not mean that the register within the peripheral 
has not been updated. Read transactions that receive an error can return invalid data.
 There is no requirement for the peripheral to drive the data bus to all 0s for a read error.
*/
  ///// reset decoder
  always@(posedge pclk, negedge presetn)
    begin
      if(presetn == 1'b0)
          state <= idle;
      else
          state <= nstate;
    end
    
    ///next state , output decoder
  always@(*)
    begin
    case(state)
     idle:
     begin
        prdata    = 8'h00;
        pready    = 1'b0;
        
            if(psel == 1'b1 && pwrite == 1'b1)  
                nstate = write;
            else if (psel == 1'b1 && pwrite == 1'b0)
                nstate = read;
            else
                nstate = idle; 
            
           
                
            
      end   
           
     
     write:
     begin
        if(psel == 1'b1 && penable == 1'b1)
        begin 
                 if(!addr_err && !addv_err && !data_err )
                    begin
                    pready = 1'b1;
                    mem[paddr]  = pwdata;
                    nstate      = idle;
                    end
                else
                     begin
                     nstate = idle;
                     pready = 1'b1;
                     end     
                 
     
        end
    end
     
    read:
     begin
        if(psel == 1'b1 && penable == 1'b1 )
        begin
            if(!addr_err && !addv_err && !data_err )
                 begin
                 pready = 1'b1;
                 prdata = mem[paddr];
                 nstate      = idle;
                 end
            else
                begin
                pready = 1'b1;
                prdata = 8'h00;
                nstate      = idle;
                end
        end
    end
     
    default : 
    begin
        nstate = idle; 
        prdata    = 8'h00;
        pready    = 1'b0;
     end
    endcase
    end
 
///////////////// checking valid values of address
reg av_t = 0;
always@(*)
begin
if(paddr >= 0)
  av_t = 1'b0;
else
  av_t = 1'b1;
end
 
///////////////// checking valid values of address
reg dv_t = 0;
always@(*)
begin
if(pwdata >= 0)
  dv_t = 1'b0;
else
  dv_t = 1'b1;
end
 
 
assign addr_err = ((nstate == write || read) && (paddr > 15)) ? 1'b1 : 1'b0;
assign addv_err = (nstate == write || read) ? av_t : 1'b0;
assign data_err = (nstate == write || read) ? dv_t : 1'b0;
 
assign pslverr  = (psel == 1'b1 && penable == 1'b1) ? ( addv_err || addr_err || data_err) : 1'b0;
 
endmodule


//Testbench Code//

class transaction;
 
  rand bit [31:0] paddr;
  rand bit [7:0] pwdata;
  rand bit psel;
  rand bit penable;
  randc bit pwrite;
  bit [7:0] prdata;
  bit pready;
  bit pslverr;
  
 
  
  constraint addr_c {
  paddr >= 0; paddr <= 15;////2 3 4
  }
  
  constraint data_c {
  pwdata >= 0; pwdata <= 255; /// 2-9
  }
  
  function void display(input string tag);
    $display("[%0s] :  paddr:%0d  pwdata:%0d pwrite:%0b  prdata:%0d pslverr:%0b @ %0t",tag,paddr,pwdata, pwrite, prdata, pslverr,$time);
  endfunction
  
endclass
 
 
/////////////////////////////////////////
class generator;
  
   transaction tr;
   mailbox #(transaction) mbx;
   int count = 0;
  
   event nextdrv; ///driver completed task of triggering interface
   event nextsco; ///scoreboard completed its objective
   event done; 
   
   
  function new(mailbox #(transaction) mbx);
      this.mbx = mbx;
      tr=new();
   endfunction; 
 
   task run(); 
    
     repeat(count)   
       begin    
           assert(tr.randomize()) else $error("Randomization failed");  
           mbx.put(tr);
           tr.display("GEN");
           @(nextdrv);
           @(nextsco);
         end  
     ->done;
   endtask
  
  
endclass
 
/////////////////////////////////////////////////////
 
 
class driver;
  
   virtual abp_if vif;
   mailbox #(transaction) mbx;
   transaction datac;
  
   event nextdrv;
 
   function new(mailbox #(transaction) mbx);
      this.mbx = mbx;
   endfunction; 
  
  
  task reset();
    vif.presetn <= 1'b0;
    vif.psel    <= 1'b0;
    vif.penable <= 1'b0;
    vif.pwdata  <= 0;
    vif.paddr   <= 0;
    vif.pwrite  <= 1'b0;
    repeat(5) @(posedge vif.pclk);
    vif.presetn <= 1'b1;
    $display("[DRV] : RESET DONE");
    $display("----------------------------------------------------------------------------");
  endtask
   
  task run();
    forever begin
      
      mbx.get(datac);
      @(posedge vif.pclk);     
      if(datac.pwrite == 1) ///write
        begin
        vif.psel    <= 1'b1;
        vif.penable <= 1'b0;
          vif.pwdata  <= datac.pwdata;
          vif.paddr   <= datac.paddr;
          vif.pwrite  <= 1'b1;
            @(posedge vif.pclk);
            vif.penable <= 1'b1; 
            @(posedge vif.pclk); 
            vif.psel <= 1'b0;
            vif.penable <= 1'b0;
            vif.pwrite <= 1'b0;
            datac.display("DRV");
            ->nextdrv;          
        end
      else if (datac.pwrite == 0) //read
        begin
            vif.psel <= 1'b1;
        vif.penable <= 1'b0;
          vif.pwdata <= 0;
          vif.paddr <= datac.paddr;
          vif.pwrite <= 1'b0;
            @(posedge vif.pclk);
            vif.penable <= 1'b1; 
            @(posedge vif.pclk); 
            vif.psel <= 1'b0;
            vif.penable <= 1'b0;
            vif.pwrite <= 1'b0;
            datac.display("DRV"); 
            ->nextdrv;
        end
      
    end
  endtask
  
  
endclass
 
 
//////////////////////////////////
 
class monitor;
 
   virtual abp_if vif;
   mailbox #(transaction) mbx;
   transaction tr;
 
  
 
 
    function new(mailbox #(transaction) mbx);
      this.mbx = mbx;     
   endfunction;
  
  task run();
    tr = new();
    forever begin
              @(posedge vif.pclk);
              if(vif.pready)
              begin
              tr.pwdata  = vif.pwdata;
              tr.paddr   = vif.paddr;
            tr.pwrite  = vif.pwrite;
            tr.prdata  = vif.prdata;
            tr.pslverr = vif.pslverr;
            @(posedge vif.pclk);
              tr.display("MON");
              mbx.put(tr);
              end
              end
   endtask
 
 
  
endclass
 
///////////////////////////////////////////////
 
class scoreboard;
  
   mailbox #(transaction) mbx;
   transaction tr;
   event nextsco;
  
  bit [7:0] pwdata[16] = '{default:0};
  bit [7:0] rdata;
  int err = 0;
  
   function new(mailbox #(transaction) mbx);
      this.mbx = mbx;     
    endfunction;
  
  task run();
  forever 
      begin
      
      mbx.get(tr);
      tr.display("SCO");
      
      if( (tr.pwrite == 1'b1) && (tr.pslverr == 1'b0))  ///write access
        begin 
        pwdata[tr.paddr] = tr.pwdata;
        $display("[SCO] : DATA STORED DATA : %0d ADDR: %0d",tr.pwdata, tr.paddr);
        end
      else if((tr.pwrite == 1'b0) && (tr.pslverr == 1'b0))  ///read access
        begin
         rdata = pwdata[tr.paddr];    
        if( tr.prdata == rdata)
          $display("[SCO] : Data Matched");           
        else
          begin
          err++;
          $display("[SCO] : Data Mismatched");
          end 
        end 
      else if(tr.pslverr == 1'b1)
        begin
          $display("[SCO] : SLV ERROR DETECTED");
        end  
      $display("---------------------------------------------------------------------------------------------------");
      ->nextsco;
 
  end
    
  endtask
 
  
endclass
 
//////////////////////////////////////////////////////////
 
class environment;
 
    generator gen;
    driver drv;
    monitor mon;
    scoreboard sco; 
  
    
  
    event nextgd; ///gen -> drv
    event nextgs;  /// gen -> sco
  
  mailbox #(transaction) gdmbx; ///gen - drv
     
  mailbox #(transaction) msmbx;  /// mon - sco
  
    virtual abp_if vif;
 
  
  function new(virtual abp_if vif);
       
    gdmbx = new();
    gen = new(gdmbx);
    drv = new(gdmbx);
    
    
    msmbx = new();
    mon = new(msmbx);
    sco = new(msmbx);
    
    this.vif = vif;
    drv.vif = this.vif;
    mon.vif = this.vif;
    
    gen.nextsco = nextgs;
    sco.nextsco = nextgs;
    
    gen.nextdrv = nextgd;
    drv.nextdrv = nextgd;
 
  endfunction
  
  task pre_test();
    drv.reset();
  endtask
  
  task test();
  fork
    gen.run();
    drv.run();
    mon.run();
    sco.run();
  join_any
  endtask
  
  task post_test();
    wait(gen.done.triggered);  
    $display("----Total number of Mismatch : %0d------",sco.err);
    $finish();
  endtask
  
  task run();
    pre_test();
    test();
    post_test();  
  endtask
  
  
  
endclass
 
 
//////////////////////////////////////////////////
 module tb;
    
   abp_if vif();
 
   
   apb_s dut (
   vif.pclk,
   vif.presetn,
   vif.paddr,
   vif.psel,
   vif.penable,
   vif.pwdata,
   vif.pwrite,
   vif.prdata,
   vif.pready,
   vif.pslverr
   );
   
    initial begin
      vif.pclk <= 0;
    end
    
    always #10 vif.pclk <= ~vif.pclk;
    
    environment env;
    
    
    
    initial begin
      env = new(vif);
      env.gen.count = 20;
      env.run();
    end
      
    
    initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
    end
   
    
  endmodule
