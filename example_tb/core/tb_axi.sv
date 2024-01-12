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
  const time INITIAL_DELAY = 200ns;
  const time CLK_PHASE_HI = 5ns;
  const time CLK_PHASE_LO = 5ns;
  const time CLK_PERIOD = CLK_PHASE_HI + CLK_PHASE_LO;

  const time STIM_APPLICATION_DEL = CLK_PERIOD * 0.1;
  const time RESP_ACQUISITION_DEL = CLK_PERIOD * 0.9;
  const time RESET_DEL = STIM_APPLICATION_DEL;
  const int  RESET_WAIT_CYCLES = 100;
  localparam LOGGING = 1;
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
    #INITIAL_DELAY
    forever begin
      #CLK_PHASE_HI clk = 1'b1;
      #CLK_PHASE_LO clk = 1'b0;
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
    if ($test$plusargs("verbose")) $display("reset deasserted", $time, "ns");

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

  localparam READ_ADDRESS = 32'h10000004;
  logic [31:0] rxData;
  logic rxValid;
  logic rxInt;

  uart #(
      .CLOCK_FREQUENCY(100_000_000),
      .UART_BAUD_RATE(57600),
      .READ_ADDRESS(READ_ADDRESS)
  ) uart_module (
      .clock(clk),
      .reset(!rst_n),

      .rw_address(READ_ADDRESS),
      .read_data(rxData),
      .read_request(rxInt),
      .read_response(rxValid),
      .write_data('0),
      .write_request('0),
      .write_response(),

      .uart_rx(tx),
      .uart_tx(rx),

      .uart_irq(rxInt),
      .uart_irq_response('1)
  );

  // print to stdout pseudo peripheral
  always_ff @(posedge clk, negedge rst_n) begin : print_peripheral
    if (rxValid && rxData) begin
      $write("%c", rxData[7:0]);
      // Because of the way the UART works, the string may arrive after the program has finished
      if (rxData[7:0] == LASTCHAR) begin
        if (exit_valid) begin
          if (exit_zero) $display("EXIT SUCCESS");
          else $display("EXIT FAILURE");
          $finish;
        end
      end
    end
  end

  wire mem_clk;
  wire mem_ar_valid;
  wire [31:0] mem_ar_addr;
  wire mem_r_valid;
  wire [31:0] mem_r_data;

  wire mem_aw_valid;
  wire [31:0] mem_aw_addr;
  wire mem_w_valid;
  wire mem_w_data;

  always @(posedge mem_clk) begin
    if (LOGGING) begin
      if (mem_ar_valid) $write("READ addr=0x%08x\n", mem_ar_addr);
      if (mem_r_valid) $write("READ data=0x%08x\n", mem_r_data);

      if (mem_aw_valid) $write("WRITE addr=0x%08x\n", mem_aw_addr);
      if (mem_w_valid) $write("WRITE data=0x%08x\n", mem_w_data);
    end
  end

  // wrapper for riscv, the memory system and stdout peripheral
  axi_subsystem #() u_axi_subsystem (
      .clk_i         (clk),
      .rst_ni        (rst_n),
      .fetch_enable_i(fetch_enable),
      .exit_zero_o   (exit_zero),
      .exit_valid_o  (exit_valid),
      .rx_i          (rx),
      .tx_o          (tx),

      .debug_clk_o   (mem_clk),
      .debug_ar_valid_o (mem_ar_valid),
      .debug_ar_addr_o  (mem_ar_addr),
      .debug_r_valid_o  (mem_r_valid),
      .debug_r_data_o   (mem_r_data),
      .debug_aw_valid_o (mem_aw_valid),
      .debug_aw_addr_o  (mem_aw_addr),
      .debug_w_valid_o  (mem_w_valid),
      .debug_w_data_o   (mem_w_data)
  );

endmodule  // tb_top
