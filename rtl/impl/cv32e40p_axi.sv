// Top file instantiating a CV32E40P core, an optional FPU and AXI interfaces
// Contributor: Davide Schiavone <davide@openhwgroup.org>

module cv32e40p_axi #(
    parameter COREV_PULP = 0, // PULP ISA Extension (incl. custom CSRs and hardware loop, excl. cv.elw)
    parameter COREV_CLUSTER = 0,  // PULP Cluster interface (incl. cv.elw)
    parameter FPU = 0,  // Floating Point Unit (interfaced via APU interface)
    parameter FPU_ADDMUL_LAT = 0,  // Floating-Point ADDition/MULtiplication computing lane pipeline registers number
    parameter FPU_OTHERS_LAT = 0,  // Floating-Point COMParison/CONVersion computing lanes pipeline registers number
    parameter ZFINX = 0,  // Float-in-General Purpose registers
    parameter NUM_MHPMCOUNTERS = 1,

    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ID_WIDTH = 16,
    parameter AXI_USER_WIDTH = 10,
    parameter REGISTERED_GRANT = "FALSE"  // "TRUE"|"FALSE"
) (
    // Clock and Reset
    input logic clk_i,
    input logic rst_ni,

    input logic pulp_clock_en_i,  // PULP clock enable (only used if COREV_CLUSTER = 1)
    input logic scan_cg_en_i,  // Enable all clock gates for testing

    // Core ID, Cluster ID, debug mode halt address and boot address are considered more or less static
    input logic [31:0] boot_addr_i,
    input logic [31:0] mtvec_addr_i,
    input logic [31:0] dm_halt_addr_i,
    input logic [31:0] hart_id_i,
    input logic [31:0] dm_exception_addr_i,

    // AXI4 Instruction Interface
    AXI_BUS.Master instr,
    // AXI4 Data Interface
    AXI_BUS.Master data,

    // Interrupt inputs
    input  logic [31:0] irq_i,      // CLINT interrupts + CLINT extension interrupts
    output logic        irq_ack_o,
    output logic [ 4:0] irq_id_o,

    // Debug Interface
    input  logic debug_req_i,
    output logic debug_havereset_o,
    output logic debug_running_o,
    output logic debug_halted_o,

    // CPU Control Signals
    input  logic fetch_enable_i,
    output logic core_sleep_o
);

  // Core <--> AXI
  // Instruction memory interface
  logic        instr_req;
  logic        instr_gnt;
  logic        instr_rvalid;
  logic [31:0] instr_addr;
  logic [31:0] instr_rdata;

  // Data memory interface
  logic        data_req;
  logic        data_gnt;
  logic        data_rvalid;
  logic        data_we;
  logic [ 3:0] data_be;
  logic [31:0] data_addr;
  logic [31:0] data_wdata;
  logic [31:0] data_rdata;

  // Instantiate the Core
  cv32e40p_top #(
      .COREV_PULP      (COREV_PULP),
      // PULP ISA Extension (incl. custom CSRs and hardware loop, excl. cv.elw)
      .COREV_CLUSTER   (COREV_CLUSTER),
      // PULP Cluster interface (incl. cv.elw)
      .FPU             (FPU),
      // Floating Point Unit (interfaced via APU interface)
      .FPU_ADDMUL_LAT  (FPU_ADDMUL_LAT),
      // Floating-Point ADDition/MULtiplication computing lane pipeline registers number
      .FPU_OTHERS_LAT  (FPU_OTHERS_LAT),
      // Floating-Point COMParison/CONVersion computing lanes pipeline registers number
      .ZFINX           (ZFINX),
      // Float-in-General Purpose registers
      .NUM_MHPMCOUNTERS(NUM_MHPMCOUNTERS)
  ) u_cv32e40p_top (
      // Clock and Reset
      .clk_i          (clk_i),
      .rst_ni         (rst_ni),
      .pulp_clock_en_i(pulp_clock_en_i),
      // PULP clock enable (only used if COREV_CLUSTER = 1)
      .scan_cg_en_i   (scan_cg_en_i),
      // Enable all clock gates for testing

      // Core ID, Cluster ID, debug mode halt address and boot address are considered more or less static
      .boot_addr_i        (boot_addr_i),
      .mtvec_addr_i       (mtvec_addr_i),
      .dm_halt_addr_i     (dm_halt_addr_i),
      .hart_id_i          (hart_id_i),
      .dm_exception_addr_i(dm_exception_addr_i),

      // Instruction memory interface
      .instr_req_o   (instr_req),
      .instr_gnt_i   (instr_gnt),
      .instr_rvalid_i(instr_rvalid),
      .instr_addr_o  (instr_addr),
      .instr_rdata_i (instr_rdata),

      // Data memory interface
      .data_req_o   (data_req),
      .data_gnt_i   (data_gnt),
      .data_rvalid_i(data_rvalid),
      .data_we_o    (data_we),
      .data_be_o    (data_be),
      .data_addr_o  (data_addr),
      .data_wdata_o (data_wdata),
      .data_rdata_i (data_rdata),

      // Interrupt inputs
      .irq_i            (irq_i),
      // CLINT interrupts + CLINT extension interrupts
      .irq_ack_o        (irq_ack_o),
      .irq_id_o         (irq_id_o),
      // Debug Interface
      .debug_req_i      (debug_req_i),
      .debug_havereset_o(debug_havereset_o),
      .debug_running_o  (debug_running_o),
      .debug_halted_o   (debug_halted_o),
      // CPU Control Signals
      .fetch_enable_i   (fetch_enable_i),
      .core_sleep_o     (core_sleep_o)
  );

  core2axi #(
      .AXI4_ADDRESS_WIDTH(AXI_ADDR_WIDTH),
      .AXI4_RDATA_WIDTH  (AXI_DATA_WIDTH),
      .AXI4_WDATA_WIDTH  (AXI_DATA_WIDTH),
      .AXI4_ID_WIDTH     (AXI_ID_WIDTH),
      .AXI4_USER_WIDTH   (AXI_USER_WIDTH),
      // "TRUE"|"FALSE"
      .REGISTERED_GRANT  (REGISTERED_GRANT)
  ) instr_core2axi (
      // Clock and Reset
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      // ---------------------------------------------------------
      // Core Ports Declarations ---------------------------------
      // ---------------------------------------------------------
      .data_req_i   (instr_req),
      .data_gnt_o   (instr_gnt),
      .data_rvalid_o(instr_rvalid),
      .data_addr_i  (instr_addr),
      .data_we_i    ('0),
      .data_be_i    ('0),
      .data_rdata_o (instr_rdata),
      .data_wdata_i ('0),
      // ---------------------------------------------------------
      // AXI TARG Port Declarations ------------------------------
      // ---------------------------------------------------------
      //AXI write address bus -------------- // USED// -----------
      .aw_id_o      (instr.aw_id),
      .aw_addr_o    (instr.aw_addr),
      .aw_len_o     (instr.aw_len),
      .aw_size_o    (instr.aw_size),
      .aw_burst_o   (instr.aw_burst),
      .aw_lock_o    (instr.aw_lock),
      .aw_cache_o   (instr.aw_cache),
      .aw_prot_o    (instr.aw_prot),
      .aw_region_o  (instr.aw_region),
      .aw_user_o    (instr.aw_user),
      .aw_qos_o     (instr.aw_qos),
      .aw_valid_o   (instr.aw_valid),
      .aw_ready_i   (instr.aw_ready),
      // ---------------------------------------------------------

      //AXI write data bus -------------- // USED// --------------
      .w_data_o (instr.w_data),
      .w_strb_o (instr.w_strb),
      .w_last_o (instr.w_last),
      .w_user_o (instr.w_user),
      .w_valid_o(instr.w_valid),
      .w_ready_i(instr.w_ready),
      // ---------------------------------------------------------

      //AXI write response bus -------------- // USED// ----------
      .b_id_i   (instr.b_id),
      .b_resp_i (instr.b_resp),
      .b_valid_i(instr.b_valid),
      .b_user_i (instr.b_user),
      .b_ready_o(instr.b_ready),
      // ---------------------------------------------------------

      //AXI read address bus -------------------------------------
      .ar_id_o    (instr.ar_id),
      .ar_addr_o  (instr.ar_addr),
      .ar_len_o   (instr.ar_len),
      .ar_size_o  (instr.ar_size),
      .ar_burst_o (instr.ar_burst),
      .ar_lock_o  (instr.ar_lock),
      .ar_cache_o (instr.ar_cache),
      .ar_prot_o  (instr.ar_prot),
      .ar_region_o(instr.ar_region),
      .ar_user_o  (instr.ar_user),
      .ar_qos_o   (instr.ar_qos),
      .ar_valid_o (instr.ar_valid),
      .ar_ready_i (instr.ar_ready),
      // ---------------------------------------------------------

      //AXI read data bus ----------------------------------------
      .r_id_i   (instr.r_id),
      .r_data_i (instr.r_data),
      .r_resp_i (instr.r_resp),
      .r_last_i (instr.r_last),
      .r_user_i (instr.r_user),
      .r_valid_i(instr.r_valid),
      .r_ready_o(instr.r_ready)
      // ---------------------------------------------------------
  );

  core2axi #(
      .AXI4_ADDRESS_WIDTH(AXI_ADDR_WIDTH),
      .AXI4_RDATA_WIDTH  (AXI_DATA_WIDTH),
      .AXI4_WDATA_WIDTH  (AXI_DATA_WIDTH),
      .AXI4_ID_WIDTH     (AXI_ID_WIDTH),
      .AXI4_USER_WIDTH   (AXI_USER_WIDTH),
      // "TRUE"|"FALSE"
      .REGISTERED_GRANT  (REGISTERED_GRANT)
  ) data_core2axi (
      // Clock and Reset
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .data_req_i   (data_req),
      .data_gnt_o   (data_gnt),
      .data_rvalid_o(data_rvalid),
      .data_addr_i  (data_addr),
      .data_we_i    (data_we),
      .data_be_i    (data_be),
      .data_rdata_o (data_rdata),
      .data_wdata_i (data_wdata),
      // ---------------------------------------------------------
      // AXI TARG Port Declarations ------------------------------
      // ---------------------------------------------------------
      //AXI write address bus -------------- // USED// -----------
      .aw_id_o      (data.aw_id),
      .aw_addr_o    (data.aw_addr),
      .aw_len_o     (data.aw_len),
      .aw_size_o    (data.aw_size),
      .aw_burst_o   (data.aw_burst),
      .aw_lock_o    (data.aw_lock),
      .aw_cache_o   (data.aw_cache),
      .aw_prot_o    (data.aw_prot),
      .aw_region_o  (data.aw_region),
      .aw_user_o    (data.aw_user),
      .aw_qos_o     (data.aw_qos),
      .aw_valid_o   (data.aw_valid),
      .aw_ready_i   (data.aw_ready),
      // ---------------------------------------------------------

      //AXI write data bus -------------- // USED// --------------
      .w_data_o (data.w_data),
      .w_strb_o (data.w_strb),
      .w_last_o (data.w_last),
      .w_user_o (data.w_user),
      .w_valid_o(data.w_valid),
      .w_ready_i(data.w_ready),
      // ---------------------------------------------------------

      //AXI write response bus -------------- // USED// ----------
      .b_id_i   (data.b_id),
      .b_resp_i (data.b_resp),
      .b_valid_i(data.b_valid),
      .b_user_i (data.b_user),
      .b_ready_o(data.b_ready),
      // ---------------------------------------------------------

      //AXI read address bus -------------------------------------
      .ar_id_o    (data.ar_id),
      .ar_addr_o  (data.ar_addr),
      .ar_len_o   (data.ar_len),
      .ar_size_o  (data.ar_size),
      .ar_burst_o (data.ar_burst),
      .ar_lock_o  (data.ar_lock),
      .ar_cache_o (data.ar_cache),
      .ar_prot_o  (data.ar_prot),
      .ar_region_o(data.ar_region),
      .ar_user_o  (data.ar_user),
      .ar_qos_o   (data.ar_qos),
      .ar_valid_o (data.ar_valid),
      .ar_ready_i (data.ar_ready),
      // ---------------------------------------------------------

      //AXI read data bus ----------------------------------------
      .r_id_i   (data.r_id),
      .r_data_i (data.r_data),
      .r_resp_i (data.r_resp),
      .r_last_i (data.r_last),
      .r_user_i (data.r_user),
      .r_valid_i(data.r_valid),
      .r_ready_o(data.r_ready)
      // ---------------------------------------------------------
  );

endmodule
