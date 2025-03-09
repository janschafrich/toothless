

import toothless_pkg::*;

module top #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input  logic clk_i,
    input  logic rst_ni

    // Instructions
    // input  logic instr_data_i
);

    logic branch_tkn;
    logic [31:0] offset;        // immediate from decoder
    logic [1:0] ctrl_transfer_instr;
    logic [31:0] tgt_addr;
    logic [31:0] pc;
    logic [31:0] pc_plus4;
    logic [31:0] instr;

    // register file
    // read port a
    logic [DATA_WIDTH-1:0] rdata_a;
    logic [4:0]            raddr_a;
    // read port b
    logic [4:0]            raddr_b;
    logic [DATA_WIDTH-1:0] rdata_b;
    // write port a
    logic [4:0]            waddr_a;
    logic [DATA_WIDTH-1:0] wdata_a;
    logic                  we_a;

    // program_counter #() program_counter_i (
	//     .clk            (clk_i),
	//     .rst_n          (rst_ni),
    //     .ctrl_transfer_instr_i(ctrl_transfer_instr),
    //     .offset_i       (offset),
	//     .branch_tkn_i   (branch_tkn), 
	//     .tgt_addr_i     (tgt_addr),
	//     .pc_o           (pc),
    //     .pc_plus4_o     (pc_plus4)
    // );

    // instruction_rom #() instruction_rom_i (
    //     .clk_i(clk_i),
    //     .rst_ni(rst_ni),
    //     .addr_i(pc),
    //     .instr_o(instr)
    // );

    register_file #(
        .DATA_WIDTH (DATA_WIDTH)
    ) register_file_i (
        .clk        (clk_i),
        .rst_n      (rst_ni),
        .raddr_a_i  (raddr_a),
        .rdata_a_o  (rdata_a),
        .raddr_b_i  (raddr_b),
        .rdata_b_o  (rdata_b),
        .waddr_a_i  (waddr_a),
        .wdata_a_i  (wdata_a),
        .we_a_i    (we_a)
    );

    // decoder #() decoder_i (

    // )

endmodule
