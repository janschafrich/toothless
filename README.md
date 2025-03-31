# toothless 

Single stage RV32I processor core. 

![](docs/blockdiagram-toothless.png)


## Mission

- design  minimal RV32I core
- test it - verilator
- do logic synthesis - yosys
- do physical synthesis - yosys
- try SystemVerilog assertions


# Simulation cocotb (Python) + Verilator (Verilator >= 5.22)

Setup Verilator Path 

```
export VERILATOR_ROOT=/home/jscha/projects/verilator
export PATH=$VERILATOR_ROOT/bin:$PATH
export PATH=/home/jscha/.config/mlonmcu/environments/default/deps/install/riscv_gcc/bin:$PATH
```

Check for Syntax Errors
```
make lint TOP=decoder
```

Run Simulation

```
make TOP=alu
```




View Waveform (uses GTKwaves)
```
make waves
```

## Simulate Hex File / Assembly

Setup compiler path
```
export PATH=/home/jscha/.config/mlonmcu/environments/default/deps/install/riscv_gcc/bin:$PATH
```

remove old Verilator model (Verialtor may not detect changes and run with an outdated model)
```
make clean
```

create test.hex from test.s
```
make bin ASM_TEST=alu
```
run compiled assembly
```
make TOP=if_id_ex_stage
```


# Synthesis Yosys

- uses synthesis script `synthesis/syn.sh`
- Need to manually specify source files inside script
- nned to manually specifyy PDK path inside script


perform logic synthesis with SKY130 library
```
make syn
```

Synthesis with Sky130 nm

## Compile PDK with OpenPDK
Skywater130 nm PDK
OpenPDK: setup of PDKs for open source tools from foundry sources



## Compile SRAM / ROM macros for SKY130 with OpenRAM

Generation of RAM/ROM macros
```
export OPENRAM_HOME="/home/jscha/projects/OpenRAM/compiler"
export OPENRAM_TECH="/home/jscha/projects/OpenRAM/technology"
export PYTHONPATH="$PYTHONPATH:$OPENRAM_HOME"
```









