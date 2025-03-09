import cocotb
from cocotb.triggers import Timer
import numpy as np
from utils import assert_response, set_current_instr, print_signal
import rv_instructions as rv


CLK_PRD = 10

def generate_instruction_list_bin():
    instr_list = []
    instr_list.append( rv.AddiInstr(1, 0,  int('10101', 2)) )
    instr_list.append( rv.AddiInstr(1, 0,  int('111111111100', 2) ) )
    instr_list.append( rv.AndiInstr(1, 31, int('00110', 2)) )
    instr_list.append( rv.OriInstr (1, 31, int('00110', 2)) )
    instr_list.append( rv.XoriInstr(5, 31, int('11111', 2)) )


    return instr_list

async def generate_clock(dut):
    """ Generate clock signal """
    
    for cycle in range(100):
        dut.clk.value = 0
        await Timer(0.5*CLK_PRD, units='ns')  # suspend execution
        dut.clk.value = 1
        await Timer(0.5*CLK_PRD, units='ns')



@cocotb.test()
async def test_if_id_ex_stage(dut):

    await cocotb.start(generate_clock(dut))     # run in background/parallel
    dut.rst_n.value = 0                             # release reset

    await Timer(3*CLK_PRD, units='ns')
    dut.rst_n.value = 1                              # release reset
    print("Reset released")

    # instr_list = generate_instruction_list_bin() 

    instr_list = []
    instr_list.append( rv.AddiInstr(1, 0,  int('10101', 2)) )
    instr_list.append( rv.AddiInstr(1, 0,  int('1111_1111_1111', 2) ) )
    instr_list.append( rv.SltiInstr(1, 2, 31) )
    instr_list.append( rv.SltiuInstr(1, 31, 2) )
    instr_list.append( rv.XoriInstr(1, 31, int('11111', 2)) )
    instr_list.append( rv.OriInstr (1, 31, int('00110', 2)) )
    instr_list.append( rv.AndiInstr(1, 31, int('00110', 2)) )
    instr_list.append( rv.SlliInstr(1, 31, 2 ) )
    instr_list.append( rv.AddInstr(1, 31, 2 ) )

    assertion_list = [int('10101', 2),
                        -1,
                        1,
                        0,
                        0,
                        31,
                        int('00110', 2),
                        int('111_1100', 2)]
    
    print("Instruction Rom")
    for i, instr in enumerate(instr_list):
        print(f"32'h{(i*4):x}:".ljust(10), "rom_data = 32'b" + instr.get_binary_string(True) + ";", "   //", instr.get_asm())

    print("Performing assertions")

    for instr, assertion in zip(instr_list, assertion_list):
        set_current_instr(instr)
        print(instr.get_binary_string(), instr.get_asm())

        assert_response(dut.cur_instr_o, instr.get_binary_string(False) )
        assert_response(dut.instr_invalid_o, False)
        assert_response(dut.result_o, assertion )

        await Timer(CLK_PRD, units='ns')




   