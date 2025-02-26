import toothless_pkg::*;

module decoder #(
    parameter DATA_WIDTH = 32
) (
    input  logic clk,
    input  logic rst_n,

    input  logic [31:0] instr_i,

    // ALU signals
    output alu_opcode_e alu_operator_o,              // select operation to be performed by ALU
    output logic [1:0]  alu_op_a_mux_sel_o,          // operand a selection: reg, PC, immediate or zero
    output logic [1:0]  alu_op_b_mux_sel_o,           // operand b selection: reg or immediate


    output logic [DATA_WIDTH-1:0]   imm_o,           // sign/zero extended immediate value from current instruction
    output logic                    imm_valid_o,       // whether current instruction has an immediate value

    // register idea
    output logic        rs1_used_o,
    output logic        rs2_used_o,
    output logic        rd_used_o,                 // need register write
    output logic [4:0]  rs1_o,
    output logic [4:0]  rs2_o, 
    output logic [4:0]  rd_o,

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

    unique case (instr_i[6:0])

        R_TYPE: begin

            alu_op_a_mux_sel_o = OP_A_REG;
            alu_op_b_mux_sel_o = OP_B_REG;

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

            alu_op_a_mux_sel_o = OP_A_REG;
            alu_op_b_mux_sel_o = OP_B_IMM;
            
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
                    imm_o    = { {27{1'b0}}, instr_i[4:0]};    // zero extented shift amount
                end

                3'b101: begin       // srai   
                    
                    imm_o    = { {27{1'b0}}, instr_i[4:0]};    // zero extented shift amount
                    
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

        LUI, AUIPC: begin

            rd_used_o   = 1'b1;

            imm_valid_o = 1'b1;
            imm_o       = { instr_i[31:12], {12{1'b0}} };

            alu_operator_o = ALU_ADD;
                
            unique case (instr_i[5])

                1'b1: begin        // load upper immediate
                    alu_op_a_mux_sel_o = OP_A_REG;      // zero register
                    alu_op_b_mux_sel_o = OP_B_IMM;
                end

                1'b0: begin        // add upper immediate to pc
                    alu_op_a_mux_sel_o = OP_A_CURPC;
                    alu_op_b_mux_sel_o = OP_B_IMM;
                end

                default: begin
                    instr_invalid_o = 1'b1;
                end

            endcase
        end

        B_TYPE: begin

            rs1_used_o  = 1'b1;
            rs2_used_o  = 1'b1;

            imm_valid_o = 1'b1;
            imm_o[31:13]= {19{1'b0}};
            imm_o[12]   = instr_i[31];
            imm_o[11]   = instr_i[7];
            imm_o[10:5] = instr_i[30:25];
            imm_o[4:1]  = instr_i[11:8];
            imm_o[0]    = 1'b0;

            unique case (instr_i[14:12])

                3'b000: begin       // BEQ

                end

                3'b001: begin       // BNE

                end

                3'b100: begin       // BLT

                end

                3'b101: begin       // BGE

                end

                3'b110: begin       // BLTU

                end

                3'b111: begin       // BGEU

                end

                default: begin
                    instr_invalid_o = 1'b1;
                end

            endcase
        end



        default: begin
            instr_invalid_o = 1;
        end
    endcase

end

    
endmodule