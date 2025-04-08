// Instruction ROM using OpenRAM SRAM
// Uses little endian byte order
// https://cornell-ece5745.github.io/ece5745-tut8-sram/

module instruction_rom #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
) (
    input logic clk,
    input logic [ADDR_WIDTH-1:0] addr_i,
    output logic [DATA_WIDTH-1:0] data_o
);
    
`ifdef SIMULATION

    localparam WORD_WIDTH = 8;
    localparam RAM_DEPTH = 1 << 20;

    logic [WORD_WIDTH-1:0] mem [0:RAM_DEPTH-1] /* verilator public_flat_rw */;
    
    assign data_o[7:0]   = mem[addr_i  ];
    assign data_o[15:8]  = mem[addr_i+1];
    assign data_o[23:16] = mem[addr_i+2];
    assign data_o[31:24] = mem[addr_i+3];
    

    initial begin

        $display("loading program into memory");
        $readmemh("verification/system/build/test_program.hex", mem);

        // for 32 bit words, TODO  respect offsets @10074
        /*
        integer i, file;
        logic [7:0] byte0, byte1, byte2, byte3;
        // Clear memory first
        for (i = 0; i < RAM_DEPTH; i = i + 1) 
            mem[i] = 32'h0;
            
        file = $fopen("verification/system/build/asm_test.hex", "r");
        i = 0;
        
        while (!$feof(file) && i < RAM_DEPTH) begin
            // Skip lines that start with comments
            if ($fscanf(file, "// %s", byte0) > 0) 
            begin
                $fgets(byte0, file); // Read to end of line
                continue;
            end
            
            // Read 4 bytes (assuming they exist)
            if ($fscanf(file, "%h %h %h %h", byte0, byte1, byte2, byte3) == 4) 
            begin
                // Combine bytes into a 32-bit word (little endian)
                mem[i] = {byte3, byte2, byte1, byte0};
                $display("loaded addr=%3h instr=%h %h %h %h", i, byte3, byte2, byte1, byte0);

                i = i + 1;
            end else 
            begin
                // If we can't read 4 bytes, read to end of line and continue
                $fgets(byte0, file);
            end
        end
        
        $fclose(file);
        */
    end

`else

    // Calculate SRAM address by word (32-bit) instead of by byte
    logic [7:0] sram_addr;
    // Control signals
    wire sram_csb = 1'b0;               // Chip select (active low) - always enabled
    wire sram_web = 1'b1;               // Write enable (active low) - always in read mode for ROM
    wire [3:0] sram_wmask = 4'b0000;    // Write mask - not used for ROM
    wire [31:0] sram_din = 32'h0;       // Data input - not used for ROM
    reg [31:0] sram_dout0;
    
    // Unused second port signals
    wire sram_csb1 = 1'b1;              // Disable second port
    wire [7:0] sram_addr1 = 8'b0;
    wire [31:0] sram_dout1;             // Unused output

    assign sram_addr = addr_i[9:2]; // 256 words (8-bit address)
    
    // Instantiate the SRAM macro
    sram_1rw1r_32_256_8_sky130 instruction_sram (
        // Port 0: RW port (used as read-only)
        .clk0(clk),
        .csb0(sram_csb),
        .web0(sram_web),
        .wmask0(sram_wmask),
        .addr0(sram_addr),
        .din0(sram_din),
        .dout0(sram_dout0),
        
        // Port 1: R port (unused)
        .clk1(clk),
        .csb1(sram_csb1),
        .addr1(sram_addr1),
        .dout1(sram_dout1)
    );

    // synchornize from negedge back to posedge
    always_ff @( posedge clk ) begin
        data_o <= sram_dout0;
    end

`endif


endmodule