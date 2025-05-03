/*
Copyright Jan-Eric Schäfrich 2025
Part of Toothless

Top level module which instantiates the whole soc and may provide some glue logic
to interface with EDA tools in the future.  

*/




module top 
    import toothless_pkg::*;
#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter INSTR_WIDTH = 32
) (
    input  logic clk,
    input  logic rst_n,
    input  logic enable     // todo: pause execution at any time
);

    soc #(
        .DATA_WIDTH (DATA_WIDTH),   
        .ADDR_WIDTH (ADDR_WIDTH),
        .INSTR_WIDTH(INSTR_WIDTH)  
    ) soc_i (
        .clk(clk),
        .rst_n(rst_n)
    );

endmodule
