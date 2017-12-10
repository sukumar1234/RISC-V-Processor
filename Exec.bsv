package Exec;

import Types::*;
import ProcTypes::*;


(*noinline*)
function Data alu(Data a, Data b, AluFunc func);
  Data res = case(func)
     Add   : (a + b);
     Sub   : (a - b);
     And   : (a & b);
     Or    : (a | b);
     Xor   : (a ^ b);
     Slt   : zeroExtend( pack( signedLT(a, b) ) );
     Sltu  : zeroExtend( pack( a < b ) );
   // 5-bit shift width for 32-bit data
     Sll   : (a << b[4:0]);
     Srl   : (a >> b[4:0]);
     Sra   : signedShiftRight(a, b[4:0]);
  endcase;
  return res;
endfunction

(* noinline *)
function Bool aluBr(Data a, Data b, BrFunc brFunc);
  Bool brTaken = case(brFunc)
    Eq  : (a == b);
    Neq : (a != b);
    Lt  : signedLT(a, b);
    Ltu : (a < b);
    Ge  : signedGE(a, b);
    Geu : (a >= b);
    AT  : True;
    NT  : False;
  endcase;
  return brTaken;
endfunction


(* noinline *)
function Addr brAddrCalc(Addr pc, Data val, IType iType, Data imm, Bool taken);
  Addr pcPlus4 = pc + 4;
  Addr targetAddr = case (iType)
    J  : (pc + imm);
    Jr : {truncateLSB(val + imm), 1'b0};
    Br : (taken ? pc + imm : pcPlus4);
    default: pcPlus4;
  endcase;
  return targetAddr;
endfunction


(*noinline*)
function ExecInst exec(DecodedInst dInst,Data rVal1,Data rVal2,Addr pc,Addr ppc);
  ExecInst eInst = ?;

  // perform an alu operation using rval1,rval2/imm,and for that check whether immediate value is valid or not

  
  Data aluVal2 = isValid(dInst.imm) ? fromMaybe(?,dInst.imm) : rVal2;
  let aluRes = alu(rVal1,aluVal2,dInst.aluFunc);

  eInst.data = dInst.iType==St ?
                 rVal2 :
               (dInst.iType==J || dInst.iType == Jr) ?
                 (pc+4) :
               dInst.iType==Auipc ?
                 (pc + fromMaybe(?, dInst.imm)) :
                 aluRes;
  let brTaken = aluBr(rVal1, rVal2, dInst.brFunc);
  let brAddr = brAddrCalc(pc, rVal1, dInst.iType, fromMaybe(?, dInst.imm), brTaken);
  //set execute instruction

  eInst.addr = (dInst.iType == Ld || dInst.iType == St) ? aluRes : brAddr;
  eInst.iType = dInst.iType;
  eInst.mispredict = brAddr != ppc;
  eInst.brTaken = brTaken;
  eInst.dst = dInst.dst;
  eInst.ldst = dInst.ldst;
  eInst.csr = dInst.csr;
  return eInst;
endfunction

endpackage
