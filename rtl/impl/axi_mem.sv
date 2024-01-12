module axi_mem #(
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ID_WIDTH = 16,
    parameter AXI_USER_WIDTH = 10,
    parameter LOGGING = 0
) (
    input logic clk_i,
    input logic rst_ni,

    AXI_BUS.Slave AXI_Slave
);
  
  wire rsta_busy;
  wire rstb_busy;
 
  // BRAM AXI Access
  dp_axi_bram mem (
      .rsta_busy(rsta_busy),  // output wire rsta_busy
      .rstb_busy(rstb_busy),  // output wire rstb_busy

      .s_aclk   (clk_i),  // input wire s_aclk
      .s_aresetn(rst_ni), // input wire s_aresetn

      .s_axi_awid   (AXI_Slave.aw_id),     // input wire [0 : 0] s_axi_awid
      .s_axi_awaddr (AXI_Slave.aw_addr),   // input wire [31 : 0] s_axi_awaddr
      .s_axi_awlen  (AXI_Slave.aw_len),    // input wire [7 : 0] s_axi_awlen
      .s_axi_awsize (AXI_Slave.aw_size),   // input wire [2 : 0] s_axi_awsize
      .s_axi_awburst(AXI_Slave.aw_burst),  // input wire [1 : 0] s_axi_awburst
      .s_axi_awvalid(AXI_Slave.aw_valid),  // input wire s_axi_awvalid
      .s_axi_awready(AXI_Slave.aw_ready),  // output wire s_axi_awready
      .s_axi_wdata  (AXI_Slave.w_data),    // input wire [31 : 0] s_axi_wdata
      .s_axi_wstrb  (AXI_Slave.w_strb),    // input wire [3 : 0] s_axi_wstrb
      .s_axi_wlast  (AXI_Slave.w_last),    // input wire s_axi_wlast
      .s_axi_wvalid (AXI_Slave.w_valid),   // input wire s_axi_wvalid
      .s_axi_wready (AXI_Slave.w_ready),   // output wire s_axi_wready
      .s_axi_bid    (AXI_Slave.b_id),      // output wire [0 : 0] s_axi_bid
      .s_axi_bresp  (AXI_Slave.b_resp),    // output wire [1 : 0] s_axi_bresp
      .s_axi_bvalid (AXI_Slave.b_valid),   // output wire s_axi_bvalid
      .s_axi_bready (AXI_Slave.b_ready),   // input wire s_axi_bready
      .s_axi_arid   (AXI_Slave.ar_id),     // input wire [0 : 0] s_axi_arid
      .s_axi_araddr (AXI_Slave.ar_addr),   // input wire [31 : 0] s_axi_araddr
      .s_axi_arlen  (AXI_Slave.ar_len),    // input wire [7 : 0] s_axi_arlen
      .s_axi_arsize (AXI_Slave.ar_size),   // input wire [2 : 0] s_axi_arsize
      .s_axi_arburst(AXI_Slave.ar_burst),  // input wire [1 : 0] s_axi_arburst
      .s_axi_arvalid(AXI_Slave.ar_valid),  // input wire s_axi_arvalid
      .s_axi_arready(AXI_Slave.ar_ready),  // output wire s_axi_arready
      .s_axi_rid    (AXI_Slave.r_id),      // output wire [0 : 0] s_axi_rid
      .s_axi_rdata  (AXI_Slave.r_data),    // output wire [31 : 0] s_axi_rdata
      .s_axi_rresp  (AXI_Slave.r_resp),    // output wire [1 : 0] s_axi_rresp
      .s_axi_rlast  (AXI_Slave.r_last),    // output wire s_axi_rlast
      .s_axi_rvalid (AXI_Slave.r_valid),   // output wire s_axi_rvalid
      .s_axi_rready (AXI_Slave.r_ready)    // input wire s_axi_rready
  );

  assign AXI_Slave.b_user = AXI_Slave.w_user;
  assign AXI_Slave.r_user = AXI_Slave.ar_user;

  generate
    if (LOGGING) begin
      always @(posedge clk_i) begin
        if (AXI_Slave.ar_valid)
          $display("addr=0x%08x: data=0x%08x", AXI_Slave.ar_addr, AXI_Slave.r_data);
        if (AXI_Slave.aw_valid)
          $display("write addr=0x%08x: data=0x%08x", AXI_Slave.aw_addr, AXI_Slave.w_data);
      end
    end
  endgenerate
endmodule
