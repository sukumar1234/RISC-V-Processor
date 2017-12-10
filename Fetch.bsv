package Fetch;

import Types::*;
import Interfaces::*;
import RegFile::*;
import BRAM::*;
import DefaultValue::*;


function BRAMRequest#(Bit#(16),Data) makeRequest(Bool write, Bit#(16) addr, Data data);
return BRAMRequest{
write : write,
responseOnWrite : False,
address : addr,
datain : data
};
endfunction

(*synthesize*)


module mkLoaddata_bram(Fetch_IFC);
  BRAM_Configure cfg = defaultValue;
  cfg.allowWriteResponseBypass = False;
  cfg.loadFormat = tagged Hex "sum.mem";
  BRAM2Port#(Bit#(16),Data) instmem<- mkBRAM2Server(cfg);
//  String file = "max.vmh";
//  BRAM_PORT#(Bit#(16),Data) instmem <- mkBRAMCore1Load(0,False,file,False);

  method Action get_inst(Addr address);
    Bit#(16) check_addr = truncate(address>>2);
    instmem.portA.request.put(makeRequest(False,check_addr,0));
  //  instmem.put(False,check_addr,0);
  endmethod



  method ActionValue#(Instruction) fetch_inst(Addr address);
    actionvalue
      let x <- instmem.portA.response.get;
      return x;
    endactionvalue
  endmethod

endmodule

endpackage
