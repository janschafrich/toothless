import toothless_pkg::*;

module decoder #(
    parameter DATA_WIDTH = 32
) (
    input  logic clk,
    input  logic rst_n,

    input  logic [31:0] instr_i,

    // ALU signals
    output alu_opcode_e alu_operator_o,              // select operation to be performed by ALU

    output logic [DATA_WIDTH-1:0]   imm_o,           // sign/zero extended immediate value from current instruction
    output logic                    imm_valid_o,       // whether current instruction has an immediate value

    // register file signals
    output logic        rs1_used_o,
    output logic        rs2_used_o,
    output logic        rd_used_o,                 // need register write
    output logic [4:0]  rs1_o,
    output logic [4:0]  rs2_o, 
    output logic [4:0]  rd_o,

    // controller signals
    output logic [1:0]  rf_wp_mux_sel_o,            // write source: 00 ALU, 01 PC
    output logic [1:0]  alu_op_a_mux_sel_o,          // operand a selection: reg, PC, immediate or zero
    output logic [1:0]  alu_op_b_mux_sel_o,           // operand b selection: reg or immediate


    // program counter signals
    output logic [1:0]  ctrl_trans_instr_o,      // current instr is control transfer, 00 none, 01 jump, 10 branch

    // load store unit signals
    output logic        data_req_o,                   // request data memory access
    output logic [1:0]  data_type_o,                // word, half word, byte for LSU
    output logic        data_we_o,                    // write or read to memory
    output logic        data_sign_ext_o,            // whether or not data from memory is to be sign extended

    output logic instr_invalid_o                    // everything not part of RV32I is invalid
);


