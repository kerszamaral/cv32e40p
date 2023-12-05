module axi_mm_ram #(
    parameter MAXBLKSIZE = 20,
    parameter BYTES = 4,
    parameter AXI4_ADDRESS_WIDTH = 32,
    parameter AXI4_RDATA_WIDTH = 32,
    parameter AXI4_WDATA_WIDTH = 32,
    parameter AXI4_ID_WIDTH = 16,
    parameter AXI4_USER_WIDTH = 10,
    parameter LOGGING = 0
) (
    input  logic                          clk_i,
    input  logic                          rst_ni,
    //! AXI4 Instruction Interface
    //AXI write address bus -------------- // USED// -----------
    input  logic [     AXI4_ID_WIDTH-1:0] instr_aw_id_i,
    input  logic [AXI4_ADDRESS_WIDTH-1:0] instr_aw_addr_i,
    input  logic [                   7:0] instr_aw_len_i,
    input  logic [                   2:0] instr_aw_size_i,
    input  logic [                   1:0] instr_aw_burst_i,
    input  logic                          instr_aw_lock_i,
    input  logic [                   3:0] instr_aw_cache_i,
    input  logic [                   2:0] instr_aw_prot_i,
    input  logic [                   3:0] instr_aw_region_i,
    input  logic [   AXI4_USER_WIDTH-1:0] instr_aw_user_i,
    input  logic [                   3:0] instr_aw_qos_i,
    input  logic                          instr_aw_valid_i,
    output logic                          instr_aw_ready_o,
    // ---------------------------------------------------------

    //AXI write data bus -------------- // USED// --------------
    input  logic [  AXI4_WDATA_WIDTH-1:0] instr_w_data_i,
    input  logic [AXI4_WDATA_WIDTH/8-1:0] instr_w_strb_i,
    input  logic                          instr_w_last_i,
    input  logic [   AXI4_USER_WIDTH-1:0] instr_w_user_i,
    input  logic                          instr_w_valid_i,
    output logic                          instr_w_ready_o,
    // ---------------------------------------------------------

    //AXI write response bus -------------- // USED// ----------
    output logic [  AXI4_ID_WIDTH-1:0] instr_b_id_o,
    output logic [                1:0] instr_b_resp_o,
    output logic                       instr_b_valid_o,
    output logic [AXI4_USER_WIDTH-1:0] instr_b_user_o,
    input  logic                       instr_b_ready_i,
    // ---------------------------------------------------------

    //AXI read address bus -------------------------------------
    input  logic [     AXI4_ID_WIDTH-1:0] instr_ar_id_i,
    input  logic [AXI4_ADDRESS_WIDTH-1:0] instr_ar_addr_i,
    input  logic [                   7:0] instr_ar_len_i,
    input  logic [                   2:0] instr_ar_size_i,
    input  logic [                   1:0] instr_ar_burst_i,
    input  logic                          instr_ar_lock_i,
    input  logic [                   3:0] instr_ar_cache_i,
    input  logic [                   2:0] instr_ar_prot_i,
    input  logic [                   3:0] instr_ar_region_i,
    input  logic [   AXI4_USER_WIDTH-1:0] instr_ar_user_i,
    input  logic [                   3:0] instr_ar_qos_i,
    input  logic                          instr_ar_valid_i,
    output logic                          instr_ar_ready_o,
    // ---------------------------------------------------------

    //AXI read data bus ----------------------------------------
    output logic [   AXI4_ID_WIDTH-1:0] instr_r_id_o,
    output logic [AXI4_RDATA_WIDTH-1:0] instr_r_data_o,
    output logic [                 1:0] instr_r_resp_o,
    output logic                        instr_r_last_o,
    output logic [ AXI4_USER_WIDTH-1:0] instr_r_user_o,
    output logic                        instr_r_valid_o,
    input  logic                        instr_r_ready_i,
    // ---------------------------------------------------------

    //! AXI4 Data Interface
    //AXI write address bus -------------- // USED// -----------
    input  logic [     AXI4_ID_WIDTH-1:0] data_aw_id_i,
    input  logic [AXI4_ADDRESS_WIDTH-1:0] data_aw_addr_i,
    input  logic [                   7:0] data_aw_len_i,
    input  logic [                   2:0] data_aw_size_i,
    input  logic [                   1:0] data_aw_burst_i,
    input  logic                          data_aw_lock_i,
    input  logic [                   3:0] data_aw_cache_i,
    input  logic [                   2:0] data_aw_prot_i,
    input  logic [                   3:0] data_aw_region_i,
    input  logic [   AXI4_USER_WIDTH-1:0] data_aw_user_i,
    input  logic [                   3:0] data_aw_qos_i,
    input  logic                          data_aw_valid_i,
    output logic                          data_aw_ready_o,
    // ---------------------------------------------------------

    //AXI write data bus -------------- // USED// --------------
    input  logic [  AXI4_WDATA_WIDTH-1:0] data_w_data_i,
    input  logic [AXI4_WDATA_WIDTH/8-1:0] data_w_strb_i,
    input  logic                          data_w_last_i,
    input  logic [   AXI4_USER_WIDTH-1:0] data_w_user_i,
    input  logic                          data_w_valid_i,
    output logic                          data_w_ready_o,
    // ---------------------------------------------------------

    //AXI write response bus -------------- // USED// ----------
    output logic [  AXI4_ID_WIDTH-1:0] data_b_id_o,
    output logic [                1:0] data_b_resp_o,
    output logic                       data_b_valid_o,
    output logic [AXI4_USER_WIDTH-1:0] data_b_user_o,
    input  logic                       data_b_ready_i,
    // ---------------------------------------------------------

    //AXI read address bus -------------------------------------
    input  logic [     AXI4_ID_WIDTH-1:0] data_ar_id_i,
    input  logic [AXI4_ADDRESS_WIDTH-1:0] data_ar_addr_i,
    input  logic [                   7:0] data_ar_len_i,
    input  logic [                   2:0] data_ar_size_i,
    input  logic [                   1:0] data_ar_burst_i,
    input  logic                          data_ar_lock_i,
    input  logic [                   3:0] data_ar_cache_i,
    input  logic [                   2:0] data_ar_prot_i,
    input  logic [                   3:0] data_ar_region_i,
    input  logic [   AXI4_USER_WIDTH-1:0] data_ar_user_i,
    input  logic [                   3:0] data_ar_qos_i,
    input  logic                          data_ar_valid_i,
    output logic                          data_ar_ready_o,
    // ---------------------------------------------------------

    //AXI read data bus ----------------------------------------
    output logic [   AXI4_ID_WIDTH-1:0] data_r_id_o,
    output logic [AXI4_RDATA_WIDTH-1:0] data_r_data_o,
    output logic [                 1:0] data_r_resp_o,
    output logic                        data_r_last_o,
    output logic [ AXI4_USER_WIDTH-1:0] data_r_user_o,
    output logic                        data_r_valid_o,
    input  logic                        data_r_ready_i,
    // ---------------------------------------------------------

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

  localparam DATA = 0;
  localparam INSTR = 1;

  assign s_axi_awaddr[(INSTR*ADDRSIZE)+:ADDRSIZE] = instr_aw_addr_i;
  assign s_axi_awaddr[(DATA*ADDRSIZE)+:ADDRSIZE] = data_aw_addr_i;
  assign s_axi_awprot[(INSTR*PROTSIZE)+:PROTSIZE] = instr_aw_prot_i;
  assign s_axi_awprot[(DATA*PROTSIZE)+:PROTSIZE] = data_aw_prot_i;
  assign s_axi_awvalid[(INSTR*VALIDSIZE)+:VALIDSIZE] = instr_aw_valid_i;
  assign s_axi_awvalid[(DATA*VALIDSIZE)+:VALIDSIZE] = data_aw_valid_i;
  assign instr_aw_ready_o = s_axi_awready[(INSTR*READYSIZE)+:READYSIZE];
  assign data_aw_ready_o = s_axi_awready[(DATA*READYSIZE)+:READYSIZE];
  assign s_axi_wdata[(INSTR*DATASIZE)+:DATASIZE] = instr_w_data_i;
  assign s_axi_wdata[(DATA*DATASIZE)+:DATASIZE] = data_w_data_i;
  assign s_axi_wstrb[(INSTR*STRBSIZE)+:STRBSIZE] = instr_w_strb_i;
  assign s_axi_wstrb[(DATA*STRBSIZE)+:STRBSIZE] = data_w_strb_i;
  assign s_axi_wvalid[(INSTR*VALIDSIZE)+:VALIDSIZE] = instr_w_valid_i;
  assign s_axi_wvalid[(DATA*VALIDSIZE)+:VALIDSIZE] = data_w_valid_i;
  assign instr_w_ready_o = s_axi_wready[(INSTR*READYSIZE)+:READYSIZE];
  assign data_w_ready_o = s_axi_wready[(DATA*READYSIZE)+:READYSIZE];
  assign instr_b_resp_o = s_axi_bresp[(INSTR*RESPSIZE)+:RESPSIZE];
  assign data_b_resp_o = s_axi_bresp[(DATA*RESPSIZE)+:RESPSIZE];
  assign instr_b_valid_o = s_axi_bvalid[(INSTR*VALIDSIZE)+:VALIDSIZE];
  assign data_b_valid_o = s_axi_bvalid[(DATA*VALIDSIZE)+:VALIDSIZE];
  assign s_axi_bready[(INSTR*READYSIZE)+:READYSIZE] = instr_b_ready_i;
  assign s_axi_bready[(DATA*READYSIZE)+:READYSIZE] = data_b_ready_i;
  assign s_axi_araddr[(INSTR*ADDRSIZE)+:ADDRSIZE] = instr_ar_addr_i;
  assign s_axi_araddr[(DATA*ADDRSIZE)+:ADDRSIZE] = data_ar_addr_i;
  assign s_axi_arprot[(INSTR*PROTSIZE)+:PROTSIZE] = instr_ar_prot_i;
  assign s_axi_arprot[(DATA*PROTSIZE)+:PROTSIZE] = data_ar_prot_i;
  assign s_axi_arvalid[(INSTR*VALIDSIZE)+:VALIDSIZE] = instr_ar_valid_i;
  assign s_axi_arvalid[(DATA*VALIDSIZE)+:VALIDSIZE] = data_ar_valid_i;
  assign instr_ar_ready_o = s_axi_arready[(INSTR*READYSIZE)+:READYSIZE];
  assign data_ar_ready_o = s_axi_arready[(DATA*READYSIZE)+:READYSIZE];
  assign instr_r_data_o = s_axi_rdata[(INSTR*DATASIZE)+:DATASIZE];
  assign data_r_data_o = s_axi_rdata[(DATA*DATASIZE)+:DATASIZE];
  assign instr_r_resp_o = s_axi_rresp[(INSTR*RESPSIZE)+:RESPSIZE];
  assign data_r_resp_o = s_axi_rresp[(DATA*RESPSIZE)+:RESPSIZE];
  assign instr_r_valid_o = s_axi_rvalid[(INSTR*VALIDSIZE)+:VALIDSIZE];
  assign data_r_valid_o = s_axi_rvalid[(DATA*VALIDSIZE)+:VALIDSIZE];
  assign s_axi_rready[(INSTR*READYSIZE)+:READYSIZE] = instr_r_ready_i;
  assign s_axi_rready[(DATA*READYSIZE)+:READYSIZE] = data_r_ready_i;

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

    wire rsta_busy;
    wire rstb_busy;

  // BRAM AXI Access
  dp_axi_bram mem (
      .rsta_busy(rsta_busy),  // output wire rsta_busy
      .rstb_busy(rstb_busy),  // output wire rstb_busy

      .s_aclk   (clk_i),  // input wire s_aclk
      .s_aresetn(rst_ni), // input wire s_aresetn

      .s_axi_awaddr(m_axi_awaddr[(MEM*ADDRSIZE)+:ADDRSIZE]),  // input wire [31 : 0] s_axi_awaddr
      .s_axi_awvalid(m_axi_awvalid[(MEM*VALIDSIZE)+:VALIDSIZE]),  // input wire s_axi_awvalid
      .s_axi_awready(m_axi_awready[(MEM*READYSIZE)+:READYSIZE]),  // output wire s_axi_awready
      .s_axi_wdata(m_axi_wdata[(MEM*DATASIZE)+:DATASIZE]),  // input wire [31 : 0] s_axi_wdata
      .s_axi_wstrb(m_axi_wstrb[(MEM*STRBSIZE)+:STRBSIZE]),  // input wire [3 : 0] s_axi_wstrb
      .s_axi_wvalid(m_axi_wvalid[(MEM*VALIDSIZE)+:VALIDSIZE]),  // input wire s_axi_wvalid
      .s_axi_wready(m_axi_wready[(MEM*READYSIZE)+:READYSIZE]),  // output wire s_axi_wready
      .s_axi_bresp(m_axi_bresp[(MEM*RESPSIZE)+:RESPSIZE]),  // output wire [1 : 0] s_axi_bresp
      .s_axi_bvalid(m_axi_bvalid[(MEM*VALIDSIZE)+:VALIDSIZE]),  // output wire s_axi_bvalid
      .s_axi_bready(m_axi_bready[(MEM*READYSIZE)+:READYSIZE]),  // input wire s_axi_bready
      .s_axi_araddr(m_axi_araddr[(MEM*ADDRSIZE)+:ADDRSIZE]),  // input wire [31 : 0] s_axi_araddr
      .s_axi_arvalid(m_axi_arvalid[(MEM*VALIDSIZE)+:VALIDSIZE]),  // input wire s_axi_arvalid
      .s_axi_arready(m_axi_arready[(MEM*READYSIZE)+:READYSIZE]),  // output wire s_axi_arready
      .s_axi_rdata(m_axi_rdata[(MEM*DATASIZE)+:DATASIZE]),  // output wire [31 : 0] s_axi_rdata
      .s_axi_rresp(m_axi_rresp[(MEM*RESPSIZE)+:RESPSIZE]),  // output wire [1 : 0] s_axi_rresp
      .s_axi_rvalid(m_axi_rvalid[(MEM*VALIDSIZE)+:VALIDSIZE]),  // output wire s_axi_rvalid
      .s_axi_rready(m_axi_rready[(MEM*READYSIZE)+:READYSIZE])  // input wire s_axi_rready
  );

  generate
    if (LOGGING) begin
      always @(posedge clk_i) begin
        if (m_axi_awvalid[(MEM*VALIDSIZE)+:VALIDSIZE])
          $display(
              "addr=0x%08x: data=0x%08x",
              m_axi_araddr[(MEM*ADDRSIZE)+:ADDRSIZE],
              m_axi_rdata[(MEM*DATASIZE)+:DATASIZE]
          );
        if (m_axi_wvalid[(MEM*VALIDSIZE)+:VALIDSIZE])
          $display(
              "write addr=0x%08x: data=0x%08x",
              m_axi_awaddr[(MEM*ADDRSIZE)+:ADDRSIZE],
              m_axi_wdata[(MEM*DATASIZE)+:DATASIZE]
          );
      end
    end
  endgenerate

    wire interrupt;

  // UART AXI Access
  axi_uartlite_0 uart (
      .s_axi_aclk   (clk_i),     // input wire s_axi_aclk
      .s_axi_aresetn(rst_ni),  // input wire s_axi_aresetn

      .interrupt(interrupt),  // output wire interrupt

      .s_axi_awaddr('h4),  // input wire [3 : 0] s_axi_awaddr m_axi_awaddr[(UART*ADDRSIZE)+:4]
      .s_axi_awvalid(m_axi_awvalid[(UART*VALIDSIZE)+:VALIDSIZE]),  // input wire s_axi_awvalid
      .s_axi_awready(m_axi_awready[(UART*READYSIZE)+:READYSIZE]),  // output wire s_axi_awready
      .s_axi_wdata(m_axi_wdata[(UART*DATASIZE)+:DATASIZE]),  // input wire [31 : 0] s_axi_wdata
      .s_axi_wstrb(m_axi_wstrb[(UART*STRBSIZE)+:STRBSIZE]),  // input wire [3 : 0] s_axi_wstrb
      .s_axi_wvalid(m_axi_wvalid[(UART*VALIDSIZE)+:VALIDSIZE]),  // input wire s_axi_wvalid
      .s_axi_wready(m_axi_wready[(UART*READYSIZE)+:READYSIZE]),  // output wire s_axi_wready
      .s_axi_bresp(m_axi_bresp[(UART*RESPSIZE)+:RESPSIZE]),  // output wire [1 : 0] s_axi_bresp
      .s_axi_bvalid(m_axi_bvalid[(UART*VALIDSIZE)+:VALIDSIZE]),  // output wire s_axi_bvalid
      .s_axi_bready(m_axi_bready[(UART*READYSIZE)+:READYSIZE]),  // input wire s_axi_bready
      .s_axi_araddr(m_axi_araddr[(UART*ADDRSIZE)+:4]),  // input wire [3 : 0] s_axi_araddr
      .s_axi_arvalid(m_axi_arvalid[(UART*VALIDSIZE)+:VALIDSIZE]),  // input wire s_axi_arvalid
      .s_axi_arready(m_axi_arready[(UART*READYSIZE)+:READYSIZE]),  // output wire s_axi_arready
      .s_axi_rdata(m_axi_rdata[(UART*DATASIZE)+:DATASIZE]),  // output wire [31 : 0] s_axi_rdata
      .s_axi_rresp(m_axi_rresp[(UART*RESPSIZE)+:RESPSIZE]),  // output wire [1 : 0] s_axi_rresp
      .s_axi_rvalid(m_axi_rvalid[(UART*VALIDSIZE)+:VALIDSIZE]),  // output wire s_axi_rvalid
      .s_axi_rready(m_axi_rready[(UART*READYSIZE)+:READYSIZE]),  // input wire s_axi_rready

      .rx(rx_i),  // input wire rx
      .tx(tx_o)   // output wire tx
  );

  // EXIT AXI Access
  axi_exit_dec u_exit_dec (
      .s_axi_aclk   (clk_i),     // input wire s_axi_aclk
      .s_axi_aresetn(rst_ni),  // input wire s_axi_aresetn

      .s_axi_awaddr(m_axi_awaddr[(EXIT*ADDRSIZE)+:ADDRSIZE]),  // input wire [31 : 0] s_axi_awaddr
      .s_axi_awprot(m_axi_awprot[(EXIT*PROTSIZE)+:PROTSIZE]),  // input wire [2 : 0] s_axi_awprot
      .s_axi_awvalid(m_axi_awvalid[(EXIT*VALIDSIZE)+:VALIDSIZE]),  // input wire s_axi_awvalid
      .s_axi_awready(m_axi_awready[(EXIT*READYSIZE)+:READYSIZE]),  // output wire s_axi_awready
      .s_axi_wdata(m_axi_wdata[(EXIT*DATASIZE)+:DATASIZE]),  // input wire [31 : 0] s_axi_wdata
      .s_axi_wstrb(m_axi_wstrb[(EXIT*STRBSIZE)+:STRBSIZE]),  // input wire [3 : 0] s_axi_wstrb
      .s_axi_wvalid(m_axi_wvalid[(EXIT*VALIDSIZE)+:VALIDSIZE]),  // input wire s_axi_wvalid
      .s_axi_wready(m_axi_wready[(EXIT*READYSIZE)+:READYSIZE]),  // output wire s_axi_wready
      .s_axi_bresp(m_axi_bresp[(EXIT*RESPSIZE)+:RESPSIZE]),  // output wire [1 : 0] s_axi_bresp
      .s_axi_bvalid(m_axi_bvalid[(EXIT*VALIDSIZE)+:VALIDSIZE]),  // output wire s_axi_bvalid
      .s_axi_bready(m_axi_bready[(EXIT*READYSIZE)+:READYSIZE]),  // input wire s_axi_bready
      .s_axi_araddr(m_axi_araddr[(EXIT*ADDRSIZE)+:ADDRSIZE]),  // input wire [31 : 0] s_axi_araddr
      .s_axi_arprot(m_axi_arprot[(EXIT*PROTSIZE)+:PROTSIZE]),  // input wire [2 : 0] s_axi_arprot
      .s_axi_arvalid(m_axi_arvalid[(EXIT*VALIDSIZE)+:VALIDSIZE]),  // input wire s_axi_arvalid
      .s_axi_arready(m_axi_arready[(EXIT*READYSIZE)+:READYSIZE]),  // output wire s_axi_arready
      .s_axi_rdata(m_axi_rdata[(EXIT*DATASIZE)+:DATASIZE]),  // output wire [31 : 0] s_axi_rdata
      .s_axi_rresp(m_axi_rresp[(EXIT*RESPSIZE)+:RESPSIZE]),  // output wire [1 : 0] s_axi_rresp
      .s_axi_rvalid(m_axi_rvalid[(EXIT*VALIDSIZE)+:VALIDSIZE]),  // output wire s_axi_rvalid
      .s_axi_rready(m_axi_rready[(EXIT*READYSIZE)+:READYSIZE]),  // input wire s_axi_rready

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
