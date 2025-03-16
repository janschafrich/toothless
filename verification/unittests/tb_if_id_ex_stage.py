import cocotb
from cocotb.triggers import Timer
import numpy as np
from utils import assert_response, set_current_instr, print_signal
import rv_instructions as rv


CLK_PRD = 10


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


    instr_list = [
                    [ rv.AddiInstr(1, 0, 1), 1],
                    [ rv.AddiInstr(2, 0, 2), 2],
                    [ rv.AddInstr(3, 1, 2), int('0011', 2)],
                    [ rv.SllInstr(4, 3, 2), int('1100', 2)],
                    [ rv.OrInstr(5, 4, 3), int('1111', 2)],
                    [ rv.AndInstr(6, 3, 5), int('0011', 2)],
                    [ rv.XorInstr(7, 3, 4), int('1111', 2)],
                    # [ rv.JalInstr(8, 0),   None],
                    [ rv.BeqInstr(5, 7, -12), None]
                ]

    
    print("Instruction Rom")
    for i, (instr, assertion) in enumerate(instr_list):
        print(f"            32'h{(i*4):x}:".ljust(10), "rom_data = 32'b" + instr.get_binary_string(True) + ";", "   //", instr.get_asm())

    print("Performing assertions")

    # for instr, assertion in zip(instr_list, assertion_list):
    for instr, assertion in instr_list:
        set_current_instr(instr)
        print(instr.get_binary_string(), instr.get_asm())

        # assert_response(dut.cur_instr_o, instr.get_binary_string(False) )
        assert_response(dut.instr_invalid_o, False)
        # assert_response(dut.result_o, assertion )

        await Timer(CLK_PRD, units='ns')




   