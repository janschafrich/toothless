#! /bin/bash

TASK=${1:-syn}         # stats,  syn

export PATH="/home/jscha/projects/oss-cad-suite/bin:$PATH"

TOP=if_id_ex_stage

TOOTHLESS_ROOT=/home/jscha/projects/toothless

RTL_DIR=$TOOTHLESS_ROOT/rtl
SYN_DIR=$TOOTHLESS_ROOT/synthesis


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
        yosys -l stat.log -p "plugin -i slang; \
                read_slang $RTL_SRC; \
                hierarchy -top $TOP; \
                proc; opt; techmap; opt; \
                write_verilog $SYN_DIR/$TOP-netlist.v; \
                synth; \
                stat"
fi
