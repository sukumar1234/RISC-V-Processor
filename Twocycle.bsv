package Twocycle;

import Types::*;
import ProcTypes::*;
import Interfaces::*;
import Fetch::*;
import Decode::*;
import Exec::*;
import RFile::*;
import DMemory::*;

interface Get_IFC;
method Addr res(Addr address);
endinterface


(*synthesize*)


module mkTwocycle(Get_IFC);
  Reg#(Addr) pc<-mkReg(16495<<2);
  Reg#(State) state<-mkReg(Fetch);
  Reg#(Data) f2d <- mkRegU;
  Reg#(int) count<-mkReg(0);
  //the dut
  Fetch_IFC dut<-mkLoaddata;
  DMemory dMem <- mkDMemory;
  Decode_IFC dut1<-mkDecode;
  RFile rf<-mkRFile;         //A register file with 2 read ports and a write port


  //rules
  rule doFetch(state == Fetch);

    //fetch Instruction
    Instruction inst = dut.get_inst(pc);


    if(inst == 0) $finish(0);

    count<=count+1;
    f2d<=inst;
    state <=Execute;
  endrule
  rule doExecute(state == Execute);
    let inst = f2d;
    //Decode Instruction
    DecodedInst dInst = dut1.decode_method(inst);

    $display("---decoded instruction from %b", inst);
  //  $display("inst type : %b , dst :%b , src1: %b ,src2 : %b , imm : %b",dInst.iType,dInst.dst,dInst.src1, dInst.src2,dInst.imm);

    //Execute Instruction
    Data rval1=rf.rd1(fromMaybe(?,dInst.src1));
    Data rval2 = rf.rd2(fromMaybe(?,dInst.src2));
    ExecInst eInst = exec(dInst,rval1,rval2,pc,?);

    //memory access
    if(eInst.iType == Ld || eInst.iType == St)
    begin
      if(eInst.ldst == Lb)
      begin
      eInst.data <- dMem.req(MemReq{op:Lb , addr : eInst.addr, data : ?});
      end
      else if(eInst.ldst == Lh)
      begin
      eInst.data <- dMem.req(MemReq{op:Lh , addr : eInst.addr, data : ?});
      end
      else if(eInst.ldst == Lw)
      begin
      eInst.data <- dMem.req(MemReq{op:Lw , addr : eInst.addr, data : ?});
      end
      else if(eInst.ldst == Lbu)
      begin
      eInst.data <- dMem.req(MemReq{op:Lbu , addr : eInst.addr, data : ?});
      end
      else if(eInst.ldst == Lhu)
      begin
      eInst.data <- dMem.req(MemReq{op:Lhu , addr : eInst.addr, data : ?});
      end
      else if(eInst.ldst == Sb)
      begin
      let d <- dMem.req(MemReq{op:Sb , addr : eInst.addr, data : eInst.data});
      end
      else if(eInst.ldst == Sh) begin
      let d<-dMem.req(MemReq{op:Sh, addr : eInst.addr, data : eInst.data});
      end
      else if(eInst.ldst == Sw)
      begin
      let d <- dMem.req(MemReq{op:Sw , addr : eInst.addr, data : eInst.data});
      end
    end

    $display("pc: %d inst: (%h) expanded: ", pc, inst, showInst(inst));

    //write back
    if(isValid(eInst.dst))
    begin
          rf.wr(fromMaybe(?,eInst.dst),eInst.data);
    end

      $display("src1 :%b src2 : %b imm : %b data : %d dst : %b",dInst.src1,dInst.src2,dInst.imm,eInst.data,eInst.dst);
      $display("addr : %b",eInst.addr);

      //increment pc
      pc<=eInst.brTaken ? (eInst.addr) : pc+4 ;
      $display("\n");
      count<=count+1;
    state <= Fetch;
  endrule

  rule end_rule(pc == 0);
  $display("%d",count);
  $finish(0);
  endrule

method Addr res(Addr address);
return pc;
endmethod

endmodule

endpackage
