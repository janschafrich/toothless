# toothless - Mission

design  minimal RV32I core

test it - verilator

do logic synthesis - yosys

do physical synthesis - yosys

# Core - Toothless

instruction fetch
decoder
alu
lsu
regfile


# Steps

Simulation: Verilator which version Ubtuntu 22.04?


# Setup Simulation

Verilator Path 
```
export NEMO_DIR=/home/jscha/projects/nemo
export VERILATOR_ROOT=$NEMO_DIR/verilator
export PATH=$VERILATOR_ROOT/bin:$PATH
```

Launch Simulation (Verilator version 4.21)

```
cd rtl
make
```






