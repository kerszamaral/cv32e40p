module axi_mm_ram #(
    parameter MAXBLKSIZE = 20,
    parameter BYTES = 4,
    parameter AXI4_ADDRESS_WIDTH = 32,
    parameter AXI4_RDATA_WIDTH = 32,
    parameter AXI4_WDATA_WIDTH = 32,
    parameter AXI4_ID_WIDTH = 16,
    parameter AXI4_USER_WIDTH = 10,
    parameter FILE = "C:/Users/kersz/Documents/ufrgs/IC/cv32e40p/programs/prog.hex",
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
    output logic [31:0] irq_i,      // CLINT interrupts + CLINT extension interrupts
    input  logic        irq_ack_o,
    input  logic [ 4:0] irq_id_o,

    input  logic [31:0] pc_core_id_i,
    output logic        exit_valid_o,
    output logic [31:0] exit_value_o,

    input  logic rx_i,
    output logic tx_o
);

  logic bram_clk_a;
  logic bram_en_a;
  logic [BYTES-1:0] bram_we_a;
  logic [MAXBLKSIZE-1:0] bram_addr_a;
  logic [AXI4_WDATA_WIDTH-1:0] bram_wrdata_a;
  logic [AXI4_RDATA_WIDTH-1:0] bram_rddata_a;


  logic bram_clk_b;
  logic bram_en_b;
  logic [BYTES-1:0] bram_we_b;
  logic [MAXBLKSIZE-1:0] bram_addr_b;
  logic [AXI4_WDATA_WIDTH-1:0] bram_wrdata_b;
  logic [AXI4_RDATA_WIDTH-1:0] bram_rddata_b;

  axi_to_bram instr_axi_ctrl (
      .s_axi_aclk   (clk_i),  // input wire s_axi_aclk
      .s_axi_aresetn(rst_ni), // input wire s_axi_aresetn

      .s_axi_awaddr(instr_aw_addr_i[0+:MAXBLKSIZE]),  // input wire [19 : 0] s_axi_awaddr
      .s_axi_awprot(instr_aw_prot_i),  // input wire [2 : 0] s_axi_awprot
      .s_axi_awvalid(instr_aw_valid_i),  // input wire s_axi_awvalid
      .s_axi_awready(instr_aw_ready_o),  // output wire s_axi_awready
      .s_axi_wdata(instr_w_data_i),  // input wire [31 : 0] s_axi_wdata
      .s_axi_wstrb(instr_w_strb_i),  // input wire [3 : 0] s_axi_wstrb
      .s_axi_wvalid(instr_w_valid_i),  // input wire s_axi_wvalid
      .s_axi_wready(instr_w_ready_o),  // output wire s_axi_wready
      .s_axi_bresp(instr_b_resp_o),  // output wire [1 : 0] s_axi_bresp
      .s_axi_bvalid(instr_b_valid_o),  // output wire s_axi_bvalid
      .s_axi_bready(instr_b_ready_i),  // input wire s_axi_bready
      .s_axi_araddr(instr_ar_addr_i[0+:MAXBLKSIZE]),  // input wire [19 : 0] s_axi_araddr
      .s_axi_arprot(instr_ar_prot_i),  // input wire [2 : 0] s_axi_arprot
      .s_axi_arvalid(instr_ar_valid_i),  // input wire s_axi_arvalid
      .s_axi_arready(instr_ar_ready_o),  // output wire s_axi_arready
      .s_axi_rdata(instr_r_data_o),  // output wire [31 : 0] s_axi_rdata
      .s_axi_rresp(instr_r_resp_o),  // output wire [1 : 0] s_axi_rresp
      .s_axi_rvalid(instr_r_valid_o),  // output wire s_axi_rvalid
      .s_axi_rready(instr_r_ready_i),  // input wire s_axi_rready

      .bram_rst_a   (bram_rst_a),     // output wire bram_rst_a
      .bram_clk_a   (bram_clk_a),     // output wire bram_clk_a
      .bram_en_a    (bram_en_a),      // output wire bram_en_a
      .bram_we_a    (bram_we_a),      // output wire [3 : 0] bram_we_a
      .bram_addr_a  (bram_addr_a),    // output wire [19 : 0] bram_addr_a
      .bram_wrdata_a(bram_wrdata_a),  // output wire [31 : 0] bram_wrdata_a
      .bram_rddata_a(bram_rddata_a)   // input wire [31 : 0] bram_rddata_a
  );

  localparam DATA = 0;
  localparam UART = 1;
  localparam EXIT = 2;
  localparam ADDRSIZE = 32;
  localparam PROTSIZE = 3;
  localparam VALIDSIZE = 1;
  localparam READYSIZE = 1;
  localparam DATASIZE = 32;
  localparam STRBSIZE = 4;
  localparam RESPSIZE = 2;

  wire [95 : 0] m_axi_awaddr;
  wire [ 8 : 0] m_axi_awprot;
  wire [ 2 : 0] m_axi_awvalid;
  wire [ 2 : 0] m_axi_awready;
  wire [95 : 0] m_axi_wdata;
  wire [11 : 0] m_axi_wstrb;
  wire [ 2 : 0] m_axi_wvalid;
  wire [ 2 : 0] m_axi_wready;
  wire [ 5 : 0] m_axi_bresp;
  wire [ 2 : 0] m_axi_bvalid;
  wire [ 2 : 0] m_axi_bready;
  wire [95 : 0] m_axi_araddr;
  wire [ 8 : 0] m_axi_arprot;
  wire [ 2 : 0] m_axi_arvalid;
  wire [ 2 : 0] m_axi_arready;
  wire [95 : 0] m_axi_rdata;
  wire [ 5 : 0] m_axi_rresp;
  wire [ 2 : 0] m_axi_rvalid;
  wire [ 2 : 0] m_axi_rready;

  axi_crossbar_0 data_crossbar (
      .aclk   (clk_i),    // input wire aclk
      .aresetn(rst_ni), // input wire aresetn

      .s_axi_awaddr (data_aw_addr_i),   // input wire [31 : 0] s_axi_awaddr
      .s_axi_awprot (data_aw_prot_i),   // input wire [2 : 0] s_axi_awprot
      .s_axi_awvalid(data_aw_valid_i),  // input wire [0 : 0] s_axi_awvalid
      .s_axi_awready(data_aw_ready_o),  // output wire [0 : 0] s_axi_awready
      .s_axi_wdata  (data_w_data_i),    // input wire [31 : 0] s_axi_wdata
      .s_axi_wstrb  (data_w_strb_i),    // input wire [3 : 0] s_axi_wstrb
      .s_axi_wvalid (data_w_valid_i),   // input wire [0 : 0] s_axi_wvalid
      .s_axi_wready (data_w_ready_o),   // output wire [0 : 0] s_axi_wready
      .s_axi_bresp  (data_b_resp_o),    // output wire [1 : 0] s_axi_bresp
      .s_axi_bvalid (data_b_valid_o),   // output wire [0 : 0] s_axi_bvalid
      .s_axi_bready (data_b_ready_i),   // input wire [0 : 0] s_axi_bready
      .s_axi_araddr (data_ar_addr_i),   // input wire [31 : 0] s_axi_araddr
      .s_axi_arprot (data_ar_prot_i),   // input wire [2 : 0] s_axi_arprot
      .s_axi_arvalid(data_ar_valid_i),  // input wire [0 : 0] s_axi_arvalid
      .s_axi_arready(data_ar_ready_o),  // output wire [0 : 0] s_axi_arready
      .s_axi_rdata  (data_r_data_o),    // output wire [31 : 0] s_axi_rdata
      .s_axi_rresp  (data_r_resp_o),    // output wire [1 : 0] s_axi_rresp
      .s_axi_rvalid (data_r_valid_o),   // output wire [0 : 0] s_axi_rvalid
      .s_axi_rready (data_r_ready_i),   // input wire [0 : 0] s_axi_rready


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

  // BRAM AXI Access
  axi_to_bram data_axi_ctrl (
      .s_axi_aclk   (clk_i),     // input wire s_axi_aclk
      .s_axi_aresetn(rst_ni),  // input wire s_axi_aresetn

      .s_axi_awaddr(m_axi_awaddr[(DATA*ADDRSIZE)+:MAXBLKSIZE]),  // input wire [19 : 0] s_axi_awaddr
      .s_axi_awprot(m_axi_awprot[(DATA*PROTSIZE)+:PROTSIZE]),  // input wire [2 : 0] s_axi_awprot
      .s_axi_awvalid(m_axi_awvalid[(DATA*VALIDSIZE)+:VALIDSIZE]),  // input wire s_axi_awvalid
      .s_axi_awready(m_axi_awready[(DATA*READYSIZE)+:READYSIZE]),  // output wire s_axi_awready
      .s_axi_wdata(m_axi_wdata[(DATA*DATASIZE)+:DATASIZE]),  // input wire [31 : 0] s_axi_wdata
      .s_axi_wstrb(m_axi_wstrb[(DATA*STRBSIZE)+:STRBSIZE]),  // input wire [3 : 0] s_axi_wstrb
      .s_axi_wvalid(m_axi_wvalid[(DATA*VALIDSIZE)+:VALIDSIZE]),  // input wire s_axi_wvalid
      .s_axi_wready(m_axi_wready[(DATA*READYSIZE)+:READYSIZE]),  // output wire s_axi_wready
      .s_axi_bresp(m_axi_bresp[(DATA*RESPSIZE)+:RESPSIZE]),  // output wire [1 : 0] s_axi_bresp
      .s_axi_bvalid(m_axi_bvalid[(DATA*VALIDSIZE)+:VALIDSIZE]),  // output wire s_axi_bvalid
      .s_axi_bready(m_axi_bready[(DATA*READYSIZE)+:READYSIZE]),  // input wire s_axi_bready
      .s_axi_araddr(m_axi_araddr[(DATA*ADDRSIZE)+:MAXBLKSIZE]),  // input wire [16 : 0] s_axi_araddr
      .s_axi_arprot(m_axi_arprot[(DATA*PROTSIZE)+:PROTSIZE]),  // input wire [2 : 0] s_axi_arprot
      .s_axi_arvalid(m_axi_arvalid[(DATA*VALIDSIZE)+:VALIDSIZE]),  // input wire s_axi_arvalid
      .s_axi_arready(m_axi_arready[(DATA*READYSIZE)+:READYSIZE]),  // output wire s_axi_arready
      .s_axi_rdata(m_axi_rdata[(DATA*DATASIZE)+:DATASIZE]),  // output wire [31 : 0] s_axi_rdata
      .s_axi_rresp(m_axi_rresp[(DATA*RESPSIZE)+:RESPSIZE]),  // output wire [1 : 0] s_axi_rresp
      .s_axi_rvalid(m_axi_rvalid[(DATA*VALIDSIZE)+:VALIDSIZE]),  // output wire s_axi_rvalid
      .s_axi_rready(m_axi_rready[(DATA*READYSIZE)+:READYSIZE]),  // input wire s_axi_rready

      .bram_rst_a   (bram_rst_b),     // output wire bram_rst_a
      .bram_clk_a   (bram_clk_b),     // output wire bram_clk_a
      .bram_en_a    (bram_en_b),      // output wire bram_en_a
      .bram_we_a    (bram_we_b),      // output wire [3 : 0] bram_we_a
      .bram_addr_a  (bram_addr_b),    // output wire [16 : 0] bram_addr_a
      .bram_wrdata_a(bram_wrdata_b),  // output wire [31 : 0] bram_wrdata_a
      .bram_rddata_a(bram_rddata_b)   // input wire [31 : 0] bram_rddata_a
  );

  localparam IMPL_MAXBLKSIZE = 17;

  logic [IMPL_MAXBLKSIZE-1:0] addr_a_aligned;
  logic [IMPL_MAXBLKSIZE-1:0] addr_b_aligned;

  assign addr_a_aligned = {bram_addr_a[2+:IMPL_MAXBLKSIZE]};
  assign addr_b_aligned = {bram_addr_b[2+:IMPL_MAXBLKSIZE]};

  dp_2clk_blk_ram #(
      .NB_COL(BYTES),  // Specify number of columns (number of bytes)
      .COL_WIDTH(AXI4_RDATA_WIDTH / BYTES),  // Specify column width (byte width, typically 8 or 9)
      .RAM_DEPTH(2 ** IMPL_MAXBLKSIZE),  // Specify RAM depth (number of entries)
      .RAM_PERFORMANCE("LOW_LATENCY"),  // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
      .INIT_FILE(FILE)                        // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) mem (
      .clka(bram_clk_a),  // Port A clock
      .ena(bram_en_a),  // Port A RAM Enable, for additional power savings, disable port when not in use
      .wea(bram_we_a),  // Port A write enable, width determined from NB_COL
      .addra(addr_a_aligned),  // Port A address bus, width determined from RAM_DEPTH
      .dina(bram_wrdata_a),  // Port A RAM input data, width determined from NB_COL*COL_WIDTH
      .douta(bram_rddata_a),  // Port A RAM output data, width determined from NB_COL*COL_WIDTH

      .clkb(bram_clk_b),  // Port B clock
      .enb(bram_en_b),  // Port B RAM Enable, for additional power savings, disable port when not in use
      .web(bram_we_b),  // Port B write enable, width determined from NB_COL
      .addrb(addr_b_aligned),  // Port B address bus, width determined from RAM_DEPTH
      .dinb(bram_wrdata_b),  // Port B RAM input data, width determined from NB_COL*COL_WIDTH
      .doutb(bram_rddata_b),  // Port B RAM output data, width determined from NB_COL*COL_WIDTH
      // Other
      .rsta('0),  // Port A output reset (does not affect memory contents)
      .rstb('0),  // Port B output reset (does not affect memory contents)
      .regcea('1),  // Port A output register enable //Unused
      .regceb('1)  // Port B output register enable //Unused
  );

  generate
    if (LOGGING) begin
      always @(posedge clk_i) begin
        // if (bram_en_a || bram_en_b)
        $display("addr_A=0x%08x: data_A=0x%08x addr_B=0x%08x: data_B=0x%08x", addr_a_aligned,
                 bram_rddata_a, addr_b_aligned, bram_rddata_b);
        if (bram_we_b) $display("write addr=0x%08x: data=0x%08x", addr_b_aligned, bram_wrdata_b);
        if ((addr_a_aligned >= 2 ** MAXBLKSIZE) || (addr_b_aligned >= 2 ** MAXBLKSIZE))
          $display("Out of Bounds Access!!");
      end
    end
  endgenerate

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

  logic exit_clk;
  logic exit_en;
  logic [BYTES-1:0] exit_we;
  logic [MAXBLKSIZE-1:0] exit_addr;
  logic [AXI4_WDATA_WIDTH-1:0] exit_wrdata;
  logic [AXI4_RDATA_WIDTH-1:0] exit_rddata = '0;

  // EXIT AXI Access
  axi_to_bram exit_axi_ctrl (
      .s_axi_aclk   (clk_i),     // input wire s_axi_aclk
      .s_axi_aresetn(rst_ni),  // input wire s_axi_aresetn

      .s_axi_awaddr(m_axi_awaddr[(EXIT*ADDRSIZE)+:MAXBLKSIZE]),  // input wire [16 : 0] s_axi_awaddr
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
      .s_axi_araddr(m_axi_araddr[(EXIT*ADDRSIZE)+:MAXBLKSIZE]),  // input wire [16 : 0] s_axi_araddr
      .s_axi_arprot(m_axi_arprot[(EXIT*PROTSIZE)+:PROTSIZE]),  // input wire [2 : 0] s_axi_arprot
      .s_axi_arvalid(m_axi_arvalid[(EXIT*VALIDSIZE)+:VALIDSIZE]),  // input wire s_axi_arvalid
      .s_axi_arready(m_axi_arready[(EXIT*READYSIZE)+:READYSIZE]),  // output wire s_axi_arready
      .s_axi_rdata(m_axi_rdata[(EXIT*DATASIZE)+:DATASIZE]),  // output wire [31 : 0] s_axi_rdata
      .s_axi_rresp(m_axi_rresp[(EXIT*RESPSIZE)+:RESPSIZE]),  // output wire [1 : 0] s_axi_rresp
      .s_axi_rvalid(m_axi_rvalid[(EXIT*VALIDSIZE)+:VALIDSIZE]),  // output wire s_axi_rvalid
      .s_axi_rready(m_axi_rready[(EXIT*READYSIZE)+:READYSIZE]),  // input wire s_axi_rready

      .bram_rst_a   (exit_rst),     // output wire bram_rst_a
      .bram_clk_a   (exit_clk),     // output wire bram_clk_a
      .bram_en_a    (exit_en),      // output wire bram_en_a
      .bram_we_a    (exit_we),      // output wire [3 : 0] bram_we_a
      .bram_addr_a  (exit_addr),    // output wire [16 : 0] bram_addr_a
      .bram_wrdata_a(exit_wrdata),  // output wire [31 : 0] bram_wrdata_a
      .bram_rddata_a(exit_rddata)   // input wire [31 : 0] bram_rddata_a
  );

  logic [31:0] exit_value;
  logic exit_valid;

  always_comb begin
    exit_valid = 0;
    exit_value = '0;

    if (exit_en && (exit_we[3] || exit_we[2] || exit_we[1] || exit_we[0])) begin
      if (exit_addr == 'h4) begin
        exit_valid = '1;
        exit_value = exit_wrdata;
      end else if (exit_addr == 'h10) begin
        exit_valid = '1;
        exit_value = '0;
      end
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      exit_valid_o <= 0;
      exit_value_o <= '0;
    end else if (clk_i) begin
      if (exit_valid) begin
        exit_valid_o <= exit_valid;
        exit_value_o <= exit_value;
      end
    end
  end

endmodule
