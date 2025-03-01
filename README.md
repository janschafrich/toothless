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


# Simulation cocotb (Python) + Verilator (Verilator >= 5.22)

Setup Verilator Path 

```
export VERILATOR_ROOT=/home/jscha/projects/verilator
export PATH=$VERILATOR_ROOT/bin:$PATH
```

Check for Syntax Errors
```
make lint DUT=decoder
```

Run Simulation

```
cd rtl
make DUT=alu
```

View Waveform (uses GTKwaves)
```
make waves
```

# TODO

- where to define which register to access
- python central single definiton of constants








