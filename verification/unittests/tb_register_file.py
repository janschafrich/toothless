import cocotb
from cocotb.triggers import Timer
from cocotb.binary import BinaryRepresentation, BinaryValue

CLK_PRD = 10


async def generate_clock(dut):
    """ Generate clock signal """
    
    for cycle in range(100):
        dut.clk.value = 0
        await Timer(0.5*CLK_PRD, units='ns')  # suspend execution
        dut.clk.value = 1
        await Timer(0.5*CLK_PRD, units='ns')


@cocotb.test()
async def test_register_file(dut):

    await cocotb.start(generate_clock(dut))     # run in background/parallel

    
    dut.rst_n.value         = 0
    dut.raddr_a_i.value     = 0
    dut.raddr_b_i.value     = 0
    dut.waddr_a_i.value     = 0
    dut.rdata_a_o.value     = 0
    dut.rdata_b_o.value     = 0
    dut.wdata_a_i.value     = 0
    dut.we_a_i.value        = 0


    await Timer(3*CLK_PRD, units='ns')
    print("Test Reset")
    dut.rst_n.value = 1                              # release reset
    for i in range(32):
        dut.raddr_a_i.value     = BinaryValue(i, 5)
        dut.raddr_b_i.value     = BinaryValue(i, 5)
        await Timer(CLK_PRD, units='ns')
        assert dut.rdata_a_o.value == 0x0, f"Expected reg_file[{i}]=0, but got {hex(dut.rdata_a_o.value)}"
        assert dut.rdata_b_o.value == 0x0, f"Expected reg_file[{i}]=0, but got {hex(dut.rdata_b_o.value)}"

    print("Test Write and Read, single ported")
    dut.we_a_i.value = 1
    for i in range(32):
        dut.waddr_a_i.value     = BinaryValue(i, 5, bigEndian=False)
        dut.wdata_a_i.value     = BinaryValue(0xAAAA+i, 32, bigEndian=False)
        dut.raddr_a_i.value     = BinaryValue(i, 5, bigEndian=False) 
        await Timer(CLK_PRD, units='ns')
        if i == 0:
            assert dut.rdata_a_o.value == 0, f"Expected reg_file[{i}]=0, but got {hex(dut.rdata_a_o.value)}"
        else:
            assert dut.rdata_a_o.value == 0xAAAA+i, f"Expected reg_file[{i}]={hex(0xAAAA+i)}, but got {hex(dut.rdata_a_o.value)}"

    dut.we_a_i.value = 0

    print("Testing simultaneouse access to same address")
    dut.raddr_a_i.value         = BinaryValue(8, 5, bigEndian=False)
    dut.raddr_b_i.value         = BinaryValue(8, 5, bigEndian=False)
    await Timer(CLK_PRD, units='ns')
    assert dut.rdata_a_o.value == dut.rdata_a_o.value, f"Expected rdata_a_o == rdata_b_o, but got rdata_a_o={hex(dut.rdata_a_o.value)} and rdata_b_o={hex(dut.rdata_b_o.value)}"

    print("Testing asynchronous read, synchronous write")
    dut.raddr_a_i.value         = BinaryValue(8, 5, bigEndian=False)
    dut.we_a_i.value            = 1
    dut.waddr_a_i.value         = BinaryValue(8, 5, bigEndian=False)
    dut.wdata_a_i.value         = BinaryValue(0xFFFF, 32, bigEndian=False)
    assert dut.rdata_a_o.value == 0xAAAA+8, f"Expected reg_file[8]={hex(0xAAAA+8)}, but got reg_file[8]={hex(dut.rdata_a_o.value)}"
    await Timer(CLK_PRD, units='ns')
    assert dut.rdata_a_o.value == 0xFFFF, f"Expected reg_file[8]={hex(0xFFFF)}, but got reg_file[8]={hex(dut.rdata_a_o.value)}"

