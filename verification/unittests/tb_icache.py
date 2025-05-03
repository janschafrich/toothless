import cocotb
from utils import assert_response, set_current_instr, print_signal
from cocotb.triggers import Timer

CLK_PRD = 10
N_CYCLES = 1000


async def generate_clock(dut):
    """ Generate clock signal """
    
    for cycle in range(100):
        dut.clk.value = 0
        await Timer(0.5*CLK_PRD, units='ns')  # suspend execution
        dut.clk.value = 1
        await Timer(0.5*CLK_PRD, units='ns')



@cocotb.test()
async def test_instruction_rom(dut):

    await cocotb.start(generate_clock(dut))     # run in background/parallel

    for addr in range (0x10074, 0x10090):
        dut.addr_i.value = addr

        print(hex(dut.data_o.value))

        await Timer(CLK_PRD, units='ns')





