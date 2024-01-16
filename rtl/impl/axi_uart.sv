module axi_uart #(
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ID_WIDTH = 16,
    parameter AXI_USER_WIDTH = 10,
    /// CLOCK_FREQUENCY / UART_BAUD_RATE > 50        (clock cycles per baud)
    parameter CLK_FREQ = 25_000_000,
    parameter BAUD_RATE = 57600,
    parameter WRITE_ADDRESS = 32'h10000000,
    parameter READ_ADDRESS = 32'h10000004
) (
    input logic clk_i,
    input logic rst_ni,

    AXI_BUS.Slave AXI_Slave,

    output logic interrupt_o,
    input logic interrupt_ack_i,
    input logic rx_i,
    output logic tx_o
);

  wire uart_req;
  wire uart_gnt;
  wire [31:0] uart_addr;
  wire [31:0] uart_wdata;
  wire [31:0] uart_rdata;

  wire uart_we;
  wire uart_ack;

  wire uart_r_ack;
  wire uart_w_ack;

  wire uart_r_req;
  wire uart_w_req;

  assign uart_r_req = uart_req & !uart_we;
  assign uart_w_req = uart_req & uart_we;
  assign uart_ack = uart_r_ack | uart_w_ack;
  assign uart_gnt = uart_w_ack | uart_r_ack;

  axi_to_mem_intf #(
      /// See `axi_to_mem`, parameter `AddrWidth`.
      .ADDR_WIDTH    (AXI_ADDR_WIDTH),
      /// See `axi_to_mem`, parameter `DataWidth`.
      .DATA_WIDTH    (AXI_DATA_WIDTH),
      /// AXI4+ATOP ID width.
      .ID_WIDTH      (AXI_ID_WIDTH),
      /// AXI4+ATOP user width.
      .USER_WIDTH    (AXI_USER_WIDTH),
      /// See `axi_to_mem`, parameter `NumBanks`.
      .NUM_BANKS     (1),
      /// See `axi_to_mem`, parameter `BufDepth`.
      .BUF_DEPTH     (1),
      /// Hide write requests if the strb == '0
      .HIDE_STRB     (0),
      /// Depth of output fifo/fall_through_register. Increase for asymmetric backpressure (contention) on banks.
      .OUT_FIFO_DEPTH(1)
  ) u_axi_to_mem_intf (
      /// Clock input.
      .clk_i (clk_i),
      /// Asynchronous re
      //set, active low.
      .rst_ni(rst_ni),
      /// See `axi_to_mem`, port `busy_o`.
      .busy_o(),
      /// AXI4+ATOP slave interface port.
      .slv   (AXI_Slave),

      /// See `axi_to_mem`, port `mem_req_o`.
      .mem_req_o   (uart_req),
      /// See `axi_to_mem`, port `mem_gnt_i`.
      .mem_gnt_i   (uart_gnt),
      /// See `axi_to_mem`, port `mem_addr_o`.
      .mem_addr_o  (uart_addr),
      /// See `axi_to_mem`, port `mem_wdata_o`.
      .mem_wdata_o (uart_wdata),
      /// See `axi_to_mem`, port `mem_strb_o`.
      .mem_strb_o  (),
      /// See `axi_to_mem`, port `mem_atop_o`.
      .mem_atop_o  (),
      /// See `axi_to_mem`, port `mem_we_o`.
      .mem_we_o    (uart_we),
      /// See `axi_to_mem`, port `mem_rvalid_i`.
      .mem_rvalid_i(uart_ack),
      /// See `axi_to_mem`, port `mem_rdata_i`.
      .mem_rdata_i (uart_rdata)
  );

   uart #(
    .CLOCK_FREQUENCY(CLK_FREQ),
    .UART_BAUD_RATE(BAUD_RATE),
    .WRITE_ADDRESS(WRITE_ADDRESS),
    .READ_ADDRESS(READ_ADDRESS)
  ) uart_module (
    .clk_i(clk_i),
    .rst_ni(rst_ni),

    .rw_address(uart_addr),
    .read_data(uart_rdata),
    .read_request(uart_r_req),
    .read_response(uart_r_ack),
    .write_data(uart_wdata[7:0]),
    .write_request(uart_w_req),
    .write_response(uart_w_ack),

    .uart_rx(rx_i),
    .uart_tx(tx_o),

    .uart_irq(interrupt_o),
    .uart_irq_response(interrupt_ack_i)
    );

endmodule
