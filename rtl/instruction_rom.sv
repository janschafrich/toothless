// read only instruction memory
module instruction_rom(
	input  logic        clk_i, 
    input  logic        rst_ni,
	input  logic [31:0] addr_i,	
	output logic [31:0] instr_o
	);

	logic [31:0]rom_data;		

	always_comb begin
		case(addr_i)	// lookup table - instructions from Steven Hoover RISC-V tutorial https://github.com/stevehoover/LF-Building-a-RISC-V-CPU-Core.git
			//                        imm         rs1 funct3 rd   opcode
			32'h0:	rom_data = 32'b0000_0001_0101_00000_000_00001_0010011;		// (I) ADDI x1, x0, 10101
			32'h4:	rom_data = 32'b0000_0000_0111_00000_000_00010_0010011;		// (I) ADDI x2, x0, 111
			32'h8:	rom_data = 32'b1111_1111_1100_00000_000_00011_0010011;		// (I) ADDI x3, x0, 111111111100
			32'hc:	rom_data = 32'b0000_0101_1100_00001_111_00101_0010011;		// (I) ANDI x5, x1, 1011100
			32'h10:	rom_data = 32'b0000_0001_0101_00101_100_00101_0010011;		// (I) XORI x5, x5, 10101
			32'h14:	rom_data = 32'b0000_0101_1100_00001_110_00110_0010011;		// (I) ORI x6, x1, 1011100
			32'h18:	rom_data = 32'b0000_0101_1100_00110_100_00110_0010011;		// (I) XORI x6, x6, 1011100
			32'h1c:	rom_data = 32'b0000_0000_0111_00001_000_00111_0010011;		// (I) ADDI x7, x1, 111
			32'h20:	rom_data = 32'b0000_0001_1101_00111_100_00111_0010011;		// (I) XORI x7, x7, 11101
			32'h24:	rom_data = 32'b0000_0000_0110_00001_001_01000_0010011;		// (I) SLLI x8, x1, 110
			32'h28:	rom_data = 32'b0101_0100_0001_01000_100_01000_0010011;		// (I) XORI x8, x8, 10101000001
			32'h2c:	rom_data = 32'b0000_0000_0010_00001_101_01001_0010011;		// (I) SRLI x9, x1, 10
			32'h30:	rom_data = 32'b0000_0000_0100_01001_100_01001_0010011;		// (I) XORI x9, x9, 100
			32'h34:	rom_data = 32'b0000_0000_0010_0000_1111_0101_0011_0011;		// Cycle 13 (R) AND r10, x1, x2
			32'h38:	rom_data = 32'b0000_0000_0000_0000_0000_1001_1011_0111;		// Cycle 31 (U) LUI x19, 0
			32'h3c:	rom_data = 32'b0000_0000_0100_0000_0000_1100_1110_1111;		// Cycle 44 (J) JAL x25, 10
			32'h40:	rom_data = 32'b0000_0000_0001_0001_0010_0000_1010_0011;		// Cycle 51 (S) SW x2, x1, 1
		endcase
    end


    always_ff @(posedge clk_i) begin 
		if(!rst_ni)
			instr_o <= 32'b0;
		else 
			instr_o <= rom_data;
	end
    
endmodule