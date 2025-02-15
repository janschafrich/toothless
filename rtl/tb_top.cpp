#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vtop.h"  // Generated from Verilog module "top"

#define D_CLK_PRD 10  // Clock period in time units (arbitrary)

// Main function for Verilator testbench
int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);  

    // Instantiate the Verilog module
    Vtop* top = new Vtop;

    // Enable waveform generation
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("waveform.vcd");

    // Simulation parameters
    vluint64_t sim_time = 0;
    vluint64_t max_sim_time = 1000; // Run simulation for 1000 time units
    bool clk = 1;

    // Reset phase
    top->rst_ni = 0;  // Active-low reset
    for (int i = 0; i < 5; i++) {  // Hold reset for 5 cycles
        top->clk_i = clk;
        top->eval();
        tfp->dump(sim_time);
        sim_time += (D_CLK_PRD / 2);
        clk = !clk;
    }
    top->rst_ni = 1;  // Release reset

    // Main simulation loop
    while (sim_time < max_sim_time) {
        top->clk_i = clk;  // Toggle clock
        top->eval();  // Evaluate the model
        tfp->dump(sim_time);  // Dump waveform
        sim_time += (D_CLK_PRD / 2);
        clk = !clk;
    }

    // Cleanup and exit
    tfp->close();
    delete top;
    return 0;
}
