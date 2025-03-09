/*

Instruction Fetch, Instruction Decode and Exxcution in a single stage for now

*/


import toothless_pkg::*;


module if_id_ex_stage #(
    DATA_WIDTH  = 32,
    ADDR_WIDTH  = 32,
    INSTR_WIDTH = 32
)(
    input  logic                    clk,
    input  logic                    rst_n,
    output logic [INSTR_WIDTH-1:0]  cur_instr_o,
    output logic [DATA_WIDTH-1:0]   result_o,
    output logic                    instr_invalid_o
);

    instruction_rom #() instruction_rom_i (
        .clk (clk),
        .rst_n(rst_n),
        .addr_i(pc),
        .instr_o(cur_instr)
    );


    program_counter #(
        .INSTR_WIDTH (INSTR_WIDTH),
	    .ADDR_WIDTH  (DATA_WIDTH)
    ) program_counter_i (
        .clk            (clk),
        .rst_n          (rst_n),
        .ctrl_trans_instr_i(ctrl_trans_instr),
        .offset_i       (),
        .branch_tkn_i   (), 
        .tgt_addr_i     (),
        .pc_o           (pc),
        .pc_plus4_o     ()
    );

    decoder #(
        .DATA_WIDTH (DATA_WIDTH)
    ) decoder_i (
        .clk        (clk),
        .rst_n      (rst_n), 
        .instr_i    (cur_instr),

        // ALU signals
        .alu_operator_o(alu_operator),              // select operation to be performed by ALU


        .imm_o(alu_operand_b),           // sign/zero extended immediate value from current instruction
        .imm_valid_o(),       // whether current instruction has an immediate value

        // register file signals
        .rs1_used_o(),
        .rs2_used_o(),
        .rd_used_o(),                   // need register write
        .rs1_o(alu_operand_a[4:0]),          // using x0 for testing 
        .rs2_o(), 
        .rd_o(),

        // controller signals
        .alu_op_a_mux_sel_o(),          // operand a selection: reg, PC, immediate or zero
        .alu_op_b_mux_sel_o(),           // operand b selection: reg or immediate
        .rf_wp_mux_sel_o(),           // write source: 00 ALU, 01 PC
        .alu_result_mux_sel_o(),      // where should the ALU result go: 00 RF, 01 PC, 10 LSU

        // program counter signals
        .ctrl_trans_instr_o(ctrl_trans_instr),      // current instr is control transfer, 00 none, 01 jump, 10 branch

        // load store unit signals
        .data_req_o(),                   // request data memory access
        .data_type_o(),                // word, half word, byte for LSU
        .data_we_o(),                    // write or read to memory
        .data_sign_ext_o(),            // whether or not data from memory is to be sign extended

        .instr_invalid_o(instr_invalid_o)                    // everything not part of RV32I is invalid
    );


    alu #(
        .DATA_WIDTH (DATA_WIDTH),
        .ALU_OP_WIDTH (ALU_OP_WIDTH)   
    ) alu_i (
        .clk    (clk),
        .rst_n  (rst_n),

        .operator_i (alu_operator),
        .operand_a_i(alu_operand_a),
        .operand_b_i(alu_operand_b),

        .result_o (result_o)
    );

    // program counter
    logic [1:0] ctrl_trans_instr;
    logic [ADDR_WIDTH-1:0] pc;

    // program counter <-> decoder
    logic [INSTR_WIDTH-1:0]     cur_instr;

    // decoder <-> alu
    logic [ALU_OP_WIDTH-1:0]    alu_operator;
    logic [DATA_WIDTH-1:0]      alu_operand_a; 
    logic [DATA_WIDTH-1:0]      alu_operand_b; 

    assign cur_instr_o = cur_instr;

endmodule