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

module tb_uart #(
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
  const int  RESET_WAIT_CYCLES = 50;

  // clock and reset for tb
  logic         clk = 'b0;
  logic         rst_n = 'b0;

  // stdout pseudo peripheral
  logic         rx;
  logic         tx;

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
  
  logic clk_s;
  clk_divisor u_clk_div (
      .clk_i(clk),
      .clk_o(clk_s)
  );

  byte unsigned USEDCHAR = "a";
  localparam WRITE_ADDRESS = 32'h10000000;
  localparam READ_ADDRESS = 32'h10000004;
  wire [31:0] uart_addr = WRITE_ADDRESS;
  wire [31:0] uart_rdata;
  wire uart_r_req = 0;
  wire uart_r_ack;
  wire [7:0] uart_wdata = USEDCHAR;
  wire uart_w_req = 0;
  wire uart_w_ack;

  
   uart #(
    .CLOCK_FREQUENCY(25_000_000),
    .UART_BAUD_RATE(57600),
    .WRITE_ADDRESS(WRITE_ADDRESS),
    .READ_ADDRESS(READ_ADDRESS)
  ) uart_module (
    .clock(clk_s),
    .reset(!rst_n),

    .rw_address(uart_addr),
    .read_data(uart_rdata),
    .read_request(uart_r_req),
    .read_response(uart_r_ack),
    .write_data(uart_wdata),
    .write_request(uart_w_req),
    .write_response(uart_w_ack),

    .uart_rx(rx),
    .uart_tx(tx),

    .uart_irq(),
    .uart_irq_response(interrupt_ack)
    );

  logic [31:0] rxData;
  logic rxValid;
  logic rxInt;
  
   uart #(
    .CLOCK_FREQUENCY(100_000_000),
    .UART_BAUD_RATE(57600),
    .READ_ADDRESS(READ_ADDRESS)
  ) uart_module1 (
    .clock(clk),
    .reset(!rst_n),

    .rw_address(READ_ADDRESS),
    .read_data(rxData),
    .read_request('1),
    .read_response(),
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
    if (~rst_n) begin
       rxValid = 0;
    end else begin
    if (rxInt) begin
       rxValid = 1;
    end
    if (rxValid && rxData) begin
      $write("%c", rxData[7:0]);
      rxValid = 0;
    end
  end
  end
endmodule  // tb_top
