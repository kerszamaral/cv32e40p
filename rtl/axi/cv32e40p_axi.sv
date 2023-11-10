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
    parameter AXI4_ADDRESS_WIDTH = 32,
    parameter AXI4_RDATA_WIDTH = 32,
    parameter AXI4_WDATA_WIDTH = 32,
    parameter AXI4_ID_WIDTH = 16,
    parameter AXI4_USER_WIDTH = 10,
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

    //! AXI4 Instruction Interface
    //AXI write address bus -------------- // USED// -----------
    output logic [     AXI4_ID_WIDTH-1:0] instr_aw_id_o,
    output logic [AXI4_ADDRESS_WIDTH-1:0] instr_aw_addr_o,
    output logic [                   7:0] instr_aw_len_o,
    output logic [                   2:0] instr_aw_size_o,
    output logic [                   1:0] instr_aw_burst_o,
    output logic                          instr_aw_lock_o,
    output logic [                   3:0] instr_aw_cache_o,
    output logic [                   2:0] instr_aw_prot_o,
    output logic [                   3:0] instr_aw_region_o,
    output logic [   AXI4_USER_WIDTH-1:0] instr_aw_user_o,
    output logic [                   3:0] instr_aw_qos_o,
    output logic                          instr_aw_valid_o,
    input  logic                          instr_aw_ready_i,
    // ---------------------------------------------------------

    //AXI write data bus -------------- // USED// --------------
    output logic [  AXI4_WDATA_WIDTH-1:0] instr_w_data_o,
    output logic [AXI4_WDATA_WIDTH/8-1:0] instr_w_strb_o,
    output logic                          instr_w_last_o,
    output logic [   AXI4_USER_WIDTH-1:0] instr_w_user_o,
    output logic                          instr_w_valid_o,
    input  logic                          instr_w_ready_i,
    // ---------------------------------------------------------

    //AXI write response bus -------------- // USED// ----------
    input  logic [  AXI4_ID_WIDTH-1:0] instr_b_id_i,
    input  logic [                1:0] instr_b_resp_i,
    input  logic                       instr_b_valid_i,
    input  logic [AXI4_USER_WIDTH-1:0] instr_b_user_i,
    output logic                       instr_b_ready_o,
    // ---------------------------------------------------------

    //AXI read address bus -------------------------------------
    output logic [     AXI4_ID_WIDTH-1:0] instr_ar_id_o,
    output logic [AXI4_ADDRESS_WIDTH-1:0] instr_ar_addr_o,
    output logic [                   7:0] instr_ar_len_o,
    output logic [                   2:0] instr_ar_size_o,
    output logic [                   1:0] instr_ar_burst_o,
    output logic                          instr_ar_lock_o,
    output logic [                   3:0] instr_ar_cache_o,
    output logic [                   2:0] instr_ar_prot_o,
    output logic [                   3:0] instr_ar_region_o,
    output logic [   AXI4_USER_WIDTH-1:0] instr_ar_user_o,
    output logic [                   3:0] instr_ar_qos_o,
    output logic                          instr_ar_valid_o,
    input  logic                          instr_ar_ready_i,
    // ---------------------------------------------------------

    //AXI read data bus ----------------------------------------
    input  logic [   AXI4_ID_WIDTH-1:0] instr_r_id_i,
    input  logic [AXI4_RDATA_WIDTH-1:0] instr_r_data_i,
    input  logic [                 1:0] instr_r_resp_i,
    input  logic                        instr_r_last_i,
    input  logic [ AXI4_USER_WIDTH-1:0] instr_r_user_i,
    input  logic                        instr_r_valid_i,
    output logic                        instr_r_ready_o,
    // ---------------------------------------------------------

    //! AXI4 Data Interface
    //AXI write address bus -------------- // USED// -----------
    output logic [     AXI4_ID_WIDTH-1:0] data_aw_id_o,
    output logic [AXI4_ADDRESS_WIDTH-1:0] data_aw_addr_o,
    output logic [                   7:0] data_aw_len_o,
    output logic [                   2:0] data_aw_size_o,
    output logic [                   1:0] data_aw_burst_o,
    output logic                          data_aw_lock_o,
    output logic [                   3:0] data_aw_cache_o,
    output logic [                   2:0] data_aw_prot_o,
    output logic [                   3:0] data_aw_region_o,
    output logic [   AXI4_USER_WIDTH-1:0] data_aw_user_o,
    output logic [                   3:0] data_aw_qos_o,
    output logic                          data_aw_valid_o,
    input  logic                          data_aw_ready_i,
    // ---------------------------------------------------------

    //AXI write data bus -------------- // USED// --------------
    output logic [  AXI4_WDATA_WIDTH-1:0] data_w_data_o,
    output logic [AXI4_WDATA_WIDTH/8-1:0] data_w_strb_o,
    output logic                          data_w_last_o,
    output logic [   AXI4_USER_WIDTH-1:0] data_w_user_o,
    output logic                          data_w_valid_o,
    input  logic                          data_w_ready_i,
    // ---------------------------------------------------------

    //AXI write response bus -------------- // USED// ----------
    input  logic [  AXI4_ID_WIDTH-1:0] data_b_id_i,
    input  logic [                1:0] data_b_resp_i,
    input  logic                       data_b_valid_i,
    input  logic [AXI4_USER_WIDTH-1:0] data_b_user_i,
    output logic                       data_b_ready_o,
    // ---------------------------------------------------------

    //AXI read address bus -------------------------------------
    output logic [     AXI4_ID_WIDTH-1:0] data_ar_id_o,
    output logic [AXI4_ADDRESS_WIDTH-1:0] data_ar_addr_o,
    output logic [                   7:0] data_ar_len_o,
    output logic [                   2:0] data_ar_size_o,
    output logic [                   1:0] data_ar_burst_o,
    output logic                          data_ar_lock_o,
    output logic [                   3:0] data_ar_cache_o,
    output logic [                   2:0] data_ar_prot_o,
    output logic [                   3:0] data_ar_region_o,
    output logic [   AXI4_USER_WIDTH-1:0] data_ar_user_o,
    output logic [                   3:0] data_ar_qos_o,
    output logic                          data_ar_valid_o,
    input  logic                          data_ar_ready_i,
    // ---------------------------------------------------------

    //AXI read data bus ----------------------------------------
    input  logic [   AXI4_ID_WIDTH-1:0] data_r_id_i,
    input  logic [AXI4_RDATA_WIDTH-1:0] data_r_data_i,
    input  logic [                 1:0] data_r_resp_i,
    input  logic                        data_r_last_i,
    input  logic [ AXI4_USER_WIDTH-1:0] data_r_user_i,
    input  logic                        data_r_valid_i,
    output logic                        data_r_ready_o,
    // ---------------------------------------------------------

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

  import cv32e40p_apu_core_pkg::*;

  // Core to FPU
  logic                              clk;
  logic                              apu_req;
  logic [   APU_NARGS_CPU-1:0][31:0] apu_operands;
  logic [     APU_WOP_CPU-1:0]       apu_op;
  logic [APU_NDSFLAGS_CPU-1:0]       apu_flags;

  // FPU to Core
  logic                              apu_gnt;
  logic                              apu_rvalid;
  logic [                31:0]       apu_rdata;
  logic [APU_NUSFLAGS_CPU-1:0]       apu_rflags;

  // Core <--> AXI
  // Instruction memory interface
  logic                              instr_req;
  logic                              instr_gnt;
  logic                              instr_rvalid;
  logic [                31:0]       instr_addr;
  logic [                31:0]       instr_rdata;

  // Data memory interface
  logic                              data_req;
  logic                              data_gnt;
  logic                              data_rvalid;
  logic [                31:0]       data_addr;
  logic                              data_we;
  logic [                 3:0]       data_be;
  logic [                31:0]       data_rdata;
  logic [                31:0]       data_wdata;

  // Instantiate the Core
  cv32e40p_core #(
      .COREV_PULP      (COREV_PULP),
      .COREV_CLUSTER   (COREV_CLUSTER),
      .FPU             (FPU),
      .FPU_ADDMUL_LAT  (FPU_ADDMUL_LAT),
      .FPU_OTHERS_LAT  (FPU_OTHERS_LAT),
      .ZFINX           (ZFINX),
      .NUM_MHPMCOUNTERS(NUM_MHPMCOUNTERS)
  ) core_i (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .pulp_clock_en_i(pulp_clock_en_i),
      .scan_cg_en_i   (scan_cg_en_i),

      .boot_addr_i        (boot_addr_i),
      .mtvec_addr_i       (mtvec_addr_i),
      .dm_halt_addr_i     (dm_halt_addr_i),
      .hart_id_i          (hart_id_i),
      .dm_exception_addr_i(dm_exception_addr_i),

      .instr_req_o   (instr_req),
      .instr_gnt_i   (instr_gnt),
      .instr_rvalid_i(instr_rvalid),
      .instr_addr_o  (instr_addr),
      .instr_rdata_i (instr_rdata),

      .data_req_o   (data_req),
      .data_gnt_i   (data_gnt),
      .data_rvalid_i(data_rvalid),
      .data_we_o    (data_we),
      .data_be_o    (data_be),
      .data_addr_o  (data_addr),
      .data_wdata_o (data_wdata),
      .data_rdata_i (data_rdata),

      .apu_req_o     (apu_req),
      .apu_gnt_i     (apu_gnt),
      .apu_operands_o(apu_operands),
      .apu_op_o      (apu_op),
      .apu_flags_o   (apu_flags),
      .apu_rvalid_i  (apu_rvalid),
      .apu_result_i  (apu_rdata),
      .apu_flags_i   (apu_rflags),

      .irq_i    (irq_i),
      .irq_ack_o(irq_ack_o),
      .irq_id_o (irq_id_o),

      .debug_req_i      (debug_req_i),
      .debug_havereset_o(debug_havereset_o),
      .debug_running_o  (debug_running_o),
      .debug_halted_o   (debug_halted_o),

      .fetch_enable_i(fetch_enable_i),
      .core_sleep_o  (core_sleep_o)
  );

  generate
    if (FPU) begin : fpu_gen
      // FPU clock gate
      cv32e40p_clock_gate core_clock_gate_i (
          .clk_i       (clk_i),
          .en_i        (!core_sleep_o),
          .scan_cg_en_i(scan_cg_en_i),
          .clk_o       (clk)
      );

      // Instantiate the FPU wrapper
      cv32e40p_fp_wrapper #(
          .FPU_ADDMUL_LAT(FPU_ADDMUL_LAT),
          .FPU_OTHERS_LAT(FPU_OTHERS_LAT)
      ) fp_wrapper_i (
          .clk_i         (clk),
          .rst_ni        (rst_ni),
          .apu_req_i     (apu_req),
          .apu_gnt_o     (apu_gnt),
          .apu_operands_i(apu_operands),
          .apu_op_i      (apu_op),
          .apu_flags_i   (apu_flags),
          .apu_rvalid_o  (apu_rvalid),
          .apu_rdata_o   (apu_rdata),
          .apu_rflags_o  (apu_rflags)
      );
    end else begin : no_fpu_gen
      // Drive FPU output signals to 0
      assign apu_gnt    = '0;
      assign apu_rvalid = '0;
      assign apu_rdata  = '0;
      assign apu_rflags = '0;
    end
  endgenerate

  core2axi #(
      .AXI4_ADDRESS_WIDTH(AXI4_ADDRESS_WIDTH),
      .AXI4_RDATA_WIDTH  (AXI4_RDATA_WIDTH),
      .AXI4_WDATA_WIDTH  (AXI4_WDATA_WIDTH),
      .AXI4_ID_WIDTH     (AXI4_ID_WIDTH),
      .AXI4_USER_WIDTH   (AXI4_USER_WIDTH),
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
      .aw_id_o      (instr_aw_id_o),
      .aw_addr_o    (instr_aw_addr_o),
      .aw_len_o     (instr_aw_len_o),
      .aw_size_o    (instr_aw_size_o),
      .aw_burst_o   (instr_aw_burst_o),
      .aw_lock_o    (instr_aw_lock_o),
      .aw_cache_o   (instr_aw_cache_o),
      .aw_prot_o    (instr_aw_prot_o),
      .aw_region_o  (instr_aw_region_o),
      .aw_user_o    (instr_aw_user_o),
      .aw_qos_o     (instr_aw_qos_o),
      .aw_valid_o   (instr_aw_valid_o),
      .aw_ready_i   (instr_aw_ready_i),
      // ---------------------------------------------------------

      //AXI write data bus -------------- // USED// --------------
      .w_data_o (instr_w_data_o),
      .w_strb_o (instr_w_strb_o),
      .w_last_o (instr_w_last_o),
      .w_user_o (instr_w_user_o),
      .w_valid_o(instr_w_valid_o),
      .w_ready_i(instr_w_ready_i),
      // ---------------------------------------------------------

      //AXI write response bus -------------- // USED// ----------
      .b_id_i   (instr_b_id_i),
      .b_resp_i (instr_b_resp_i),
      .b_valid_i(instr_b_valid_i),
      .b_user_i (instr_b_user_i),
      .b_ready_o(instr_b_ready_o),
      // ---------------------------------------------------------

      //AXI read address bus -------------------------------------
      .ar_id_o    (instr_ar_id_o),
      .ar_addr_o  (instr_ar_addr_o),
      .ar_len_o   (instr_ar_len_o),
      .ar_size_o  (instr_ar_size_o),
      .ar_burst_o (instr_ar_burst_o),
      .ar_lock_o  (instr_ar_lock_o),
      .ar_cache_o (instr_ar_cache_o),
      .ar_prot_o  (instr_ar_prot_o),
      .ar_region_o(instr_ar_region_o),
      .ar_user_o  (instr_ar_user_o),
      .ar_qos_o   (instr_ar_qos_o),
      .ar_valid_o (instr_ar_valid_o),
      .ar_ready_i (instr_ar_ready_i),
      // ---------------------------------------------------------

      //AXI read data bus ----------------------------------------
      .r_id_i   (instr_r_id_i),
      .r_data_i (instr_r_data_i),
      .r_resp_i (instr_r_resp_i),
      .r_last_i (instr_r_last_i),
      .r_user_i (instr_r_user_i),
      .r_valid_i(instr_r_valid_i),
      // ---------------------------------------------------------
      .r_ready_o(instr_r_ready_o)
  );

  core2axi #(
      .AXI4_ADDRESS_WIDTH(AXI4_ADDRESS_WIDTH),
      .AXI4_RDATA_WIDTH  (AXI4_RDATA_WIDTH),
      .AXI4_WDATA_WIDTH  (AXI4_WDATA_WIDTH),
      .AXI4_ID_WIDTH     (AXI4_ID_WIDTH),
      .AXI4_USER_WIDTH   (AXI4_USER_WIDTH),
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
      .aw_id_o      (data_aw_id_o),
      .aw_addr_o    (data_aw_addr_o),
      .aw_len_o     (data_aw_len_o),
      .aw_size_o    (data_aw_size_o),
      .aw_burst_o   (data_aw_burst_o),
      .aw_lock_o    (data_aw_lock_o),
      .aw_cache_o   (data_aw_cache_o),
      .aw_prot_o    (data_aw_prot_o),
      .aw_region_o  (data_aw_region_o),
      .aw_user_o    (data_aw_user_o),
      .aw_qos_o     (data_aw_qos_o),
      .aw_valid_o   (data_aw_valid_o),
      .aw_ready_i   (data_aw_ready_i),
      // ---------------------------------------------------------

      //AXI write data bus -------------- // USED// --------------
      .w_data_o (data_w_data_o),
      .w_strb_o (data_w_strb_o),
      .w_last_o (data_w_last_o),
      .w_user_o (data_w_user_o),
      .w_valid_o(data_w_valid_o),
      .w_ready_i(data_w_ready_i),
      // ---------------------------------------------------------

      //AXI write response bus -------------- // USED// ----------
      .b_id_i   (data_b_id_i),
      .b_resp_i (data_b_resp_i),
      .b_valid_i(data_b_valid_i),
      .b_user_i (data_b_user_i),
      .b_ready_o(data_b_ready_o),
      // ---------------------------------------------------------

      //AXI read address bus -------------------------------------
      .ar_id_o    (data_ar_id_o),
      .ar_addr_o  (data_ar_addr_o),
      .ar_len_o   (data_ar_len_o),
      .ar_size_o  (data_ar_size_o),
      .ar_burst_o (data_ar_burst_o),
      .ar_lock_o  (data_ar_lock_o),
      .ar_cache_o (data_ar_cache_o),
      .ar_prot_o  (data_ar_prot_o),
      .ar_region_o(data_ar_region_o),
      .ar_user_o  (data_ar_user_o),
      .ar_qos_o   (data_ar_qos_o),
      .ar_valid_o (data_ar_valid_o),
      .ar_ready_i (data_ar_ready_i),
      // ---------------------------------------------------------

      //AXI read data bus ----------------------------------------
      .r_id_i   (data_r_id_i),
      .r_data_i (data_r_data_i),
      .r_resp_i (data_r_resp_i),
      .r_last_i (data_r_last_i),
      .r_user_i (data_r_user_i),
      .r_valid_i(data_r_valid_i),
      // ---------------------------------------------------------
      .r_ready_o(data_r_ready_o)
  );

endmodule