always_comb begin: instruction_decoder

    imm_valid_o = 0;
    imm_o       = 0;

    instr_invalid_o = 1'b0;

    rs1_used_o = 1'b0;
    rs2_used_o = 1'b0;
    rd_used_o  = 1'b0;

    rs1_o       = instr_i[19:15];
    rs2_o       = instr_i[24:20];
    rd_o        = instr_i[11:7];

    rf_wp_mux_sel_o         = RF_WP_A_SEL_ALU;        // ALU
    ctrl_trans_instr_o   = CTRL_TRANS_SEL_NONE;        // none

    data_req_o  = 1'b0;
    data_type_o = 2'b10;                    // word
    data_we_o     = 1'b0;                   // load

    unique case (instr_i[6:0])

        R_TYPE: begin

            alu_op_a_mux_sel_o = ALU_OP_A_SEL_REG;
            alu_op_b_mux_sel_o = ALU_OP_B_SEL_REG;

            rs1_used_o  = 1'b1;
            rs2_used_o  = 1'b1;
            rd_used_o   = 1'b1;

            unique case (instr_i[14:12])
                3'b000: begin           // add / sub
                    if (instr_i[30]) 
                    begin
                        alu_operator_o = ALU_SUB;
                    end else 
                    begin
                        alu_operator_o = ALU_ADD;
                    end
                end

                3'b001: begin           // sll
                    alu_operator_o = ALU_SLL;  
                end

                3'b010: begin           // slt
                    alu_operator_o = ALU_SLT;  
                    
                end

                3'b011: begin           // sltu
                    alu_operator_o = ALU_SLTU;  
                    
                end

                3'b100: begin           // xor
                    alu_operator_o = ALU_XOR;  
                end

                3'b101: begin           // srl / sra
                    if (instr_i[30]) 
                    begin
                        alu_operator_o = ALU_SRA;
                    end else 
                    begin
                        alu_operator_o = ALU_SRL;
                    end
                end

                3'b110: begin           // or
                    alu_operator_o = ALU_OR;  
                end

                3'b111: begin           // and
                    alu_operator_o = ALU_AND;  
                end

                default: begin
                    instr_invalid_o = 1'b1;
                end

            endcase
        end

        I_TYPE: begin

            rs1_used_o  = 1'b1;
            rd_used_o   = 1'b1;

            imm_valid_o = 1'b1;
            imm_o       = { {20{instr_i[31]}} , instr_i[31:20] };    // sign extended 12 bit value

            alu_op_a_mux_sel_o = ALU_OP_A_SEL_REG;
            alu_op_b_mux_sel_o = ALU_OP_B_SEL_IMM;
            
            unique case (instr_i[14:12])

                3'b000: begin        // addi
                    alu_operator_o = ALU_ADD;
                end

                3'b010: begin        // slti
                    alu_operator_o = ALU_SLT;
                end

                3'b011: begin        // sltiu
                    alu_operator_o = ALU_SLTU;
                end

                3'b111: begin        // andi
                    alu_operator_o = ALU_AND;
                end
                
                3'b110: begin        // ori
                    alu_operator_o = ALU_OR;
                end

                3'b100: begin        // xori
                    alu_operator_o = ALU_XOR;
                end

                3'b001: begin        // slli
                    alu_operator_o = ALU_SLL;
                    imm_o    = { {27{1'b0}}, instr_i[24:20]};    // zero extented shift amount
                end

                3'b101: begin       // srai   
                    
                    imm_o    = { {27{1'b0}}, instr_i[24:20]};    // zero extented shift amount
                    
                    if (instr_i[30]) 
                    begin
                        alu_operator_o = ALU_SRA;

                    end
                    else           // srli
                    begin
                        alu_operator_o = ALU_SRL;
                    end
                end


                default: begin
                    instr_invalid_o = 1'b1;
                end

            endcase
        end

        OPC_LUI, OPC_AUIPC: begin

            rd_used_o   = 1'b1;

            imm_valid_o = 1'b1;
            imm_o       = { instr_i[31:12], {12{1'b0}} };

            alu_operator_o = ALU_ADD;
                
            unique case (instr_i[5])

                1'b1: begin        // load upper immediate
                    alu_op_a_mux_sel_o = ALU_OP_A_SEL_REG;      // zero register
                    alu_op_b_mux_sel_o = ALU_OP_B_SEL_IMM;
                end

                1'b0: begin        // add upper immediate to pc
                    alu_op_a_mux_sel_o = ALU_OP_A_SEL_PC;
                    alu_op_b_mux_sel_o = ALU_OP_B_SEL_IMM;
                end

                default: begin
                    instr_invalid_o = 1'b1;
                end

            endcase
        end

        B_TYPE: begin

            rs1_used_o  = 1'b1;
            rs2_used_o  = 1'b1;

            alu_op_a_mux_sel_o  = ALU_OP_A_SEL_REG;
            alu_op_b_mux_sel_o  = ALU_OP_B_SEL_REG;

            ctrl_trans_instr_o = CTRL_TRANS_SEL_BRANCH;

            // offset, to program counter ?
            imm_valid_o = 1'b1;
            imm_o[31:12]= { 20{instr_i[31]} };
            imm_o[11]   = instr_i[7];
            imm_o[10:5] = instr_i[30:25];
            imm_o[4:1]  = instr_i[11:8];
            imm_o[0]    = 1'b0;

            unique case (instr_i[14:12])
                3'b000:     alu_operator_o  = ALU_EQ;   // BEQ
                3'b001:     alu_operator_o  = ALU_NE;   // BNE
                3'b100:     alu_operator_o  = ALU_SLT;  // BLT
                3'b101:     alu_operator_o  = ALU_GES;  // BGE
                3'b110:     alu_operator_o  = ALU_SLTU; // BLTU
                3'b111:     alu_operator_o  = ALU_GEU;  // BGEU
                default:    instr_invalid_o = 1'b1;

            endcase
        end

        OPC_JAL, OPC_JALR: begin

            alu_op_b_mux_sel_o      = ALU_OP_B_SEL_IMM;

            ctrl_trans_instr_o      = CTRL_TRANS_SEL_JUMP;
            rf_wp_mux_sel_o         = RF_WP_A_SEL_PCPLUS4;              // MUX select pc_plus4
            alu_operator_o          = ALU_ADD;                          // jump target
            rd_used_o               = 1'b1;
            imm_valid_o             = 1'b1;

            if (instr_i[3])     // JAL
            begin
                alu_op_a_mux_sel_o  = ALU_OP_A_SEL_PC;
                imm_o[31:20]    = { 12{instr_i[31]} };
                imm_o[19:12]    = instr_i[19:12];
                imm_o[11]       = instr_i[20];
                imm_o[10:1]     = instr_i[30:21];
                imm_o[0]        = 1'b0;
            end
            else                // JALR
            begin
                rs1_used_o          = 1'b1;
                alu_op_a_mux_sel_o  = ALU_OP_A_SEL_REG;
                imm_o               = { {21{instr_i[31]}} , instr_i[30:20]};
            end
        end


        OPC_LOAD: begin

            alu_operator_o          = ALU_ADD;
            alu_op_a_mux_sel_o      = ALU_OP_A_SEL_REG;     // rs1 / base
            alu_op_b_mux_sel_o      = ALU_OP_B_SEL_IMM;     // offset
            rf_wp_mux_sel_o         = RF_WP_A_SEL_LSU;

            rs1_used_o  = 1'b1;                 // base address
            rd_used_o   = 1'b1;                 // memory value destination

            data_req_o  = 1'b1;

            unique case (instr_i[13:12])
                2'b00:  data_type_o = 2'b00;        // byte
                2'b01:  data_type_o = 2'b01;        // halfword
                2'b10:  data_type_o = 2'b10;        // word
                2'b11:  instr_invalid_o = 1'b1;
            endcase

            imm_valid_o = 1'b1;

            if (instr_i[14]) imm_o = { {20{1'b0}}, instr_i[31:20]};       // zero extend
            else           imm_o = { { 21{instr_i[31]} }, instr_i[30:20]};  // sign extend

        end


        OPC_STORE: begin
            
            alu_operator_o          = ALU_ADD;
            alu_op_a_mux_sel_o      = ALU_OP_A_SEL_REG;
            alu_op_b_mux_sel_o      = ALU_OP_B_SEL_IMM;

            rs1_used_o          = 1'b1;
            rs2_used_o          = 1'b1;

            imm_valid_o = 1'b1;
            imm_o       = { {21{instr_i[31]}}, instr_i[30:25], instr_i[11:7] } ;    // sign extend

            data_req_o      = 1'b1;
            data_we_o       = 1'b1;

            unique case (instr_i[14:12])
                3'b000:     data_type_o = 2'b00;
                3'b001:     data_type_o = 2'b01;
                3'b010:     data_type_o = 2'b10;
                default:    instr_invalid_o = 1'b1;
            endcase
        end





        default: begin
            instr_invalid_o = 1;
        end
    endcase

end

    
endmodule