package Bram;

//import Types::*;
//import Interfaces::*;
import BRAM::*;
import StmtFSM::*;
import Clocks::*;
import Real :: * ;

function BRAMRequest#(Bit#(16), Bit#(32)) makeRequest(Bool write, Bit#(16) addr, Bit#(32) data); 
return BRAMRequest{
                      write: write,
                      responseOnWrite:False,
                      address: addr,
                      datain: data
};

endfunction

(*synthesize*)

module mkLoadbram();

 Reg#(Bit#(16)) count <- mkReg(16449);
 Reg#(Bit#(32)) x <- mkReg(0);
 BRAM_Configure cfg = defaultValue;
 cfg.allowWriteResponseBypass = False;
 //cfg.memorySize = 2*1024*32;
 cfg.latency=2;
 cfg.loadFormat = tagged Hex "sort_first.mem";
 BRAM2Port#(Bit#(16),Bit#(32)) bram_mem <- mkBRAM2Server(cfg);  

//rule dummy;
//endrule

Stmt test = 
(seq
delay(10);

while(count < 16459)
 par
 action
 bram_mem.portA.request.put(makeRequest(False,count,0));
 endaction
 action
 $display("%x", bram_mem.portA.response.get);
 endaction

 //$display("%d",count);
 count <= count + 1;
endpar

delay(100);
endseq);
mkAutoFSM(test);

/*function fetch1 (Bit#(16) address);
Stmt fetch = 
    (seq
    action
    bram_mem.portA.request.put(makeRequest(Flase,address,0)); 
    endaction
    action
     x <= bram_mem.portA.response.get;
    endaction
    endseq);
    mkAutoFSM(fetch);

endfunction

  method Instruction get_inst(Bit#(16) address);
    fetch1(address);
    return x;
  endmethod */


endmodule

endpackage


