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

module uart_tb #();

  const time CLK_PHASE_HI = 20ns;
  const time CLK_PHASE_LO = 20ns;
  const time CLK_PERIOD = CLK_PHASE_HI + CLK_PHASE_LO;

  const int  RESET_WAIT_CYCLES = 4;
  const time RESET_DEL = CLK_PERIOD * 0.1;

  // clock and reset for tb
  logic      clk = 'b1;
  logic      rst_n = 'b0;

  // stdout pseudo peripheral
  //   logic      [7:0] print_wdata;
  //   logic            print_valid;
  //   logic      rx;
  logic      tx;

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

  logic output_interr = '0;
  logic [3:0] output_awaddr = '0;
  logic output_awvalid = '0;
  logic output_awready = '0;
  logic [31:0] output_wdata = '0;
  logic [3:0] output_wstrb = '0;
  logic output_wvalid = '0;
  logic output_wready = '0;
  logic [1:0] output_bresp = '0;
  logic output_bvalid = '0;
  logic output_bready = '0;
  logic [3:0] output_araddr = '0;
  logic output_arvalid = '0;
  logic output_arready = '0;
  logic [31:0] output_rdata = '0;
  logic [1:0] output_rresp = '0;
  logic output_rvalid = '0;
  logic output_rready = '0;


  axi_uartlite_0 output_uart (
      .s_axi_aclk   (clk),     // input wire s_axi_aclk
      .s_axi_aresetn(rst_n),  // input wire s_axi_aresetn

      .interrupt(output_interr),  // output wire interrupt

      .s_axi_awaddr (output_awaddr),   // input wire [3 : 0] s_axi_awaddr
      .s_axi_awvalid(output_awvalid),  // input wire s_axi_awvalid
      .s_axi_awready(output_awready),  // output wire s_axi_awready
      .s_axi_wdata  (output_wdata),    // input wire [31 : 0] s_axi_wdata
      .s_axi_wstrb  (output_wstrb),    // input wire [3 : 0] s_axi_wstrb
      .s_axi_wvalid (output_wvalid),   // input wire s_axi_wvalid
      .s_axi_wready (output_wready),   // output wire s_axi_wready
      .s_axi_bresp  (output_bresp),    // output wire [1 : 0] s_axi_bresp
      .s_axi_bvalid (output_bvalid),   // output wire s_axi_bvalid
      .s_axi_bready (output_bready),   // input wire s_axi_bready

      .s_axi_araddr (output_araddr),   // input wire [3 : 0] s_axi_araddr
      .s_axi_arvalid(output_arvalid),  // input wire s_axi_arvalid
      .s_axi_arready(output_arready),  // output wire s_axi_arready
      .s_axi_rdata  (output_rdata),    // output wire [31 : 0] s_axi_rdata
      .s_axi_rresp  (output_rresp),    // output wire [1 : 0] s_axi_rresp
      .s_axi_rvalid (output_rvalid),   // output wire s_axi_rvalid
      .s_axi_rready (output_rready),   // input wire s_axi_rready

      .rx(tx),  // input wire rx
      .tx(tx)   // output wire tx
  );

  enum logic [2:0] {
    IDLE,
    SENDING,
    RESPONSE,
    READINGADDR,
    READINGDATA,
    DONE
  } state;

  always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      output_awaddr <= '0;
      state = IDLE;
    end else begin
      case (state)
        IDLE: begin
          state <= SENDING;
        end
        SENDING: begin
          if (output_awready && output_wready) state <= RESPONSE;
        end
        RESPONSE: begin
          if (output_bvalid) state <= READINGADDR;
        end
        READINGADDR: begin
          if (output_arready) state <= READINGDATA;
        end
        READINGDATA: begin
          if (output_rvalid) state <= DONE;
        end
        DONE: begin
          output_awaddr <= output_awaddr + 1;
          state <= IDLE;
        end
        default: begin
          state <= IDLE;
        end

      endcase
    end

  end
  always_comb begin
    output_awvalid <= '0;
    output_wvalid  <= '0;
    output_wdata   <= 'h32;
    output_bready  <= '0;
    output_araddr  <= output_awaddr;

    output_arvalid <= '0;
    output_rready  <= '0;

    case (state)
      IDLE: begin
      end
      SENDING: begin
        output_awvalid <= '1;
        output_wvalid  <= '1;
      end
      RESPONSE: begin
        output_bready <= '1;
      end
      READINGADDR: begin
        output_arvalid <= '1;
      end
      READINGDATA: begin
        output_rready <= '1;
      end
      DONE: begin
      end
      default: begin
      end
    endcase
  end

  // print to stdout pseudo peripheral
  //   always_ff @(posedge clk, negedge rst_n) begin : print_peripheral2
  //     if (rxDone) begin
  //       $write("%c", out[7:0]);
  //     end
  //   end

endmodule  // tb_top
