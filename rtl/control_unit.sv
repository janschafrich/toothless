/*
    Control Unit provides some glue logic between the modules
    controls the select signal for several muxes to route signals correctly between modules,
    depending on select signal provided by decoder


*/

module control_unit 
    import toothless_pkg::*;
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    // Decoder
    input  logic [1:0] alu_op_a_mux_sel_i,
    input  logic [1:0] alu_op_b_mux_sel_i,
    input  logic                  rs1_valid_i,
    input  logic                  rs2_valid_i,
    input  logic                  imm_valid_i,
    input  logic [ADDR_WIDTH-1:0] imm_i,

    input  logic [ADDR_WIDTH-1:0] rf_rp_a_i,
    input  logic [ADDR_WIDTH-1:0] rf_rp_b_i,

    // ALU
    output logic [DATA_WIDTH-1:0] alu_op_a_o,
    output logic [DATA_WIDTH-1:0] alu_op_b_o,
    input  logic [DATA_WIDTH-1:0] alu_result_i,
    // register file
    input  logic [1:0]            rf_wp_mux_sel_i,
    output logic [ADDR_WIDTH-1:0] rf_wp_o,
    // program counter
    input  logic [ADDR_WIDTH-1:0] pc_plus4_i,
    input  logic [ADDR_WIDTH-1:0] pc_i,

    // memory
    input  logic [DATA_WIDTH-1:0] mem_rdata_i
);


    always_comb begin : alu_op_a_mux
        unique case (alu_op_a_mux_sel_i)
            ALU_OP_A_SEL_REG:    alu_op_a_o = rs1_valid_i ? rf_rp_a_i : 0;
            ALU_OP_A_SEL_PC:     alu_op_a_o = pc_i;
            ALU_OP_A_SEL_IMM:    alu_op_a_o = imm_valid_i ? imm_i : 0;
            default:             alu_op_a_o = 0;
        endcase
    end


    always_comb begin : alu_op_b_mux
        unique case (alu_op_b_mux_sel_i)
            ALU_OP_B_SEL_REG:    alu_op_b_o = rs2_valid_i ? rf_rp_b_i : 0;
            ALU_OP_B_SEL_IMM:    alu_op_b_o = imm_valid_i ? imm_i : 0;
            default:            alu_op_b_o = 0;
        endcase
    end


    always_comb begin : rf_wp_mux
        unique case (rf_wp_mux_sel_i)
            RF_WP_A_SEL_ALU:     rf_wp_o = alu_result_i;
            RF_WP_A_SEL_PCPLUS4: rf_wp_o = pc_plus4_i;
            RF_WP_A_SEL_LSU:     rf_wp_o = mem_rdata_i;  
            default :            rf_wp_o = alu_result_i;
        endcase
    end
    

endmodule