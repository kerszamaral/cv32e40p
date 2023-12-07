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

      // Core interface
      .data_req_i   (instr_req),
      .data_gnt_o   (instr_gnt),
      .data_rvalid_o(instr_rvalid),
      .data_addr_i  (instr_addr),
      .data_we_i    ('0),
      .data_be_i    ('0),
      .data_rdata_o (instr_rdata),
      .data_wdata_i ('0),

      // AXI Interface
      .AXI_Master(instr)
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

      // Core interface
      .data_req_i   (data_req),
      .data_gnt_o   (data_gnt),
      .data_rvalid_o(data_rvalid),
      .data_addr_i  (data_addr),
      .data_we_i    (data_we),
      .data_be_i    (data_be),
      .data_rdata_o (data_rdata),
      .data_wdata_i (data_wdata),

      // AXI Interface 
      .AXI_Master(data)
  );

endmodule
