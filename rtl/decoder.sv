

module decoder #() (
    input  logic clk_i,
    input  logic rst_ni,

    input  logic [31:0] instr_i,

    // ALU signals
    output alu_opcode_e alu_operator_o,                 // select operation to be performed by ALU
    output logic [1:0]  alu_op_a_mux_sel_o,           // operand a selection: reg, PC, immediate or zero
    output logic [1:0]  alu_op_b_mux_sel_o           // operand b selection: reg or immediate
);


    logic invalid_instruction;

always_comb begin: instruction_decoder

    in



    unique case (instr_i[6:0])

        R_TYPE: begin

            alu_op_a_mux_sel_o = OP_A_REG;
            alu_op_b_mux_sel_o = OP_B_REG;

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

                3'b011: begin           // and
                    alu_operator_o = ALU_AND;  
                end

                default: begin
                    invalid_instruction = 1'b0;
                end

            endcase
        end

    endcase

end

    
endmodule