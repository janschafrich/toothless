// Instruction Memory - read only
//
// little endian - used by x86, ARM, RISCV default
//  32bit integer:  A0B0C0D0
//  byte addresses: n+3 n+2 n+1 n


module instruction_mem #(
    parameter DATA_WIDTH    = 32,
    parameter ADDR_WIDTH    = 32,
    parameter LAU           = 8,     // least addressable unit 8 bit, 1 byte
    parameter SIZE_LAU      = 2**20,  // in LAU
    localparam N_BYTES      = DATA_WIDTH / LAU
)
(
    input  logic [ADDR_WIDTH-1:0]   addr_i,
    output logic [DATA_WIDTH-1:0]   data_o
);
    
    logic [LAU-1:0] mem [0:SIZE_LAU-1] /* verilator public_flat_rw */;

    assign data_o[7:0]   = mem[addr_i];
    assign data_o[15:8]  = mem[addr_i+1];
    assign data_o[23:16] = mem[addr_i+2];
    assign data_o[31:24] = mem[addr_i+3];

    // load machine code to execute during simulation
    initial begin
        $readmemh("test.hex", mem);
    end

endmodule