module axi_mm_ram #(
    parameter MAXBLKSIZE = 17,
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
    output logic        tests_passed_o,
    output logic        tests_failed_o,
    output logic        exit_valid_o,
    output logic [31:0] exit_value_o,

    output logic [7:0] print_wdata_o,
    output logic print_valid_o
);

  logic bram_clk_a;
  logic bram_en_a;
  logic bram_we_a;
  logic [MAXBLKSIZE-1:0] bram_addr_a;
  logic [AXI4_WDATA_WIDTH-1:0] bram_wrdata_a;
  logic [AXI4_RDATA_WIDTH-1:0] bram_rddata_a;


  logic bram_clk_b;
  logic bram_en_b;
  logic bram_we_b;
  logic [MAXBLKSIZE-1:0] bram_addr_b;
  logic [AXI4_WDATA_WIDTH-1:0] bram_wrdata_b;
  logic [AXI4_RDATA_WIDTH-1:0] bram_rddata_b;

  logic [AXI4_ADDRESS_WIDTH-1:0] data_aw_addr_dec;
  logic data_aw_valid_dec;
  logic data_aw_ready_dec;
  logic data_w_valid_dec;
  logic data_w_ready_dec;
  logic data_b_valid_dec;
  logic data_b_ready_dec;

  always_comb begin
    tests_passed_o = '0;
    tests_failed_o = '0;
    exit_value_o = 0;
    exit_valid_o = '0;
    print_wdata_o = '0;
    print_valid_o = '0;

    data_aw_addr_dec = 0;
    data_aw_valid_dec = '0;
    data_aw_ready_dec = '0;
    data_w_valid_dec = '0;
    data_w_ready_dec = '0;
    data_b_valid_dec = '0;
    data_b_ready_dec = '0;

    if (data_aw_valid_i) begin  // handle writes
      if (data_aw_addr_i == 32'h1000_0000) begin
        if (data_w_valid_i) begin
          $display("%c", data_wdata_o[7:0]);
          print_wdata_o  = data_wdata_o[7:0];
          print_valid_o  = data_awvalid_o;
          data_w_ready_o = '1;
          data_b_ready_o = '1;
        end
        data_aw_ready_o = '1;
      end else if (data_aw_addr_i == 32'h2000_0004) begin
        if (data_w_valid_i) begin
          exit_valid_o   = '1;
          exit_value_o   = data_wdata_o;
          data_w_ready_o = '1;
          data_b_ready_o = '1;
        end
        data_aw_ready_o = '1;
      end else if (data_aw_addr_i == 32'h2000_0010) begin
        // end simulation
        if (data_w_valid_i) begin
          exit_valid_o   = '1;
          exit_value_o   = '0;
          data_w_ready_o = '1;
          data_b_ready_o = '1;
        end
        data_aw_ready_o = '1;
      end else begin
        data_aw_addr_dec = data_aw_addr_i;
        data_aw_valid_dec = data_aw_valid_i;
        data_aw_ready_o = data_aw_ready_dec;
        data_w_valid_dec = data_w_valid_i;
        data_w_ready_o = data_w_ready_dec;
        data_b_ready_o = data_b_ready_dec;
        data_b_ready_dec = data_b_ready_i;
      end
    end
  end

  axi_bram_ctrl_0 instr_axi_ctrl (
      .s_axi_aclk   (clk_i),  // input wire s_axi_aclk
      .s_axi_aresetn(rst_ni), // input wire s_axi_aresetn

      .s_axi_awaddr (instr_aw_addr_i),   // input wire [16 : 0] s_axi_awaddr
      .s_axi_awlen  (instr_aw_len_i),    // input wire [7 : 0] s_axi_awlen
      .s_axi_awsize (instr_aw_size_i),   // input wire [2 : 0] s_axi_awsize
      .s_axi_awburst(instr_aw_burst_i),  // input wire [1 : 0] s_axi_awburst
      .s_axi_awlock (instr_aw_lock_i),   // input wire s_axi_awlock
      .s_axi_awcache(instr_aw_cache_i),  // input wire [3 : 0] s_axi_awcache
      .s_axi_awprot (instr_aw_prot_i),   // input wire [2 : 0] s_axi_awprot
      .s_axi_awvalid(instr_aw_valid_i),  // input wire s_axi_awvalid
      .s_axi_awready(instr_aw_ready_o),  // output wire s_axi_awready
      .s_axi_wdata  (instr_w_data_i),    // input wire [31 : 0] s_axi_wdata
      .s_axi_wstrb  (instr_w_strb_i),    // input wire [3 : 0] s_axi_wstrb
      .s_axi_wlast  (instr_w_last_i),    // input wire s_axi_wlast
      .s_axi_wvalid (instr_w_valid_i),   // input wire s_axi_wvalid
      .s_axi_wready (instr_w_ready_o),   // output wire s_axi_wready
      .s_axi_bresp  (instr_b_resp_o),    // output wire [1 : 0] s_axi_bresp
      .s_axi_bvalid (instr_b_valid_o),   // output wire s_axi_bvalid
      .s_axi_bready (instr_b_ready_i),   // input wire s_axi_bready
      .s_axi_araddr (instr_ar_addr_i),   // input wire [16 : 0] s_axi_araddr
      .s_axi_arlen  (instr_ar_len_i),    // input wire [7 : 0] s_axi_arlen
      .s_axi_arsize (instr_ar_size_i),   // input wire [2 : 0] s_axi_arsize
      .s_axi_arburst(instr_ar_burst_i),  // input wire [1 : 0] s_axi_arburst
      .s_axi_arlock (instr_ar_lock_i),   // input wire s_axi_arlock
      .s_axi_arcache(instr_ar_cache_i),  // input wire [3 : 0] s_axi_arcache
      .s_axi_arprot (instr_ar_prot_i),   // input wire [2 : 0] s_axi_arprot
      .s_axi_arvalid(instr_ar_valid_i),  // input wire s_axi_arvalid
      .s_axi_arready(instr_ar_ready_o),  // output wire s_axi_arready
      .s_axi_rdata  (instr_r_data_o),    // output wire [31 : 0] s_axi_rdata
      .s_axi_rresp  (instr_r_resp_o),    // output wire [1 : 0] s_axi_rresp
      .s_axi_rlast  (instr_r_last_o),    // output wire s_axi_rlast
      .s_axi_rvalid (instr_r_valid_o),   // output wire s_axi_rvalid
      .s_axi_rready (instr_r_ready_i),   // input wire s_axi_rready
      .bram_rst_a   (bram_rst_a),        // output wire bram_rst_a
      .bram_clk_a   (bram_clk_a),        // output wire bram_clk_a
      .bram_en_a    (bram_en_a),         // output wire bram_en_a
      .bram_we_a    (bram_we_a),         // output wire [3 : 0] bram_we_a
      .bram_addr_a  (bram_addr_a),       // output wire [16 : 0] bram_addr_a
      .bram_wrdata_a(bram_wrdata_a),     // output wire [31 : 0] bram_wrdata_a
      .bram_rddata_a(bram_rddata_a)      // input wire [31 : 0] bram_rddata_a
  );

  axi_bram_ctrl_0 data_axi_ctrl (
      .s_axi_aclk   (clk_i),  // input wire s_axi_aclk
      .s_axi_aresetn(rst_ni), // input wire s_axi_aresetn

      .s_axi_awaddr(data_aw_addr_de),  // input wire [16 : 0] s_axi_awaddr
      .s_axi_awlen(data_aw_len_i),  // input wire [7 : 0] s_axi_awlen
      .s_axi_awsize(data_aw_size_i),  // input wire [2 : 0] s_axi_awsize
      .s_axi_awburst(data_aw_burst_i),  // input wire [1 : 0] s_axi_awburst
      .s_axi_awlock(data_aw_lock_i),  // input wire s_axi_awlock
      .s_axi_awcache(data_aw_cache_i),  // input wire [3 : 0] s_axi_awcache
      .s_axi_awprot(data_aw_prot_i),  // input wire [2 : 0] s_axi_awprot
      .s_axi_awvalid(data_aw_valid_dec),  // input wire s_axi_awvalid
      .s_axi_awready(data_aw_ready_dec),  // output wire s_axi_awready
      .s_axi_wdata(data_w_data_i),  // input wire [31 : 0] s_axi_wdata
      .s_axi_wstrb(data_w_strb_i),  // input wire [3 : 0] s_axi_wstrb
      .s_axi_wlast(data_w_last_i),  // input wire s_axi_wlast
      .s_axi_wvalid(data_w_valid_dec),  // input wire s_axi_wvalid
      .s_axi_wready(data_w_ready_dec),  // output wire s_axi_wready
      .s_axi_bresp(data_b_resp_o),  // output wire [1 : 0] s_axi_bresp
      .s_axi_bvalid(data_b_valid_dec),  // output wire s_axi_bvalid
      .s_axi_bready(data_b_ready_dec),  // input wire s_axi_bready
      .s_axi_araddr(data_ar_addr_i),  // input wire [16 : 0] s_axi_araddr
      .s_axi_arlen(data_ar_len_i),  // input wire [7 : 0] s_axi_arlen
      .s_axi_arsize(data_ar_size_i),  // input wire [2 : 0] s_axi_arsize
      .s_axi_arburst(data_ar_burst_i),  // input wire [1 : 0] s_axi_arburst
      .s_axi_arlock(data_ar_lock_i),  // input wire s_axi_arlock
      .s_axi_arcache(data_ar_cache_i),  // input wire [3 : 0] s_axi_arcache
      .s_axi_arprot(data_ar_prot_i),  // input wire [2 : 0] s_axi_arprot
      .s_axi_arvalid(data_ar_valid_i),  // input wire s_axi_arvalid
      .s_axi_arready(data_ar_ready_o),  // output wire s_axi_arready
      .s_axi_rdata(data_r_data_o),  // output wire [31 : 0] s_axi_rdata
      .s_axi_rresp(data_r_resp_o),  // output wire [1 : 0] s_axi_rresp
      .s_axi_rlast(data_r_last_o),  // output wire s_axi_rlast
      .s_axi_rvalid(data_r_valid_o),  // output wire s_axi_rvalid
      .s_axi_rready(data_r_ready_i),  // input wire s_axi_rready

      .bram_rst_a   (bram_rst_b),     // output wire bram_rst_a
      .bram_clk_a   (bram_clk_b),     // output wire bram_clk_a
      .bram_en_a    (bram_en_b),      // output wire bram_en_a
      .bram_we_a    (bram_we_b),      // output wire [3 : 0] bram_we_a
      .bram_addr_a  (bram_addr_b),    // output wire [16 : 0] bram_addr_a
      .bram_wrdata_a(bram_wrdata_b),  // output wire [31 : 0] bram_wrdata_a
      .bram_rddata_a(bram_rddata_b)   // input wire [31 : 0] bram_rddata_a
  );

  logic [MAXBLKSIZE-1:0] addr_a_aligned;
  logic [MAXBLKSIZE-1:0] addr_b_aligned;

  assign addr_a_aligned = {bram_addr_a[2+:MAXBLKSIZE]};
  assign addr_b_aligned = {bram_addr_b[2+:MAXBLKSIZE]};

  dp_2clk_blk_ram #(
      .NB_COL(BYTES),  // Specify number of columns (number of bytes)
      .COL_WIDTH(AXI4_RDATA_WIDTH / BYTES),  // Specify column width (byte width, typically 8 or 9)
      .RAM_DEPTH(2 ** MAXBLKSIZE),  // Specify RAM depth (number of entries)
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
        if (bram_we_b) $display("write addr=0x%08x: data=0x%08x", addr_b_aligned, bram_wrdata_b);
        $display("addr_A=0x%08x: data_A=0x%08x addr_B=0x%08x: data_B=0x%08x", addr_a_aligned,
                 bram_rddata_a, addr_b_aligned, bram_rddata_b);
        if ((addr_a_aligned >= 2 ** MAXBLKSIZE) || (addr_b_aligned >= 2 ** MAXBLKSIZE))
          $display("Out of Bounds Access!!");
      end
    end
  endgenerate

endmodule
