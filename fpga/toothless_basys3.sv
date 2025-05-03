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

    logic           rst_n;
    logic           clk_10MHz = 0;
    
    logic [31:0]    instr_addr;
    logic [31:0]    instruction;
    logic           instr_invalid;

    logic [31:0]    data_addr;
    logic           data_we;
    logic [31:0]    rdata;
    logic [31:0]    wdata;
    logic [3:0]     data_be;
    
    core #(
        .DATA_WIDTH (32),   
        .ADDR_WIDTH (32),
        .INSTR_WIDTH(32)
    ) core_i (
        .clk            (clk_10MHz),
        .rst_n          (rst_n),

        // instruction memory
        .instr_addr_o   (instr_addr),
        .instruction_i  (instruction),

        // to data cache / external memory
        .data_addr_o    (data_addr),
        .data_we_o      (data_we),      // 0 read access, 1 write access
        .data_type_o    (),             // 00 byte, 01 halfword, 10 word
        .rdata_i        (rdata),        // read from
        .data_be_o      (data_be),      // byte enable, one hot encoding
        .wdata_o        (wdata)         // write to 
    );

    // Instantiate the block RAM generated IP
    blk_mem_instructions instr_rom_i (
        .clka   (clk_10MHz),                      // critical path of 92 ns
        .ena    (1'b1),
        .addra  (instr_addr[9:2]),                // word-aligned address
        .douta  (instruction)
    );


    // Instantiate block RAM generated IP for data memory
    blk_mem_data data_mem_i (
        .clka   (clk_10MHz),
        .ena    (1'b1),
        .wea    (data_be[3:0] & data_we),
        .addra  (data_addr),
        .dina   (wdata),
        .douta  (rdata)
    );


    ///////////////////////////////////////////////////////////
    // clock conversions
    ///////////////////////////////////////////////////////////
    // reduce clock frequency to achieve closure
    // 100 MHz to 10 MHz clock divider

    logic [3:0] clk_div_counter = 0;
    
    always_ff @(posedge clk) begin
        if (clk_div_counter == 4'd4) begin      // toggle after 5 * 10 ns = 50 ns
            clk_10MHz <= ~clk_10MHz;
            clk_div_counter <= 0;
        end else begin
            clk_div_counter <= clk_div_counter + 1;
        end
    end

    logic        clk_1Hz = 0;
    logic [25:0] led_blink_counter = 0;
    
    always_ff @(posedge clk) begin
        if (led_blink_counter == 26'd50_000_000) begin      // count to 50 * 10^6 
            clk_1Hz <= ~clk_1Hz;
            led_blink_counter <= 0;
        end else begin
            led_blink_counter <= led_blink_counter + 1;
        end
    end

    logic [15:0] counter = 0;

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

    logic [31:0] x31;
    logic [31:0] curr_pc;

    assign rst_n = !btnC;                   // convert reset from active high to active low
    assign curr_pc = instr_addr;
    assign x31 = core_i.if_id_ex_stage_i.register_file_i.reg_file[31];



    // assign led[15:0] = curr_pc[15:0];
    assign led[15:0] = counter;


    // use 7 segment display to show content of x31

    // use LEDs program counter?
endmodule