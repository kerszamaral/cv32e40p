`include "assign.svh"

module axi_mm_ram #(
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ID_WIDTH = 16,
    parameter AXI_USER_WIDTH = 10,
    parameter LOGGING = 0
) (
    input logic clk_i,
    input logic rst_ni,

    // //! AXI4 Instruction Interface
    AXI_BUS.Slave instr,
    AXI_BUS.Slave data,

    // Interrupt outputs
    output logic [31:0] irq_o,      // CLINT interrupts + CLINT extension interrupts
    input  logic        irq_ack_i,
    input  logic [ 4:0] irq_id_i,

    output logic exit_valid_o,
    output logic exit_zero_o,

    input  logic rx_i,
    output logic tx_o
);

  /// Number of AXI masters connected to the xbar. (Number of slave ports)
  localparam MASTER_NUM = 2;
  /// Number of AXI slaves connected to the xbar. (Number of master ports)
  localparam SLAVE_NUM = 3;

  // Master IDs
  localparam INSTR = 0;
  localparam DATA = 1;

  // Slave IDs
  localparam MEM = 0;
  localparam UART = 1;
  localparam EXIT = 2;

  // Crossbar configuration
  localparam axi_pkg::xbar_cfg_t xbar_cfg = '{
      NoSlvPorts: MASTER_NUM,
      NoMstPorts: SLAVE_NUM,
      MaxMstTrans: 10,
      MaxSlvTrans: 6,
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

  typedef axi_pkg::xbar_rule_32_t rule_t;

  // Each slave has its own address range:
  localparam rule_t [xbar_cfg.NoAddrRules-1:0] AddrMap = addr_map_gen();
  function rule_t [xbar_cfg.NoAddrRules-1:0] addr_map_gen();
    addr_map_gen[MEM] = rule_t'{
        idx: unsigned'(MEM),
        start_addr: 32'h0000_0000,
        end_addr: 32'h1000_0000,
        default: '0
    };
    addr_map_gen[UART] = rule_t'{
        idx: unsigned'(UART),
        start_addr: 32'h1000_0000,
        end_addr: 32'h1000_0010,
        default: '0
    };
    addr_map_gen[EXIT] = rule_t'{
        idx: unsigned'(EXIT),
        start_addr: 32'h2000_0000,
        end_addr: 32'h2000_0010,
        default: '0
    };
  endfunction


  // AXI4 Interfaces
  AXI_BUS #(
      .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
      .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
      .AXI_ID_WIDTH  (AXI_ID_WIDTH),
      .AXI_USER_WIDTH(AXI_USER_WIDTH)
  )
      master[MASTER_NUM-1:0] (), slave[SLAVE_NUM-1:0] ();

  `AXI_ASSIGN(master[INSTR], instr)
  `AXI_ASSIGN(master[DATA], data)

  axi_xbar_intf #(
      .AXI_USER_WIDTH(AXI_USER_WIDTH),
      .Cfg(xbar_cfg),
      .rule_t(rule_t)
  ) xbar (
      .clk_i   (clk_i),    // input wire clk_i
      .rst_ni  (rst_ni),   // input wire rst_ni
      .test_i('0),  // input wire test_i
      .slv_ports(master),
      .mst_ports(slave),
      .addr_map_i(AddrMap),
      .en_default_mst_port_i('0),
      .default_mst_port_i('0)
  );

  wire rsta_busy;
  wire rstb_busy;

  // BRAM AXI Access
  dp_axi_bram mem (
      .rsta_busy(rsta_busy),  // output wire rsta_busy
      .rstb_busy(rstb_busy),  // output wire rstb_busy

      .s_aclk   (clk_i),  // input wire s_aclk
      .s_aresetn(rst_ni), // input wire s_aresetn

      .s_axi_awid   (slave[MEM].aw_id),     // input wire [0 : 0] s_axi_awid
      .s_axi_awaddr (slave[MEM].aw_addr),   // input wire [31 : 0] s_axi_awaddr
      .s_axi_awlen  (slave[MEM].aw_len),    // input wire [7 : 0] s_axi_awlen
      .s_axi_awsize (slave[MEM].aw_size),   // input wire [2 : 0] s_axi_awsize
      .s_axi_awburst(slave[MEM].aw_burst),  // input wire [1 : 0] s_axi_awburst
      .s_axi_awvalid(slave[MEM].aw_valid),  // input wire s_axi_awvalid
      .s_axi_awready(slave[MEM].aw_ready),  // output wire s_axi_awready
      .s_axi_wdata  (slave[MEM].w_data),    // input wire [31 : 0] s_axi_wdata
      .s_axi_wstrb  (slave[MEM].w_strb),    // input wire [3 : 0] s_axi_wstrb
      .s_axi_wlast  (slave[MEM].w_last),    // input wire s_axi_wlast
      .s_axi_wvalid (slave[MEM].w_valid),   // input wire s_axi_wvalid
      .s_axi_wready (slave[MEM].w_ready),   // output wire s_axi_wready
      .s_axi_bid    (slave[MEM].b_id),      // output wire [0 : 0] s_axi_bid
      .s_axi_bresp  (slave[MEM].b_resp),    // output wire [1 : 0] s_axi_bresp
      .s_axi_bvalid (slave[MEM].b_valid),   // output wire s_axi_bvalid
      .s_axi_bready (slave[MEM].b_ready),   // input wire s_axi_bready
      .s_axi_arid   (slave[MEM].ar_id),     // input wire [0 : 0] s_axi_arid
      .s_axi_araddr (slave[MEM].ar_addr),   // input wire [31 : 0] s_axi_araddr
      .s_axi_arlen  (slave[MEM].ar_len),    // input wire [7 : 0] s_axi_arlen
      .s_axi_arsize (slave[MEM].ar_size),   // input wire [2 : 0] s_axi_arsize
      .s_axi_arburst(slave[MEM].ar_burst),  // input wire [1 : 0] s_axi_arburst
      .s_axi_arvalid(slave[MEM].ar_valid),  // input wire s_axi_arvalid
      .s_axi_arready(slave[MEM].ar_ready),  // output wire s_axi_arready
      .s_axi_rid    (slave[MEM].r_id),      // output wire [0 : 0] s_axi_rid
      .s_axi_rdata  (slave[MEM].r_data),    // output wire [31 : 0] s_axi_rdata
      .s_axi_rresp  (slave[MEM].r_resp),    // output wire [1 : 0] s_axi_rresp
      .s_axi_rlast  (slave[MEM].r_last),    // output wire s_axi_rlast
      .s_axi_rvalid (slave[MEM].r_valid),   // output wire s_axi_rvalid
      .s_axi_rready (slave[MEM].r_ready)    // input wire s_axi_rready
  );

  generate
    if (LOGGING) begin
      always @(posedge clk_i) begin
        if (slave[MEM].ar_valid)
          $display("addr=0x%08x: data=0x%08x", slave[MEM].ar_addr, slave[MEM].r_data);
        if (slave[MEM].aw_valid)
          $display("write addr=0x%08x: data=0x%08x", slave[MEM].aw_addr, slave[MEM].w_data);
      end
    end
  endgenerate

  wire interrupt;

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
      .slv       (slave[UART]),
      .mst       (AXI_uart)
  );

  // UART AXI Access
  axi_uartlite_0 uart (
      .s_axi_aclk   (clk_i),     // input wire s_axi_aclk
      .s_axi_aresetn(rst_ni),  // input wire s_axi_aresetn

      .interrupt(interrupt),  // output wire interrupt

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

  // EXIT AXI Access
  axi_exit_dec u_exit_dec (
      .clk_i (clk_i),  // input wire s_axi_aclk
      .rst_ni(rst_ni), // input wire s_axi_aresetn

      .AXI_Slave(slave[EXIT]),

      .exit_zero_o (exit_zero_o),
      .exit_valid_o(exit_valid_o)
  );

  assign irq_o = '0;

endmodule
