// Instruction ROM using OpenRAM SRAM
// Uses little endian byte order
module instruction_rom #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter LAU = 8 // least addressable unit 8 bit, 1 byte
)
(
    input logic clk,
    input logic [ADDR_WIDTH-1:0] addr_i,
    output logic [DATA_WIDTH-1:0] data_o
);
    // Calculate SRAM address by word (32-bit) instead of by byte
    wire [7:0] sram_addr = addr_i[9:2]; // 256 words (8-bit address)
    
    // Control signals
    wire sram_csb = 1'b0; // Chip select (active low) - always enabled
    wire sram_web = 1'b1; // Write enable (active low) - always in read mode for ROM
    wire [3:0] sram_wmask = 4'b0000; // Write mask - not used for ROM
    wire [31:0] sram_din = 32'h0; // Data input - not used for ROM
    
    // Unused second port signals
    wire sram_csb1 = 1'b1; // Disable second port
    wire [7:0] sram_addr1 = 8'b0;
    wire [31:0] sram_dout1; // Unused output
    
    // Instantiate the SRAM macro
    sram_1rw1r_32_256_8_sky130 instruction_sram (
        // Port 0: RW port (used as read-only)
        .clk0(clk),
        .csb0(sram_csb),
        .web0(sram_web),
        .wmask0(sram_wmask),
        .addr0(sram_addr),
        .din0(sram_din),
        .dout0(data_o),
        
        // Port 1: R port (unused)
        .clk1(clk),
        .csb1(sram_csb1),
        .addr1(sram_addr1),
        .dout1(sram_dout1)
    );
    

    // Memory initialization
    // For simulation only - will be ignored during synthesis
    // macro "VERILATOR" is defined automatically during compilation
    `ifdef SIMULATION
    initial begin
        $readmemh("verification/system/build/asm_test.hex", instruction_sram.mem);
    end
    `endif
    
endmodule