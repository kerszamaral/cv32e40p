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

/*
This modules makes a LUT Memory with 256 positions and 32 bit width
But we need to substitute to a BRAM. So we need to accounts for non-instant access.
Instructions read instantly 128 bits from the memory
Data is written in 32 bit width with 4 bytes enable
For that we need a BRAM with 128 bit width and 64 positions
And we need to remap the addresses to the BRAM

BRAM Stats:
128 bit Width
64 Depth

Port A:
128 bit width
64 Depth
The addr is given as the offset for a 256 depth memory, so we need to divide by 4

Port B:
32 bit width
256 Depth
That we subdivide in 4 8 bit width accesses with masks with the input and current data.

With enable pins for each port
Common clock
*/

module dp_ram #(
    parameter ADDR_WIDTH = 8,
    parameter INSTR_RDATA_WIDTH = 128
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

  localparam bytes = 2 ** ADDR_WIDTH;

impl_dp_ram_blk your_instance_name (
  .clka(clka),    // input wire clka
  .ena(ena),      // input wire ena
  .wea(wea),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [5 : 0] addra
  .dina(dina),    // input wire [127 : 0] dina
  .douta(douta),  // output wire [127 : 0] douta
  .clkb(clkb),    // input wire clkb
  .enb(enb),      // input wire enb
  .web(web),      // input wire [0 : 0] web
  .addrb(addrb),  // input wire [7 : 0] addrb
  .dinb(dinb),    // input wire [31 : 0] dinb
  .doutb(doutb)  // output wire [31 : 0] doutb
);

  logic [           7:0] mem        [bytes];
  logic [ADDR_WIDTH-1:0] addr_a_int;
  logic [ADDR_WIDTH-1:0] addr_b_int;

  always_comb addr_a_int = {addr_a_i[ADDR_WIDTH-1:2], 2'b0};
  always_comb addr_b_int = {addr_b_i[ADDR_WIDTH-1:2], 2'b0};

  always @(posedge clk_i) begin
    for (int i = 0; i < INSTR_RDATA_WIDTH / 8; i++) begin
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
      end
            /* handle reads */
            else
      begin
        if ($test$plusargs("verbose"))
          $display("read  addr=0x%08x: data=0x%08x", addr_b_int, {
                   mem[addr_b_int+3], mem[addr_b_int+2], mem[addr_b_int+1], mem[addr_b_int+0]});

        rdata_b_o[7:0]   <= mem[addr_b_int];
        rdata_b_o[15:8]  <= mem[addr_b_int+1];
        rdata_b_o[23:16] <= mem[addr_b_int+2];
        rdata_b_o[31:24] <= mem[addr_b_int+3];
      end
    end
  end

endmodule  // dp_ram
