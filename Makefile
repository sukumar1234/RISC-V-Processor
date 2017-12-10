onecycle: ProcTypes.bsv Types.bsv RFile.bsv Interfaces.bsv Exec.bsv Decode.bsv Fetch.bsv Onecycle.bsv
	  @echo "Compiling into verilog files"
	  bsc -verilog -u Onecycle.bsv
	  @echo "Generting the simulation object"
	  bsc -verilog -e  mkOnecycle -o Onecycle.bsim

twocycle: ProcTypes.bsv Types.bsv RFile.bsv Interfaces.bsv Exec.bsv Decode.bsv Fetch.bsv Twocycle.bsv
	  @echo "Compiling into verilog files"
	  bsc -verilog -u Twocycle.bsv
	  @echo "Generting the simulation object"
	  bsc -verilog -e  mkTwocycle -o Twocycle.bsim

twostg  : ProcTypes.bsv Types.bsv RFile.bsv Interfaces.bsv Exec.bsv Decode.bsv Fetch.bsv Fifo.bsv Ehr.bsv Twostage.bsv
	  @echo "Compiling into verilog files"
	  bsc -verilog -u Twostage.bsv
	  @echo "Generting the simulation object"
	  bsc -verilog -e  mkTwostage -o Twostage.bsim



twostage: ProcTypes.bsv Types.bsv RFile.bsv Interfaces.bsv Exec.bsv Decode.bsv Fetch.bsv Ehr.bsv Fifo.bsv Twostage.bsv
	  @echo "Compiling into verilog files"
	  bsc -sim -show-schedule -u Twostage.bsv
	  @echo "Generting the simulation object"
	  bsc -sim -show-schedule -e mkTwostage -o Twostage.bsim

.PHONY: clean
clean:
	@rm -f *.bi *.cxx *.sched model_*.* *.bo *.ba mk*.c mk*.h mk*.o mk*.v *_c *_v *.vcd *~ *.fsdb *.log *.bsim module_*
