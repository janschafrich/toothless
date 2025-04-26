// Data Tightly Coupled Memory 
//
// little endian - used by x86, ARM, RISCV default
//  32bit integer:  A0B0C0D0
//  byte addresses: n+3 n+2 n+1 n

module data_tcm #(
    parameter DATA_WIDTH    = 32,
    parameter ADDR_WIDTH    = 32
) (
    input  logic clk,

    input  logic [DATA_WIDTH-1:0]   data_i,
    input  logic [ADDR_WIDTH-1:0]   addr_i,
    input  logic                    we_i,       // 0 read access, 1 write access
    input  logic [3:0]              be_i,       // byte enable, one hot encoded

    output logic [DATA_WIDTH-1:0]   data_o
);

`ifdef SIMULATION

    localparam LAU           = 8;     // least addressable unit 8 bit, 1 byte
    localparam SIZE_LAU      = 1024;  // in LAU
    localparam N_BYTES      = DATA_WIDTH / LAU;

    logic [LAU-1:0] mem [0:SIZE_LAU];

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

`else

   // Calculate SRAM address by word (32-bit) instead of by byte
    logic [7:0] sram_addr;

    // first port
    wire sram_csb = 1'b0;                // Chip select (active low) - always enabled
    wire sram_web = ~we_i;               // Write enable (active low)
    reg [31:0] sram_dout0;
    
    // second port - unused
    wire sram_csb1 = 1'b1;              // Chip select active low - always disabled
    wire [7:0] sram_addr1 = 8'b0;       // unused
    wire [31:0] sram_dout1;             // Unused output
    
    assign sram_addr = addr_i[9:2]; // 256 words (8-bit address)
    
    
    // Instantiate the SRAM macro
    sram_1rw1r_32_256_8_sky130 data_sram (
        // Port 0: RW port (used as read-only)
        .clk0(clk),
        .csb0(sram_csb),
        .web0(sram_web),
        .wmask0(be_i),                  
        .addr0(sram_addr),
        .din0(data_i),
        .dout0(sram_dout0),
        
        // Port 1: R port (unused)
        .clk1(clk),
        .csb1(sram_csb1),
        .addr1(sram_addr1),
        .dout1(sram_dout1)
    );

    // synchronize from negedge back to posedge
    always_ff @( posedge clk ) begin
        data_o <= sram_dout0;
    end

`endif



endmodule