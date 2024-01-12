module impl_xbar #(
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ID_WIDTH = 16,
    parameter AXI_USER_WIDTH = 1,
    parameter MASTER_NUM = 2,
    parameter SLAVE_NUM = 3,
    parameter OLD = 0
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
      localparam axi_pkg::xbar_cfg_t xbar_cfg = '{
          NoSlvPorts: MASTER_NUM,
          NoMstPorts: SLAVE_NUM,
          MaxMstTrans: 2,
          MaxSlvTrans: 2,
          FallThrough: 1'b0,
          LatencyMode: axi_pkg::NO_LATENCY,
          PipelineStages: 32'd0,  /// Pipeline stages in the xbar itself (between demux and mux).

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

      axi_xp_intf #(
          .ATOPs(1'b0),
          .Cfg(xbar_cfg),
          .NumSlvPorts(MASTER_NUM),
          .NumMstPorts(SLAVE_NUM),
          .AxiAddrWidth(AXI_ADDR_WIDTH),
          .AxiDataWidth(AXI_DATA_WIDTH),
          .AxiIdWidth(AXI_ID_WIDTH),
          .AxiUserWidth(AXI_USER_WIDTH),
          .AxiSlvPortMaxUniqIds(1),
          .AxiSlvPortMaxTxnsPerId(1),
          .AxiSlvPortMaxTxns(1),
          .AxiMstPortMaxUniqIds(1),
          .AxiMstPortMaxTxnsPerId(1),
          .NumAddrRules(SLAVE_NUM),
          .rule_t(axi_pkg::xbar_rule_32_t)
      ) xbar_test (
          .clk_i   (clk_i),    // input wire clk_i
          .rst_ni  (rst_ni),   // input wire rst_ni
          .test_en_i('0),  // input wire test_i
          .slv_ports(AXI_Slaves),
          .mst_ports(AXI_Masters),
          .addr_map_i(addr_map_i)
      );
    end else begin : g_old_xbar
      localparam ADDRSIZE = 32;
      localparam PROTSIZE = 3;
      localparam VALIDSIZE = 1;
      localparam READYSIZE = 1;
      localparam DATASIZE = 32;
      localparam STRBSIZE = 4;
      localparam RESPSIZE = 2;

      localparam IDSIZE = 1;
      localparam LENSIZE = 8;
      localparam SIZESIZE = 3;
      localparam BURSTSIZE = 2;
      localparam LOCKSIZE = 1;
      localparam CACHESIZE = 4;
      localparam QOSSIZE = 4;
      localparam LASTSIZE = 1;
      localparam REGIONSIZE = 4;

      // Crossbar Master Wires
      wire [(ADDRSIZE*MASTER_NUM)-1:0] s_axi_awaddr;
      wire [(PROTSIZE*MASTER_NUM)-1:0] s_axi_awprot;
      wire [(VALIDSIZE*MASTER_NUM)-1:0] s_axi_awvalid;
      wire [(READYSIZE*MASTER_NUM)-1:0] s_axi_awready;
      wire [(DATASIZE*MASTER_NUM)-1:0] s_axi_wdata;
      wire [(STRBSIZE*MASTER_NUM)-1:0] s_axi_wstrb;
      wire [(VALIDSIZE*MASTER_NUM)-1:0] s_axi_wvalid;
      wire [(READYSIZE*MASTER_NUM)-1:0] s_axi_wready;
      wire [(RESPSIZE*MASTER_NUM)-1:0] s_axi_bresp;
      wire [(VALIDSIZE*MASTER_NUM)-1:0] s_axi_bvalid;
      wire [(READYSIZE*MASTER_NUM)-1:0] s_axi_bready;
      wire [(ADDRSIZE*MASTER_NUM)-1:0] s_axi_araddr;
      wire [(PROTSIZE*MASTER_NUM)-1:0] s_axi_arprot;
      wire [(VALIDSIZE*MASTER_NUM)-1:0] s_axi_arvalid;
      wire [(READYSIZE*MASTER_NUM)-1:0] s_axi_arready;
      wire [(DATASIZE*MASTER_NUM)-1:0] s_axi_rdata;
      wire [(RESPSIZE*MASTER_NUM)-1:0] s_axi_rresp;
      wire [(VALIDSIZE*MASTER_NUM)-1:0] s_axi_rvalid;
      wire [(READYSIZE*MASTER_NUM)-1:0] s_axi_rready;

      wire [(IDSIZE*MASTER_NUM)-1:0] s_axi_awid;
      wire [(LENSIZE*MASTER_NUM)-1:0] s_axi_awlen;
      wire [(SIZESIZE*MASTER_NUM)-1:0] s_axi_awsize;
      wire [(BURSTSIZE*MASTER_NUM)-1:0] s_axi_awburst;
      wire [(LOCKSIZE*MASTER_NUM)-1:0] s_axi_awlock;
      wire [(CACHESIZE*MASTER_NUM)-1:0] s_axi_awcache;
      wire [(QOSSIZE*MASTER_NUM)-1:0] s_axi_awqos;
      wire [(LASTSIZE*MASTER_NUM)-1:0] s_axi_wlast;
      wire [(IDSIZE*MASTER_NUM)-1:0] s_axi_bid;
      wire [(IDSIZE*MASTER_NUM)-1:0] s_axi_arid;
      wire [(LENSIZE*MASTER_NUM)-1:0] s_axi_arlen;
      wire [(SIZESIZE*MASTER_NUM)-1:0] s_axi_arsize;
      wire [(BURSTSIZE*MASTER_NUM)-1:0] s_axi_arburst;
      wire [(LOCKSIZE*MASTER_NUM)-1:0] s_axi_arlock;
      wire [(CACHESIZE*MASTER_NUM)-1:0] s_axi_arcache;
      wire [(QOSSIZE*MASTER_NUM)-1:0] s_axi_arqos;
      wire [(IDSIZE*MASTER_NUM):0] s_axi_rid;
      wire [(LASTSIZE*MASTER_NUM)-1:0] s_axi_rlast;

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

        assign s_axi_awid[(i*IDSIZE)+:IDSIZE] = AXI_Slaves[i].aw_id;
        assign s_axi_awlen[(i*LENSIZE)+:LENSIZE] = AXI_Slaves[i].aw_len;
        assign s_axi_awsize[(i*SIZESIZE)+:SIZESIZE] = AXI_Slaves[i].aw_size;
        assign s_axi_awburst[(i*BURSTSIZE)+:BURSTSIZE] = AXI_Slaves[i].aw_burst;
        assign s_axi_awlock[(i*LOCKSIZE)+:LOCKSIZE] = AXI_Slaves[i].aw_lock;
        assign s_axi_awcache[(i*CACHESIZE)+:CACHESIZE] = AXI_Slaves[i].aw_cache;
        assign s_axi_awqos[(i*QOSSIZE)+:QOSSIZE] = AXI_Slaves[i].aw_qos;

        assign s_axi_wlast[(i*LASTSIZE)+:LASTSIZE] = AXI_Slaves[i].w_last;

        assign AXI_Slaves[i].b_id = s_axi_bid[(i*IDSIZE)+:IDSIZE];

        assign s_axi_arid[(i*IDSIZE)+:IDSIZE] = AXI_Slaves[i].ar_id;
        assign s_axi_arlen[(i*LENSIZE)+:LENSIZE] = AXI_Slaves[i].ar_len;
        assign s_axi_arsize[(i*SIZESIZE)+:SIZESIZE] = AXI_Slaves[i].ar_size;
        assign s_axi_arburst[(i*BURSTSIZE)+:BURSTSIZE] = AXI_Slaves[i].ar_burst;
        assign s_axi_arlock[(i*LOCKSIZE)+:LOCKSIZE] = AXI_Slaves[i].ar_lock;
        assign s_axi_arcache[(i*CACHESIZE)+:CACHESIZE] = AXI_Slaves[i].ar_cache;
        assign s_axi_arqos[(i*QOSSIZE)+:QOSSIZE] = AXI_Slaves[i].ar_qos;

        assign AXI_Slaves[i].r_id = s_axi_rid[(i*IDSIZE)+:IDSIZE];
        assign AXI_Slaves[i].r_last = s_axi_rlast[(i*LASTSIZE)+:LASTSIZE];

        assign AXI_Slaves[i].b_user = AXI_Slaves[i].w_user;
        assign AXI_Slaves[i].r_user = AXI_Slaves[i].ar_user;
      end

      // Crossbar Slave Wires
      wire [(ADDRSIZE*SLAVE_NUM)-1:0] m_axi_awaddr;
      wire [(PROTSIZE*SLAVE_NUM)-1:0] m_axi_awprot;
      wire [(VALIDSIZE*SLAVE_NUM)-1:0] m_axi_awvalid;
      wire [(READYSIZE*SLAVE_NUM)-1:0] m_axi_awready;
      wire [(DATASIZE*SLAVE_NUM)-1:0] m_axi_wdata;
      wire [(STRBSIZE*SLAVE_NUM)-1:0] m_axi_wstrb;
      wire [(VALIDSIZE*SLAVE_NUM)-1:0] m_axi_wvalid;
      wire [(READYSIZE*SLAVE_NUM)-1:0] m_axi_wready;
      wire [(RESPSIZE*SLAVE_NUM)-1:0] m_axi_bresp;
      wire [(VALIDSIZE*SLAVE_NUM)-1:0] m_axi_bvalid;
      wire [(READYSIZE*SLAVE_NUM)-1:0] m_axi_bready;
      wire [(ADDRSIZE*SLAVE_NUM)-1:0] m_axi_araddr;
      wire [(PROTSIZE*SLAVE_NUM)-1:0] m_axi_arprot;
      wire [(VALIDSIZE*SLAVE_NUM)-1:0] m_axi_arvalid;
      wire [(READYSIZE*SLAVE_NUM)-1:0] m_axi_arready;
      wire [(DATASIZE*SLAVE_NUM)-1:0] m_axi_rdata;
      wire [(RESPSIZE*SLAVE_NUM)-1:0] m_axi_rresp;
      wire [(VALIDSIZE*SLAVE_NUM)-1:0] m_axi_rvalid;
      wire [(READYSIZE*SLAVE_NUM)-1:0] m_axi_rready;

      wire [(LENSIZE*SLAVE_NUM)-1:0] m_axi_awlen;
      wire [(SIZESIZE*SLAVE_NUM)-1:0] m_axi_awsize;
      wire [(BURSTSIZE*SLAVE_NUM)-1:0] m_axi_awburst;
      wire [(LOCKSIZE*SLAVE_NUM)-1:0] m_axi_awlock;
      wire [(CACHESIZE*SLAVE_NUM)-1:0] m_axi_awcache;
      wire [(REGIONSIZE*SLAVE_NUM)-1:0] m_axi_awregion;
      wire [(QOSSIZE*SLAVE_NUM)-1:0] m_axi_awqos;
      wire [(LASTSIZE*SLAVE_NUM)-1:0] m_axi_wlast;
      wire [(LENSIZE*SLAVE_NUM)-1:0] m_axi_arlen;
      wire [(SIZESIZE*SLAVE_NUM)-1:0] m_axi_arsize;
      wire [(BURSTSIZE*SLAVE_NUM)-1:0] m_axi_arburst;
      wire [(LOCKSIZE*SLAVE_NUM)-1:0] m_axi_arlock;
      wire [(CACHESIZE*SLAVE_NUM)-1:0] m_axi_arcache;
      wire [(REGIONSIZE*SLAVE_NUM)-1:0] m_axi_arregion;
      wire [(QOSSIZE*SLAVE_NUM)-1:0] m_axi_arqos;
      wire [(LASTSIZE*SLAVE_NUM)-1:0] m_axi_rlast;

      genvar j;
      for (j = 0; j < SLAVE_NUM; j = j + 1) begin : g_slaves
        assign AXI_Masters[j].aw_addr = m_axi_awaddr[(j*ADDRSIZE)+:ADDRSIZE];
        assign AXI_Masters[j].aw_prot = m_axi_awprot[(j*PROTSIZE)+:PROTSIZE];
        assign AXI_Masters[j].aw_valid = m_axi_awvalid[(j*VALIDSIZE)+:VALIDSIZE];
        assign m_axi_awready[(j*READYSIZE)+:READYSIZE] = AXI_Masters[j].aw_ready;

        assign AXI_Masters[j].w_data = m_axi_wdata[(j*DATASIZE)+:DATASIZE];
        assign AXI_Masters[j].w_strb = m_axi_wstrb[(j*STRBSIZE)+:STRBSIZE];
        assign AXI_Masters[j].w_valid = m_axi_wvalid[(j*VALIDSIZE)+:VALIDSIZE];
        assign m_axi_wready[(j*READYSIZE)+:READYSIZE] = AXI_Masters[j].w_ready;

        assign m_axi_bresp[(j*RESPSIZE)+:RESPSIZE] = AXI_Masters[j].b_resp;
        assign m_axi_bvalid[(j*VALIDSIZE)+:VALIDSIZE] = AXI_Masters[j].b_valid;
        assign AXI_Masters[j].b_ready = m_axi_bready[(j*READYSIZE)+:READYSIZE];

        assign AXI_Masters[j].ar_addr = m_axi_araddr[(j*ADDRSIZE)+:ADDRSIZE];
        assign AXI_Masters[j].ar_prot = m_axi_arprot[(j*PROTSIZE)+:PROTSIZE];
        assign AXI_Masters[j].ar_valid = m_axi_arvalid[(j*VALIDSIZE)+:VALIDSIZE];
        assign m_axi_arready[(j*READYSIZE)+:READYSIZE] = AXI_Masters[j].ar_ready;

        assign m_axi_rdata[(j*DATASIZE)+:DATASIZE] = AXI_Masters[j].r_data;
        assign m_axi_rresp[(j*RESPSIZE)+:RESPSIZE] = AXI_Masters[j].r_resp;
        assign m_axi_rvalid[(j*VALIDSIZE)+:VALIDSIZE] = AXI_Masters[j].r_valid;
        assign AXI_Masters[j].r_ready = m_axi_rready[(j*READYSIZE)+:READYSIZE];

        assign AXI_Masters[j].aw_len = m_axi_awlen[(j*LENSIZE)+:LENSIZE];
        assign AXI_Masters[j].aw_size = m_axi_awsize[(j*SIZESIZE)+:SIZESIZE];
        assign AXI_Masters[j].aw_burst = m_axi_awburst[(j*BURSTSIZE)+:BURSTSIZE];
        assign AXI_Masters[j].aw_lock = m_axi_awlock[(j*LOCKSIZE)+:LOCKSIZE];
        assign AXI_Masters[j].aw_cache = m_axi_awcache[(j*CACHESIZE)+:CACHESIZE];
        assign AXI_Masters[j].aw_region = m_axi_awregion[(j*REGIONSIZE)+:REGIONSIZE];
        assign AXI_Masters[j].aw_qos = m_axi_awqos[(j*QOSSIZE)+:QOSSIZE];
        assign AXI_Masters[j].w_last = m_axi_wlast[(j*LASTSIZE)+:LASTSIZE];
        assign AXI_Masters[j].ar_len = m_axi_arlen[(j*LENSIZE)+:LENSIZE];
        assign AXI_Masters[j].ar_size = m_axi_arsize[(j*SIZESIZE)+:SIZESIZE];
        assign AXI_Masters[j].ar_burst = m_axi_arburst[(j*BURSTSIZE)+:BURSTSIZE];
        assign AXI_Masters[j].ar_lock = m_axi_arlock[(j*LOCKSIZE)+:LOCKSIZE];
        assign AXI_Masters[j].ar_cache = m_axi_arcache[(j*CACHESIZE)+:CACHESIZE];
        assign AXI_Masters[j].ar_region = m_axi_arregion[(j*REGIONSIZE)+:REGIONSIZE];
        assign AXI_Masters[j].ar_qos = m_axi_arqos[(j*QOSSIZE)+:QOSSIZE];
        assign m_axi_rlast[(j*LASTSIZE)+:LASTSIZE] = AXI_Masters[j].r_last;
      end

      axi_crossbar_0 your_instance_name (
          .aclk   (clk_i),  // input wire aclk
          .aresetn(rst_ni), // input wire aresetn

          .s_axi_awid   (s_axi_awid),     // input wire [1 : 0] s_axi_awid
          .s_axi_awlen  (s_axi_awlen),    // input wire [15 : 0] s_axi_awlen
          .s_axi_awsize (s_axi_awsize),   // input wire [5 : 0] s_axi_awsize
          .s_axi_awburst(s_axi_awburst),  // input wire [3 : 0] s_axi_awburst
          .s_axi_awlock (s_axi_awlock),   // input wire [1 : 0] s_axi_awlock
          .s_axi_awcache(s_axi_awcache),  // input wire [7 : 0] s_axi_awcache
          .s_axi_awqos  (s_axi_awqos),    // input wire [7 : 0] s_axi_awqos
          .s_axi_wlast  (s_axi_wlast),    // input wire [1 : 0] s_axi_wlast
          .s_axi_bid    (s_axi_bid),      // output wire [1 : 0] s_axi_bid
          .s_axi_arid   (s_axi_arid),     // input wire [1 : 0] s_axi_arid
          .s_axi_arlen  (s_axi_arlen),    // input wire [15 : 0] s_axi_arlen
          .s_axi_arsize (s_axi_arsize),   // input wire [5 : 0] s_axi_arsize
          .s_axi_arburst(s_axi_arburst),  // input wire [3 : 0] s_axi_arburst
          .s_axi_arlock (s_axi_arlock),   // input wire [1 : 0] s_axi_arlock
          .s_axi_arcache(s_axi_arcache),  // input wire [7 : 0] s_axi_arcache
          .s_axi_arqos  (s_axi_arqos),    // input wire [7 : 0] s_axi_arqos
          .s_axi_rid    (s_axi_rid),      // output wire [1 : 0] s_axi_rid
          .s_axi_rlast  (s_axi_rlast),    // output wire [1 : 0] s_axi_rlast

          .m_axi_awlen   (m_axi_awlen),     // output wire [23 : 0] m_axi_awlen
          .m_axi_awsize  (m_axi_awsize),    // output wire [8 : 0] m_axi_awsize
          .m_axi_awburst (m_axi_awburst),   // output wire [5 : 0] m_axi_awburst
          .m_axi_awlock  (m_axi_awlock),    // output wire [2 : 0] m_axi_awlock
          .m_axi_awcache (m_axi_awcache),   // output wire [11 : 0] m_axi_awcache
          .m_axi_awregion(m_axi_awregion),  // output wire [11 : 0] m_axi_awregion
          .m_axi_awqos   (m_axi_awqos),     // output wire [11 : 0] m_axi_awqos
          .m_axi_wlast   (m_axi_wlast),     // output wire [2 : 0] m_axi_wlast
          .m_axi_arlen   (m_axi_arlen),     // output wire [23 : 0] m_axi_arlen
          .m_axi_arsize  (m_axi_arsize),    // output wire [8 : 0] m_axi_arsize
          .m_axi_arburst (m_axi_arburst),   // output wire [5 : 0] m_axi_arburst
          .m_axi_arlock  (m_axi_arlock),    // output wire [2 : 0] m_axi_arlock
          .m_axi_arcache (m_axi_arcache),   // output wire [11 : 0] m_axi_arcache
          .m_axi_arregion(m_axi_arregion),  // output wire [11 : 0] m_axi_arregion
          .m_axi_arqos   (m_axi_arqos),     // output wire [11 : 0] m_axi_arqos
          .m_axi_rlast   (m_axi_rlast),     // input wire [2 : 0] m_axi_rlast



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
