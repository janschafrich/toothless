
import toothless_pkg::*;

module program_counter #(
	INSTR_WIDTH = 32,
	ADDR_WIDTH 	= 32
)
(
	input  logic clk,
	input  logic rst_n,

	input  logic [1:0]ctrl_trans_instr_i,	 // from decoder

	// branches
	input  logic [31:0]offset_i,		// from decoder, calculate target as offset from control transfering instruction
	input  logic branch_tkn_i,			// comparison result from alu
	
	// jumps
	input  logic [ADDR_WIDTH-1:0]tgt_addr_i,		// from ALU
	
	output logic [INSTR_WIDTH-1:0]pc_o,
	output logic [INSTR_WIDTH-1:0]pc_plus4_o		// link address for JALR, MUX to RD
);
	
	
	always_ff @(posedge clk)
	begin	
		if (!rst_n) begin
`ifdef SIMULATION
			pc_o		<= 'h10074;				// from test.dump - start address of .text section
`else
			pc_o		<= 'h0;				
`endif
		end 
		else begin

			case (ctrl_trans_instr_i)
				CTRL_TRANS_SEL_NONE: 	pc_o <= pc_o + 4;
				CTRL_TRANS_SEL_JUMP: 	pc_o <= tgt_addr_i;
				CTRL_TRANS_SEL_BRANCH: 	pc_o <= branch_tkn_i ? pc_o + offset_i : pc_o + 4;
				default:				pc_o <= pc_o + 4;
			endcase
		end

	end

	// point to the next instruction, used as return address by JAL and JALR
	assign pc_plus4_o = pc_o + 4;


endmodule