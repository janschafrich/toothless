# Makefile

export PYTHONPATH 		:= $(PWD)/../testbenches:$(PYTHONPATH)
# export VERILATOR_ROOT 	:= /home/jscha/projects/verilator
# export $(PATH)				:= $(VERILATOR_ROOT)/bin:$(PATH)

DUT				?=
SIM             ?= verilator
TOPLEVEL_LANG   ?= verilog
EXTRA_ARGS      += --trace --trace-structs
RTL_ROOT 		= $(PWD)


VERILOG_SOURCES += \
	$(RTL_ROOT)/toothless_pkg.sv \
	$(RTL_ROOT)/top.sv \
	$(RTL_ROOT)/$(DUT).sv \
	$(RTL_ROOT)/data_tcm.sv

VERILATOR_FLAGS = \
	#-Wall



# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL        = $(DUT)

# MODULE is the basename of the Python test file
MODULE          = tb_$(DUT)

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim


.PHONY:lint
lint: $(DUT).sv
	verilator --lint-only $(VERILATOR_FLAGS) $(VERILOG_SOURCES)


.PHONY:waves
waves: dump.vcd
	gtkwave dump.vcd


.PHONY:stats
stats:
	../synthesis/syn.sh stats
	

# :: instead of : necessary due to error
.PHONY:clean
clean::
	rm -rf ./sim_build
	rm -rf dump.vcd
	rm -rf results.xml
