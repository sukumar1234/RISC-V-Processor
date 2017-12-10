package Decode;

import Types::*;
import Interfaces::*;
import ProcTypes::*;
(*synthesize*)

module mkDecode(Decode_IFC);
  function DecodedInst decode(Instruction inst);
    DecodedInst dInst = ?;

    Opcode opcode = inst[6 : 0];
    let rd        = inst[11:7];
    let funct3    = inst[14:12];
    let rs1       = inst[19:15];
    let rs2       = inst[24:20];
    let aluSel    = inst[30];//select between Add/Sub, Srl/Sra


  //immediate values for different addressing modes


    Data immI   = signExtend(inst[31:20]);
  	Data immS   = signExtend({ inst[31:25], inst[11:7] });
  	Data immB   = signExtend({ inst[31], inst[7], inst[30:25], inst[11:8], 1'b0});
    //Data immU = signExtend(inst[31:12]);//(for now just to load the value directly)
    Data immU   = signExtend({ inst[31:12], 12'b0 });
  	Data immJ   = signExtend({ inst[31], inst[19:12], inst[20], inst[30:21], 1'b0});

    case (opcode)
  		opOpImm: begin              //I type instruction
  			dInst.iType = Alu;
  			case (funct3)
  				fnADD:  dInst.aluFunc = Add;
  				fnSLT:  dInst.aluFunc = Slt;
  				fnSLTU: dInst.aluFunc = Sltu;
  				fnAND:  dInst.aluFunc = And;
  				fnOR:   dInst.aluFunc = Or;
  				fnXOR:  dInst.aluFunc = Xor;
  				fnSLL:  dInst.aluFunc = Sll;
  				fnSR:   dInst.aluFunc = aluSel == 0 ? Srl : Sra;
  				default: begin
  					dInst.aluFunc = ?;
  					dInst.iType = Unsupported;
  				end
  			endcase
  			dInst.brFunc = NT;
        dInst.ldst = ?;
  			dInst.dst  = tagged Valid rd;
  			dInst.src1 = tagged Valid rs1;
  			dInst.src2 = tagged Invalid;
  			dInst.csr = tagged Invalid;
  			dInst.imm = tagged Valid immI;
  		end

  		opOp: begin             //R type instruction
  			dInst.iType = Alu;
  			case (funct3)
  				fnADD:  dInst.aluFunc = aluSel == 0 ? Add : Sub;
  				fnSLT:  dInst.aluFunc = Slt;
  				fnSLTU: dInst.aluFunc = Sltu;
  				fnAND:  dInst.aluFunc = And;
  				fnOR:   dInst.aluFunc = Or;
  				fnXOR:  dInst.aluFunc = Xor;
  				fnSLL:  dInst.aluFunc = Sll;
  				fnSR:   dInst.aluFunc = aluSel == 0 ? Srl : Sra;
  				default: begin
  					dInst.aluFunc = ?;
  					dInst.iType = Unsupported;
  				end
  			endcase
  			dInst.brFunc = NT;
        dInst.ldst = ?;
  			dInst.dst  = tagged Valid rd;
  			dInst.src1 = tagged Valid rs1;
  			dInst.src2 = tagged Valid rs2;
  			dInst.csr = tagged Invalid;
  			dInst.imm  = tagged Invalid;
  		end
      opLui: begin // rd = immU + r0    //UType Instruction
  			dInst.iType = Alu;
        dInst.ldst = ?;
  			dInst.aluFunc = Add;
  			dInst.brFunc = NT;
  			dInst.dst = tagged Valid rd;
  			dInst.src1 = tagged Valid 0;
  			dInst.src2 = tagged Invalid;
  			dInst.csr = tagged Invalid;
  			dInst.imm = tagged Valid immU;
  		end

  		opAuipc: begin                  //UType Instruction
  			dInst.iType = Auipc;
        dInst.ldst = ?;
  			dInst.aluFunc = ?;
  			dInst.brFunc = NT;
  			dInst.dst = tagged Valid rd;
  			dInst.src1 = tagged Invalid;
  			dInst.src2 = tagged Invalid;
  			dInst.csr = tagged Invalid;
  			dInst.imm = tagged Valid immU;
  		end

      opJal: begin
  			dInst.iType = J;
  			dInst.aluFunc = ?;
  			dInst.brFunc = AT;
        dInst.ldst = ?;
  			dInst.dst = tagged Valid rd;
  			dInst.src1 = tagged Invalid;
  			dInst.src2 = tagged Invalid;
  			dInst.csr = tagged Invalid;
  			dInst.imm = tagged Valid immJ;
  		end

  		opJalr: begin
  			dInst.iType = Jr;
  			dInst.aluFunc = ?;
  			dInst.brFunc = AT;
        dInst.ldst = ?;
  			dInst.dst = tagged Valid rd;
  			dInst.src1 = tagged Valid rs1;
  			dInst.src2 = tagged Invalid;
  			dInst.csr = tagged Invalid;
  			dInst.imm = tagged Valid immI;
  		end

  		opBranch: begin
  			dInst.iType = Br;
  			dInst.aluFunc = ?;
  			case(funct3)
  				fnBEQ:  dInst.brFunc = Eq;
  				fnBNE:  dInst.brFunc = Neq;
  				fnBLT:  dInst.brFunc = Lt;
  				fnBLTU: dInst.brFunc = Ltu;
  				fnBGE:  dInst.brFunc = Ge;
  				fnBGEU: dInst.brFunc = Geu;
  				default: begin
  					dInst.brFunc = ?;
  					dInst.iType = Unsupported;
  				end
  			endcase
  			dInst.dst  = tagged Invalid;
        dInst.ldst = ?;
  			dInst.src1 = tagged Valid rs1;
  			dInst.src2 = tagged Valid rs2;
  			dInst.csr = tagged Invalid;
  			dInst.imm  = tagged Valid immB;
  		end

  		opLoad: begin // only support LW
      dInst.iType = Ld;
        case(funct3)
          fnLW : dInst.ldst = Lw;
          fnLB : dInst.ldst = Lb;
          fnLH : dInst.ldst = Lh;
          fnLBU: dInst.ldst = Lbu;
          fnLHU: dInst.ldst = Lhu;
          default : begin
              dInst.ldst = ?;
              dInst.iType = Unsupported;
          end
        endcase
  			dInst.aluFunc = Add; // calc effective addr
  			dInst.brFunc = NT;
  			dInst.dst  = tagged Valid rd;
  			dInst.src1 = tagged Valid rs1;
  			dInst.src2 = tagged Invalid;
  			dInst.csr = tagged Invalid;
  			dInst.imm = tagged Valid immI;
  		end

  		opStore: begin
      	dInst.iType = St;
        case(funct3)
          fnSB : dInst.ldst = Sb;
          fnSH : dInst.ldst = Sh;
          fnSW : dInst.ldst = Sw;
          default: begin
            dInst.ldst = ?;
            dInst.iType = Unsupported;
          end
        endcase
  			dInst.aluFunc = Add; // calc effective addr
  			dInst.brFunc = NT;
  			dInst.dst = tagged Invalid;
  			dInst.src1 = tagged Valid rs1;
  			dInst.src2 = tagged Valid rs2;
  			dInst.csr = tagged Invalid;
  			dInst.imm = tagged Valid immS;
  		end

      default: begin
  			dInst.iType = Unsupported;
        dInst.ldst = ?;
  			dInst.aluFunc = ?;
  			dInst.brFunc = NT;
  			dInst.dst = tagged Invalid;
  			dInst.src1 = tagged Invalid;
  			dInst.src2 = tagged Invalid;
  			dInst.csr = tagged Invalid;
  			dInst.imm = tagged Invalid;
  		end
  	endcase

    //no write to x0
    if(dInst.dst matches tagged Valid .dst &&& dst == 0) begin
  		dInst.dst = tagged Invalid;
  	end

    return dInst;
  endfunction


method DecodedInst decode_method(Instruction inst);
  return decode(inst);
endmethod
endmodule

endpackage
