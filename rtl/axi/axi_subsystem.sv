module axi_subsystem #(
    parameter INSTR_RDATA_WIDTH = 32,
    parameter RAM_ADDR_WIDTH = 22,
    parameter BOOT_ADDR = 'h80,
    parameter PULP_XPULP = 0,
    parameter PULP_CLUSTER = 0,
    parameter FPU = 0,
    parameter FPU_ADDMUL_LAT = 0,
    parameter FPU_OTHERS_LAT = 0,
    parameter ZFINX = 0,
    parameter NUM_MHPMCOUNTERS = 1,
    parameter DM_HALTADDRESS = 32'h1A110800
) (
    input logic clk_i,
    input logic rst_ni,

    input  logic        fetch_enable_i,
    output logic        tests_passed_o,
    output logic        tests_failed_o,
    output logic [31:0] exit_value_o,
    output logic        exit_valid_o,
    output logic [ 7:0] print_wdata_o,
    output logic        print_valid_o
);

  localparam MAXBLKSIZE = 17;
  localparam BYTES = 4;
  localparam AXI4_ADDRESS_WIDTH = 32;
  localparam AXI4_RDATA_WIDTH = 32;
  localparam AXI4_WDATA_WIDTH = 32;
  localparam AXI4_ID_WIDTH = 16;
  localparam AXI4_USER_WIDTH = 10;
  localparam REGISTERED_GRANT = "FALSE";  // "TRUE"|"FALSE"
  localparam FILE = "C:/Users/kersz/Documents/ufrgs/IC/cv32e40p/programs/prog.hex";
  localparam LOGGING = 0;

  cv32e40p_axi #(
      .COREV_PULP        (PULP_XPULP),
      // PULP ISA Extension (incl. custom CSRs and hardware loop, excl. cv.elw)
      .COREV_CLUSTER     (PULP_CLUSTER),
      // PULP Cluster interface (incl. cv.elw)
      .FPU               (FPU),
      // Floating Point Unit (interfaced via APU interface)
      .FPU_ADDMUL_LAT    (FPU_ADDMUL_LAT),
      // Floating-Point ADDition/MULtiplication computing lane pipeline registers number
      .FPU_OTHERS_LAT    (FPU_OTHERS_LAT),
      // Floating-Point COMParison/CONVersion computing lanes pipeline registers number
      .ZFINX             (ZFINX),
      // Float-in-General Purpose registers
      .NUM_MHPMCOUNTERS  (NUM_MHPMCOUNTERS),
      .AXI4_ADDRESS_WIDTH(AXI4_ADDRESS_WIDTH),
      .AXI4_RDATA_WIDTH  (AXI4_RDATA_WIDTH),
      .AXI4_WDATA_WIDTH  (AXI4_WDATA_WIDTH),
      .AXI4_ID_WIDTH     (AXI4_ID_WIDTH),
      .AXI4_USER_WIDTH   (AXI4_USER_WIDTH),
      // "TRUE"|"FALSE"
      .REGISTERED_GRANT  (REGISTERED_GRANT)
  ) top_i (
      // Clock and Reset
      .clk_i          (clk_i),
      .rst_ni         (rst_ni),
      .pulp_clock_en_i(1'b1),
      // PULP clock enable (only used if COREV_CLUSTER = 1)
      .scan_cg_en_i   (1'b0),
      // Enable all clock gates for testing

      // Core ID, Cluster ID, debug mode halt address and boot address are considered more or less static
      .boot_addr_i        (BOOT_ADDR),
      .mtvec_addr_i       (32'h0),
      .dm_halt_addr_i     (DM_HALTADDRESS),
      .hart_id_i          (32'h0),
      .dm_exception_addr_i(32'h0),
      //! AXI4 Instruction Interface
      //AXI write address bus -------------- // USED// -----------
      .instr_aw_id_o      (instr_aw_id),
      .instr_aw_addr_o    (instr_aw_addr),
      .instr_aw_len_o     (instr_aw_len),
      .instr_aw_size_o    (instr_aw_size),
      .instr_aw_burst_o   (instr_aw_burst),
      .instr_aw_lock_o    (instr_aw_lock),
      .instr_aw_cache_o   (instr_aw_cache),
      .instr_aw_prot_o    (instr_aw_prot),
      .instr_aw_region_o  (instr_aw_region),
      .instr_aw_user_o    (instr_aw_user),
      .instr_aw_qos_o     (instr_aw_qos),
      .instr_aw_valid_o   (instr_aw_valid),
      .instr_aw_ready_i   (instr_aw_ready),
      // ---------------------------------------------------------

      //AXI write data bus -------------- // USED// --------------
      .instr_w_data_o (instr_w_data),
      .instr_w_strb_o (instr_w_strb),
      .instr_w_last_o (instr_w_last),
      .instr_w_user_o (instr_w_user),
      .instr_w_valid_o(instr_w_valid),
      .instr_w_ready_i(instr_w_ready),
      // ---------------------------------------------------------

      //AXI write response bus -------------- // USED// ----------
      .instr_b_id_i   (instr_b_id),
      .instr_b_resp_i (instr_b_resp),
      .instr_b_valid_i(instr_b_valid),
      .instr_b_user_i (instr_b_user),
      .instr_b_ready_o(instr_b_ready),
      // ---------------------------------------------------------

      //AXI read address bus -------------------------------------
      .instr_ar_id_o    (instr_ar_id),
      .instr_ar_addr_o  (instr_ar_addr),
      .instr_ar_len_o   (instr_ar_len),
      .instr_ar_size_o  (instr_ar_size),
      .instr_ar_burst_o (instr_ar_burst),
      .instr_ar_lock_o  (instr_ar_lock),
      .instr_ar_cache_o (instr_ar_cache),
      .instr_ar_prot_o  (instr_ar_prot),
      .instr_ar_region_o(instr_ar_region),
      .instr_ar_user_o  (instr_ar_user),
      .instr_ar_qos_o   (instr_ar_qos),
      .instr_ar_valid_o (instr_ar_valid),
      .instr_ar_ready_i (instr_ar_ready),
      // ---------------------------------------------------------

      //AXI read data bus ----------------------------------------
      .instr_r_id_i   (instr_r_id),
      .instr_r_data_i (instr_r_data),
      .instr_r_resp_i (instr_r_resp),
      .instr_r_last_i (instr_r_last),
      .instr_r_user_i (instr_r_user),
      .instr_r_valid_i(instr_r_valid),
      .instr_r_ready_o(instr_r_ready),
      // ---------------------------------------------------------

      //! AXI4 Data Interface
      //AXI write address bus -------------- // USED// -----------
      .data_aw_id_o    (data_aw_id),
      .data_aw_addr_o  (data_aw_addr),
      .data_aw_len_o   (data_aw_len),
      .data_aw_size_o  (data_aw_size),
      .data_aw_burst_o (data_aw_burst),
      .data_aw_lock_o  (data_aw_lock),
      .data_aw_cache_o (data_aw_cache),
      .data_aw_prot_o  (data_aw_prot),
      .data_aw_region_o(data_aw_region),
      .data_aw_user_o  (data_aw_user),
      .data_aw_qos_o   (data_aw_qos),
      .data_aw_valid_o (data_aw_valid),
      .data_aw_ready_i (data_aw_ready),
      // ---------------------------------------------------------

      //AXI write data bus -------------- // USED// --------------
      .data_w_data_o (data_w_data),
      .data_w_strb_o (data_w_strb),
      .data_w_last_o (data_w_last),
      .data_w_user_o (data_w_user),
      .data_w_valid_o(data_w_valid),
      .data_w_ready_i(data_w_ready),
      // ---------------------------------------------------------

      //AXI write response bus -------------- // USED// ----------
      .data_b_id_i   (data_b_id),
      .data_b_resp_i (data_b_resp),
      .data_b_valid_i(data_b_valid),
      .data_b_user_i (data_b_user),
      .data_b_ready_o(data_b_ready),
      // ---------------------------------------------------------

      //AXI read address bus -------------------------------------
      .data_ar_id_o    (data_ar_id),
      .data_ar_addr_o  (data_ar_addr),
      .data_ar_len_o   (data_ar_len),
      .data_ar_size_o  (data_ar_size),
      .data_ar_burst_o (data_ar_burst),
      .data_ar_lock_o  (data_ar_lock),
      .data_ar_cache_o (data_ar_cache),
      .data_ar_prot_o  (data_ar_prot),
      .data_ar_region_o(data_ar_region),
      .data_ar_user_o  (data_ar_user),
      .data_ar_qos_o   (data_ar_qos),
      .data_ar_valid_o (data_ar_valid),
      .data_ar_ready_i (data_ar_ready),
      // ---------------------------------------------------------

      //AXI read data bus ----------------------------------------
      .data_r_id_i   (data_r_id),
      .data_r_data_i (data_r_data),
      .data_r_resp_i (data_r_resp),
      .data_r_last_i (data_r_last),
      .data_r_user_i (data_r_user),
      .data_r_valid_i(data_r_valid),
      .data_r_ready_o(data_r_ready),
      // ---------------------------------------------------------

      // Interrupt inputs
      .irq_i            (irq),
      // CLINT interrupts + CLINT extension interrupts
      .irq_ack_o        (irq_ack),
      .irq_id_o         (irq_id),
      // Debug Interface
      .debug_req_i      (debug_req),
      .debug_havereset_o(debug_havereset),
      .debug_running_o  (debug_running),
      .debug_halted_o   (debug_halted),
      // CPU Control Signals
      .fetch_enable_i   (fetch_enable),
      .core_sleep_o     (core_sleep)
  );

  axi_mm_ram #(
      .MAXBLKSIZE        (MAXBLKSIZE),
      .BYTES             (BYTES),
      .AXI4_ADDRESS_WIDTH(AXI4_ADDRESS_WIDTH),
      .AXI4_RDATA_WIDTH  (AXI4_RDATA_WIDTH),
      .AXI4_WDATA_WIDTH  (AXI4_WDATA_WIDTH),
      .AXI4_ID_WIDTH     (AXI4_ID_WIDTH),
      .AXI4_USER_WIDTH   (AXI4_USER_WIDTH),
      .FILE              (FILE),
      .LOGGING           (LOGGING)
  ) u_axi_mm_ram (
      .clk_i            (clk_i),
      .rst_ni           (rst_ni),
      //! AXI4 Instruction Interface
      //AXI write address bus -------------- // USED// -----------
      .instr_aw_id_i    (instr_aw_id),
      .instr_aw_addr_i  (instr_aw_addr),
      .instr_aw_len_i   (instr_aw_len),
      .instr_aw_size_i  (instr_aw_size),
      .instr_aw_burst_i (instr_aw_burst),
      .instr_aw_lock_i  (instr_aw_lock),
      .instr_aw_cache_i (instr_aw_cache),
      .instr_aw_prot_i  (instr_aw_prot),
      .instr_aw_region_i(instr_aw_region),
      .instr_aw_user_i  (instr_aw_user),
      .instr_aw_qos_i   (instr_aw_qos),
      .instr_aw_valid_i (instr_aw_valid),
      .instr_aw_ready_o (instr_aw_ready),
      // ---------------------------------------------------------

      //AXI write data bus -------------- // USED// --------------
      .instr_w_data_i (instr_w_data),
      .instr_w_strb_i (instr_w_strb),
      .instr_w_last_i (instr_w_last),
      .instr_w_user_i (instr_w_user),
      .instr_w_valid_i(instr_w_valid),
      .instr_w_ready_o(instr_w_ready),
      // ---------------------------------------------------------

      //AXI write response bus -------------- // USED// ----------
      .instr_b_id_o   (instr_b_id),
      .instr_b_resp_o (instr_b_resp),
      .instr_b_valid_o(instr_b_valid),
      .instr_b_user_o (instr_b_user),
      .instr_b_ready_i(instr_b_ready),
      // ---------------------------------------------------------

      //AXI read address bus -------------------------------------
      .instr_ar_id_i    (instr_ar_id),
      .instr_ar_addr_i  (instr_ar_addr),
      .instr_ar_len_i   (instr_ar_len),
      .instr_ar_size_i  (instr_ar_size),
      .instr_ar_burst_i (instr_ar_burst),
      .instr_ar_lock_i  (instr_ar_lock),
      .instr_ar_cache_i (instr_ar_cache),
      .instr_ar_prot_i  (instr_ar_prot),
      .instr_ar_region_i(instr_ar_region),
      .instr_ar_user_i  (instr_ar_user),
      .instr_ar_qos_i   (instr_ar_qos),
      .instr_ar_valid_i (instr_ar_valid),
      .instr_ar_ready_o (instr_ar_ready),
      // ---------------------------------------------------------

      //AXI read data bus ----------------------------------------
      .instr_r_id_o   (instr_r_id),
      .instr_r_data_o (instr_r_data),
      .instr_r_resp_o (instr_r_resp),
      .instr_r_last_o (instr_r_last),
      .instr_r_user_o (instr_r_user),
      .instr_r_valid_o(instr_r_valid),
      .instr_r_ready_i(instr_r_ready),
      // ---------------------------------------------------------

      //! AXI4 Data Interface
      //AXI write address bus -------------- // USED// -----------
      .data_aw_id_i    (data_aw_id),
      .data_aw_addr_i  (data_aw_addr),
      .data_aw_len_i   (data_aw_len),
      .data_aw_size_i  (data_aw_size),
      .data_aw_burst_i (data_aw_burst),
      .data_aw_lock_i  (data_aw_lock),
      .data_aw_cache_i (data_aw_cache),
      .data_aw_prot_i  (data_aw_prot),
      .data_aw_region_i(data_aw_region),
      .data_aw_user_i  (data_aw_user),
      .data_aw_qos_i   (data_aw_qos),
      .data_aw_valid_i (data_aw_valid),
      .data_aw_ready_o (data_aw_ready),
      // ---------------------------------------------------------

      //AXI write data bus -------------- // USED// --------------
      .data_w_data_i (data_w_data),
      .data_w_strb_i (data_w_strb),
      .data_w_last_i (data_w_last),
      .data_w_user_i (data_w_user),
      .data_w_valid_i(data_w_valid),
      .data_w_ready_o(data_w_ready),
      // ---------------------------------------------------------

      //AXI write response bus -------------- // USED// ----------
      .data_b_id_o   (data_b_id),
      .data_b_resp_o (data_b_resp),
      .data_b_valid_o(data_b_valid),
      .data_b_user_o (data_b_user),
      .data_b_ready_i(data_b_ready),
      // ---------------------------------------------------------

      //AXI read address bus -------------------------------------
      .data_ar_id_i    (data_ar_id),
      .data_ar_addr_i  (data_ar_addr),
      .data_ar_len_i   (data_ar_len),
      .data_ar_size_i  (data_ar_size),
      .data_ar_burst_i (data_ar_burst),
      .data_ar_lock_i  (data_ar_lock),
      .data_ar_cache_i (data_ar_cache),
      .data_ar_prot_i  (data_ar_prot),
      .data_ar_region_i(data_ar_region),
      .data_ar_user_i  (data_ar_user),
      .data_ar_qos_i   (data_ar_qos),
      .data_ar_valid_i (data_ar_valid),
      .data_ar_ready_o (data_ar_ready),
      // ---------------------------------------------------------

      //AXI read data bus ----------------------------------------
      .data_r_id_o   (data_r_id),
      .data_r_data_o (data_r_data),
      .data_r_resp_o (data_r_resp),
      .data_r_last_o (data_r_last),
      .data_r_user_o (data_r_user),
      .data_r_valid_o(data_r_valid),
      .data_r_ready_i(data_r_ready),
      // ---------------------------------------------------------

      // Interrupt outputs
      .irq_i         (irq),
      // CLINT interrupts + CLINT extension interrupts
      .irq_ack_o     (irq_ack),
      .irq_id_o      (irq_id),
      // Debug Interface
      .pc_core_id_i  (top_i.core_i.pc_id),
      .tests_passed_o(tests_passed_o),
      .tests_failed_o(tests_failed_o),
      .exit_valid_o  (exit_valid_o),
      .exit_value_o  (exit_value_o),
      .print_valid_o (print_valid_o),
      .print_wdata_o (print_wdata_o)
  );

endmodule
