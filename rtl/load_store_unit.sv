// Load Store Unit
// data memory for now as tightly coupled memory
// little endian
//  32bit integer:  A0B0C0D0
//  byte addresses: n+3 n+2 n+1 n


module load_store_unit #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    input  logic    clk,
    // input  logic    rst_n,
    
    // from decoder
    // input  logic [ADDR_WIDTH-1:0]   addr_i,
    input  logic                    we_i,               // 0 read access, 1 write access
    input  logic                    data_req_i,         // ongoing request to the LSU
    input  logic [1:0]              data_type_i,        // 00 byte, 01 halfword, 10 word
    input  logic                    data_sign_ext_i,    // load with sign extension

    // from register file
    input  logic [DATA_WIDTH-1:0]   wdata_i,

    // to register file
    output logic [DATA_WIDTH-1:0]   rdata_o,

    // to data cache / external memory
    input  logic [DATA_WIDTH-1:0]  rdata_i,     // read from
    output logic [3:0]             data_be_o,   // byte enable, one hot encoding
    output logic [DATA_WIDTH-1:0]  wdata_o      // write to 
);
    
    logic [DATA_WIDTH-1:0]  rdata_ext;
    
    

    // data_tcm #()data_tcm_i (
    //     .clk    (clk),
    //     .data_i (wdata),
    //     .addr_i (addr_i),
    //     .be_i   (data_be),
    //     .we_i   (we_i),
    //     .data_o (rdata)             // to sign/zero extension
    // );

    assign wdata_o = (data_req_i && we_i) ? wdata_i : 0; 

    // single MUX for rdata_ext and data_be_o
    always_comb begin
        // Default values
        data_be_o    = 4'b0000;
        rdata_ext  = 32'd0;

        unique case (data_type_i)
            // Byte
            2'b00: begin
                data_be_o = 4'b0001;
                if (data_sign_ext_i) 
                    rdata_ext = { {24{rdata_i[7]} }, rdata_i[7:0] }; // Sign-extend byte
                else 
                    rdata_ext = { 24'h00_0000, rdata_i[7:0] };     // Zero-extend byte
            end
            // Halfword
            2'b01: begin
                data_be_o = 4'b0011;
                if (data_sign_ext_i) 
                    rdata_ext = { {16{rdata_i[15]} }, rdata_i[15:0] }; // Sign-extend halfword
                else 
                    rdata_ext = { 16'h0000, rdata_i[15:0] };        // Zero-extend halfword
            end
            // Word (32-bit)
            2'b10: begin
                data_be_o   = 4'b1111;
                rdata_ext = rdata_i;
            end
            default: ;
        endcase
    end

    assign rdata_o  = rdata_ext;

endmodule