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

module tb_axi #(
    parameter BOOT_ADDR = 'h80,
    parameter PULP_XPULP = 0,
    parameter PULP_CLUSTER = 0,
    parameter FPU = 0,
    parameter ZFINX = 0,
    parameter NUM_MHPMCOUNTERS = 1,
    parameter DM_HALTADDRESS = 32'h1A110800
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
  localparam LOGGING = 0;
  byte unsigned LASTCHAR = "\n";

  // clock and reset for tb
  logic         clk = 'b0;
  logic         rst_n = 'b0;

  // cycle counter
  int unsigned  cycle_cnt_q;

  // testbench result
  logic         exit_valid;
  logic         exit_zero;

  // signals for ri5cy
  logic         fetch_enable;

  // stdout pseudo peripheral
  logic         rx;
  logic         tx;

  // make the core start fetching instruction immediately
  assign fetch_enable = '1;

  // allow vcd dump
  initial begin
    if ($test$plusargs("vcd")) begin
      $dumpfile("riscy_tb.vcd");
      $dumpvars(0, tb_axi);
    end
  end

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

  // abort after n cycles, if we want to
  always_ff @(posedge clk, negedge rst_n) begin
    automatic int maxcycles;
    if ($value$plusargs("maxcycles=%d", maxcycles)) begin
      if (~rst_n) begin
        cycle_cnt_q <= 0;
      end else begin
        cycle_cnt_q <= cycle_cnt_q + 1;
        if (cycle_cnt_q >= maxcycles) begin
          $fatal(2, "Simulation aborted due to maximum cycle limit");
        end
      end
    end
  end

  logic [7:0] rxData;
  logic rxValid;
  
      logic clk_s;
    reg[27:0] counter=28'd0;
localparam DIVISOR = 28'd4;
// The frequency of the output clk_out
//  = The frequency of the input clk_in divided by DIVISOR
// For example: Fclk_in = 50Mhz, if you want to get 1Hz signal to blink LEDs
// You will modify the DIVISOR parameter value to 28'd50.000.000
// Then the frequency of the output clk_out = 50Mhz/50.000.000 = 1Hz
always @(posedge clk)
begin
 counter <= counter + 28'd1;
 if(counter>=(DIVISOR-1))
  counter <= 28'd0;
 clk_s <= (counter<DIVISOR/2)?1'b1:1'b0;
end

  axi_uartlite_0 uart (
      .s_axi_aclk   (clk_s),     // input wire s_axi_aclk
      .s_axi_aresetn(rst_n),  // input wire s_axi_aresetn

      .interrupt(),  // output wire interrupt

      .s_axi_awaddr ('0),  // input wire [3 : 0] s_axi_awaddr
      .s_axi_awvalid('0),  // input wire s_axi_awvalid
      .s_axi_awready(),    // output wire s_axi_awready
      .s_axi_wdata  ('0),  // input wire [31 : 0] s_axi_wdata
      .s_axi_wstrb  ('0),  // input wire [3 : 0] s_axi_wstrb
      .s_axi_wvalid ('0),  // input wire s_axi_wvalid
      .s_axi_wready (),    // output wire s_axi_wready
      .s_axi_bresp  (),    // output wire [1 : 0] s_axi_bresp
      .s_axi_bvalid (),    // output wire s_axi_bvalid
      .s_axi_bready ('0),  // input wire s_axi_bready

      .s_axi_araddr('0),  // input wire [3 : 0] s_axi_araddr
      .s_axi_arvalid('1),  // input wire s_axi_arvalid
      .s_axi_arready(),  // output wire   s_axi_arready
      .s_axi_rdata(rxData),  // output wire [31 : 0] s_axi_rdata
      .s_axi_rresp(),  // output wire [1 : 0] s_axi_rresp
      .s_axi_rvalid(rxValid),  // output wire s_axi_rvalid
      .s_axi_rready('1),  // input wire s_axi_rready

      .rx(tx),  // input wire rx
      .tx(rx)   // output wire tx
  );

  // print to stdout pseudo peripheral
  always_ff @(posedge clk_s, negedge rst_n) begin : print_peripheral
    if (rxValid && rxData) begin
      $write("%c", rxData);

      // Because of the way the UART works, the string may arrive after the program has finished
      if (rxData == LASTCHAR) begin
        if (exit_valid) begin
          if (exit_zero) $display("EXIT SUCCESS");
          else $display("EXIT FAILURE");
          $finish;
        end
      end
    end
  end

  // wrapper for riscv, the memory system and stdout peripheral
  axi_subsystem #(
      .BOOT_ADDR       (BOOT_ADDR),
      .PULP_XPULP      (PULP_XPULP),
      .PULP_CLUSTER    (PULP_CLUSTER),
      .FPU             (FPU),
      .ZFINX           (ZFINX),
      .NUM_MHPMCOUNTERS(NUM_MHPMCOUNTERS),
      .DM_HALTADDRESS  (DM_HALTADDRESS),
      .LOGGING         (LOGGING)
  ) u_axi_subsystem (
      .clk_i         (clk),
      .rst_ni        (rst_n),
      .fetch_enable_i(fetch_enable),
      .exit_zero_o   (exit_zero),
      .exit_valid_o  (exit_valid),
      .rx_i          (rx),
      .tx_o          (tx)
  );

endmodule  // tb_top
