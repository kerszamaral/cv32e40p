// Distributed RAM

module dp_dist_ram #(
    parameter NB_COL = 4,  // Specify number of columns (number of bytes)
    parameter COL_WIDTH = 8,  // Specify column width (byte width, typically 8 or 9)
    parameter RAM_DEPTH = 131072,  // Specify RAM depth (number of entries)
    parameter INIT_FILE = ""                        // Specify name/location of RAM initialization file if using one (leave blank if not)
) (
    input [clogb2(RAM_DEPTH-1)-1:0] addra,  // Port A address bus, width determined from RAM_DEPTH
    input [clogb2(RAM_DEPTH-1)-1:0] addrb,  // Port B address bus, width determined from RAM_DEPTH
    input [(NB_COL*COL_WIDTH)-1:0] dina,  // Port A RAM input data
    input [(NB_COL*COL_WIDTH)-1:0] dinb,  // Port B RAM input data
    input clka,  // Clock
    input [NB_COL-1:0] wea,  // Port A write enable
    input [NB_COL-1:0] web,  // Port B write enable
    input ena,  // Port A RAM Enable, for additional power savings, disable BRAM when not in use
    input enb,  // Port B RAM Enable, for additional power savings, disable BRAM when not in use
    output [(NB_COL*COL_WIDTH)-1:0] douta,  // Port A RAM output data
    output [(NB_COL*COL_WIDTH)-1:0] doutb  // Port B RAM output data
);

  logic clk_i;
  assign clk_i = clka;

  logic en_a_i;
  assign en_a_i = ena;

  logic [clogb2(RAM_DEPTH-1)-1:0] addr_a_i;
  assign addr_a_i = addra;

  logic [(NB_COL*COL_WIDTH)-1:0] wdata_a_i;
  assign wdata_a_i = dina;

  logic [(NB_COL*COL_WIDTH)-1:0] rdata_a_o;
  assign douta = rdata_a_o;

  logic we_a_i;
  always_comb we_a_i = wea[0] | wea[1] | wea[2] | wea[3];

  logic [3:0] be_a_i;
  assign be_a_i = wea;

  logic en_b_i;
  assign en_b_i = enb;

  logic [clogb2(RAM_DEPTH-1)-1:0] addr_b_i;
  assign addr_b_i = addrb;

  logic [(NB_COL*COL_WIDTH)-1:0] wdata_b_i;
  assign wdata_b_i = dinb;

  logic [(NB_COL*COL_WIDTH)-1:0] rdata_b_o;
  assign doutb = rdata_b_o;



  logic we_b_i;
  assign we_b_i = web[0] | web[1] | web[2] | web[3];

  logic [3:0] be_b_i;
  assign be_b_i = web;

  localparam bytes = (2 ** clogb2(RAM_DEPTH - 1)) * 4;

  logic [                    7:0] mem        [bytes];
  logic [clogb2(RAM_DEPTH-1)-1:0] addr_a_int;
  logic [clogb2(RAM_DEPTH-1)-1:0] addr_b_int;

  always_comb addr_a_int = {addr_a_i[clogb2(RAM_DEPTH-1)-1:2], 2'b0};
  always_comb addr_b_int = {addr_b_i[clogb2(RAM_DEPTH-1)-1:2], 2'b0};

  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
  generate
    if (INIT_FILE != "") begin : use_init_file
      initial $readmemh(INIT_FILE, mem, 0, RAM_DEPTH - 1);
    end else begin : init_bram_to_zero
      integer ram_index;
      initial
        for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
          mem[ram_index] = {(NB_COL * COL_WIDTH) {1'b0}};
    end
  endgenerate

  always @(posedge clk_i) begin
    for (int i = 0; i < (NB_COL * COL_WIDTH) / 8; i++) begin
      rdata_a_o[(i*8)+:8] <= mem[addr_a_int+i];
    end

    /* addr_b_i is the actual memory address referenced */
    if (en_b_i) begin
      /* handle writes */
      if (we_b_i) begin
        if (be_b_i[0]) mem[addr_b_int] <= wdata_b_i[0+:8];
        if (be_b_i[1]) mem[addr_b_int+1] <= wdata_b_i[8+:8];
        if (be_b_i[2]) mem[addr_b_int+2] <= wdata_b_i[16+:8];
        if (be_b_i[3]) mem[addr_b_int+3] <= wdata_b_i[24+:8];
      end            /* handle reads */
      else begin

        rdata_b_o[7:0]   <= mem[addr_b_int];
        rdata_b_o[15:8]  <= mem[addr_b_int+1];
        rdata_b_o[23:16] <= mem[addr_b_int+2];
        rdata_b_o[31:24] <= mem[addr_b_int+3];
      end
    end
  end

  //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
    for (clogb2 = 0; depth > 0; clogb2 = clogb2 + 1) depth = depth >> 1;
  endfunction
endmodule
