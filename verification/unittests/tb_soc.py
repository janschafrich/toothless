import cocotb
from cocotb.triggers import Timer


CLK_PRD = 10

N_CYCLES = 1000


async def generate_clock(dut):
    """ Generate clock signal """
    
    for cycle in range(N_CYCLES):
        dut.clk.value = 1
        await Timer(0.5*CLK_PRD, units='ns')  # suspend execution
        dut.clk.value = 0
        await Timer(0.5*CLK_PRD, units='ns')


@cocotb.test()
async def test_riscv_cpu(dut):
    dut._log.info("Starting RISC-V CPU test")

    await cocotb.start(generate_clock(dut))     # run in background/parallel


    # Reset
    dut.rst_n.value = 0                             # active low reset                     

    await Timer(3*CLK_PRD, units='ns')
    print("Test Reset")
    dut.rst_n.value = 1                              # release reset



    # wait for some amount of clock cycles
    print("Beginning instruction execution")
    for cycle in range(N_CYCLES):  
        await Timer(CLK_PRD, units="ns")

    # Check the result in register x31 (success or fail)
    assert dut.core_i.if_id_ex_stage_i.register_file_i.reg_file[31].value == 0xBEEF, "Test failed!"
