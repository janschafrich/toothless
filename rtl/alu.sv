

import toothless_pkg::*;

module alu #(
    parameter DATA_WIDTH = 32,
    parameter ALU_OP_WIDTH = 5
)(
    input  logic                    clk,
    input  logic                    rst_n,

    input  alu_opcode_e             operator_i,
    input  logic [DATA_WIDTH-1:0]   operand_a_i,
    input  logic [DATA_WIDTH-1:0]   operand_b_i,

    output logic [DATA_WIDTH-1:0]   result_o
);

    // logic [DATA_WIDTH-1:0] result;

    always_comb begin

        result_o = 0;

        unique case (operator_i)

            ALU_ADD:  result_o = $signed(operand_a_i) + $signed(operand_b_i);
            ALU_ADDU: result_o = operand_a_i + operand_b_i;

            // logical
            ALU_AND: result_o = operand_a_i & operand_b_i;
            ALU_OR:  result_o = operand_a_i | operand_b_i;
            ALU_XOR: result_o = operand_a_i ^ operand_b_i;

            // shifts
            ALU_SRL: result_o = operand_a_i >>  operand_b_i;
            ALU_SRA: result_o = $signed(operand_a_i) >>> operand_b_i;
            ALU_SLL: result_o = operand_a_i <<  operand_b_i;

            //comparisons
            ALU_SLT: result_o[0] = $signed(operand_a_i) < $signed(operand_b_i);
            ALU_SLTU:result_o[0] = operand_a_i < operand_b_i;
            ALU_LES: result_o[0] = $signed(operand_a_i) <= $signed(operand_b_i);
            ALU_LEU: result_o[0] = operand_a_i <= operand_b_i;
            ALU_GTS: result_o[0] = $signed(operand_a_i) >  $signed(operand_b_i);
            ALU_GTU: result_o[0] = operand_a_i >  operand_b_i;
            ALU_GES: result_o[0] = $signed(operand_a_i) >= $signed(operand_b_i);
            ALU_GEU: result_o[0] = operand_a_i >= operand_b_i;
            ALU_EQ:  result_o[0] = operand_a_i == operand_b_i;
            ALU_NE:  result_o[0] = operand_a_i != operand_b_i;

            default: ; // suppress warning



        endcase

    end


endmodule