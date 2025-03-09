


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
	
	// logic [31:0]	pc_next;
	
	always_ff @(posedge clk)
	begin	
		if (!rst_n) begin
			pc_o		<= 0;
		end 
		else begin

			case (ctrl_trans_instr_i)
				CTRL_TRANS_SEL_NONE: 	pc_o <= pc_o + 4;
				CTRL_TRANS_SEL_JUMP: 	pc_o <= tgt_addr_i;
				CTRL_TRANS_SEL_BRANCH: 	if (branch_tkn_i) pc_o <= pc_o + offset_i;
				default:				pc_o <= pc_o + 4;
			endcase
		end

	end

	// assign pc_o 	= pc_next;
	// point to the next instruction, used as return address by JAL and JALR
	assign pc_plus4_o = pc_o + 4;


endmodule