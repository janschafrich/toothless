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
    input  logic [ADDR_WIDTH-1:0]   addr_i,
    input  logic                    we_i,               // 0 read access, 1 write access
    input  logic                    data_req_i,         // ongoing request to the LSU
    input  logic [1:0]              data_type_i,        // 00 byte, 01 halfword, 10 word
    input  logic                    data_sign_ext_i,    // load with sign extension

    // from register file
    input  logic [DATA_WIDTH-1:0]   wdata_i,

    // to register file
    output logic [DATA_WIDTH-1:0]   rdata_ext_o
);

    data_tcm #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .SIZE_LAU(1024)
    )data_tcm_i (
        .clk    (clk),
        .data_i (wdata_i),
        .addr_i (addr_i),
        .be_i   (data_be),
        .we_i   (we_i),
        .data_o (rdata)             // to sign/zero extension
    );

    logic [3:0] data_be;                 // byte enable, one hot encoding

    logic [DATA_WIDTH-1:0]  rdata;
    logic [DATA_WIDTH-1:0]  rdata_ext;


    // load/store: data type byte enable
    always_comb begin
        unique case (data_type_i)
            2'b00:   data_be = 4'b0001;       // byte
            2'b01:   data_be = 4'b0011;       // halfword
            2'b10:   data_be = 4'b1111;       // word
            default: data_be = 4'b0000;       // not used
        endcase
    end

    // loads - sign extension 
    always_comb begin
        unique case (data_type_i)
            // bytes
            2'b00:  begin               
                if (data_sign_ext_i)    rdata_ext = { {25{rdata[7]} }, rdata[6:0] };
                else                    rdata_ext = { 24'h00_0000 , rdata[7:0] };
            end    
            // halfwords    
            2'b01: begin                
                if (data_sign_ext_i)    rdata_ext = { {17{rdata[15]} }, rdata[14:0] };
                else                    rdata_ext = { 16'h0000 , rdata[15:0] };
            end
            2'b10:                      rdata_ext = rdata;
            default:                    rdata_ext = 32'd0;
        endcase 
    end

    assign rdata_ext_o  = rdata_ext;

endmodule