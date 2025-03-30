# Makefile for toothless project

export PYTHONPATH 		:= $(PWD)/verification/unittests:$(PYTHONPATH)
# export VERILATOR_ROOT 	:= /home/jscha/projects/verilator
# export $(PATH)				:= $(VERILATOR_ROOT)/bin:$(PATH)

DUT				?= if_id_ex_stage
ASM_TEST 		?= test
SIM             ?= verilator
TOPLEVEL_LANG   ?= verilog
EXTRA_ARGS      += --trace --trace-structs

RTL_DIR 		= $(PWD)/rtl
UNITTESTS_DIR   = verification/unittests
SYSTEMTESTS_DIR = $(PWD)/verification/system
SYNTHESIS_DIR   = $(PWD)/synthesis
ASSEMBLY_DIR 	= verification/system
ASSEMBLY_BUILD_DIR 	= $(ASSEMBLY_DIR)/build

# assembly compilation
RISCV_GCC 		= riscv32-unknown-elf-gcc
RISCV_AS 		= riscv32-unknown-elf-as
RISCV_LD 		= riscv32-unknown-elf-ld
RISCV_OBJCOPY 	= riscv32-unknown-elf-objcopy
RISCV_OBJDUMP 	= riscv32-unknown-elf-objdump

ARCH = -march=rv32i -mabi=ilp32
ASM_FILE 	= $(ASSEMBLY_DIR)/$(ASM_TEST).s
OBJ_FILE 	= $(ASSEMBLY_BUILD_DIR)/asm_test.o
ELF_FILE 	= $(ASSEMBLY_BUILD_DIR)/asm_test.elf
BIN_FILE 	= $(ASSEMBLY_BUILD_DIR)/asm_test.bin
HEX_FILE 	= $(ASSEMBLY_BUILD_DIR)/asm_test.hex
DUMP_FILE 	= $(ASSEMBLY_BUILD_DIR)/asm_test.dump


VERILOG_SOURCES += \
	$(RTL_DIR)/toothless_pkg.sv \
	$(RTL_DIR)/top.sv \
	$(RTL_DIR)/if_id_ex_stage.sv \
	$(RTL_DIR)/alu.sv \
	$(RTL_DIR)/control_unit.sv \
	$(RTL_DIR)/decoder.sv \
	$(RTL_DIR)/instruction_rom.sv \
	$(RTL_DIR)/load_store_unit.sv \
	$(RTL_DIR)/data_tcm.sv \
	$(RTL_DIR)/program_counter.sv \
	$(RTL_DIR)/register_file.sv \

VERILATOR_FLAGS = \
	#-Wall
# VERILATOR_ARGS += +vmem+if_id_ex_stage.instruction_rom.mem=test.hex
# SIMULATION used in instruction_rom to differentiate between SIMULATION and synthesis
VERILATOR_ARGS += +vmem+$(HEX_FILE) -DSIMULATION

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL        = $(DUT)

# MODULE is the basename of the Python test file
MODULE          = tb_$(DUT)

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim


.PHONY:lint
lint: $(RTL_DIR)/$(DUT).sv
	verilator --lint-only $(VERILATOR_FLAGS) $(VERILATOR_ARGS) $(VERILOG_SOURCES) 


.PHONY:waves
waves: dump.vcd
	gtkwave dump.vcd &


.PHONY:syn
syn:
	$(SYNTHESIS_DIR)/syn.sh syn
	

.PHONY: bin
bin: $(BIN_FILE)

$(OBJ_FILE): $(ASM_FILE)
	mkdir -p $(ASSEMBLY_BUILD_DIR)
	$(RISCV_AS) $(ARCH) -o $@ $<

$(ELF_FILE): $(OBJ_FILE)
	$(RISCV_LD) -o $@ $<

$(BIN_FILE): $(ELF_FILE)
	$(RISCV_OBJCOPY) -O binary $< $@
	$(RISCV_OBJDUMP) -D $< > $(DUMP_FILE)  		# Generate disassembly for debugging
	$(RISCV_OBJCOPY) -O verilog $< $(HEX_FILE)  # Generate Verilog hex format


# :: instead of : necessary due to error
.PHONY:clean
clean::
	rm -rf ./sim_build
	rm -rf dump.vcd
	rm -rf results.xml
	rm -rf $(ASSEMBLY_BUILD_DIR)
	rm -rf $(SYNTHESIS_DIR)/outputs
