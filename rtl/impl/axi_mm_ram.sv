module axi_mm_ram #(
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

    input  logic [31:0] pc_core_id_i,
    output logic        exit_valid_o,
    output logic        exit_zero_o,

    input  logic rx_i,
    output logic tx_o
);

  localparam MASTER_NUM = 2;
  localparam SLAVE_NUM = 3;

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

  localparam INSTR = 0;
  localparam DATA = 1;

  assign s_axi_awaddr[(INSTR*ADDRSIZE)+:ADDRSIZE] = instr.aw_addr;
  assign s_axi_awaddr[(DATA*ADDRSIZE)+:ADDRSIZE] = data.aw_addr;

  assign s_axi_awprot[(INSTR*PROTSIZE)+:PROTSIZE] = instr.aw_prot;
  assign s_axi_awprot[(DATA*PROTSIZE)+:PROTSIZE] = data.aw_prot;

  assign s_axi_awvalid[(INSTR*VALIDSIZE)+:VALIDSIZE] = instr.aw_valid;
  assign s_axi_awvalid[(DATA*VALIDSIZE)+:VALIDSIZE] = data.aw_valid;

  assign instr.aw_ready = s_axi_awready[(INSTR*READYSIZE)+:READYSIZE];
  assign data.aw_ready = s_axi_awready[(DATA*READYSIZE)+:READYSIZE];

  assign s_axi_wdata[(INSTR*DATASIZE)+:DATASIZE] = instr.w_data;
  assign s_axi_wdata[(DATA*DATASIZE)+:DATASIZE] = data.w_data;

  assign s_axi_wstrb[(INSTR*STRBSIZE)+:STRBSIZE] = instr.w_strb;
  assign s_axi_wstrb[(DATA*STRBSIZE)+:STRBSIZE] = data.w_strb;

  assign s_axi_wvalid[(INSTR*VALIDSIZE)+:VALIDSIZE] = instr.w_valid;
  assign s_axi_wvalid[(DATA*VALIDSIZE)+:VALIDSIZE] = data.w_valid;

  assign instr.w_ready = s_axi_wready[(INSTR*READYSIZE)+:READYSIZE];
  assign data.w_ready = s_axi_wready[(DATA*READYSIZE)+:READYSIZE];

  assign instr.b_resp = s_axi_bresp[(INSTR*RESPSIZE)+:RESPSIZE];
  assign data.b_resp = s_axi_bresp[(DATA*RESPSIZE)+:RESPSIZE];

  assign instr.b_valid = s_axi_bvalid[(INSTR*VALIDSIZE)+:VALIDSIZE];
  assign data.b_valid = s_axi_bvalid[(DATA*VALIDSIZE)+:VALIDSIZE];

  assign s_axi_bready[(INSTR*READYSIZE)+:READYSIZE] = instr.b_ready;
  assign s_axi_bready[(DATA*READYSIZE)+:READYSIZE] = data.b_ready;

  assign s_axi_araddr[(INSTR*ADDRSIZE)+:ADDRSIZE] = instr.ar_addr;
  assign s_axi_araddr[(DATA*ADDRSIZE)+:ADDRSIZE] = data.ar_addr;

  assign s_axi_arprot[(INSTR*PROTSIZE)+:PROTSIZE] = instr.ar_prot;
  assign s_axi_arprot[(DATA*PROTSIZE)+:PROTSIZE] = data.ar_prot;

  assign s_axi_arvalid[(INSTR*VALIDSIZE)+:VALIDSIZE] = instr.ar_valid;
  assign s_axi_arvalid[(DATA*VALIDSIZE)+:VALIDSIZE] = data.ar_valid;

  assign instr.ar_ready = s_axi_arready[(INSTR*READYSIZE)+:READYSIZE];
  assign data.ar_ready = s_axi_arready[(DATA*READYSIZE)+:READYSIZE];

  assign instr.r_data = s_axi_rdata[(INSTR*DATASIZE)+:DATASIZE];
  assign data.r_data = s_axi_rdata[(DATA*DATASIZE)+:DATASIZE];

  assign instr.r_resp = s_axi_rresp[(INSTR*RESPSIZE)+:RESPSIZE];
  assign data.r_resp = s_axi_rresp[(DATA*RESPSIZE)+:RESPSIZE];

  assign instr.r_valid = s_axi_rvalid[(INSTR*VALIDSIZE)+:VALIDSIZE];
  assign data.r_valid = s_axi_rvalid[(DATA*VALIDSIZE)+:VALIDSIZE];

  assign s_axi_rready[(INSTR*READYSIZE)+:READYSIZE] = instr.r_ready;
  assign s_axi_rready[(DATA*READYSIZE)+:READYSIZE] = data.r_ready;

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

  localparam MEM = 0;
  localparam UART = 1;
  localparam EXIT = 2;

  // BRAM AXI Access
  AXI_LITE #(
      .AXI_ADDR_WIDTH(32),
      .AXI_DATA_WIDTH(32)
  ) AXI_mem ();

  AXI_BUS #(
      .AXI_ADDR_WIDTH(32),
      .AXI_DATA_WIDTH(32),
      .AXI_ID_WIDTH  (16),
      .AXI_USER_WIDTH(10)
  ) AXI_mem_temp ();

  axi_lite_to_axi_intf #(
      .AXI_DATA_WIDTH(32)
  ) u_axi_lite_to_axi_intf_mem (
      .in            (AXI_mem),
      .slv_aw_cache_i('0),
      .slv_ar_cache_i('0),
      .out           (AXI_mem_temp)
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

  axi_mem mem (
      .clk_i (clk_i),  // input wire clk_i
      .rst_ni(rst_ni), // input wire rst_ni

      .AXI_Slave(AXI_mem_temp)
  );

  wire interrupt;

  // UART AXI Access
  AXI_LITE #(
      .AXI_ADDR_WIDTH(32),
      .AXI_DATA_WIDTH(32)
  ) AXI_uart ();

  AXI_BUS #(
      .AXI_ADDR_WIDTH(32),
      .AXI_DATA_WIDTH(32),
      .AXI_ID_WIDTH  (16),
      .AXI_USER_WIDTH(10)
  ) AXI_uart_temp ();

  axi_lite_to_axi_intf #(
      .AXI_DATA_WIDTH(32)
  ) u_axi_lite_to_axi_intf_uart (
      .in            (AXI_uart),
      .slv_aw_cache_i('0),
      .slv_ar_cache_i('0),
      .out           (AXI_uart_temp)
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

  axi_uart uart (
      .clk_i (clk_i),  // input wire clk_i
      .rst_ni(rst_ni), // input wire rst_ni

      .AXI_Slave(AXI_uart_temp),

      .interrupt_o(interrupt),  // output wire interrupt

      .rx_i(rx_i),  // input wire rx
      .tx_o(tx_o)   // output wire tx
  );

  AXI_LITE #(
      .AXI_ADDR_WIDTH(32),
      .AXI_DATA_WIDTH(32)
  ) AXI_exit ();

  AXI_BUS #(
      .AXI_ADDR_WIDTH(32),
      .AXI_DATA_WIDTH(32),
      .AXI_ID_WIDTH  (16),
      .AXI_USER_WIDTH(10)
  ) AXI_exit_temp ();

  axi_lite_to_axi_intf #(
      .AXI_DATA_WIDTH(32)
  ) u_axi_lite_to_axi_intf (
      .in            (AXI_exit),
      .slv_aw_cache_i('0),
      .slv_ar_cache_i('0),
      .out           (AXI_exit_temp)
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

  // EXIT AXI Access
  axi_exit_dec u_exit_dec (
      .clk_i (clk_i),  // input wire s_axi_aclk
      .rst_ni(rst_ni), // input wire s_axi_aresetn

      .AXI_Slave(AXI_exit_temp),

      .exit_zero_o (exit_zero_o),
      .exit_valid_o(exit_valid_o)
  );

  // Unused
  assign instr_b_id_o = '0;
  assign instr_b_user_o = '0;
  assign instr_r_id_o = '0;
  assign instr_r_user_o = '0;
  assign instr_r_last_o = '0;

  assign data_b_id_o = '0;
  assign data_b_user_o = '0;
  assign data_r_id_o = '0;
  assign data_r_user_o = '0;
  assign data_r_last_o = '0;

  assign irq_o = '0;

endmodule
