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

  logic clk_s;
  clk_divisor #(
      .INPUT_CLK_FREQ (100_000_000),
      .OUTPUT_CLK_FREQ(25_000_000)
  ) u_clk_div (
      .clk_i(clk),
      .clk_o(clk_s)
  );

  localparam READ_ADDRESS = 32'h10000004;
  logic [31:0] rxData;
  logic rxValid;
  logic rxInt;
  logic receiving;

  uart_sim #(
      .CLOCK_FREQUENCY(25_000_000),
      .UART_BAUD_RATE(57600),
      .READ_ADDRESS(READ_ADDRESS)
  ) uart_module (
      .clk_i (clk_s),
      .rst_ni(rst_n),

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
      .uart_irq_response('1),
      .receiving(receiving)
  );

  // print to stdout pseudo peripheral
  always_ff @(posedge clk_s, negedge rst_n) begin : print_peripheral
    if (rxValid && rxData) begin
      $write("%c", rxData[7:0]);
    end
  end

  // exit peripheral
  always_ff @(posedge clk_s, negedge rst_n) begin : exit_peripheral
    if (exit_valid && !receiving) begin
      if (exit_zero) $display("EXIT SUCCESS");
      else $display("EXIT FAILURE");
      $finish;
    end
  end

  localparam LOGGING = 0;
  localparam NUM_MASTERS = 2;
  generate
    ;
    if (LOGGING) begin : logging
      for (genvar i = 0; i < NUM_MASTERS; i = i + 1) begin
        always @(posedge u_axi_subsystem.clk) begin
          if (u_axi_subsystem.AXI_Masters[i].ar_valid) begin
            $write("BUS %01d READ addr=0x%08x at %t\n", i, u_axi_subsystem.AXI_Masters[i].ar_addr,
                   $time);
            if (u_axi_subsystem.AXI_Masters[i].ar_addr == 32'h1f08) begin
              $write("HERE");
            end
          end
          if (u_axi_subsystem.AXI_Masters[i].r_valid) begin
            $write("BUS %01d READ data=0x%08x at %t\n", i, u_axi_subsystem.AXI_Masters[i].r_data,
                   $time);
          end

          if (u_axi_subsystem.AXI_Masters[i].aw_valid) begin
            $write("BUS %01d WRITE addr=0x%08x at %t\n", i, u_axi_subsystem.AXI_Masters[i].aw_addr,
                   $time);
          end
          if (u_axi_subsystem.AXI_Masters[i].w_valid) begin
            $write("BUS %01d WRITE data=0x%08x at %t\n", i, u_axi_subsystem.AXI_Masters[i].w_data,
                   $time);
          end
        end
      end
    end
  endgenerate

  // wrapper for riscv, the memory system and stdout peripheral
  axi_subsystem #() u_axi_subsystem (
      .clk_i         (clk),
      .rst_ni        (rst_n),
      .fetch_enable_i(fetch_enable),
      .exit_zero_o   (exit_zero),
      .exit_valid_o  (exit_valid),
      .rx_i          (rx),
      .tx_o          (tx)
  );

endmodule  // tb_top

/**************************************************************************************************

  - This UART module works with 8 data bits, 1 stop bit, no parity bit and no flow control signals
  - It only partially implements AXI4 Slave Interface requirements
  - The baud rate can be adjusted to any value as long as the following condition is satisfied:

    CLOCK_FREQUENCY / UART_BAUD_RATE > 50        (clock cycles per baud)

**************************************************************************************************/
module uart_sim #(

    parameter CLOCK_FREQUENCY = 50000000,
    parameter UART_BAUD_RATE = 9600,
    parameter WRITE_ADDRESS = 32'h10000000,
    parameter READ_ADDRESS = 32'h10000004
) (

    // Global signals

    input wire clk_i,
    input wire rst_ni,

    // IO interface

    input  wire [31:0] rw_address,
    output reg  [31:0] read_data,
    input  wire        read_request,
    output reg         read_response,
    input  wire [ 7:0] write_data,
    input  wire        write_request,
    output reg         write_response,

    // RX/TX signals

    input  wire uart_rx,
    output wire uart_tx,

    // Interrupt signaling

    output reg  uart_irq,
    input  wire uart_irq_response,

    output reg receiving

);

  localparam CYCLES_PER_BAUD = CLOCK_FREQUENCY / UART_BAUD_RATE;

  wire reset;
  assign reset = ~rst_ni;

  reg  [31:0] tx_cycle_counter = 0;
  reg  [31:0] rx_cycle_counter = 0;
  reg  [ 3:0] tx_bit_counter;
  reg  [ 3:0] rx_bit_counter;
  reg  [ 9:0] tx_register;
  reg  [ 7:0] rx_register;
  reg  [ 7:0] rx_data;
  reg         rx_active;
  reg         reset_reg;

  wire        reset_internal;

  always @(posedge clk_i) reset_reg <= reset;

  assign reset_internal = reset | reset_reg;

  assign uart_tx = tx_register[0];

  always @(posedge clk_i) begin
    if (reset_internal) begin
      tx_cycle_counter <= 0;
      tx_register <= 10'b1111111111;
      tx_bit_counter <= 0;
    end else if (tx_bit_counter == 0 && rw_address == WRITE_ADDRESS && write_request == 1'b1) begin
      tx_cycle_counter <= 0;
      tx_register <= {1'b1, write_data[7:0], 1'b0};
      tx_bit_counter <= 10;
    end else begin
      if (tx_cycle_counter < CYCLES_PER_BAUD) begin
        tx_cycle_counter <= tx_cycle_counter + 1;
        tx_register <= tx_register;
        tx_bit_counter <= tx_bit_counter;
      end else begin
        tx_cycle_counter <= 0;
        tx_register <= {1'b1, tx_register[9:1]};
        tx_bit_counter <= tx_bit_counter > 0 ? tx_bit_counter - 1 : 0;
      end
    end
  end

  always @(posedge clk_i) begin
    if (reset_internal) begin
      rx_cycle_counter <= 0;
      rx_register <= 8'h00;
      rx_data <= 8'h00;
      rx_bit_counter <= 0;
      uart_irq <= 1'b0;
      rx_active <= 1'b0;
    end else if (uart_irq == 1'b1) begin
      if (uart_irq_response == 1'b1) begin
        rx_cycle_counter <= 0;
        rx_register <= 8'h00;
        rx_data <= rx_data;
        rx_bit_counter <= 0;
        uart_irq <= 1'b0;
        rx_active <= 1'b0;
      end else begin
        rx_cycle_counter <= 0;
        rx_register <= 8'h00;
        rx_data <= rx_data;
        rx_bit_counter <= 0;
        uart_irq <= 1'b1;
        rx_active <= 1'b0;
      end
    end else if (rx_bit_counter == 0 && rx_active == 1'b0) begin
      if (uart_rx == 1'b1) begin
        rx_cycle_counter <= 0;
        rx_register <= 8'h00;
        rx_data <= rx_data;
        rx_bit_counter <= 0;
        uart_irq <= 1'b0;
        rx_active <= 1'b0;
      end else if (uart_rx == 1'b0) begin
        if (rx_cycle_counter < CYCLES_PER_BAUD / 2) begin
          rx_cycle_counter <= rx_cycle_counter + 1;
          rx_register <= 8'h00;
          rx_data <= rx_data;
          rx_bit_counter <= 0;
          uart_irq <= 1'b0;
          rx_active <= 1'b0;
        end else begin
          rx_cycle_counter <= 0;
          rx_register <= 8'h00;
          rx_data <= rx_data;
          rx_bit_counter <= 8;
          uart_irq <= 1'b0;
          rx_active <= 1'b1;
        end
      end
    end else begin
      if (rx_cycle_counter < CYCLES_PER_BAUD) begin
        rx_cycle_counter <= rx_cycle_counter + 1;
        rx_register <= rx_register;
        rx_data <= rx_data;
        rx_bit_counter <= rx_bit_counter;
        uart_irq <= 1'b0;
        rx_active <= 1'b1;
      end else begin
        rx_cycle_counter <= 0;
        rx_register <= {uart_rx, rx_register[7:1]};
        rx_data <= (rx_bit_counter == 0) ? rx_register : rx_data;
        rx_bit_counter <= rx_bit_counter > 0 ? rx_bit_counter - 1 : 0;
        uart_irq <= (rx_bit_counter == 0) ? 1'b1 : 1'b0;
        rx_active <= 1'b1;
      end
    end
  end

  always @(posedge clk_i) begin
    if (reset_internal) begin
      read_response  <= 1'b0;
      write_response <= 1'b0;
    end else begin
      read_response  <= read_request;
      write_response <= write_request;
    end
  end

  always @(posedge clk_i) begin
    if (reset_internal) read_data <= 32'h00000000;
    else if (rw_address == WRITE_ADDRESS && read_request == 1'b1)
      read_data <= {31'b0, tx_bit_counter == 0};
    else if (rw_address == READ_ADDRESS && read_request == 1'b1) read_data <= {24'b0, rx_data};
    else read_data <= 32'h00000000;
  end

  assign receiving = rx_active;

endmodule

