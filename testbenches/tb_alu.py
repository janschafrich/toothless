import operator
import cocotb
from cocotb.triggers import Timer
from cocotb.binary import BinaryRepresentation, BinaryValue

CLK_PRD = 10

# ALU operations
# arithmetic operations
ALU_ADD     = int('0_0000', 2)
ALU_SUB     = int('0_0001', 2)
ALU_ADDU    = int('0_0010', 2)
ALU_SUBU    = int('0_0011', 2)

# logical 
ALU_AND     = int('0_0100', 2)
ALU_OR      = int('0_0101', 2)
ALU_XOR     = int('0_0110', 2)

# # shifts
ALU_SRL     = int('0_1000', 2)
ALU_SRA     = int('0_1001', 2)
ALU_SLL     = int('0_1010', 2)

# # comparisons
ALU_SLT     = int('1_0000', 2)
ALU_SLTU    = int('1_0001', 2)
ALU_LES     = int('1_0010', 2)
ALU_LEU     = int('1_0011', 2)
ALU_GTS     = int('1_0100', 2)
ALU_GTU     = int('1_0101', 2)
ALU_GES     = int('1_0110', 2)
ALU_GEU     = int('1_0111', 2)
ALU_EQ      = int('1_1001', 2)
ALU_NE      = int('1_1010', 2)



async def generate_clock(dut):
    """ Generate clock signal """
    
    for cycle in range(100):
        dut.clk.value = 0
        await Timer(0.5*CLK_PRD, units='ns')  # suspend execution
        dut.clk.value = 1
        await Timer(0.5*CLK_PRD, units='ns')


@cocotb.test()
async def test_alu(dut):
    """ ALU test cases """

    await cocotb.start(generate_clock(dut))     # run in background/parallel

    dut.rst_n.value         = 0
    dut.operator_i.value    = 0
    dut.operand_a_i.value   = 0
    dut.operand_b_i.value   = 0
    dut.result_o.value      = 0



    print("Test reset")
    
    await Timer(3*CLK_PRD, units='ns')
    dut.rst_n.value = 1                              # release reset
    assert dut.result_o.value == 0, f"Expected result_o=0, got {hex(dut.result_o.value)}"

    # testing alu operations

    # unsigned
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
    print("Test signed addition")
    dut.operator_i.value    = ALU_ADD

    dut.operand_a_i.value   = -2
    dut.operand_b_i.value   = -2
    await Timer(CLK_PRD, units='ns')
    assert dut.result_o.value.signed_integer == -4, f"Expected result_o=-4, got {hex(dut.result_o.value)}"

    dut.operand_a_i.value   = 2
    dut.operand_b_i.value   = -2
    await Timer(CLK_PRD, units='ns')
    assert dut.result_o.value.signed_integer == 0, f"Expected result_o=-4, got {hex(dut.result_o.value)}"

    dut.operand_a_i.value   = -2
    dut.operand_b_i.value   = 2
    await Timer(CLK_PRD, units='ns')
    assert dut.result_o.value.signed_integer == 0, f"Expected result_o=-4, got {hex(dut.result_o.value)}"


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


    # # comparison
    # print("Testing signed comparisons")
    # operands_a = [0,1,-1]
    # operands_b = [0,1,-1]
    # alu_opcodes = [ALU_LT, ALU_LES, ALU_GTS, ALU_GES, ALU_EQ, ALU_NE]
    # py_operators = [operator.lt, operator.le, operator.gt, operator.ge, operator.eq, operator.ne]
  
    # for alu_opcode, py_operator in zip(alu_opcodes, py_operators):
    #     dut.operator_i.value = alu_opcode
        
    #     for operand_a in operands_a:
    #         for operand_b in operands_b:
    #             # dut.operand_a_i.value = BinaryValue(operand_a, 32, bigEndian=False)
    #             # dut.operand_b_i.value = BinaryValue(operand_b, 32, bigEndian=False)
    #             dut.operand_b_i.value.signed_integer = operand_a
    #             dut.operand_b_i.value.signed_integer = operand_b

    #             await Timer(CLK_PRD, units='ns')
                
    #             expected_result = int(py_operator(operand_a, operand_b))
    #             actual_result   = int(dut.result_o.value)

    #             assert expected_result == actual_result, \
    #                 f"Comparison {hex(alu_opcode)}: {hex(operand_a)} {py_operator.__name__} {hex(operand_b)} = {expected_result}, got {actual_result}"

    # comparison SLTU
    print("Testing unsigned comparisons")
    operands_a = [0,1]
    operands_b = [0,1]

    alu_opcodes = [ALU_LEU, ALU_GTU, ALU_GEU]
    py_operators = [operator.le, operator.gt, operator.ge]

    for alu_opcode, py_operator in zip(alu_opcodes, py_operators):
        dut.operator_i.value = alu_opcode
        
        for operand_a in operands_a:
            for operand_b in operands_b:
                # dut.operand_a_i.value = BinaryValue(operand_a, 32, bigEndian=False)
                # dut.operand_b_i.value = BinaryValue(operand_b, 32, bigEndian=False)
                dut.operand_a_i.value = operand_a
                dut.operand_b_i.value = operand_b

                await Timer(CLK_PRD, units='ns')
                
                expected_result = int(py_operator(operand_a, operand_b))
                actual_result   = int(dut.result_o.value)

                assert expected_result == actual_result, \
                    f"Comparison {hex(alu_opcode)}: {hex(operand_a)} {py_operator.__name__} {hex(operand_b)} = {expected_result}, got {actual_result}"
                
    print("Testing SLTU")
    dut.operator_i.value = ALU_SLTU
    operands_b = [0, 1, 100]
    expected_results = [0, 1, 1]

    for operand_b, expected_result in zip(operands_b, expected_results):
        dut.operand_b_i.value = operand_b

        await Timer(CLK_PRD, units='ns')

        actual_result = int(dut.result_o.value)

        assert expected_result == actual_result, \
            f"ALU OPCODE {hex(alu_opcode)}: {hex(operand_b)} != 0 = {expected_result}, got {actual_result}"

