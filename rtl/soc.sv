/*

Copyright Jan-Eric Schäfrich 2025
Part of Toothless

System on Chip Module. 
Connects the the core with externals like memories, peripherals, bus. 

*/



module soc #(
    parameter DATA_WIDTH  = 32,   
    parameter ADDR_WIDTH  = 32,
    parameter INSTR_WIDTH = 32
)(
    input  logic            clk,
    input  logic            rst_n
);

    logic [ADDR_WIDTH-1:0]  instr_addr;
    logic [INSTR_WIDTH-1:0] instruction;
    logic                   instr_invalid;

    logic [ADDR_WIDTH-1:0]  data_addr;
    logic                   data_we;
    logic [DATA_WIDTH-1:0]  rdata;
    logic [DATA_WIDTH-1:0]  wdata;
    logic [3:0]             data_be;


    core #(
        .DATA_WIDTH (DATA_WIDTH),   
        .ADDR_WIDTH (ADDR_WIDTH),
        .INSTR_WIDTH(INSTR_WIDTH)
    ) core_i (
        .clk            (clk),
        .rst_n          (rst_n),

        // instruction memory
        .instr_addr_o   (instr_addr),
        .instruction_i  (instruction),

        // to data cache / external memory
        .data_addr_o    (data_addr),
        .data_we_o      (data_we),      // 0 read access, 1 write access
        .data_type_o    (),             // 00 byte, 01 halfword, 10 word
        .rdata_i        (rdata),        // read from
        .data_be_o      (data_be),      // byte enable, one hot encoding
        .wdata_o        (wdata)         // write to 
    );


    // instruction cache
    icache # (
        .INSTR_WIDTH(INSTR_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH)
    ) icache_i (
        .clk    (clk),                      // critical path of 92 ns
        .addr_i (instr_addr),                // word-aligned address
        .data_o (instruction)
    );

    // data cache
    dcache #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dache_i (
        .clk    (clk),
        .data_i (wdata),                // store data in cache
        .addr_i (data_addr),
        .we_i   (data_we),              // 0 read access, 1 write access
        .be_i   (data_be),              // byte enable, one hot encoded
        .data_o (rdata)                 // read data from cache
    );

endmodule

