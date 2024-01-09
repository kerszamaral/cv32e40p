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

    generate;
        if (OLD == 0) begin : g_new_xbar
            // Crossbar configuration
            localparam FALLTHROUGH = 1'b1;
            localparam axi_pkg::xbar_cfg_t xbar_cfg = '{
                NoSlvPorts: MASTER_NUM,
                NoMstPorts: SLAVE_NUM,
                MaxMstTrans: 1,
                MaxSlvTrans: 1,
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
           
            AXI_LITE #(
               .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
               .AXI_DATA_WIDTH(AXI_DATA_WIDTH)
            ) AXI_lite_mst[MASTER_NUM-1:0] (), AXI_lite_slv[SLAVE_NUM-1:0] ();

            genvar i;
            for (i = 0; i < MASTER_NUM; i = i + 1) begin : g_master_converter
               axi_to_axi_lite_intf #(
                 .AXI_ID_WIDTH      (AXI_ID_WIDTH),
                 .AXI_ADDR_WIDTH    (AXI_ADDR_WIDTH),
                 .AXI_DATA_WIDTH    (AXI_DATA_WIDTH),
                 .AXI_USER_WIDTH    (AXI_USER_WIDTH),
                 .AXI_MAX_WRITE_TXNS(32'd1),
                 .AXI_MAX_READ_TXNS (32'd1),
                 .FALL_THROUGH      (FALLTHROUGH)
               ) lite_to_axi (
                 .clk_i     (clk_i),
                 .rst_ni    (rst_ni),
                 .testmode_i(1'b0),
                 .slv       (AXI_Slaves[i]),
                 .mst       (AXI_lite_mst[i])
               );
            end

            genvar j;
            for (j = 0; j < SLAVE_NUM; j = j + 1) begin : g_slave_converter
               axi_lite_to_axi_intf #(
                 .AXI_DATA_WIDTH(AXI_DATA_WIDTH)
               ) lite_to_axi (
                 .in(AXI_lite_slv[j]),
                 .out(AXI_Masters[j]),
                 .slv_aw_cache_i(0),
                 .slv_ar_cache_i(0)
               );
            end

            // AXI4 Crossbar
            axi_lite_xbar_intf #(
                .Cfg(xbar_cfg),
                .rule_t(axi_pkg::xbar_rule_32_t)
            ) xbar (
                .clk_i   (clk_i),    // input wire clk_i
                .rst_ni  (rst_ni),   // input wire rst_ni
                .test_i('0),  // input wire test_i
                .slv_ports(AXI_lite_mst),
                .mst_ports(AXI_lite_slv),
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

            localparam INSTR = 0;
            localparam DATA = 1;

            localparam MEM = 0;
            localparam UART = 1;
            localparam EXIT = 2;

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

            // Crossbar Slave Wires
            wire [  (ADDRSIZE*SLAVE_NUM)-1:0] m_axi_awaddr;
            wire [  (PROTSIZE*SLAVE_NUM)-1:0] m_axi_awprot;
            wire [ (VALIDSIZE*SLAVE_NUM)-1:0] m_axi_awvalid;
            wire [ (READYSIZE*SLAVE_NUM)-1:0] m_axi_awready;
            wire [  (DATASIZE*SLAVE_NUM)-1:0] m_axi_wdata;
            wire [  (STRBSIZE*SLAVE_NUM)-1:0] m_axi_wstrb;
            wire [ (VALIDSIZE*SLAVE_NUM)-1:0] m_axi_wvalid;
            wire [ (READYSIZE*SLAVE_NUM)-1:0] m_axi_wready;
            wire [  (RESPSIZE*SLAVE_NUM)-1:0] m_axi_bresp;
            wire [ (VALIDSIZE*SLAVE_NUM)-1:0] m_axi_bvalid;
            wire [ (READYSIZE*SLAVE_NUM)-1:0] m_axi_bready;
            wire [  (ADDRSIZE*SLAVE_NUM)-1:0] m_axi_araddr;
            wire [  (PROTSIZE*SLAVE_NUM)-1:0] m_axi_arprot;
            wire [ (VALIDSIZE*SLAVE_NUM)-1:0] m_axi_arvalid;
            wire [ (READYSIZE*SLAVE_NUM)-1:0] m_axi_arready;
            wire [  (DATASIZE*SLAVE_NUM)-1:0] m_axi_rdata;
            wire [  (RESPSIZE*SLAVE_NUM)-1:0] m_axi_rresp;
            wire [ (VALIDSIZE*SLAVE_NUM)-1:0] m_axi_rvalid;
            wire [ (READYSIZE*SLAVE_NUM)-1:0] m_axi_rready;

            assign s_axi_awaddr[(INSTR*ADDRSIZE)+:ADDRSIZE] = AXI_Slaves[INSTR].aw_addr;
            assign s_axi_awaddr[(DATA*ADDRSIZE)+:ADDRSIZE] = AXI_Slaves[DATA].aw_addr;

            assign s_axi_awprot[(INSTR*PROTSIZE)+:PROTSIZE] = AXI_Slaves[INSTR].aw_prot;
            assign s_axi_awprot[(DATA*PROTSIZE)+:PROTSIZE] = AXI_Slaves[DATA].aw_prot;

            assign s_axi_awvalid[(INSTR*VALIDSIZE)+:VALIDSIZE] = AXI_Slaves[INSTR].aw_valid;
            assign s_axi_awvalid[(DATA*VALIDSIZE)+:VALIDSIZE] = AXI_Slaves[DATA].aw_valid;

            assign AXI_Slaves[INSTR].aw_ready = s_axi_awready[(INSTR*READYSIZE)+:READYSIZE];
            assign AXI_Slaves[DATA].aw_ready = s_axi_awready[(DATA*READYSIZE)+:READYSIZE];

            assign s_axi_wdata[(INSTR*DATASIZE)+:DATASIZE] = AXI_Slaves[INSTR].w_data;
            assign s_axi_wdata[(DATA*DATASIZE)+:DATASIZE] = AXI_Slaves[DATA].w_data;

            assign s_axi_wstrb[(INSTR*STRBSIZE)+:STRBSIZE] = AXI_Slaves[INSTR].w_strb;
            assign s_axi_wstrb[(DATA*STRBSIZE)+:STRBSIZE] = AXI_Slaves[DATA].w_strb;

            assign s_axi_wvalid[(INSTR*VALIDSIZE)+:VALIDSIZE] = AXI_Slaves[INSTR].w_valid;
            assign s_axi_wvalid[(DATA*VALIDSIZE)+:VALIDSIZE] = AXI_Slaves[DATA].w_valid;

            assign AXI_Slaves[INSTR].w_ready = s_axi_wready[(INSTR*READYSIZE)+:READYSIZE];
            assign AXI_Slaves[DATA].w_ready = s_axi_wready[(DATA*READYSIZE)+:READYSIZE];

            assign AXI_Slaves[INSTR].b_resp = s_axi_bresp[(INSTR*RESPSIZE)+:RESPSIZE];
            assign AXI_Slaves[DATA].b_resp = s_axi_bresp[(DATA*RESPSIZE)+:RESPSIZE];

            assign AXI_Slaves[INSTR].b_valid = s_axi_bvalid[(INSTR*VALIDSIZE)+:VALIDSIZE];
            assign AXI_Slaves[DATA].b_valid = s_axi_bvalid[(DATA*VALIDSIZE)+:VALIDSIZE];

            assign s_axi_bready[(INSTR*READYSIZE)+:READYSIZE] = AXI_Slaves[INSTR].b_ready;
            assign s_axi_bready[(DATA*READYSIZE)+:READYSIZE] = AXI_Slaves[DATA].b_ready;

            assign s_axi_araddr[(INSTR*ADDRSIZE)+:ADDRSIZE] = AXI_Slaves[INSTR].ar_addr;
            assign s_axi_araddr[(DATA*ADDRSIZE)+:ADDRSIZE] = AXI_Slaves[DATA].ar_addr;

            assign s_axi_arprot[(INSTR*PROTSIZE)+:PROTSIZE] = AXI_Slaves[INSTR].ar_prot;
            assign s_axi_arprot[(DATA*PROTSIZE)+:PROTSIZE] = AXI_Slaves[DATA].ar_prot;

            assign s_axi_arvalid[(INSTR*VALIDSIZE)+:VALIDSIZE] = AXI_Slaves[INSTR].ar_valid;
            assign s_axi_arvalid[(DATA*VALIDSIZE)+:VALIDSIZE] = AXI_Slaves[DATA].ar_valid;

            assign AXI_Slaves[INSTR].ar_ready = s_axi_arready[(INSTR*READYSIZE)+:READYSIZE];
            assign AXI_Slaves[DATA].ar_ready = s_axi_arready[(DATA*READYSIZE)+:READYSIZE];

            assign AXI_Slaves[INSTR].r_data = s_axi_rdata[(INSTR*DATASIZE)+:DATASIZE];
            assign AXI_Slaves[DATA].r_data = s_axi_rdata[(DATA*DATASIZE)+:DATASIZE];

            assign AXI_Slaves[INSTR].r_resp = s_axi_rresp[(INSTR*RESPSIZE)+:RESPSIZE];
            assign AXI_Slaves[DATA].r_resp = s_axi_rresp[(DATA*RESPSIZE)+:RESPSIZE];

            assign AXI_Slaves[INSTR].r_valid = s_axi_rvalid[(INSTR*VALIDSIZE)+:VALIDSIZE];
            assign AXI_Slaves[DATA].r_valid = s_axi_rvalid[(DATA*VALIDSIZE)+:VALIDSIZE];

            assign s_axi_rready[(INSTR*READYSIZE)+:READYSIZE] = AXI_Slaves[INSTR].r_ready;
            assign s_axi_rready[(DATA*READYSIZE)+:READYSIZE] = AXI_Slaves[DATA].r_ready;

            // MEM Conversion
            AXI_LITE #(
                .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
                .AXI_DATA_WIDTH(AXI_DATA_WIDTH)
            ) AXI_mem ();

            axi_lite_to_axi_intf #(
                .AXI_DATA_WIDTH(AXI_DATA_WIDTH)
            ) u_axi_lite_to_axi_intf_mem (
                .in            (AXI_mem),
                .slv_aw_cache_i('0),
                .slv_ar_cache_i('0),
                .out           (AXI_Masters[MEM])
            );

            assign AXI_mem.aw_addr = m_axi_awaddr[(MEM*ADDRSIZE)+:ADDRSIZE];
            assign AXI_mem.aw_prot = m_axi_awprot[(MEM*PROTSIZE)+:PROTSIZE];
            assign AXI_mem.aw_valid = m_axi_awvalid[(MEM*VALIDSIZE)+:VALIDSIZE];
            assign m_axi_awready[(MEM*READYSIZE)+:READYSIZE] = AXI_mem.aw_ready;

            assign AXI_mem.w_data = m_axi_wdata[(MEM*DATASIZE)+:DATASIZE];
            assign AXI_mem.w_strb = m_axi_wstrb[(MEM*STRBSIZE)+:STRBSIZE];
            assign AXI_mem.w_valid = m_axi_wvalid[(MEM*VALIDSIZE)+:VALIDSIZE];
            assign m_axi_wready[(MEM*READYSIZE)+:READYSIZE] = AXI_mem.w_ready;

            assign m_axi_bresp[(MEM*RESPSIZE)+:RESPSIZE] = AXI_mem.b_resp;
            assign m_axi_bvalid[(MEM*VALIDSIZE)+:VALIDSIZE] = AXI_mem.b_valid;
            assign AXI_mem.b_ready = m_axi_bready[(MEM*READYSIZE)+:READYSIZE];

            assign AXI_mem.ar_addr = m_axi_araddr[(MEM*ADDRSIZE)+:ADDRSIZE];
            assign AXI_mem.ar_prot = m_axi_arprot[(MEM*PROTSIZE)+:PROTSIZE];
            assign AXI_mem.ar_valid = m_axi_arvalid[(MEM*VALIDSIZE)+:VALIDSIZE];
            assign m_axi_arready[(MEM*READYSIZE)+:READYSIZE] = AXI_mem.ar_ready;

            assign m_axi_rdata[(MEM*DATASIZE)+:DATASIZE] = AXI_mem.r_data;
            assign m_axi_rresp[(MEM*RESPSIZE)+:RESPSIZE] = AXI_mem.r_resp;
            assign m_axi_rvalid[(MEM*VALIDSIZE)+:VALIDSIZE] = AXI_mem.r_valid;
            assign AXI_mem.r_ready = m_axi_rready[(MEM*READYSIZE)+:READYSIZE];


            // UART Conversion
            AXI_LITE #(
                .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
                .AXI_DATA_WIDTH(AXI_DATA_WIDTH)
            ) AXI_uart ();

            axi_lite_to_axi_intf #(
                .AXI_DATA_WIDTH(AXI_DATA_WIDTH)
            ) u_axi_lite_to_axi_intf_uart (
                .in            (AXI_uart),
                .slv_aw_cache_i('0),
                .slv_ar_cache_i('0),
                .out           (AXI_Masters[UART])
            );

            assign AXI_uart.aw_addr = m_axi_awaddr[(UART*ADDRSIZE)+:ADDRSIZE];
            assign AXI_uart.aw_prot = m_axi_awprot[(UART*PROTSIZE)+:PROTSIZE];
            assign AXI_uart.aw_valid = m_axi_awvalid[(UART*VALIDSIZE)+:VALIDSIZE];
            assign m_axi_awready[(UART*READYSIZE)+:READYSIZE] = AXI_uart.aw_ready;

            assign AXI_uart.w_data = m_axi_wdata[(UART*DATASIZE)+:DATASIZE];
            assign AXI_uart.w_strb = m_axi_wstrb[(UART*STRBSIZE)+:STRBSIZE];
            assign AXI_uart.w_valid = m_axi_wvalid[(UART*VALIDSIZE)+:VALIDSIZE];
            assign m_axi_wready[(UART*READYSIZE)+:READYSIZE] = AXI_uart.w_ready;

            assign m_axi_bresp[(UART*RESPSIZE)+:RESPSIZE] = AXI_uart.b_resp;
            assign m_axi_bvalid[(UART*VALIDSIZE)+:VALIDSIZE] = AXI_uart.b_valid;
            assign AXI_uart.b_ready = m_axi_bready[(UART*READYSIZE)+:READYSIZE];

            assign AXI_uart.ar_addr = m_axi_araddr[(UART*ADDRSIZE)+:ADDRSIZE];
            assign AXI_uart.ar_prot = m_axi_arprot[(UART*PROTSIZE)+:PROTSIZE];
            assign AXI_uart.ar_valid = m_axi_arvalid[(UART*VALIDSIZE)+:VALIDSIZE];
            assign m_axi_arready[(UART*READYSIZE)+:READYSIZE] = AXI_uart.ar_ready;

            assign m_axi_rdata[(UART*DATASIZE)+:DATASIZE] = AXI_uart.r_data;
            assign m_axi_rresp[(UART*RESPSIZE)+:RESPSIZE] = AXI_uart.r_resp;
            assign m_axi_rvalid[(UART*VALIDSIZE)+:VALIDSIZE] = AXI_uart.r_valid;
            assign AXI_uart.r_ready = m_axi_rready[(UART*READYSIZE)+:READYSIZE];

            // Exit Conversion
            AXI_LITE #(
                .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
                .AXI_DATA_WIDTH(AXI_DATA_WIDTH)
            ) AXI_exit ();

            axi_lite_to_axi_intf #(
                .AXI_DATA_WIDTH(AXI_DATA_WIDTH)
            ) u_axi_lite_to_axi_intf_exit (
                .in            (AXI_exit),
                .slv_aw_cache_i('0),
                .slv_ar_cache_i('0),
                .out           (AXI_Masters[EXIT])
            );

            assign AXI_exit.aw_addr = m_axi_awaddr[(EXIT*ADDRSIZE)+:ADDRSIZE];
            assign AXI_exit.aw_prot = m_axi_awprot[(EXIT*PROTSIZE)+:PROTSIZE];
            assign AXI_exit.aw_valid = m_axi_awvalid[(EXIT*VALIDSIZE)+:VALIDSIZE];
            assign m_axi_awready[(EXIT*READYSIZE)+:READYSIZE] = AXI_exit.aw_ready;

            assign AXI_exit.w_data = m_axi_wdata[(EXIT*DATASIZE)+:DATASIZE];
            assign AXI_exit.w_strb = m_axi_wstrb[(EXIT*STRBSIZE)+:STRBSIZE];
            assign AXI_exit.w_valid = m_axi_wvalid[(EXIT*VALIDSIZE)+:VALIDSIZE];
            assign m_axi_wready[(EXIT*READYSIZE)+:READYSIZE] = AXI_exit.w_ready;

            assign m_axi_bresp[(EXIT*RESPSIZE)+:RESPSIZE] = AXI_exit.b_resp;
            assign m_axi_bvalid[(EXIT*VALIDSIZE)+:VALIDSIZE] = AXI_exit.b_valid;
            assign AXI_exit.b_ready = m_axi_bready[(EXIT*READYSIZE)+:READYSIZE];

            assign AXI_exit.ar_addr = m_axi_araddr[(EXIT*ADDRSIZE)+:ADDRSIZE];
            assign AXI_exit.ar_prot = m_axi_arprot[(EXIT*PROTSIZE)+:PROTSIZE];
            assign AXI_exit.ar_valid = m_axi_arvalid[(EXIT*VALIDSIZE)+:VALIDSIZE];
            assign m_axi_arready[(EXIT*READYSIZE)+:READYSIZE] = AXI_exit.ar_ready;

            assign m_axi_rdata[(EXIT*DATASIZE)+:DATASIZE] = AXI_exit.r_data;
            assign m_axi_rresp[(EXIT*RESPSIZE)+:RESPSIZE] = AXI_exit.r_resp;
            assign m_axi_rvalid[(EXIT*VALIDSIZE)+:VALIDSIZE] = AXI_exit.r_valid;
            assign AXI_exit.r_ready = m_axi_rready[(EXIT*READYSIZE)+:READYSIZE];

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
