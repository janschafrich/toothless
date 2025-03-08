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
async def test_load_store_unit(dut):

    await cocotb.start(generate_clock(dut))     # run in background/parallel

    values = [1, 2, 512, 65536, 2, 512]
    data_types = [0, 0, 1, 2, 0, 1]

    print("testing loads wo sign extension")
    print("testing stores")
    addr = 0
    dut.data_req_i.value = 1

    for value, data_type in zip(values, data_types):
        
        dut.addr_i.value        = addr
        dut.wdata_i.value        = value
        print_signal(dut.addr_i)
        print_signal(dut.wdata_i)
        dut.we_i.value          = 1
        dut.data_type_i.value   = data_type
        await Timer(CLK_PRD, units='ns')
         
        addr = addr + 2^data_type           # use data type as offset 


    print("testing loads") 
    dut.data_sign_ext_i.value   = 0
    dut.data_req_i.value        = 1
    dut.we_i.value              = 0 
    addr = 0

    for value, data_type in zip(values, data_types):
        dut.addr_i.value        = addr
        dut.data_type_i.value   = data_type

        await Timer(CLK_PRD, units='ns')
        print_signal(dut.rdata_ext_o)

        addr = addr + 2^data_type
        assert_response(dut.rdata_ext_o , value)



    print("testing w sign extension")

    values = [-1, -2, -512, -65536, 65536, -2, -512]
    data_types = [0, 0, 1, 2, 2, 0, 1]

    print("testing stores")

    addr = 0
    dut.data_req_i.value = 1

    for value, data_type in zip(values, data_types):
        
        dut.addr_i.value        = addr
        dut.wdata_i.value        = value
        print_signal(dut.addr_i)
        print_signal(dut.wdata_i)
        print()
        dut.we_i.value          = 1
        dut.data_type_i.value   = data_type
        await Timer(CLK_PRD, units='ns')
         
        addr = addr + 2^data_type

    print("testing loads")

    dut.data_sign_ext_i.value   = 1
    dut.data_req_i.value        = 1
    dut.we_i.value              = 0 
    addr = 0

    for value, data_type in zip(values, data_types):
        dut.addr_i.value        = addr
        dut.data_type_i.value   = data_type

        await Timer(CLK_PRD, units='ns')
        print_signal(dut.rdata_ext_o)

        addr = addr + 2^data_type
        assert_response(dut.rdata_ext_o , value)





