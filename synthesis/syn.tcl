# Synthesis script to be used with Yosys
# https://github.com/asinghani/open-eda-course/blob/main/yosys-tutorial/yosys-tutorial.md
# Yosys commands: https://yosyshq.readthedocs.io/projects/yosys/en/stable/cmd_ref.html

# set TOP               [lindex $argv 0]
# set TOP             if_id_ex_stage
# set TOP             decoder
# set TOP               icache
# set TOP               dcache
# set TOP             load_store_unit
# set TOP             program_counter
# set TOP             register_file
set TOP                 soc

# if {[info exists ::TOP]} {
#     set top $::TOP
# } else {
#     set top instruction_rom # Default value
# }

# relative to Makefile loacted in TOOTHLESS root
set RTL_DIR         rtl
set MACRO_DIR       $RTL_DIR/ips
set OUT_DIR         synthesis/outputs
set PDK_DIR         /usr/local/share/pdk
set STD_CELL_LIB    $PDK_DIR/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
set SRAM_LIB        $PDK_DIR/sky130A/libs.ref/sky130_sram_macros/sram_1rw1r_32_256_8_sky130_TT_1p8V_25C.lib
# process corners: slow, typical, fast for NMOS / PMOS
# operating environment:
# best case: n40c = low resistance, high voltage (1.8 V) = fast propagation, worst case: 105c (high resistance), low voltage (1.65 V) = slow propagation 
# cell library: choose typical process variations at typical operating conditions (25c, 1.8 V)


# init - create OUT_DIR
file mkdir $OUT_DIR     

###########################################
# start synthesis flow
###########################################

# load SystemVerilog frontend
yosys plugin -i slang.so

# read memory macro first and tell yosys to dont optimize its definition
yosys read_slang $MACRO_DIR/sram_1rw1r_32_256_8_sky130.sv
yosys blackbox sram_1rw1r_32_256_8_sky130

# read in the rest source files
yosys read_slang $RTL_DIR/*.sv --top $TOP -Weverything        

# Basic optimizations
yosys hierarchy -check -top $TOP
yosys proc
yosys opt

# Write intermediate result for inspection
yosys write_verilog -sv -noattr $OUT_DIR/stage_proc.sv

# Memory specific handling
yosys memory
yosys write_verilog -sv -noattr $OUT_DIR/stage_memory.sv

# Read liberty files
yosys read_liberty -lib $STD_CELL_LIB
yosys read_liberty -lib $SRAM_LIB

yosys synth -top $TOP

# Map sequential cells (flip flop) onto target technology
yosys dfflibmap -liberty $STD_CELL_LIB

# Map combinatorial cells onto target technology
yosys abc -liberty $STD_CELL_LIB

# Generate final outputs
yosys write_verilog -sv -noattr $OUT_DIR/stage_final.sv
yosys stat
yosys show
# yosys show -format dot -prefix ${TOP}_mapped
