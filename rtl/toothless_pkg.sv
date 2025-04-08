/*
    Central file to define constants and special data types to be used by modules of the Toothless processor

*/


package toothless_pkg;

    parameter R_TYPE = 7'b0110011;
    parameter I_TYPE = 7'b0010011;
    parameter S_TYPE = 7'b0100011;
    parameter B_TYPE = 7'b1100011;
    parameter OPC_LOAD = 7'b0000011;
    parameter OPC_STORE = 7'b0100011;

    parameter OPC_LUI   = 7'b011_0111;
    parameter OPC_AUIPC = 7'b001_0111;

    parameter OPC_JAL   = 7'b110_1111;
    parameter OPC_JALR  = 7'b110_0111;

    parameter ALU_OP_WIDTH = 5;

    typedef enum logic [ALU_OP_WIDTH-1:0] {

        // arithmetic operations
        ALU_ADD     = 5'b0_0000,
        ALU_SUB     = 5'b0_0001,
        ALU_ADDU    = 5'b0_0010,
        ALU_SUBU    = 5'b0_0011,

        // logical 
        ALU_AND     = 5'b0_0100,
        ALU_OR      = 5'b0_0101,
        ALU_XOR     = 5'b0_0110,

        // shifts
        ALU_SRL     = 5'b0_1000,
        ALU_SRA     = 5'b0_1001,
        ALU_SLL     = 5'b0_1010,
        
        // comparisons
        ALU_SLT     = 5'b1_0000,
        ALU_SLTU    = 5'b1_0001,
        ALU_LES     = 5'b1_0010,
        ALU_LEU     = 5'b1_0011,
        ALU_GTS     = 5'b1_0100,
        ALU_GTU     = 5'b1_0101,
        ALU_GES     = 5'b1_0110,
        ALU_GEU     = 5'b1_0111,
        ALU_EQ      = 5'b1_1001,
        ALU_NE      = 5'b1_1010

    } alu_opcode_e;

    parameter ALU_OP_A_SEL_REG  = 2'b00;
    parameter ALU_OP_A_SEL_PC   = 2'b01;
    parameter ALU_OP_A_SEL_IMM  = 2'b10;
    parameter ALU_OP_A_SEL_ZERO = 2'b11;

    parameter ALU_OP_B_SEL_REG  = 2'b00;
    parameter ALU_OP_B_SEL_IMM  = 2'b10;

    parameter CTRL_TRANS_SEL_NONE    = 2'b00; 
    parameter CTRL_TRANS_SEL_JUMP    = 2'b01; 
    parameter CTRL_TRANS_SEL_BRANCH  = 2'b10; 

    parameter RF_WP_A_SEL_ALU       = 2'b00;
    parameter RF_WP_A_SEL_PCPLUS4   = 2'b01;
    parameter RF_WP_A_SEL_LSU       = 2'b10;

endpackage