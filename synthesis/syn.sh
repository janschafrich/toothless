#! /bin/bash

TASK=${1:-syn}         # stats,  syn

export PATH="/home/jscha/projects/oss-cad-suite/bin:$PATH"

TOOTHLESS_ROOT=/home/jscha/projects/toothless

RTL_ROOT=$TOOTHLESS_ROOT/rtl
SYN_ROOT=$TOOTHLESS_ROOT/synthesis


RTL_SRC="$RTL_ROOT/toothless_pkg.sv \
        $RTL_ROOT/control_unit.sv \
        $RTL_ROOT/alu.sv \
        $RTL_ROOT/register_file.sv \
        $RTL_ROOT/program_counter.sv \
        $RTL_ROOT/decoder.sv \
        $RTL_ROOT/instruction_rom.sv \
        $RTL_ROOT/load_store_unit.sv \
        $RTL_ROOT/if_id_ex_stage.sv \
         $RTL_ROOT/data_tcm.sv"

TOP=if_id_ex_stage

if [[ "$TASK" == "stats" ]]
then
        yosys -p "read -sv $RTL_SRC; \
                hierarchy -top $TOP; \
                proc; opt; techmap; opt; \
                write_verilog $SYN_ROOT/$TOP-netlist.v; \
                stat"
fi

if [[ "$TASK" == "syn" ]]
then
        yosys -l stat.log -p "read -sv $RTL_SRC; \
                hierarchy -top $TOP; \
                proc; opt; techmap; opt; \
                write_verilog $SYN_ROOT/$TOP-netlist.v; \
                synth; \
                stat"
fi
