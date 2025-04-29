/*
Copyright Jan-Eric Schäfrich 2025
Part of Toothless

Top Level FPGA Module
tested with Digilent Basys3

*/

module toothless_basys3(
// inputs/ouputs names must match .xdc file
    input  logic clk,                       // default 100 MHz, 10 ns period
    input  logic btnC,                       // use as reset

    // Input interfaces
    // input  logic [15:0] sw                  // switches
    // input  logic btnU, btnL, btnD, btnR     // buttons

    // Output interfaces
    output logic [15:0] led,                // 16 LEDs
    output logic [6:0] seg,                 // 7 segment digit: segments one hot encoded
    output logic [3:0] an                   // digit select, start with lowest, one hot encoded 
);

    logic rst_n;
    logic [31:0] instr_addr;
    logic [31:0] instruction;
    logic [31:0] x31;
    logic [31:0] curr_pc;

    logic [3:0] clk_div_counter = 0;
    logic [25:0] led_blink_counter = 0;
    logic clk_10MHz = 0;
    logic clk_1Hz = 0;
    logic [15:0] counter = 0;
    
    top top_i (
        .clk(clk_10MHz),
        .rst_n(rst_n),
        .instruction_i(instruction),
        .instr_addr_o(instr_addr)
    );

    // Instantiate the block RAM generated IP
    blk_mem_instructions instr_ro_i (
        .clka(clk_10MHz),                       // critical path of 92 ns
        .ena(1'b1),
        .addra(instr_addr[9:2]),                // word-aligned address
        .douta(instruction)
    );


    ///////////////////////////////////////////////////////////
    // clock conversions
    ///////////////////////////////////////////////////////////
    // reduce clock frequency to achieve closure
    // 100 MHz to 10 MHz clock divider
    always_ff @(posedge clk) begin
        if (clk_div_counter == 4'd4) begin      // toggle after 5 * 10 ns = 50 ns
            clk_10MHz <= ~clk_10MHz;
            clk_div_counter <= 0;
        end else begin
            clk_div_counter <= clk_div_counter + 1;
        end
    end

    always_ff @(posedge clk) begin
        if (led_blink_counter == 26'd50_000_000) begin      // count to 50 * 10^6 
            clk_1Hz <= ~clk_1Hz;
            led_blink_counter <= 0;
        end else begin
            led_blink_counter <= led_blink_counter + 1;
        end
    end

    always_ff @(posedge clk_1Hz) begin
        if (!rst_n) begin
            counter = 0;
        end else begin
            counter = counter + 1;
        end
    end

    /////////////////////////////////////////////////////////////////////////
    // connections
    /////////////////////////////////////////////////////////////////////////

    assign rst_n = !btnC;                   // convert reset from active high to active low
    assign curr_pc = instr_addr;
    assign x31 = top_i.if_id_ex_stage_i.register_file_i.reg_file[31];



    // assign led[15:0] = curr_pc[15:0];
    assign led[15:0] = counter;


    // use 7 segment display to show content of x31

    // use LEDs program counter?
endmodule