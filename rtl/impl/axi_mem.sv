module axi_mem #(
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ID_WIDTH = 16,
    parameter AXI_USER_WIDTH = 10
) (
    input logic clk_i,
    input logic rst_ni,

    AXI_BUS.Slave AXI_Slave
);
  localparam MEM_SIZE = 17;
  localparam INIT_FILE = "C:/Users/kersz/Documents/ufrgs/IC/cv32e40p/programs/basic/basic.hex";

  axi_ram #(
      // Width of data bus in bits
      .DATA_WIDTH     (AXI_ADDR_WIDTH),
      // Width of address bus in bits
      .ADDR_WIDTH     (MEM_SIZE),
      // Width of wstrb (width of data bus in words)
      .STRB_WIDTH     ((AXI_DATA_WIDTH / 8)),
      // Width of ID signal
      .ID_WIDTH       (AXI_ID_WIDTH),
      // Extra pipeline register on output
      .PIPELINE_OUTPUT(0),
      .INIT_FILE      (INIT_FILE)
  ) u_axi_ram (
      .clk(clk_i),
      .rst(!rst_ni),

      .s_axi_awid   (AXI_Slave.aw_id),
      .s_axi_awaddr (AXI_Slave.aw_addr),
      .s_axi_awlen  (AXI_Slave.aw_len),
      .s_axi_awsize (AXI_Slave.aw_size),
      .s_axi_awburst(AXI_Slave.aw_burst),
      .s_axi_awlock (AXI_Slave.aw_lock),
      .s_axi_awcache(AXI_Slave.aw_cache),
      .s_axi_awprot (AXI_Slave.aw_prot),
      .s_axi_awvalid(AXI_Slave.aw_valid),
      .s_axi_awready(AXI_Slave.aw_ready),
      .s_axi_wdata  (AXI_Slave.w_data),
      .s_axi_wstrb  (AXI_Slave.w_strb),
      .s_axi_wlast  (AXI_Slave.w_last),
      .s_axi_wvalid (AXI_Slave.w_valid),
      .s_axi_wready (AXI_Slave.w_ready),
      .s_axi_bid    (AXI_Slave.b_id),
      .s_axi_bresp  (AXI_Slave.b_resp),
      .s_axi_bvalid (AXI_Slave.b_valid),
      .s_axi_bready (AXI_Slave.b_ready),
      .s_axi_arid   (AXI_Slave.ar_id),
      .s_axi_araddr (AXI_Slave.ar_addr),
      .s_axi_arlen  (AXI_Slave.ar_len),
      .s_axi_arsize (AXI_Slave.ar_size),
      .s_axi_arburst(AXI_Slave.ar_burst),
      .s_axi_arlock (AXI_Slave.ar_lock),
      .s_axi_arcache(AXI_Slave.ar_cache),
      .s_axi_arprot (AXI_Slave.ar_prot),
      .s_axi_arvalid(AXI_Slave.ar_valid),
      .s_axi_arready(AXI_Slave.ar_ready),
      .s_axi_rid    (AXI_Slave.r_id),
      .s_axi_rdata  (AXI_Slave.r_data),
      .s_axi_rresp  (AXI_Slave.r_resp),
      .s_axi_rlast  (AXI_Slave.r_last),
      .s_axi_rvalid (AXI_Slave.r_valid),
      .s_axi_rready (AXI_Slave.r_ready)
  );
endmodule
