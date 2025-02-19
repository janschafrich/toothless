module register_file #(
	parameter ADDR_WIDTH = 5,
	parameter DATA_WIDTH = 32
)(
	input  logic clk, 
	input  logic rst_n,

	// Read port a
	input  logic [ADDR_WIDTH-1:0] raddr_a_i,
	output logic [DATA_WIDTH-1:0] rdata_a_o,

	// Read port b
	input  logic [ADDR_WIDTH-1:0] raddr_b_i,
	output logic [DATA_WIDTH-1:0] rdata_b_o,

	// Write port a
	input  logic [ADDR_WIDTH-1:0] waddr_a_i,
	input  logic [DATA_WIDTH-1:0] wdata_a_i,
	input  logic 			      we_a_i
);

	localparam N_WORDS = 2**(ADDR_WIDTH);

	logic [N_WORDS-1:0]reg_file[DATA_WIDTH-1:0];		// 2D array (Matrix): word size, register count


	always_ff @(posedge clk) begin
		if (!rst_n) 
		begin
			for (integer i = 1; i < N_WORDS; i++)		// skip x0, as this is always zero
			begin
				reg_file[i] <= 32'b0;					// initialize with zero
			end
		end 
		else
		begin
			if ( (we_a_i == 1) && (waddr_a_i != 0) ) 
			begin
				reg_file[waddr_a_i] <= wdata_a_i;
			end
		end
	end

	assign reg_file[0] = 32'b0;
	assign rdata_a_o = reg_file[raddr_a_i];
	assign rdata_b_o = reg_file[raddr_b_i];

endmodule