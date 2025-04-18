import operator
import cocotb
from cocotb.triggers import Timer
from cocotb.binary import BinaryRepresentation, BinaryValue
from constants_pkg import *
import numpy as np

CLK_PRD = 10


@cocotb.test()
async def test_alu(dut):
    """ ALU test cases """

    dut.operator_i.value    = 0
    dut.operand_a_i.value   = 0
    dut.operand_b_i.value   = 0
    dut.result_o.value      = 0


    # testing alu operations

    # unsigned

    print("Testing signed and unsigned additions")
    dut.operator_i.value = ALU_ADDU

    opA_opB = [ [0, 0],
                [0, 1],
                [1, 0],
                [1, 1] 
                          ]

    for (operand_a, operand_b) in opA_opB:
        
        dut.operand_a_i.value = operand_a
        dut.operand_b_i.value = operand_b

        await Timer(CLK_PRD, units='ns')

        expected_result = operand_a + operand_b
        actual_result = int(dut.result_o.value)

        assert expected_result == actual_result, \
            f"Addition: {operand_a} + {operand_b} = {expected_result}, got {actual_result}"


    print("testing unsigned addition")
    dut.operator_i.value    = ALU_ADDU
    dut.operand_a_i.value   = BinaryValue(0, 32, bigEndian=False)
    dut.operand_b_i.value   = BinaryValue(1, 32, bigEndian=False)
    await Timer(CLK_PRD, units='ns')
    assert dut.result_o.value == 0x1, f"Expected result_o=0, got {hex(dut.result_o.value)}"

    dut.operand_a_i.value   = BinaryValue(0xffff_fffe, 32, bigEndian=False)
    dut.operand_b_i.value   = BinaryValue(1, 32, bigEndian=False)
    await Timer(CLK_PRD, units='ns')
    assert dut.result_o.value == 0xffff_ffff, f"Expected result_o=0, got {hex(dut.result_o.value)}"

    dut.operand_a_i.value   = BinaryValue(0xffff_fffe, 32, bigEndian=False)
    dut.operand_b_i.value   = BinaryValue(1, 32, bigEndian=False)
    await Timer(CLK_PRD, units='ns')
    assert dut.result_o.value == 0xffff_ffff, f"Expected result_o=0, got {hex(dut.result_o.value)}"

    print("Testing unsigned addition overflow handling")
    dut.operand_a_i.value   = BinaryValue(1, 32, bigEndian=False)
    dut.operand_b_i.value   = BinaryValue(0xffff_ffff, 32, bigEndian=False)
    await Timer(CLK_PRD, units='ns')
    assert dut.result_o.value == 0x0, f"Expected result_o=0, got {hex(dut.result_o.value)}"

    # signed
    print("Testing signed addition")
    dut.operator_i.value    = ALU_ADD

    opA_opB = [ [-2, -2],
                [2, -2],
                [-2, 2]
                          ]

    for (operand_a, operand_b) in opA_opB:
        
        dut.operand_a_i.value = operand_a
        dut.operand_b_i.value = operand_b

        await Timer(CLK_PRD, units='ns')

        expected_result = operand_a + operand_b
        actual_result = np.int32(int(dut.result_o.value))

        assert expected_result == actual_result, \
            f"Addition: {operand_a} + {operand_b} = {expected_result}, got {actual_result}"
    
    # subtraction
    print("Testing signed subtraction")
    dut.operator_i.value    = ALU_SUB

    opA_opB = [ [-2, -2],
                [2, -2],
                [-2, 2]
                          ]

    for (operand_a, operand_b) in opA_opB:
        
        dut.operand_a_i.value = operand_a
        dut.operand_b_i.value = operand_b

        await Timer(CLK_PRD, units='ns')

        expected_result = operand_a - operand_b
        actual_result = np.int32(int(dut.result_o.value))

        assert expected_result == actual_result, \
            f"Addition: {operand_a} - {operand_b} = {expected_result}, got {actual_result}"


    #logical
    print("Tesing logical operations")

    alu_opcodes = [ALU_AND, ALU_OR, ALU_XOR]                
    py_operators = [operator.and_, operator.or_, operator.xor]  # python functions
    operands_a = [0x0, 0xffff_ffff]
    operands_b = [0x0, 0xffff_ffff]

    for alu_opcode, py_operator in zip(alu_opcodes, py_operators):
        dut.operator_i.value    = alu_opcode
        
        for operand_a in operands_a:
            for operand_b in operands_b:
                dut.operand_a_i.value   = operand_a
                dut.operand_b_i.value   = operand_b
                
                await Timer(CLK_PRD, units='ns')

                expected_result = py_operator(operand_a,  operand_b)
                actual_result   = int(dut.result_o.value)

                assert expected_result == actual_result, \
                    f"ALU opcode {alu_opcode}: {hex(operand_a)} {py_operator.__name__} {hex(operand_b)} = {hex(expected_result)}, got {hex(actual_result)}"
                
    # shifts
    print("Tesing shift operations")

    dut.operator_i.value    = ALU_SRL
    operands_a          = [0x0, 0x4, -0x4]
    shift_amounts       = [0x5, 0x1,  0x1]
    expected_results    = [0x0, 0x2,  0x7ffffffe]
        
    for operand_a, shift_amount, expected_result in zip(operands_a, shift_amounts, expected_results):
            dut.operand_a_i.value   = operand_a
            dut.operand_b_i.value   = shift_amount
            
            await Timer(CLK_PRD, units='ns')

            expected_result = expected_result
            actual_result   = int(dut.result_o.value)

            assert expected_result == actual_result, \
                f"ALU opcode {alu_opcode}: {hex(operand_a)} >> {hex(shift_amount)} = {hex(expected_result)}, got {hex(actual_result)}"
            


    dut.operator_i.value    = ALU_SRA
    operands_a              = [0x0, 0x4, -0x4]
    shift_amounts           = [0x5, 0x1,  0x1]

    for operand_a, shift_amount in zip(operands_a, shift_amounts):
            dut.operand_a_i.value   = operand_a
            dut.operand_b_i.value   = shift_amount
            
            await Timer(CLK_PRD, units='ns')

            expected_result = operand_a >> shift_amount
            actual_result   = dut.result_o.value.signed_integer

            assert expected_result == actual_result, \
                 f"Shift {hex(operand_a)} >> {hex(shift_amount)} = {hex(expected_result)}, got {hex(actual_result)}"
            


    dut.operator_i.value    = ALU_SLL
    operands_a              = [0x0, 0x4, -0x4]
    shift_amounts           = [0x5, 0x1,  0x1]
    expected_results        = [0x0, 0x8,  0xfffffff8]

    for operand_a, shift_amount in zip(operands_a, shift_amounts):
            dut.operand_a_i.value   = operand_a
            dut.operand_b_i.value   = shift_amount
            
            await Timer(CLK_PRD, units='ns')

            expected_result = operand_a << shift_amount
            actual_result   = dut.result_o.value.signed_integer

            assert expected_result == actual_result, \
                f"Shift {hex(operand_a)} >> {hex(shift_amount)} = {hex(expected_result)}, got {hex(actual_result)}"


    # signed comparison
    print("Testing signed comparisons")
    operands_a = [0,1,-1]
    operands_b = [0,1,-1]
    alu_opcodes = [ALU_SLT, ALU_LES, ALU_GTS, ALU_GES, ALU_EQ, ALU_NE]
    py_operators = [operator.lt, operator.le, operator.gt, operator.ge, operator.eq, operator.ne]
  
    for alu_opcode, py_operator in zip(alu_opcodes, py_operators):
        dut.operator_i.value = alu_opcode
        
        for operand_a in operands_a:
            for operand_b in operands_b:
                dut.operand_a_i.value = operand_a
                dut.operand_b_i.value = operand_b

                await Timer(CLK_PRD, units='ns')
                
                expected_result = int(py_operator(operand_a, operand_b))
                actual_result   = int(dut.result_o.value)

                assert expected_result == actual_result, \
                    f"Comparison {hex(alu_opcode)}: {operand_a:x} {py_operator.__name__} {operand_b:x} = {bool(expected_result)}, got {bool(actual_result)}"

    # unsigned comparisons
    print("Testing unsigned comparisons")
    operands_a = [0,1]
    operands_b = [0,1]

    alu_opcodes = [ALU_SLTU, ALU_LEU, ALU_GTU, ALU_GEU]
    py_operators = [operator.lt, operator.le, operator.gt, operator.ge]

    for alu_opcode, py_operator in zip(alu_opcodes, py_operators):
        dut.operator_i.value = alu_opcode
        
        for operand_a in operands_a:
            for operand_b in operands_b:
                dut.operand_a_i.value = operand_a
                dut.operand_b_i.value = operand_b

                await Timer(CLK_PRD, units='ns')
                
                expected_result = bool(py_operator(operand_a, operand_b))
                actual_result   = bool(dut.result_o.value)

                assert expected_result == actual_result, \
                    f"Comparison {hex(alu_opcode)}: {operand_a} {py_operator.__name__} {operand_b} = {expected_result}, got {actual_result}"
                