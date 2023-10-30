// Copyright 2015 ETH Zurich and University of Bologna.
// Copyright 2017 Embecosm Limited <www.embecosm.com>
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.


module impl_dp_ram #(
    parameter ADDR_WIDTH = 22,
    parameter INSTR_RDATA_WIDTH = 32  // 32
) (
    input logic clk_i,

    input  logic                         en_a_i,
    input  logic [       ADDR_WIDTH-1:0] addr_a_i,
    input  logic [                 31:0] wdata_a_i,
    output logic [INSTR_RDATA_WIDTH-1:0] rdata_a_o,
    input  logic                         we_a_i,
    input  logic [                  3:0] be_a_i,

    input  logic                  en_b_i,
    input  logic [ADDR_WIDTH-1:0] addr_b_i,
    input  logic [          31:0] wdata_b_i,
    output logic [          31:0] rdata_b_o,
    input  logic                  we_b_i,
    input  logic [           3:0] be_b_i
);

  localparam MAXBLKSIZE = 17;

  logic [MAXBLKSIZE-1:0] addr_a_aligned;
  logic [MAXBLKSIZE-1:0] addr_b_aligned;

  always_comb addr_a_aligned = {addr_a_i[MAXBLKSIZE-1:2], 2'b0};
  always_comb addr_b_aligned = {addr_b_i[MAXBLKSIZE-1:2], 2'b0};

  logic [MAXBLKSIZE-1:0] addr_a_shifted;
  logic [MAXBLKSIZE-1:0] addr_b_shifted;

  always_comb addr_a_shifted = {addr_a_i[MAXBLKSIZE+1:2]};
  always_comb addr_b_shifted = {addr_b_i[MAXBLKSIZE+1:2]};


  logic [3:0] we_a;
  logic [3:0] we_b;

  always_comb
    we_a = {
      be_a_i[3] ? we_a_i : 1'b0,
      be_a_i[2] ? we_a_i : 1'b0,
      be_a_i[1] ? we_a_i : 1'b0,
      be_a_i[0] ? we_a_i : 1'b0
    };
  always_comb
    we_b = {
      be_b_i[3] ? we_b_i : 1'b0,
      be_b_i[2] ? we_b_i : 1'b0,
      be_b_i[1] ? we_b_i : 1'b0,
      be_b_i[0] ? we_b_i : 1'b0
    };

  logic [31:0] rdata_a;
  logic [31:0] rdata_b;

  assign rdata_a_o = rdata_a;
  assign rdata_b_o = rdata_b;

  always @(posedge clk_i) begin
    if ($test$plusargs("verbose")) begin
      if (we_b_i) $display("write addr=0x%08x: data=0x%08x", addr_b_aligned, wdata_b_i);
      $display("addr_A=0x%08x: data_A=0x%08x addr_B=0x%08x: data_B=0x%08x", addr_a_aligned,
               rdata_a, addr_b_aligned, rdata_b);
      if ((addr_a_aligned >= 2 ** MAXBLKSIZE) || (addr_b_aligned >= 2 ** MAXBLKSIZE))
        $display("Out of Bounds Access!!");
    end
  end

  dp_blk_ram #(
      .NB_COL(4),  // Specify number of columns (number of bytes)
      .COL_WIDTH(8),  // Specify column width (byte width, typically 8 or 9)
      .RAM_DEPTH((2 ** MAXBLKSIZE)),  // Specify RAM depth (number of entries)
      .RAM_PERFORMANCE("HIGH_PERFORMANCE"),  // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
      .INIT_FILE("/home/kersz/Documents/cv32e40p/programs/prog.hex")                        // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) mem (
      .clka(clk_i),  // Port A clock

      // Port A 
      .ena('1),  // Port A RAM Enable, for additional power savings, disable port when not in use
      .wea(we_a),  // Port A write enable, width determined from NB_COL
      .addra(addr_a_shifted),  // Port A address bus, width determined from RAM_DEPTH
      .dina(wdata_a_i),  // Port A RAM input data, width determined from NB_COL*COL_WIDTH
      .douta(rdata_a),  // Port A RAM output data, width determined from NB_COL*COL_WIDTH

      // Port B
      .enb('1),  // Port B RAM Enable, for additional power savings, disable port when not in use
      .web(we_b),  // Port B write enable, width determined from NB_COL
      .addrb(addr_b_shifted),  // Port B address bus, width determined from RAM_DEPTH
      .dinb(wdata_b_i),  // Port B RAM input data, width determined from NB_COL*COL_WIDTH
      .doutb(rdata_b),  // Port B RAM output data, width determined from NB_COL*COL_WIDTH

      // Other
      .rsta  ('0),  // Port A output reset (does not affect memory contents)
      .rstb  ('0),  // Port B output reset (does not affect memory contents)
      .regcea('1),  // Port A output register enable //Unused
      .regceb('1)   // Port B output register enable //Unused
  );

endmodule  // dp_ram
