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

module impl_dp_ram #(
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

  logic [           5:0] addr_a;

  always_comb addr_a = {addr_a_i[ADDR_WIDTH-1:2], 2'b0}; //Divide by 4 
  // (we recive the offset for a 256 depth memory and remap to a 64 depth memory)

  logic [           31:0] rdata_b; // Because we need to read the output of the BRAM
  logic [           31:0] wdata_b; // For masking the data and writing it back

  always_comb wdata_b = {
    be_b_i[0] ? wdata_b_i[0+:8] : rdata_b[0+:8], // If the mask is 1, we write the input data, else we write the current data
    be_b_i[1] ? wdata_b_i[8+:8] : rdata_b[8+:8], // We do this for each byte
    be_b_i[2] ? wdata_b_i[16+:8] : rdata_b[16+:8], 
    be_b_i[3] ? wdata_b_i[24+:8] : rdata_b[24+:8]
  };

  always_comb rdata_b_o = rdata_b; // Output the data read from the BRAM

  impl_dp_ram_blk mem (
    .clka(clk_i),    // input wire clka
    .ena(en_a_i),      // input wire ena
    .wea(we_a_i),      // input wire [0 : 0] wea
    .addra(addr_a),  // input wire [5 : 0] addra
    .dina('0),    // input wire [127 : 0] dina //Always Disabled
    .douta(rdata_a_o),  // output wire [127 : 0] douta


    .clkb(clk_i),    // input wire clkb
    .enb(en_b_i),      // input wire enb
    .web(we_b_i),      // input wire [0 : 0] web
    .addrb(addr_b_i),  // input wire [7 : 0] addrb
    .dinb(dinb),    // input wire [31 : 0] dinb
    .doutb(rdata_b)  // output wire [31 : 0] doutb
  );

endmodule  // dp_ram
