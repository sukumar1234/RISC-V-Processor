package Twostage;

import Types::*;
import ProcTypes::*;
import Interfaces::*;
import Fetch::*;
import Decode::*;
import Exec::*;
import RFile::*;
//import Fifo::*;
import Fifo_cf::*;
import DMemory::*;


typedef struct {
	DecodedInst dInst;
	Addr pc;
  Bool epoch;
	Addr ppc;
} Dec2Ex deriving (Bits, Eq);


interface Get_IFC;
//method Addr res(Addr address);
method Bit#(7) outpt();
endinterface
(*synthesize*)



module mkTwostage(Get_IFC);
  Reg#(Addr) pc<-mkReg(16495<<2);
  //the dut
  Fetch_IFC dut_bram <-mkLoaddata_bram;
  DMemory_IFC dMem_bram  <- mkDMemory_bram;
  Decode_IFC dut1<-mkDecode;
  RFile rf<-mkRFile;         //A register file with 2 read ports and a write port


//  Fifo #(10,Fetch2Execute) f2d <- mkCFFifo;
  Fifo #(2,Dec2Ex) d2e <- mkCFFifo;
  Fifo #(2,Addr) execRedirect <- mkCFFifo;
  Reg#(Bool) fEpoch <- mkReg(False);
  Reg#(Bool) eEpoch <- mkReg(False);
  Reg#(int) count <- mkReg(0);
  Reg#(ExecInst) exec_reg <- mkRegU;

	Reg#(Bit#(7)) output_val <- mkRegU; // for displaying output in led



(* conflict_free = "doFetch, doExecute" *)

  //rules


rule upd_cnt;
//	$display("%d Count", count);
  count<=(count+1)%3;
endrule

rule fet_data(count == 0 && pc!=0);
  dut_bram.get_inst(pc);
endrule

rule doFetch(count == 1);

  //fetch Instruction
  let inst <- dut_bram.fetch_inst(pc);
//    $display("%x %d",inst,pc);
  if(execRedirect.notEmpty)
  begin
    fEpoch<=!fEpoch;
    pc<=execRedirect.first;
    execRedirect.deq;
  end
  else
  begin
		let cur_pc = pc;
		let cur_fEpoch = fEpoch;
    let ppc = pc+4; // predicting next pc;
    pc<=ppc;
    let dInst = dut1.decode_method(inst);
    $display("---decoded instruction from %b", inst);
    $display("pc: %d inst: (%h) expanded: ", pc, inst, showInst(inst));
    d2e.enq ( Dec2Ex{pc:cur_pc, ppc:ppc, dInst:dInst, epoch:cur_fEpoch} );
  end
endrule


  rule doExecute(count == 1);
    if(d2e.notEmpty)
    begin
     let x = d2e.first;
      if(x.epoch == eEpoch) begin

        //Execute Instruction
        Data rval1=rf.rd1(fromMaybe(?,x.dInst.src1));
        Data rval2 = rf.rd2(fromMaybe(?,x.dInst.src2));
        ExecInst eInst = exec(x.dInst,rval1,rval2,x.pc,x.ppc);
        if(eInst.iType == Ld || eInst.iType == St)
        begin
         dMem_bram.find(eInst.addr);
        end
        else
        begin
          $display("execute step  data : %d dst : %b",eInst.data,eInst.dst);

          //write back
          if(isValid(eInst.dst))
          begin
            rf.wr(fromMaybe(?,eInst.dst),eInst.data);
          end

          if(eInst.mispredict) begin
            execRedirect.enq(eInst.addr);
            eEpoch <= !eEpoch;
          end
          $display("addr : %b",eInst.addr);
        end
        exec_reg <= eInst;
      end
      d2e.deq;
    end
endrule


  rule dummy(pc!=0 && count == 2);
  ExecInst eInst = ?;
  eInst = exec_reg;
  if(eInst.iType == Ld || eInst.iType == St)
  begin
    if(eInst.ldst == Lb)
    begin
    eInst.data <- dMem_bram.req(MemReq{op:Lb , addr : eInst.addr, data : ?});
    end
    else if(eInst.ldst == Lh)
    begin
    eInst.data <- dMem_bram.req(MemReq{op:Lh , addr : eInst.addr, data : ?});
    end
    else if(eInst.ldst == Lw)
    begin
    eInst.data <- dMem_bram.req(MemReq{op:Lw , addr : eInst.addr, data : ?});
    end
    else if(eInst.ldst == Lbu)
    begin
    eInst.data <- dMem_bram.req(MemReq{op:Lbu , addr : eInst.addr, data : ?});
    end
    else if(eInst.ldst == Lhu)
    begin
    eInst.data <- dMem_bram.req(MemReq{op:Lhu , addr : eInst.addr, data : ?});
    end
    else if(eInst.ldst == Sb)
    begin
    let d <- dMem_bram.req(MemReq{op:Sb , addr : eInst.addr, data : eInst.data});
    end
    else if(eInst.ldst == Sh) begin
    let d<-dMem_bram.req(MemReq{op:Sh, addr : eInst.addr, data : eInst.data});
    end
    else if(eInst.ldst == Sw)
    begin
    let d <- dMem_bram.req(MemReq{op:Sw , addr : eInst.addr, data : eInst.data});
    end
    $display("write back rule data : %d dst : %b",eInst.data,eInst.dst);
		if(eInst.iType == St) output_val <= truncate(eInst.data);
    //write back
    if(isValid(eInst.dst))
    begin
          rf.wr(fromMaybe(?,eInst.dst),eInst.data);
    end
    if(eInst.mispredict) begin
      execRedirect.enq(eInst.addr);
      eEpoch <= !eEpoch;
    end
    $display("addr : %b",eInst.addr);
  end
  endrule



rule end_rule(pc == 0);
	//$display("%d",output_val);
	$finish(0);
endrule

/*method Addr res(Addr address);
  return pc;
endmethod*/

method Bit#(7) outpt();
	return output_val;
endmethod
endmodule

endpackage
