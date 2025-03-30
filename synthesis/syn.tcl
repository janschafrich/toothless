# Synthesis script to be used with Yosys
# https://github.com/asinghani/open-eda-course/blob/main/yosys-tutorial/yosys-tutorial.md

# set TOP             sram_1rw1r_32_256_8_sky130
# set TOP               instruction_rom
# set TOP             if_id_ex_stage
set TOP             program_counter

# relative to Makefile loacted in TOOTHLESS root
set RTL_DIR         rtl
set OUT_DIR         synthesis/outputs
set PDK_DIR         /usr/local/share/pdk
set STD_CELL_LIB    $PDK_DIR/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
set SRAM_LIB        $PDK_DIR/sky130A/libs.ref/sky130_sram_macros/sram_1rw1r_32_256_8_sky130_TT_1p8V_25C.lib

# set RTL_SRC    "$RTL_DIR/toothless_pkg.sv \
#                 $RTL_DIR/program_counter.sv \
# "


# init
file mkdir $OUT_DIR


# load SystemVerilog frontend
yosys plugin -i slang.so


# read memory macro
yosys read_slang $RTL_DIR/sram_1rw1r_32_256_8_sky130.sv -Weverything
yosys blackbox sram_1rw1r_32_256_8_sky130


# readl RTL with simulation disabled for synthesis
# yosys read_slang -D SYNTHESIS ../rtl/toothless_pkg.sv ../rtl/$TOP.sv -Weverything
# yosys read_slang $RTL_DIR/*.sv -Weverything
yosys read_slang $RTL_DIR/toothless_pkg.sv $RTL_DIR/program_counter.sv -Weverything

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
