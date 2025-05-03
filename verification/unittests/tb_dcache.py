import cocotb
from utils import assert_response, set_current_instr, print_signal
from cocotb.triggers import Timer

CLK_PRD = 10


async def generate_clock(dut):
    """ Generate clock signal """
    
    for cycle in range(100):
        dut.clk.value = 0
        await Timer(0.5*CLK_PRD, units='ns')  # suspend execution
        dut.clk.value = 1
        await Timer(0.5*CLK_PRD, units='ns')



@cocotb.test()
async def test_data_cache(dut):

    await cocotb.start(generate_clock(dut))     # run in background/parallel

    values = [1, 2, 512, 65536]
    bes = [0b0001, 0b0001, 0b0011, 0b1111]
    # masks = [0xFF, 0xFF, 0xFFFF, 0xFFFF_FFFF]
    addrs = [0, 1, 3, 12]

    for value, addr, be in zip(values, addrs, bes):
        dut.data_i.value        = value
        print_signal(dut.data_i)
        dut.addr_i.value        = addr
        print_signal(dut.addr_i)
        dut.we_i.value          = 1
        dut.be_i.value          = be

        await Timer(CLK_PRD, units='ns')


    # read    
    print("reading")
    dut.we_i.value          = 0 

    for value, addr in zip(values, addrs):
        dut.addr_i.value    = addr

        await Timer(CLK_PRD, units='ns')
        print_signal(dut.data_o)
        # assert_response(dut.data_o , value)





