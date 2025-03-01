import cocotb
import numpy as np
import rv_instructions as rv
from utils import assert_response, set_current_instr
from constants_pkg import *
from cocotb.triggers import Timer

CLK_PRD = 10

async def generate_clock(dut):
    """ Generate clock signal """
    
    for cycle in range(100):
        dut.clk.value = 0
        await Timer(0.5*CLK_PRD, units='ns')  # suspend execution
        dut.clk.value = 1
        await Timer(0.5*CLK_PRD, units='ns')



async def test_decoding_stores(dut):

    print("Testing decoding of stores")

    offset  = 4
    rs2     = 2
    rs1     = 1

    for width in range(8):
        instr = rv.SType(offset, rs2, rs1, width)
        dut.instr_i.value = instr.get_binary()
        set_current_instr(instr)

        await Timer(CLK_PRD, units='ns')

        if width >= 3:
            assert_response(dut.instr_invalid_o, True)
        else:
            assert_response(dut.instr_invalid_o, False)
            assert_response(dut.data_type_o, width)
            
        # RF
        assert_response(dut.rs1_used_o, True)  
        assert_response(dut.rs2_used_o, True)
        assert_response(dut.rd_used_o, False)

        assert_response(dut.imm_valid_o, True)
        assert_response(dut.imm_o, np.int32(offset))
        # ALU
        assert_response(dut.alu_operator_o, ALU_ADD)
        assert_response(dut.alu_op_a_mux_sel_o, OP_A_REG)
        assert_response(dut.alu_op_b_mux_sel_o, OP_B_IMM)
        # controller
        assert_response(dut.ctrl_transfer_instr_o,CTRL_TRANSFER_SEL_NONE)
        assert_response(dut.rf_wp_mux_sel_o, RF_IN_ALU)
        assert_response(dut.alu_result_mux_sel_o, ALU_RESULT_SEL_LSU)
        # LSU
        assert_response(dut.data_req_o, True)
        assert_response(dut.data_we_o, True)




async def test_decoding_invalid_instructions(dut):
    print("Testing decoding of invalid instruction")

    dut.instr_i.value = 0

    await Timer(CLK_PRD, units='ns')

    assert_response(dut.instr_invalid_o, True)
    assert_response(dut.rs1_used_o, False)  
    assert_response(dut.rs2_used_o, False)
    assert_response(dut.rd_used_o, False)
    assert_response(dut.imm_valid_o, False)



async def test_decoding_itypes(dut):
    print("Testing decoding of I-Type instructions")

    rs1 = np.uint8(1)
    rd  = np.uint8(3)
    imm12 = -2

    print("Testing decoding of ADDI")

    instr = rv.IType(imm12, rs1, F3_ADD_SUB, rd)
    dut.instr_i.value = instr.get_binary()
    set_current_instr(instr)

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

    imm12 = 2

    instr = rv.IType(imm12, rs1, F3_ADD_SUB, rd)
    dut.instr_i.value = instr.get_binary()

    await Timer(CLK_PRD, units='ns')

    assert_response(dut.alu_operator_o, ALU_ADD)
    assert_response(dut.rs1_used_o, True)  
    assert_response(dut.rs2_used_o, False)
    assert_response(dut.rd_used_o, True)
    assert_response(dut.rs1_o, rs1)
    assert_response(dut.rd_o, rd)
    assert_response(dut.imm_valid_o, True)
    assert_response(dut.imm_o, np.int32(imm12))
    assert_response(dut.alu_op_a_mux_sel_o, OP_A_REG)
    assert_response(dut.alu_op_b_mux_sel_o, OP_B_IMM)
    assert_response(dut.instr_invalid_o, False)



async def test_decoding_rtypes(dut):
    print("Testing decoding of R-Type instructions")

    rs1 = np.int8(1)
    rs2 = np.int8(2)
    rd  = np.int8(3)

    print("Testing decoding of ADD")
    
    instr = rv.RType(rs2, rs1, F3_ADD_SUB, rd)
    dut.instr_i.value = instr.get_binary()
    set_current_instr(instr)

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



async def test_decoding_lui_auipc(dut):
    print("Testing decoding of U-Type LUI instruction")

    rd          = np.int8(3)
    imm20       = 1

    instr = rv.UType(imm20, rd, OPC_LUI)
    dut.instr_i.value = instr.get_binary()
    set_current_instr(instr)

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

    lui = rv.UType(imm20, rd, OPC_AUIPC)
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



async def test_decoding_branches(dut):
    print("Testing decoding of B-Type instruction")

    print("Testing aligned branch")

    rs1     = np.int8(1)
    rs2     = np.int8(2)
    offset = -4096

    b_types = [F3_BEQ, F3_BNE, F3_BLT, F3_BGE, F3_BLTU, F3_BGEU]
    alu_operators = [ALU_EQ, ALU_NE, ALU_SLT, ALU_GES, ALU_SLTU, ALU_GEU]

    for b_type, alu_op in zip(b_types, alu_operators):
        
        instr = rv.BType(offset, rs2, rs1, b_type)
        dut.instr_i.value = instr.get_binary()
        set_current_instr(instr)

        print("Branch %x" %(b_type) )

        await Timer(CLK_PRD, units='ns')

        assert_response(dut.instr_invalid_o, False)

        assert_response(dut.alu_operator_o, alu_op)
        assert_response(dut.rs1_used_o, True)  
        assert_response(dut.rs2_used_o, True)
        assert_response(dut.rd_used_o, False)
        assert_response(dut.imm_valid_o, True)
        assert_response(dut.imm_o, np.int32( (offset >> 1) << 1))       # the hardware does not consider the zeroth bit
        assert_response(dut.alu_op_a_mux_sel_o, OP_A_REG)
        assert_response(dut.alu_op_b_mux_sel_o, OP_B_REG)

    print("Testing unaligned branch")
    offset = 3
    b_instr = rv.BType(offset, rs2, rs1, F3_BLT)
    dut.instr_i.value = b_instr.get_binary()

    await Timer(CLK_PRD, units='ns')

    assert_response(dut.instr_invalid_o, False)

    assert_response(dut.alu_operator_o, ALU_SLT)
    assert_response(dut.rs1_used_o, True)  
    assert_response(dut.rs2_used_o, True)
    assert_response(dut.rd_used_o, False)
    assert_response(dut.imm_valid_o, True)
    assert_response(dut.imm_o, np.int32( (offset >> 1) << 1))       # the hardware does not consider the zeroth bit
    assert_response(dut.alu_op_a_mux_sel_o, OP_A_REG)
    assert_response(dut.alu_op_b_mux_sel_o, OP_B_REG)
    assert_response(dut.ctrl_transfer_instr_o,CTRL_TRANSFER_SEL_BRANCH)
    assert_response(dut.rf_wp_mux_sel_o, RF_IN_ALU)



