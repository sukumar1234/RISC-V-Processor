package DMemory;

import Types::*;
import Interfaces::*;
import RegFile::*;
import BRAM::*;
import DefaultValue::*;
//import ClientServer::*;
//import GetPut::*;

function BRAMRequest#(Bit#(16),Data) makeRequest(Bool write, Bit#(16) addr, Data data);
return BRAMRequest{
write : write,
responseOnWrite : False,
address : addr,
datain : data
};
endfunction


(*synthesize*)


module mkDMemory_bram(DMemory_IFC);

  BRAM_Configure cfg = defaultValue;
  cfg.allowWriteResponseBypass = False;
  cfg.loadFormat = tagged Hex "sum.mem";
  BRAM2Port#(Bit#(16),Data) instmem<- mkBRAM2Server(cfg);

  method Action find(Addr address);
    Bit#(16) index = truncate(address>>2);
    instmem.portA.request.put(makeRequest(False,index,0));
  endmethod

/*  method ActionValue#(Data) req(MemReq r) if(found);
    actionvalue
      let x <- instmem.portA.response.get;
      found <= False;
      return x;
    endactionvalue
  endmethod*/


  method ActionValue#(Data) req (MemReq r);
    actionvalue
      Bit#(16) index = truncate(r.addr>>2);
      let data <- instmem.portA.response.get;
      Bit#(32) retdata = data;

        if(r.op == Sb)  begin
        retdata[7:0]=r.data[7:0];
        instmem.portB.request.put(makeRequest(True,index,retdata));
        end
        else if(r.op == Sh) begin
        retdata[15:0] = r.data[15:0];
        instmem.portB.request.put(makeRequest(True,index,retdata));
        end
        else if(r.op == Sw) begin
        retdata = r.data;
        instmem.portB.request.put(makeRequest(True,index ,retdata));
        end



      else if(r.op == Lb) retdata = signExtend(data[7:0]);
      else if(r.op == Lh) retdata = signExtend(data[15:0]);
      else if(r.op == Lw) retdata = data;
      else if(r.op == Lbu) retdata = zeroExtend(data[7:0]);
      else if(r.op == Lhu) retdata = zeroExtend(data[15:0]);
      return retdata;
    endactionvalue
  endmethod

method ActionValue#(Data) dum_req();
  actionvalue
    let x <- instmem.portA.response.get;
    return x;
  endactionvalue
endmethod

endmodule


endpackage
