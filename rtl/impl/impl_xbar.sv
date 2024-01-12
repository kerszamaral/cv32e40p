module impl_xbar #(
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ID_WIDTH = 16,
    parameter AXI_USER_WIDTH = 1,
    parameter MASTER_NUM = 2,
    parameter SLAVE_NUM = 3,
    parameter OLD = 1
) (
    input logic clk_i,
    input logic rst_ni,

    input axi_pkg::xbar_rule_32_t [SLAVE_NUM-1:0] addr_map_i,

    AXI_BUS.Slave AXI_Slaves[MASTER_NUM-1:0],

    AXI_BUS.Master AXI_Masters[SLAVE_NUM-1:0]
);

  generate
    ;
    if (OLD == 0) begin : g_new_xbar
      // Crossbar configuration
      localparam FALLTHROUGH = 1'b0;
      localparam axi_pkg::xbar_cfg_t xbar_cfg = '{
          NoSlvPorts: MASTER_NUM,
          NoMstPorts: SLAVE_NUM,
          MaxMstTrans: 2,
          MaxSlvTrans: 2,
          FallThrough: FALLTHROUGH,
          LatencyMode: axi_pkg::NO_LATENCY,
          PipelineStages: 1'b0,  /// Pipeline stages in the xbar itself (between demux and mux).

          /// AXI4+ATOP ID width of the masters connected to the slave ports of the DUT.
          /// The ID width of the slaves is calculated depending on the xbar configuration.
          AxiIdWidthSlvPorts:
          AXI_USER_WIDTH,

          /// The used ID width of the DUT.
          /// Has to be `TbAxiIdWidthMasters >= TbAxiIdUsed`.
          AxiIdUsedSlvPorts:
          AXI_USER_WIDTH,
          UniqueIds: 1'b0,  /// Restrict to only unique IDs
          AxiAddrWidth: AXI_ADDR_WIDTH,
          AxiDataWidth: AXI_DATA_WIDTH,
          NoAddrRules: SLAVE_NUM
      };

      // AXI_LITE #(
      //    .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
      //    .AXI_DATA_WIDTH(AXI_DATA_WIDTH)
      // ) AXI_lite_mst[MASTER_NUM-1:0] (), AXI_lite_slv[SLAVE_NUM-1:0] ();

      // genvar i;
      // for (i = 0; i < MASTER_NUM; i = i + 1) begin : g_master_converter
      //    axi_to_axi_lite_intf #(
      //      .AXI_ID_WIDTH      (AXI_ID_WIDTH),
      //      .AXI_ADDR_WIDTH    (AXI_ADDR_WIDTH),
      //      .AXI_DATA_WIDTH    (AXI_DATA_WIDTH),
      //      .AXI_USER_WIDTH    (AXI_USER_WIDTH),
      //      .AXI_MAX_WRITE_TXNS(32'd1),
      //      .AXI_MAX_READ_TXNS (32'd1),
      //      .FALL_THROUGH      (FALLTHROUGH)
      //    ) lite_to_axi (
      //      .clk_i     (clk_i),
      //      .rst_ni    (rst_ni),
      //      .testmode_i(1'b0),
      //      .slv       (AXI_Slaves[i]),
      //      .mst       (AXI_lite_mst[i])
      //    );
      // end

      // genvar j;
      // for (j = 0; j < SLAVE_NUM; j = j + 1) begin : g_slave_converter
      //    axi_lite_to_axi_intf #(
      //      .AXI_DATA_WIDTH(AXI_DATA_WIDTH)
      //    ) lite_to_axi (
      //      .in(AXI_lite_slv[j]),
      //      .out(AXI_Masters[j]),
      //      .slv_aw_cache_i(0),
      //      .slv_ar_cache_i(0)
      //    );
      // end

      // // AXI4 Crossbar
      // axi_lite_xbar_intf #(
      //     .Cfg(xbar_cfg),
      //     .rule_t(axi_pkg::xbar_rule_32_t)
      // ) xbar (
      //     .clk_i   (clk_i),    // input wire clk_i
      //     .rst_ni  (rst_ni),   // input wire rst_ni
      //     .test_i('0),  // input wire test_i
      //     .slv_ports(AXI_lite_mst),
      //     .mst_ports(AXI_lite_slv),
      //     .addr_map_i(addr_map_i),
      //     .en_default_mst_port_i('0),
      //     .default_mst_port_i('0)
      // )

      //   assign AXI_Masters[1].b_valid = AXI_Slaves[0].b_valid;
      //   always_comb
      //     if (AXI_Slaves[0].b_valid) test1 = 1;
      //     else test1 = 0;
      //   always_comb
      //     if (AXI_Slaves[0].b_valid) AXI_Slaves[1].b_valid = 1;
      //     else AXI_Slaves[1].b_valid = 0;
      axi_xbar_intf #(
          .AXI_USER_WIDTH(AXI_USER_WIDTH),
          .Cfg(xbar_cfg),
          .ATOPS(1'b0),
          .rule_t(axi_pkg::xbar_rule_32_t)
      ) xbar (
          .clk_i   (clk_i),    // input wire clk_i
          .rst_ni  (rst_ni),   // input wire rst_ni
          .test_i('0),  // input wire test_i
          .slv_ports(AXI_Slaves),
          .mst_ports(AXI_Masters),
          .addr_map_i(addr_map_i),
          .en_default_mst_port_i('0),
          .default_mst_port_i('0)
      );
    end else begin : g_old_xbar
      localparam ADDRSIZE = 32;
      localparam PROTSIZE = 3;
      localparam VALIDSIZE = 1;
      localparam READYSIZE = 1;
      localparam DATASIZE = 32;
      localparam STRBSIZE = 4;
      localparam RESPSIZE = 2;

      // Crossbar Master Wires
      wire [ (ADDRSIZE*MASTER_NUM)-1:0] s_axi_awaddr;
      wire [ (PROTSIZE*MASTER_NUM)-1:0] s_axi_awprot;
      wire [(VALIDSIZE*MASTER_NUM)-1:0] s_axi_awvalid;
      wire [(READYSIZE*MASTER_NUM)-1:0] s_axi_awready;
      wire [ (DATASIZE*MASTER_NUM)-1:0] s_axi_wdata;
      wire [ (STRBSIZE*MASTER_NUM)-1:0] s_axi_wstrb;
      wire [(VALIDSIZE*MASTER_NUM)-1:0] s_axi_wvalid;
      wire [(READYSIZE*MASTER_NUM)-1:0] s_axi_wready;
      wire [ (RESPSIZE*MASTER_NUM)-1:0] s_axi_bresp;
      wire [(VALIDSIZE*MASTER_NUM)-1:0] s_axi_bvalid;
      wire [(READYSIZE*MASTER_NUM)-1:0] s_axi_bready;
      wire [ (ADDRSIZE*MASTER_NUM)-1:0] s_axi_araddr;
      wire [ (PROTSIZE*MASTER_NUM)-1:0] s_axi_arprot;
      wire [(VALIDSIZE*MASTER_NUM)-1:0] s_axi_arvalid;
      wire [(READYSIZE*MASTER_NUM)-1:0] s_axi_arready;
      wire [ (DATASIZE*MASTER_NUM)-1:0] s_axi_rdata;
      wire [ (RESPSIZE*MASTER_NUM)-1:0] s_axi_rresp;
      wire [(VALIDSIZE*MASTER_NUM)-1:0] s_axi_rvalid;
      wire [(READYSIZE*MASTER_NUM)-1:0] s_axi_rready;

      genvar i;
      for (i = 0; i < MASTER_NUM; i = i + 1) begin : g_master
        assign s_axi_awaddr[(i*ADDRSIZE)+:ADDRSIZE] = AXI_Slaves[i].aw_addr;
        assign s_axi_awprot[(i*PROTSIZE)+:PROTSIZE] = AXI_Slaves[i].aw_prot;
        assign s_axi_awvalid[(i*VALIDSIZE)+:VALIDSIZE] = AXI_Slaves[i].aw_valid;
        assign AXI_Slaves[i].aw_ready = s_axi_awready[(i*READYSIZE)+:READYSIZE];
        assign s_axi_wdata[(i*DATASIZE)+:DATASIZE] = AXI_Slaves[i].w_data;
        assign s_axi_wstrb[(i*STRBSIZE)+:STRBSIZE] = AXI_Slaves[i].w_strb;
        assign s_axi_wvalid[(i*VALIDSIZE)+:VALIDSIZE] = AXI_Slaves[i].w_valid;
        assign AXI_Slaves[i].w_ready = s_axi_wready[(i*READYSIZE)+:READYSIZE];
        assign AXI_Slaves[i].b_resp = s_axi_bresp[(i*RESPSIZE)+:RESPSIZE];
        assign AXI_Slaves[i].b_valid = s_axi_bvalid[(i*VALIDSIZE)+:VALIDSIZE];
        assign s_axi_bready[(i*READYSIZE)+:READYSIZE] = AXI_Slaves[i].b_ready;
        assign s_axi_araddr[(i*ADDRSIZE)+:ADDRSIZE] = AXI_Slaves[i].ar_addr;
        assign s_axi_arprot[(i*PROTSIZE)+:PROTSIZE] = AXI_Slaves[i].ar_prot;
        assign s_axi_arvalid[(i*VALIDSIZE)+:VALIDSIZE] = AXI_Slaves[i].ar_valid;
        assign AXI_Slaves[i].ar_ready = s_axi_arready[(i*READYSIZE)+:READYSIZE];
        assign AXI_Slaves[i].r_data = s_axi_rdata[(i*DATASIZE)+:DATASIZE];
        assign AXI_Slaves[i].r_resp = s_axi_rresp[(i*RESPSIZE)+:RESPSIZE];
        assign AXI_Slaves[i].r_valid = s_axi_rvalid[(i*VALIDSIZE)+:VALIDSIZE];
        assign s_axi_rready[(i*READYSIZE)+:READYSIZE] = AXI_Slaves[i].r_ready;

        assign AXI_Slaves[i].b_id = AXI_Slaves[i].aw_id;
        assign AXI_Slaves[i].b_user = AXI_Slaves[i].w_user;
        assign AXI_Slaves[i].r_user = AXI_Slaves[i].ar_user;
        assign AXI_Slaves[i].r_id = AXI_Slaves[i].ar_id;
        assign AXI_Slaves[i].r_last = 1'b1;
      end

      // Crossbar Slave Wires
      wire [ (ADDRSIZE*SLAVE_NUM)-1:0] m_axi_awaddr;
      wire [ (PROTSIZE*SLAVE_NUM)-1:0] m_axi_awprot;
      wire [(VALIDSIZE*SLAVE_NUM)-1:0] m_axi_awvalid;
      wire [(READYSIZE*SLAVE_NUM)-1:0] m_axi_awready;
      wire [ (DATASIZE*SLAVE_NUM)-1:0] m_axi_wdata;
      wire [ (STRBSIZE*SLAVE_NUM)-1:0] m_axi_wstrb;
      wire [(VALIDSIZE*SLAVE_NUM)-1:0] m_axi_wvalid;
      wire [(READYSIZE*SLAVE_NUM)-1:0] m_axi_wready;
      wire [ (RESPSIZE*SLAVE_NUM)-1:0] m_axi_bresp;
      wire [(VALIDSIZE*SLAVE_NUM)-1:0] m_axi_bvalid;
      wire [(READYSIZE*SLAVE_NUM)-1:0] m_axi_bready;
      wire [ (ADDRSIZE*SLAVE_NUM)-1:0] m_axi_araddr;
      wire [ (PROTSIZE*SLAVE_NUM)-1:0] m_axi_arprot;
      wire [(VALIDSIZE*SLAVE_NUM)-1:0] m_axi_arvalid;
      wire [(READYSIZE*SLAVE_NUM)-1:0] m_axi_arready;
      wire [ (DATASIZE*SLAVE_NUM)-1:0] m_axi_rdata;
      wire [ (RESPSIZE*SLAVE_NUM)-1:0] m_axi_rresp;
      wire [(VALIDSIZE*SLAVE_NUM)-1:0] m_axi_rvalid;
      wire [(READYSIZE*SLAVE_NUM)-1:0] m_axi_rready;

      // MEM Conversion
      AXI_LITE #(
          .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
          .AXI_DATA_WIDTH(AXI_DATA_WIDTH)
      ) AXI_slaves_lite[SLAVE_NUM-1:0] ();

      genvar j;
      for (j = 0; j < SLAVE_NUM; j = j + 1) begin : g_slaves
        axi_lite_to_axi_intf #(
            .AXI_DATA_WIDTH(AXI_DATA_WIDTH)
        ) u_axi_lite_to_axi_intf_slaves (
            .in            (AXI_slaves_lite[j]),
            .slv_aw_cache_i('0),
            .slv_ar_cache_i('0),
            .out           (AXI_Masters[j])
        );

        assign AXI_slaves_lite[j].aw_addr = m_axi_awaddr[(j*ADDRSIZE)+:ADDRSIZE];
        assign AXI_slaves_lite[j].aw_prot = m_axi_awprot[(j*PROTSIZE)+:PROTSIZE];
        assign AXI_slaves_lite[j].aw_valid = m_axi_awvalid[(j*VALIDSIZE)+:VALIDSIZE];
        assign m_axi_awready[(j*READYSIZE)+:READYSIZE] = AXI_slaves_lite[j].aw_ready;

        assign AXI_slaves_lite[j].w_data = m_axi_wdata[(j*DATASIZE)+:DATASIZE];
        assign AXI_slaves_lite[j].w_strb = m_axi_wstrb[(j*STRBSIZE)+:STRBSIZE];
        assign AXI_slaves_lite[j].w_valid = m_axi_wvalid[(j*VALIDSIZE)+:VALIDSIZE];
        assign m_axi_wready[(j*READYSIZE)+:READYSIZE] = AXI_slaves_lite[j].w_ready;

        assign m_axi_bresp[(j*RESPSIZE)+:RESPSIZE] = AXI_slaves_lite[j].b_resp;
        assign m_axi_bvalid[(j*VALIDSIZE)+:VALIDSIZE] = AXI_slaves_lite[j].b_valid;
        assign AXI_slaves_lite[j].b_ready = m_axi_bready[(j*READYSIZE)+:READYSIZE];

        assign AXI_slaves_lite[j].ar_addr = m_axi_araddr[(j*ADDRSIZE)+:ADDRSIZE];
        assign AXI_slaves_lite[j].ar_prot = m_axi_arprot[(j*PROTSIZE)+:PROTSIZE];
        assign AXI_slaves_lite[j].ar_valid = m_axi_arvalid[(j*VALIDSIZE)+:VALIDSIZE];
        assign m_axi_arready[(j*READYSIZE)+:READYSIZE] = AXI_slaves_lite[j].ar_ready;

        assign m_axi_rdata[(j*DATASIZE)+:DATASIZE] = AXI_slaves_lite[j].r_data;
        assign m_axi_rresp[(j*RESPSIZE)+:RESPSIZE] = AXI_slaves_lite[j].r_resp;
        assign m_axi_rvalid[(j*VALIDSIZE)+:VALIDSIZE] = AXI_slaves_lite[j].r_valid;
        assign AXI_slaves_lite[j].r_ready = m_axi_rready[(j*READYSIZE)+:READYSIZE];
      end

      axi_crossbar_0 data_crossbar (
          .aclk   (clk_i),    // input wire aclk
          .aresetn(rst_ni), // input wire aresetn

          .s_axi_awaddr (s_axi_awaddr),   // input wire [63 : 0] s_axi_awaddr
          .s_axi_awprot (s_axi_awprot),   // input wire [5 : 0] s_axi_awprot
          .s_axi_awvalid(s_axi_awvalid),  // input wire [1 : 0] s_axi_awvalid
          .s_axi_awready(s_axi_awready),  // output wire [1 : 0] s_axi_awready
          .s_axi_wdata  (s_axi_wdata),    // input wire [63 : 0] s_axi_wdata
          .s_axi_wstrb  (s_axi_wstrb),    // input wire [7 : 0] s_axi_wstrb
          .s_axi_wvalid (s_axi_wvalid),   // input wire [1 : 0] s_axi_wvalid
          .s_axi_wready (s_axi_wready),   // output wire [1 : 0] s_axi_wready
          .s_axi_bresp  (s_axi_bresp),    // output wire [3 : 0] s_axi_bresp
          .s_axi_bvalid (s_axi_bvalid),   // output wire [1 : 0] s_axi_bvalid
          .s_axi_bready (s_axi_bready),   // input wire [1 : 0] s_axi_bready
          .s_axi_araddr (s_axi_araddr),   // input wire [63 : 0] s_axi_araddr
          .s_axi_arprot (s_axi_arprot),   // input wire [5 : 0] s_axi_arprot
          .s_axi_arvalid(s_axi_arvalid),  // input wire [1 : 0] s_axi_arvalid
          .s_axi_arready(s_axi_arready),  // output wire [1 : 0] s_axi_arready
          .s_axi_rdata  (s_axi_rdata),    // output wire [63 : 0] s_axi_rdata
          .s_axi_rresp  (s_axi_rresp),    // output wire [3 : 0] s_axi_rresp
          .s_axi_rvalid (s_axi_rvalid),   // output wire [1 : 0] s_axi_rvalid
          .s_axi_rready (s_axi_rready),   // input wire [1 : 0] s_axi_rready


          .m_axi_awaddr (m_axi_awaddr),   // output wire [95 : 0] m_axi_awaddr
          .m_axi_awprot (m_axi_awprot),   // output wire [8 : 0] m_axi_awprot
          .m_axi_awvalid(m_axi_awvalid),  // output wire [2 : 0] m_axi_awvalid
          .m_axi_awready(m_axi_awready),  // input wire [2 : 0] m_axi_awready
          .m_axi_wdata  (m_axi_wdata),    // output wire [95 : 0] m_axi_wdata
          .m_axi_wstrb  (m_axi_wstrb),    // output wire [11 : 0] m_axi_wstrb
          .m_axi_wvalid (m_axi_wvalid),   // output wire [2 : 0] m_axi_wvalid
          .m_axi_wready (m_axi_wready),   // input wire [2 : 0] m_axi_wready
          .m_axi_bresp  (m_axi_bresp),    // input wire [5 : 0] m_axi_bresp
          .m_axi_bvalid (m_axi_bvalid),   // input wire [2 : 0] m_axi_bvalid
          .m_axi_bready (m_axi_bready),   // output wire [2 : 0] m_axi_bready
          .m_axi_araddr (m_axi_araddr),   // output wire [95 : 0] m_axi_araddr
          .m_axi_arprot (m_axi_arprot),   // output wire [8 : 0] m_axi_arprot
          .m_axi_arvalid(m_axi_arvalid),  // output wire [2 : 0] m_axi_arvalid
          .m_axi_arready(m_axi_arready),  // input wire [2 : 0] m_axi_arready
          .m_axi_rdata  (m_axi_rdata),    // input wire [95 : 0] m_axi_rdata
          .m_axi_rresp  (m_axi_rresp),    // input wire [5 : 0] m_axi_rresp
          .m_axi_rvalid (m_axi_rvalid),   // input wire [2 : 0] m_axi_rvalid
          .m_axi_rready (m_axi_rready)    // output wire [2 : 0] m_axi_rready
      );
    end
    endgenerate

endmodule
