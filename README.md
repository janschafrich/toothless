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


# Simulation cocotb + Verilator Simulation (Verilator >= 5.22)

Setup Verilator Path 

```
export VERILATOR_ROOT=/home/jscha/projects/verilator
export PATH=$VERILATOR_ROOT/bin:$PATH
```

Launch program_counter

```
cd rtl
make DUT=alu
```

# TODO









