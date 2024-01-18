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
endmodule
