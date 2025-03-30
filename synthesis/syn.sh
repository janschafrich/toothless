#! /bin/bash

TASK=${1:-syn}         # stats,  syn

export PATH="/home/jscha/projects/oss-cad-suite/bin:$PATH"

TOP=if_id_ex_stage

TOOTHLESS_ROOT=/home/jscha/projects/toothless

RTL_DIR=$TOOTHLESS_ROOT/rtl
SYN_DIR=$TOOTHLESS_ROOT/synthesis
PDK_ROOT=/usr/local/share/pdk # Update this to your PDK location
# process corners: slow, typical, fast for NMOS / PMOS
# operating environment:
# best case: n40c = low resistance, high voltage (1.8 V) = fast propagation, worst case: 105c (high resistance), low voltage (1.65 V) = slow propagation 
# cell library: choose typical process variations at typical operating conditions (25c, 1.8 V)
STD_CELL_LIB=$PDK_ROOT/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib



RTL_SRC="$RTL_DIR/toothless_pkg.sv \
        $RTL_DIR/control_unit.sv \
        $RTL_DIR/alu.sv \
        $RTL_DIR/register_file.sv \
        $RTL_DIR/program_counter.sv \
        $RTL_DIR/decoder.sv \
        $RTL_DIR/instruction_rom.sv \
        $RTL_DIR/load_store_unit.sv \
        $RTL_DIR/if_id_ex_stage.sv \
        $RTL_DIR/data_tcm.sv"


if [[ "$TASK" == "stats" ]]
then
        yosys -p "plugin -i slang; \
                read_slang $RTL_SRC; \
                hierarchy -top $TOP; \
                proc; opt; techmap; opt; \
                write_verilog $SYN_DIR/$TOP-netlist.v; \
                stat"
fi

if [[ "$TASK" == "syn" ]]
then
        # mkdir -p $SYN_DIR/outputs
        yosys $SYN_DIR/syn.tcl
fi



