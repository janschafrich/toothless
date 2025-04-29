/*

Instruction Fetch, Instruction Decode and Execution as a minimal starting point

*/

import toothless_pkg::*;

module if_id_ex_stage #(
    DATA_WIDTH  = 32,
    ADDR_WIDTH  = 32,
    INSTR_WIDTH = 32
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic [INSTR_WIDTH-1:0]  instruction_i,
    output logic [ADDR_WIDTH-1:0]   instr_addr_o,
    output logic                    instr_invalid_o
);

    // Signal declarations
    // program counter
    logic [1:0] ctrl_trans_instr;
    logic [ADDR_WIDTH-1:0] instr_addr;

    // program counter <-> decoder
    logic [INSTR_WIDTH-1:0]     cur_instr;

    // decoder <-> alu
    alu_opcode_e    alu_operator;

    // decoder <-> register file
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;
    logic       rf_we;

    // decoder <-> control unit
    logic [1:0]             alu_op_a_mux_sel;
    logic [1:0]             alu_op_b_mux_sel;
    logic [1:0]             rf_wp_mux_sel;
    logic [DATA_WIDTH-1:0]  imm;
    logic                   imm_valid;
    logic                   rs1_valid;
    logic                   rs2_valid;

    // alu <-> control unit
    logic [DATA_WIDTH-1:0] alu_result;
    logic [DATA_WIDTH-1:0] alu_operand_a; 
    logic [DATA_WIDTH-1:0] alu_operand_b; 

    // register file <-> control unit
    logic [ADDR_WIDTH-1:0] rf_rp_a;
    logic [ADDR_WIDTH-1:0] rf_rp_b;
    logic [ADDR_WIDTH-1:0] rf_wp_a;

    // control unit <-> program counter
    logic [ADDR_WIDTH-1:0] pc_plus4;

    // decoder <-> load store unit
    logic                   mem_we;               // 0 read access, 1 write access
    logic                   mem_data_req;         // ongoing request to the LSU
    logic [1:0]             mem_data_type;        // 00 byte, 01 halfword, 10 word
    logic                   mem_data_sign_ext;    // sign extension or zero extension

    // control <-> load store unit
    logic [DATA_WIDTH-1:0]  mem_rdata;



    // module instantiations
    program_counter #(
        .INSTR_WIDTH (INSTR_WIDTH),
	    .ADDR_WIDTH  (DATA_WIDTH)
    ) program_counter_i (
        .clk            (clk),
        .rst_n          (rst_n),
        .ctrl_trans_instr_i(ctrl_trans_instr),
        .offset_i       (imm),                  // from decoder
        .branch_tkn_i   (alu_result[0]), 
        .tgt_addr_i     (alu_result),
        .pc_o           (instr_addr),
        .pc_plus4_o     (pc_plus4)
    );

    decoder #(
        .DATA_WIDTH (DATA_WIDTH)
    ) decoder_i (
        .clk        (clk),
        .rst_n      (rst_n), 
        .instr_i    (instruction_i),

        // ALU signals
        .alu_operator_o(alu_operator),              // select operation to be performed by ALU


        .imm_o(imm),           // sign/zero extended immediate value from current instruction
        .imm_valid_o(imm_valid),       // whether current instruction has an immediate value

        // register file signals
        .rs1_used_o(rs1_valid),
        .rs2_used_o(rs2_valid),
        .rd_used_o(rf_we),                              // need register write
        .rs1_o(rs1),                                     
        .rs2_o(rs2), 
        .rd_o(rd),

        // controller signals
        .alu_op_a_mux_sel_o(alu_op_a_mux_sel),          // operand a selection: reg, PC, immediate or zero
        .alu_op_b_mux_sel_o(alu_op_b_mux_sel),           // operand b selection: reg or immediate
        .rf_wp_mux_sel_o(rf_wp_mux_sel),                             // write source: 00 RF, 01 PC

        // program counter signals
        .ctrl_trans_instr_o(ctrl_trans_instr),      // current instr is control transfer, 00 none, 01 jump, 10 branch

        // load store unit signals
        .data_req_o(mem_data_req),                  // request data memory access
        .data_type_o(mem_data_type),                // word, half word, byte for LSU
        .data_we_o(mem_we),                         // write or read to memory
        .data_sign_ext_o(mem_data_sign_ext), // has no driver // whether or not data from memory is to be sign extended

        .instr_invalid_o(instr_invalid_o)           // everything not part of RV32I is invalid
    );


    alu #(
        .DATA_WIDTH (DATA_WIDTH),
        .ALU_OP_WIDTH (ALU_OP_WIDTH)   
    ) alu_i (
        .operator_i (alu_operator),
        .operand_a_i(alu_operand_a),
        .operand_b_i(alu_operand_b),
        .result_o   (alu_result)
    );

    register_file #(
        .REG_COUNT(32),
        .DATA_WIDTH(DATA_WIDTH)
    ) register_file_i (
        .clk        (clk),
        .rst_n      (rst_n),
        .raddr_a_i  (rs1),
        .rdata_a_o  (rf_rp_a),
        .raddr_b_i  (rs2),
        .rdata_b_o  (rf_rp_b),          // connected to write port of memory
        .waddr_a_i  (rd),
        .wdata_a_i  (rf_wp_a),
        .we_a_i     (rf_we)
    );

    control_unit #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) control_unit_i (
        // Decoder
        .alu_op_a_mux_sel_i     (alu_op_a_mux_sel),
        .alu_op_b_mux_sel_i     (alu_op_b_mux_sel),
        .rs1_valid_i            (rs1_valid),
        .rs2_valid_i            (rs2_valid),
        .imm_valid_i            (imm_valid),   
        .imm_i                  (imm),  
        .rf_rp_a_i              (rf_rp_a),
        .rf_rp_b_i              (rf_rp_b),

        // ALU
        .alu_op_a_o             (alu_operand_a),
        .alu_op_b_o             (alu_operand_b),
        .alu_result_i           (alu_result),
        // register file
        .rf_wp_mux_sel_i        (rf_wp_mux_sel),
        .rf_wp_o                (rf_wp_a),
        // program counter
        .pc_i                   (instr_addr),
        .pc_plus4_i             (pc_plus4),

        // 
        .mem_rdata_i            (mem_rdata)
    );


    load_store_unit # (
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) load_store_unit_i (
        .clk(clk),
        
        // from decoder
        .addr_i         (alu_result),
        .we_i           (mem_we),               // 0 read access, 1 write access
        .data_req_i     (mem_data_req),          // ongoing request to the LSU
        .data_type_i    (mem_data_type),        // 00 byte, 01 halfword, 10 word
        .data_sign_ext_i(mem_data_sign_ext),    // load with sign extension

        // stores - from register file
        .wdata_i        (rf_rp_b),              // rs2 

        // loads - to register file
        .rdata_o        (mem_rdata)             // rd
    );

    assign instr_addr_o = instr_addr;


endmodule