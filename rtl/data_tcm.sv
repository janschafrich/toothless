// Data Tightly Coupled Memory 
//
// little endian - used by x86, ARM, RISCV default
//  32bit integer:  A0B0C0D0
//  byte addresses: n+3 n+2 n+1 n


module data_tcm #(
    parameter DATA_WIDTH    = 32,
    parameter ADDR_WIDTH    = 32,
    parameter LAU           = 8,     // least addressable unit 8 bit, 1 byte
    parameter SIZE_LAU      = 1024,  // in LAU
    localparam N_BYTES      = DATA_WIDTH / LAU
) (
    input  logic clk,

    input  logic [DATA_WIDTH-1:0]   data_i,
    input  logic [ADDR_WIDTH-1:0]   addr_i,
    input  logic                    we_i,       // 0 read access, 1 write access
    input  logic [3:0]              be_i,       // byte enable, one hot encoded

    output logic [DATA_WIDTH-1:0]   data_o
);


    logic [LAU-1:0] mem [SIZE_LAU];

    always @ (posedge clk)
    begin
        if (we_i) begin
            for (int i = 0; i < N_BYTES; i++) begin
                if (be_i[i]) begin
                    mem[addr_i + i] <= data_i[ i*LAU +: LAU ];
                end
            end
        end      
    end

    assign data_o[7:0]   = mem[addr_i];
    assign data_o[15:8]  = mem[addr_i+1];
    assign data_o[23:16] = mem[addr_i+2];
    assign data_o[31:24] = mem[addr_i+3];

endmodule