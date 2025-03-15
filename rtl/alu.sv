

import toothless_pkg::*;

module alu #(
    parameter DATA_WIDTH = 32,
    parameter ALU_OP_WIDTH = 5
)(
    input  alu_opcode_e             operator_i,
    input  logic [DATA_WIDTH-1:0]   operand_a_i,
    input  logic [DATA_WIDTH-1:0]   operand_b_i,

    output logic [DATA_WIDTH-1:0]   result_o
);

    logic                  operand_b_negate;        // flag
    logic [DATA_WIDTH-1:0] operand_b_twos_compl;    // negative representation of operand b
    logic [DATA_WIDTH-1:0] adder_op_b;              // processed operand b used for add/sub
    logic [DATA_WIDTH-1:0] adder_result;
    
    ///////////////////////////
    // adder 
    ///////////////////////////
    assign operand_b_negate = ( operator_i == ALU_SUB ) ||
                              ( operator_i == ALU_SUBU );

    assign operand_b_twos_compl = (~operand_b_i) + 1;

    // MUX
    assign adder_op_b = operand_b_negate ? operand_b_twos_compl : operand_b_i;

    assign adder_result = $signed(operand_a_i) + $signed(adder_op_b);


    ////////////////////////////////////////
    // rest of ALU and result MUX
    ///////////////////////////////////////
    always_comb begin

        result_o = 0;

        unique case (operator_i)

            ALU_ADD, ALU_ADDU, ALU_SUB, ALU_SUBU:  result_o = adder_result;

            // logical
            ALU_AND:            result_o = operand_a_i & operand_b_i;
            ALU_OR:             result_o = operand_a_i | operand_b_i;
            ALU_XOR:            result_o = operand_a_i ^ operand_b_i;

            // shifts
            ALU_SRL:            result_o = operand_a_i >>  operand_b_i;
            ALU_SRA:            result_o = $signed(operand_a_i) >>> operand_b_i;
            ALU_SLL:            result_o = operand_a_i <<  operand_b_i;

            //comparisons
            ALU_SLT, ALU_SLTU:  result_o[0] = $signed(operand_a_i) < $signed(operand_b_i);
            ALU_LES, ALU_LEU:   result_o[0] = $signed(operand_a_i) <= $signed(operand_b_i);
            ALU_GTS, ALU_GTU:   result_o[0] = $signed(operand_a_i) >  $signed(operand_b_i);
            ALU_GES, ALU_GEU:   result_o[0] = $signed(operand_a_i) >= $signed(operand_b_i);
            ALU_EQ:             result_o[0] = operand_a_i == operand_b_i;
            ALU_NE:             result_o[0] = operand_a_i != operand_b_i;

            default: result_o = 0; 

        endcase
    end


endmodule