async def test_decoding_jal_jalr(dut):
    print("Testing JAL")

    offsets = [0, 2, -2, 2^20, -2^20]   # offset + pc -> target
    dest = 1                            # link register to store pc + 4

    for offset in offsets:
        instr = rv.JalInstr(offset, dest)
        dut.instr_i.value = instr.get_binary()
        set_current_instr(instr)

        await Timer(CLK_PRD, units='ns')

        assert_response(dut.instr_invalid_o, False)

        assert_response(dut.alu_operator_o, ALU_ADD)
        assert_response(dut.rs1_used_o, False)  
        assert_response(dut.rs2_used_o, False)
        assert_response(dut.rd_used_o, True)
        assert_response(dut.imm_valid_o, True)
        assert_response(dut.imm_o, np.int32( (offset >> 1) << 1))       # the hardware does not consider the zeroth bit
        assert_response(dut.alu_op_a_mux_sel_o, OP_A_CURPC)
        assert_response(dut.alu_op_b_mux_sel_o, OP_B_IMM)
        assert_response(dut.ctrl_transfer_instr_o,CTRL_TRANSFER_SEL_JUMP)
        assert_response(dut.rf_wp_mux_sel_o, RF_IN_PC)


    print("Testing JALR")

    offsets = [0, 2, -2, 2^12, -2^12]   # offset + pc -> target
    rd = 1                            # link register to store pc + 4
    rs1  = 2

    for offset in offsets:
        instr = rv.JalrInstr(offset, rs1, rd)
        dut.instr_i.value = instr.get_binary()
        set_current_instr(instr)


        await Timer(CLK_PRD, units='ns')

        assert_response(dut.instr_invalid_o, False)

        assert_response(dut.alu_operator_o, ALU_ADD)
        assert_response(dut.rs1_used_o, True)  
        assert_response(dut.rs2_used_o, False)
        assert_response(dut.rd_used_o, True)
        assert_response(dut.imm_valid_o, True)
        assert_response(dut.imm_o, np.int32( (offset >> 1) << 1))       # the hardware does not consider the zeroth bit
        assert_response(dut.alu_op_a_mux_sel_o, OP_A_REG)
        assert_response(dut.alu_op_b_mux_sel_o, OP_B_IMM)
        assert_response(dut.ctrl_transfer_instr_o,CTRL_TRANSFER_SEL_JUMP)
        assert_response(dut.rf_wp_mux_sel_o, RF_IN_PC)



async def test_decoding_loads(dut):
    print("Testing decoding of loads")

    offset = 4
    rs1     = 1
    rd      = 2

    for width in range(4):
        instr = rv.LoadInstr(offset, rs1, width, rd)
        dut.instr_i.value = instr.get_binary()
        set_current_instr(instr)

        await Timer(CLK_PRD, units='ns')

        if width >= 3:
            assert_response(dut.instr_invalid_o, True)
        else:
            assert_response(dut.instr_invalid_o, False)
            assert_response(dut.data_type_o, width)
            
        # RF
        assert_response(dut.rs1_used_o, True)  
        assert_response(dut.rs2_used_o, False)
        assert_response(dut.rd_used_o, True)

        assert_response(dut.imm_valid_o, True)
        assert_response(dut.imm_o, np.int32(offset))
        # ALU
        assert_response(dut.alu_operator_o, ALU_ADD)
        assert_response(dut.alu_op_a_mux_sel_o, OP_A_REG)
        assert_response(dut.alu_op_b_mux_sel_o, OP_B_IMM)
        # controller
        assert_response(dut.ctrl_transfer_instr_o,CTRL_TRANSFER_SEL_NONE)
        assert_response(dut.rf_wp_mux_sel_o, RF_IN_ALU)
        assert_response(dut.alu_result_mux_sel_o, ALU_RESULT_SEL_LSU)
        # LSU
        assert_response(dut.data_req_o, True)
        assert_response(dut.data_we_o, False)



####################### TESTBENCH #####################################

@cocotb.test()
async def test_decoder(dut):

    await cocotb.start(generate_clock(dut))     # run in background/parallel

    
    dut.instr_i.value         = 0

    await Timer(3*CLK_PRD, units='ns')
    print("Test Reset")
    dut.rst_n.value = 1                              # release reset

    await test_decoding_invalid_instructions(dut)
    await test_decoding_itypes(dut)
    await test_decoding_rtypes(dut)
    await test_decoding_lui_auipc(dut)
    await test_decoding_branches(dut)
    await test_decoding_jal_jalr(dut)
    await test_decoding_stores(dut)
    await test_decoding_loads(dut)