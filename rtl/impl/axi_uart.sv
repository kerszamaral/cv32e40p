module axi_uart #(
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ID_WIDTH = 16,
    parameter AXI_USER_WIDTH = 10
) (
    input logic clk_i,
    input logic rst_ni,

    AXI_BUS.Slave AXI_Slave,

    output logic interrupt_o,
    input logic rx_i,
    output logic tx_o
);

  AXI_LITE #(
      .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
      .AXI_DATA_WIDTH(AXI_DATA_WIDTH)
  ) AXI_uart ();

  axi_to_axi_lite_intf #(
      .AXI_ID_WIDTH      (AXI_ID_WIDTH),
      .AXI_ADDR_WIDTH    (AXI_ADDR_WIDTH),
      .AXI_DATA_WIDTH    (AXI_DATA_WIDTH),
      .AXI_USER_WIDTH    (AXI_USER_WIDTH),
      .AXI_MAX_WRITE_TXNS(32'd10),
      .AXI_MAX_READ_TXNS (32'd10),
      .FALL_THROUGH      (1'b1)
  ) lite_to_axi (
      .clk_i     (clk_i),
      .rst_ni    (rst_ni),
      .testmode_i(1'b0),
      .slv       (AXI_Slave),
      .mst       (AXI_uart)
  );

  // UART AXI Access
  axi_uartlite_0 uart (
      .s_axi_aclk   (clk_i),     // input wire s_axi_aclk
      .s_axi_aresetn(rst_ni),  // input wire s_axi_aresetn

      .interrupt(interrupt_o),  // output wire interrupt

      .s_axi_awaddr('h4),  // input wire [3 : 0] s_axi_awaddr m_axi_awaddr[(UART*ADDRSIZE)+:4]
      .s_axi_awvalid(AXI_uart.aw_valid),  // input wire s_axi_awvalid
      .s_axi_awready(AXI_uart.aw_ready),  // output wire s_axi_awready
      .s_axi_wdata(AXI_uart.w_data),  // input wire [31 : 0] s_axi_wdata
      .s_axi_wstrb(AXI_uart.w_strb),  // input wire [3 : 0] s_axi_wstrb
      .s_axi_wvalid(AXI_uart.w_valid),  // input wire s_axi_wvalid
      .s_axi_wready(AXI_uart.w_ready),  // output wire s_axi_wready
      .s_axi_bresp(AXI_uart.b_resp),  // output wire [1 : 0] s_axi_bresp
      .s_axi_bvalid(AXI_uart.b_valid),  // output wire s_axi_bvalid
      .s_axi_bready(AXI_uart.b_ready),  // input wire s_axi_bready
      .s_axi_araddr(AXI_uart.ar_addr[0+:4]),  // input wire [3 : 0] s_axi_araddr
      .s_axi_arvalid(AXI_uart.ar_valid),  // input wire s_axi_arvalid
      .s_axi_arready(AXI_uart.ar_ready),  // output wire s_axi_arready
      .s_axi_rdata(AXI_uart.r_data),  // output wire [31 : 0] s_axi_rdata
      .s_axi_rresp(AXI_uart.r_resp),  // output wire [1 : 0] s_axi_rresp
      .s_axi_rvalid(AXI_uart.r_valid),  // output wire s_axi_rvalid
      .s_axi_rready(AXI_uart.r_ready),  // input wire s_axi_rready

      .rx(rx_i),  // input wire rx
      .tx(tx_o)   // output wire tx
  );

endmodule 
