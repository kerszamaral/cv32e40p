module impl_xbar #(
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ID_WIDTH = 16,
    parameter AXI_USER_WIDTH = 10,
    parameter MASTER_NUM = 2,
    parameter SLAVE_NUM = 3
) (
    input logic clk_i,
    input logic rst_ni,

    input  axi_pkg::xbar_rule_32_t [SLAVE_NUM-1:0] addr_map_i,

    AXI_BUS.Slave AXI_Slaves [MASTER_NUM-1:0],

    AXI_BUS.Master AXI_Masters [SLAVE_NUM-1:0]
);

  // Crossbar configuration
  localparam axi_pkg::xbar_cfg_t xbar_cfg = '{
      NoSlvPorts: MASTER_NUM,
      NoMstPorts: SLAVE_NUM,
      MaxMstTrans: 1,
      MaxSlvTrans: 1,
      FallThrough: 1'b0,
      LatencyMode: axi_pkg::CUT_ALL_AX,
      PipelineStages: 1'b1,  /// Pipeline stages in the xbar itself (between demux and mux).

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

  // AXI4 Crossbar
  axi_xbar_intf #(
      .AXI_USER_WIDTH(AXI_USER_WIDTH),
      .Cfg(xbar_cfg),
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

endmodule
