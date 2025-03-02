#! /bin/bash

TASK=${1:-syn}         # stats,  syn

export PATH="/home/jscha/projects/oss-cad-suite/bin:$PATH"

TOOTHLESS_ROOT=/home/jscha/projects/toothless

RTL_ROOT=$TOOTHLESS_ROOT/rtl
SYN_ROOT=$TOOTHLESS_ROOT/synthesis


RTL_SRC="$RTL_ROOT/load_store_unit.sv \
        $RTL_ROOT/data_tcm.sv"

TOP=load_store_unit

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
