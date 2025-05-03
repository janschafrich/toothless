/*
Copyright Jan-Eric Schäfrich 2025
Part of Toothless

Contains all pipeline stages, processor components of Toothless.
Interfaces with external memories. 

Is meant to be standalone to facilitate deployment on a FPGA. 


*/

module core #(
    parameter DATA_WIDTH  = 32,   
    parameter ADDR_WIDTH  = 32,
    parameter INSTR_WIDTH = 32
) (
    input  logic                    clk,
    input  logic                    rst_n,

    // instruction memory
    input  logic [INSTR_WIDTH-1:0]  instruction_i,
    output logic [ADDR_WIDTH-1:0]   instr_addr_o,

    // to data cache / external memory
    output logic [ADDR_WIDTH-1:0]   data_addr_o,
    output logic                    data_we_o,      // 0 read access, 1 write access
    output logic [1:0]              data_type_o,    // 00 byte, 01 halfword, 10 word
    input  logic [DATA_WIDTH-1:0]   rdata_i,        // read from
    output logic [3:0]              data_be_o,      // byte enable, one hot encoding
    output logic [DATA_WIDTH-1:0]   wdata_o         // write to 
);

    // single stage processor
    if_id_ex_stage #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .INSTR_WIDTH(INSTR_WIDTH)
    ) if_id_ex_stage_i (
        .clk                (clk),
        .rst_n              (rst_n),
        .instr_invalid_o    (),

        // instruction memory
        .instruction_i      (instruction_i),
        .instr_addr_o       (instr_addr_o),

        // to data cache / external memory
        .data_addr_o        (data_addr_o),
        .data_we_o          (data_we_o),      // 0 read access, 1 write access
        .data_type_o        (data_type_o),    // 00 byte, 01 halfword, 10 word
        .rdata_i            (rdata_i),        // read from
        .data_be_o          (data_be_o),      // byte enable, one hot encoding
        .wdata_o            (wdata_o)         // write to 
    );

endmodule