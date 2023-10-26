// Copyright 2017 Embecosm Limited <www.embecosm.com>
// Copyright 2018 Robert Balas <balasr@student.ethz.ch>
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Top level wrapper for a RI5CY testbench
// Contributor: Robert Balas <balasr@student.ethz.ch>
//              Jeremy Bennett <jeremy.bennett@embecosm.com>

module bram_tb #(
    parameter NB_COL = 4,  // Specify number of columns (number of bytes)
    parameter COL_WIDTH = 8,  // Specify column width (byte width, typically 8 or 9)
    parameter RAM_DEPTH = 131072,  // Specify RAM depth (number of entries)
    parameter INIT_FILE = "C:/Users/kersz/Documents/ufrgs/IC/cv32e40p/programs/basic.hex"                        // Specify name/location of RAM initialization file if using one (leave blank if not)
);

  // comment to record execution trace
  //`define TRACE_EXECUTION

  const time CLK_PHASE_HI = 5ns;
  const time CLK_PHASE_LO = 5ns;
  const time CLK_PERIOD = CLK_PHASE_HI + CLK_PHASE_LO;

  const time STIM_APPLICATION_DEL = CLK_PERIOD * 0.1;
  const time RESP_ACQUISITION_DEL = CLK_PERIOD * 0.9;
  const time RESET_DEL = STIM_APPLICATION_DEL;
  const int  RESET_WAIT_CYCLES = 4;

  // clock and reset for tb
  logic      clk = 'b1;
  logic      rst_n = 'b0;

  // clock generation
  initial begin : clock_gen
    forever begin
      #CLK_PHASE_HI clk = 1'b0;
      #CLK_PHASE_LO clk = 1'b1;
    end
  end : clock_gen

  // reset generation
  initial begin : reset_gen
    rst_n = 1'b0;

    // wait a few cycles
    repeat (RESET_WAIT_CYCLES) begin
      @(posedge clk);
    end

    // start running
    #RESET_DEL rst_n = 1'b1;
    if ($test$plusargs("verbose")) $display("reset deasserted", $time);

  end : reset_gen

  // set timing format
  initial begin : timing_format
    $timeformat(-9, 0, "ns", 9);
  end : timing_format

  logic en_a_i = 1'b1;
  logic [NB_COL-1:0] we_a = 4'b000;
  logic [17-1:0] addr_a_i = '0;
  logic [NB_COL*COL_WIDTH-1:0] rdata_a_o;

  logic [1:0] counter = 2'b00;

  always @(posedge clk) begin
    if (rst_n == 1'b0) begin
      counter <= 2'b00;
    end else if (counter == 2'b11) begin
      addr_a_i <= addr_a_i + 1;

      counter  <= 2'b00;
    end else begin
      counter <= counter + 1'b1;
    end
    $display("addr=0x%08x: data=0x%08x", addr_a_i, rdata_a_o);
  end


  dp_blk_ram #(
      .NB_COL(4),  // Specify number of columns (number of bytes)
      .COL_WIDTH(8),  // Specify column width (byte width, typically 8 or 9)
      .RAM_DEPTH(131072),  // Specify RAM depth (number of entries)
      .RAM_PERFORMANCE("LOW_LATENCY"),  // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
      .INIT_FILE(INIT_FILE)                        // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) mem (
      .clka(clk),  // Port A clock

      // Port A 
      .ena(en_a_i),  // Port A RAM Enable, for additional power savings, disable port when not in use
      .wea(we_a),  // Port A write enable, width determined from NB_COL
      .addra(addr_a_i),  // Port A address bus, width determined from RAM_DEPTH
      .dina('0),  // Port A RAM input data, width determined from NB_COL*COL_WIDTH
      .douta(rdata_a_o),  // Port A RAM output data, width determined from NB_COL*COL_WIDTH

      // Port B
      .enb  ('0),  // Port B RAM Enable, for additional power savings, disable port when not in use
      .web  ('0),  // Port B write enable, width determined from NB_COL
      .addrb('0),  // Port B address bus, width determined from RAM_DEPTH
      .dinb ('0),  // Port B RAM input data, width determined from NB_COL*COL_WIDTH
      .doutb(),    // Port B RAM output data, width determined from NB_COL*COL_WIDTH

      // Other
      .rsta  ('0),  // Port A output reset (does not affect memory contents)
      .rstb  ('0),  // Port B output reset (does not affect memory contents)
      .regcea('0),  // Port A output register enable //Unused
      .regceb('0)   // Port B output register enable //Unused
  );


endmodule  // tb_top
