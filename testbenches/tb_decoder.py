import cocotb
import numpy as np
import rv_instructions as rv
from utils import assert_response
from constants_pkg import *
from cocotb.triggers import Timer
# from cocotb.binary import BinaryRepresentation, BinaryValue

CLK_PRD = 10

async def generate_clock(dut):
    """ Generate clock signal """
    
    for cycle in range(100):
        dut.clk.value = 0
        await Timer(0.5*CLK_PRD, units='ns')  # suspend execution
        dut.clk.value = 1
        await Timer(0.5*CLK_PRD, units='ns')


@cocotb.test()
async def test_decoder(dut):

    await cocotb.start(generate_clock(dut))     # run in background/parallel

    
    dut.instr_i.value         = 0

    await Timer(3*CLK_PRD, units='ns')
    print("Test Reset")
    dut.rst_n.value = 1                              # release reset



    print("Testing decoding of invalid instruction")

    dut.instr_i.value = 0

    await Timer(CLK_PRD, units='ns')

    assert_response(dut.instr_invalid_o, True)
    assert_response(dut.rs1_used_o, False)  
    assert_response(dut.rs2_used_o, False)
    assert_response(dut.rd_used_o, False)
    assert_response(dut.imm_valid_o, False)
   

    print("Testing decoding of I-Type instructions")

    rs1 = 1
    rd  = 3
    imm12 = 1

    print("Testing decoding of ADDI")

    add_instr = rv.IType(imm12, rs1, F3_ADD_SUB, rd)
    dut.instr_i.value = add_instr.get_binary()

    await Timer(CLK_PRD, units='ns')

    assert_response(dut.alu_operator_o, ALU_ADD)
    assert_response(dut.rs1_used_o, True)  
    assert_response(dut.rs2_used_o, False)
    assert_response(dut.rd_used_o, True)
    assert_response(dut.rs1_o, rs1)
    assert_response(dut.rd_o, rd)
    assert_response(dut.imm_valid_o, True)
    assert_response(dut.imm_o, imm12)
    assert_response(dut.alu_op_a_mux_sel_o, OP_A_REG)
    assert_response(dut.alu_op_b_mux_sel_o, OP_B_IMM)
    assert_response(dut.instr_invalid_o, False)


    print("Testing sign extension of imm")

    imm12 = -2

    add_instr = rv.IType(imm12, rs1, F3_ADD_SUB, rd)
    dut.instr_i.value = add_instr.get_binary()

    await Timer(CLK_PRD, units='ns')

    assert_response(dut.alu_operator_o, ALU_ADD)
    assert_response(dut.rs1_used_o, True)  
    assert_response(dut.rs2_used_o, False)
    assert_response(dut.rd_used_o, True)
    assert_response(dut.rs1_o, rs1)
    assert_response(dut.rd_o, rd)
    assert_response(dut.imm_valid_o, True)
    assert_response(dut.imm_o, np.int32(imm12))
    # assert_response(dut.imm_o, np.int32(np.binary_repr(imm12, 12)))
    assert_response(dut.alu_op_a_mux_sel_o, OP_A_REG)
    assert_response(dut.alu_op_b_mux_sel_o, OP_B_IMM)
    assert_response(dut.instr_invalid_o, False)


    print("Testing decoding of R-Type instructions")

    rs2 = 2

    print("Testing decoding of ADD")
    
    add_instr = rv.RType(2, 1, F3_ADD_SUB, 3)
    dut.instr_i.value = add_instr.get_binary()

    await Timer(CLK_PRD, units='ns')

    assert_response(dut.alu_operator_o, ALU_ADD)
    assert_response(dut.rs1_used_o, True)  
    assert_response(dut.rs2_used_o, True)
    assert_response(dut.rd_used_o, True)
    assert_response(dut.rs1_o, rs1)
    assert_response(dut.rs2_o, rs2)
    assert_response(dut.rd_o, rd)
    assert_response(dut.imm_valid_o, False)
    assert_response(dut.alu_op_a_mux_sel_o, OP_A_REG)
    assert_response(dut.alu_op_b_mux_sel_o, OP_B_REG)
    assert_response(dut.instr_invalid_o, False)

    
    print("Testing decoding of U-Type LUI instruction")

    imm20       = 1

    lui = rv.UType(imm20, rd, LUI)
    dut.instr_i.value = lui.get_binary()

    await Timer(CLK_PRD, units='ns')

    assert_response(dut.instr_invalid_o, False)

    assert_response(dut.alu_operator_o, ALU_ADD)
    assert_response(dut.rs1_used_o, False)  
    assert_response(dut.rs2_used_o, False)
    assert_response(dut.rd_used_o, True)
    assert_response(dut.imm_valid_o, True)
    assert_response(dut.imm_o, np.int32(imm20 << 12))
    assert_response(dut.alu_op_a_mux_sel_o, OP_A_REG)
    assert_response(dut.alu_op_b_mux_sel_o, OP_B_IMM)


    print("Testing decoding of U-Type AUIPC instruction")

    lui = rv.UType(imm20, rd, AUIPC)
    dut.instr_i.value = lui.get_binary()

    await Timer(CLK_PRD, units='ns')

    assert_response(dut.instr_invalid_o, False)

    assert_response(dut.alu_operator_o, ALU_ADD)
    assert_response(dut.rs1_used_o, False)  
    assert_response(dut.rs2_used_o, False)
    assert_response(dut.rd_used_o, True)
    assert_response(dut.imm_valid_o, True)
    assert_response(dut.imm_o, np.int32(imm20 << 12))
    assert_response(dut.alu_op_a_mux_sel_o, OP_A_CURPC)
    assert_response(dut.alu_op_b_mux_sel_o, OP_B_IMM)


    # print("Testing decoding of B-Type instruction")

    # offset = 128
    # b_instr = rv.BType(offset, rs2, rs1, F3_BEQ)
    # dut.instr_i.value = b_instr.get_binary()

    # await Timer(CLK_PRD, units='ns')

    # assert_response(dut.instr_invalid_o, False)

    # # assert_response(dut.alu_operator_o, ALU_ADD)
    # assert_response(dut.rs1_used_o, True)  
    # assert_response(dut.rs2_used_o, True)
    # assert_response(dut.rd_used_o, False)
    # assert_response(dut.imm_valid_o, True)
    # assert_response(dut.imm_o, np.int32(imm20 << 12))
    # # assert_response(dut.alu_op_a_mux_sel_o, OP_A_)
    # # assert_response(dut.alu_op_b_mux_sel_o, OP_B_IMM)