import Types::*;
import ProcTypes::*;
import Vector::*;
import Interfaces::*;


(* synthesize *)
module mkRFile( RFile );
    Vector#(32, Reg#(Data)) rfile <- replicateM(mkReg(0));

    function Data read(RIndx rindx);
        return rfile[rindx];
    endfunction

    method Action wr( RIndx rindx, Data data );
        if(rindx!=0) begin
            rfile[rindx] <= data;
        end
    endmethod

    method Data rd1( RIndx rindx ) = read(rindx);
    method Data rd2( RIndx rindx ) = read(rindx);
endmodule
