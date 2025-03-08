


module program_counter(
	input  logic clk,
	input  logic rst_n,

	input  logic [1:0]ctrl_transfer_instr_i,	 // from decoder

	// branches
	input  logic [31:0]offset_i,		// from decoder, calculate target as offset from control transfering instruction
	input  logic branch_tkn_i,			// comparison result from alu
	
	// jumps
	input  logic [31:0]tgt_addr_i,		// from ALU
	
	output logic [31:0]pc_o,
	output logic [31:0]pc_plus4_o		// link address for JALR, MUX to RD
);
	
	logic [31:0]	pc_next;
	
	always_ff @(posedge clk)
	begin	
		if (!rst_n) begin
			pc_next		<= 0;
		end 
		else begin

			case (ctrl_transfer_instr_i)
				
				CTRL_TRANS_SEL_JUMP: pc_o <= tgt_addr_i;

				CTRL_TRANS_SEL_BRANCH: if (branch_tkn_i) pc_o <= pc_o + offset_i;

				default: ;
			endcase
		end

	end

	assign pc_o 	= pc_next;
	assign pc_plus4_o = pc_o + 4;


endmodule