package Onecycle;

import Types::*;
import ProcTypes::*;
import Interfaces::*;
import Fetch::*;
import Decode::*;
import Exec::*;
import RFile::*;
import DMemory::*;

interface Get_IFC;
//method Addr res(Addr address);
method Bit#(7) outpt();
endinterface

(*synthesize*)


module mkOnecycle(Get_IFC);
  Reg#(Addr) pc<-mkReg(16495<<2);
  Reg#(int) count<-mkReg(0);
  //the dut
  Fetch_IFC dut_bram<-mkLoaddata_bram;
  DMemory_IFC dMem_bram <- mkDMemory_bram;
  Decode_IFC dut1<-mkDecode;
  RFile rf<-mkRFile;         //A register file with 2 read ports and a write port
  Reg#(ExecInst) exec_reg <- mkRegU;

  Reg#(Bit#(7)) output_val <- mkRegU;

  //rules
  rule upd_cnt;
    count<=(count+1)%3;
  endrule


  rule fet_data(count==0 && pc!=0);
    dut_bram.get_inst(pc);
  endrule

  rule exec_data(pc!=0 && count==1);


    //fetch Instruction
    let inst <- dut_bram.fetch_inst(pc);

    //Decode Instruction
    DecodedInst dInst = dut1.decode_method(inst);

    $display("---decoded instruction from %b", inst);
  //  $display("src1 :%b src2 : %b imm : %b dst : %b",dInst.src1,dInst.src2,dInst.imm,dInst.dst);
    $display("pc: %d inst: (%h) expanded: ", pc, inst, showInst(inst));


    //Execute Instruction
    Data rval1=rf.rd1(fromMaybe(?,dInst.src1));
    Data rval2 = rf.rd2(fromMaybe(?,dInst.src2));
    ExecInst eInst = exec(dInst,rval1,rval2,pc,?);
    if(eInst.iType == Ld || eInst.iType == St)
    begin
     dMem_bram.find(eInst.addr);
    end
    else
    begin
      $display("data : %d dst : %b",eInst.data,eInst.dst);

      //write back
      if(isValid(eInst.dst))
      begin
            rf.wr(fromMaybe(?,eInst.dst),eInst.data);
      end

        $display("addr : %b",eInst.addr);

        //increment pc
        pc<=eInst.brTaken ? (eInst.addr) : pc+4 ;
    end
    exec_reg <= eInst;
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
    $display("data : %d dst : %b",eInst.data,eInst.dst);

                 if(eInst.iType == St) output_val <= truncate(eInst.data);
    //write back
    if(isValid(eInst.dst))
    begin
          rf.wr(fromMaybe(?,eInst.dst),eInst.data);
    end

      $display("addr : %b",eInst.addr);

      //increment pc
      pc<=eInst.brTaken ? (eInst.addr) : pc+4 ;
  end
  endrule


/*  rule upd_reg_with_data(pc!=0 && count == 3);
    ExecInst eInst = ?;
    eInst = exec_reg;

    $display("data : %d dst : %b",eInst.data,eInst.dst);

    //write back
    if(isValid(eInst.dst))
    begin
          rf.wr(fromMaybe(?,eInst.dst),eInst.data);
    end

      $display("addr : %b",eInst.addr);

      //increment pc
      pc<=eInst.brTaken ? (eInst.addr) : pc+4 ;
  endrule
*/
  rule end_rule(pc == 0);
//   $display("%d",count);
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
