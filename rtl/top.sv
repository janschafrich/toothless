

import toothless_pkg::*;

module top 
    #() (
    input  logic clk_i,
    input  logic rst_ni

    // Instructions
    // input  logic instr_data_i
);

    logic branch_tkn;
    logic is_jalr;
    logic [31:0] tgt_addr;
    logic [31:0] pc;
    logic [31:0] instr;

    program_counter #() program_counter_i (
	    .clk_i          (clk_i),
	    .rst_ni         (rst_ni),
	    .branch_tkn_i   (branch_tkn), 
        .is_jalr_i      (is_jalr),
	    .tgt_addr_i     (tgt_addr),
	    .pc_o           (pc)
    );

    instruction_rom #() instruction_rom_i (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .addr_i(pc),
        .instr_o(instr)
    );

    // decoder #() decoder_i (

    // )

endmodule
