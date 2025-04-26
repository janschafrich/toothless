#! /bin/bash

TOP=${1:-instruction_rom}         # stats,  syn
TASK=${2:-syn}

# main use of this script is to automatically export yosys to the path
# oss cad suite contains another installation of Verialtor that conflicts my own, keep separated
export PATH="/home/jscha/projects/oss-cad-suite/bin:$PATH"

SYN_DIR=synthesis

if [[ "$TASK" == "syn" ]]
then
        yosys -c "$SYN_DIR/syn.tcl"
        # yosys -c "$SYN_DIR/syn.tcl" -DTOP=$TOP
fi



