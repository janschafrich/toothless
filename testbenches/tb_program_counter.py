import cocotb
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
async def test_program_counter(dut):

    await cocotb.start(generate_clock(dut))     # run in background/parallel

    
    dut.rst_n.value        = 0
    dut.branch_tkn_i.value  = 0
    dut.is_jalr_i.value     = 0
    dut.tgt_addr_i.value    = 0

    await Timer(3*CLK_PRD, units='ns')
    print("Test Reset")
    dut.rst_n.value = 1                              # release reset
    assert dut.pc_o.value == 0x0, f"Expected pc_o=0x0, but got {hex(dut.pc_o.value)}"

    print("Test Sequential Code execution")
    await Timer(3*CLK_PRD, units='ns')       
    assert dut.pc_o.value == 3*4, f"Expected pc_o={hex(3*4)}, but got {hex(dut.pc_o.value)}"       

    print("Test Branch Taken")
    dut.branch_tkn_i.value  = 1
    dut.tgt_addr_i.value    = 0x100
    await Timer(CLK_PRD, units='ns')
    assert dut.pc_o.value == 0x100, f"Expected pc_o=0x100, but got {hex(dut.pc_o.value)}"

    print("Test continue sequential execution after branch")
    dut.branch_tkn_i.value  = 0
    await Timer(2*CLK_PRD, units='ns')       
    assert dut.pc_o.value == (0x100 + 2*4), f"Expected pc_o={hex(0x100 + 2*4)}, but got {hex(dut.pc_o.value)}" 

    print("Test Jump and link register")
