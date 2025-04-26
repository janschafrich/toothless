/*
Copyright Jan-Eric Schäfrich 2025
Part of Toothless

Top level module which instantiates the whole processor. 

*/


import toothless_pkg::*;


module top #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input  logic clk,
    input  logic rst_n
);

    // single stage processor
    if_id_ex_stage #() if_id_ex_stage_i(
        .clk(clk),
        .rst_n(rst_n),
        .cur_instr_o(),
        .result_o(),
        .instr_invalid_o()
    );


endmodule
