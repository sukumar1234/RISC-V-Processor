package Interfaces;

import Types::*;
import ProcTypes::*;


interface Fetch_IFC;
  method Action get_inst(Addr address);
  method ActionValue#(Instruction) fetch_inst(Addr address);
endinterface

interface Decode_IFC;
  method DecodedInst decode_method(Instruction inst);
endinterface

interface RFile;
    method Action wr( RIndx rindx, Data data );
    method Data rd1( RIndx rindx );
    method Data rd2( RIndx rindx );
endinterface

interface DMemory_IFC;
  method Action find(Addr address);
  method ActionValue#(Data) req (MemReq r);
  method ActionValue#(Data) dum_req();
endinterface


endpackage
