


module program_counter(
	input  logic clk_i,
	input  logic rst_ni,
	input  logic branch_tkn_i, 
    input  logic is_jalr_i,
	input  logic [31:0]tgt_addr_i,
	output logic [31:0]pc_o
);
	
	always_ff @(posedge clk_i)
	begin	
		if (!rst_ni) begin
			pc_o 	<= 0;			
		end 
		else begin
			if(branch_tkn_i || is_jalr_i) 
				pc_o <= tgt_addr_i;
			else
				pc_o <= pc_o + 4;
		end
	end
endmodule