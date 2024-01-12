module axi_subsystem #(
    parameter BOOT_ADDR = 'h80,
    parameter PULP_XPULP = 0,
    parameter PULP_CLUSTER = 0,
    parameter FPU = 0,
    parameter FPU_ADDMUL_LAT = 0,
    parameter FPU_OTHERS_LAT = 0,
    parameter ZFINX = 0,
    parameter NUM_MHPMCOUNTERS = 1,
    parameter DM_HALTADDRESS = 32'h1A110800,

    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ID_WIDTH   = 2,
    parameter AXI_USER_WIDTH = 2,

    parameter REGISTERED_GRANT = "FALSE",  // "TRUE"|"FALSE"

    parameter INPUT_CLK_FREQ  = 100_000_000,
    parameter OUTPUT_CLK_FREQ = 25_000_000
) (
    input logic clk_i,
    input logic rst_ni,

    input  logic fetch_enable_i,
    output logic exit_zero_o,
    output logic exit_valid_o,
    input  logic rx_i,
    output logic tx_o
);

  logic clk;
  clk_divisor #(
      .INPUT_CLK_FREQ (INPUT_CLK_FREQ),
      .OUTPUT_CLK_FREQ(OUTPUT_CLK_FREQ)
  ) u_clk_div (
      .clk_i(clk_i),
      .clk_o(clk)
  );

  // AXI interface
  localparam MASTER_NUM = 2;
  localparam INSTR = 0;
  localparam DATA = 1;
  AXI_BUS #(
      .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
      .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
      .AXI_ID_WIDTH  (AXI_ID_WIDTH),
      .AXI_USER_WIDTH(AXI_USER_WIDTH)
  ) AXI_Masters[MASTER_NUM-1:0] ();

  // Interrupts
  logic [31:0] irq;  // CLINT interrupts + CLINT extension interrupts
  logic irq_ack;
  logic [4:0] irq_id;

  logic debug_req = 1'b0;

  cv32e40p_axi #(
      .COREV_PULP      (PULP_XPULP),
      // PULP ISA Extension (incl. custom CSRs and hardware loop, excl. cv.elw)
      .COREV_CLUSTER   (PULP_CLUSTER),
      // PULP Cluster interface (incl. cv.elw)
      .FPU             (FPU),
      // Floating Point Unit (interfaced via APU interface)
      .FPU_ADDMUL_LAT  (FPU_ADDMUL_LAT),
      // Floating-Point ADDition/MULtiplication computing lane pipeline registers number
      .FPU_OTHERS_LAT  (FPU_OTHERS_LAT),
      // Floating-Point COMParison/CONVersion computing lanes pipeline registers number
      .ZFINX           (ZFINX),
      // Float-in-General Purpose registers
      .NUM_MHPMCOUNTERS(NUM_MHPMCOUNTERS),

      .AXI_ADDR_WIDTH  (AXI_ADDR_WIDTH),
      .AXI_DATA_WIDTH  (AXI_DATA_WIDTH),
      .AXI_ID_WIDTH    (AXI_ID_WIDTH),
      .AXI_USER_WIDTH  (AXI_USER_WIDTH),
      // "TRUE"|"FALSE"
      .REGISTERED_GRANT(REGISTERED_GRANT)
  ) top_i (
      // Clock and Reset
      .clk_i          (clk),
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
      .instr              (AXI_Masters[INSTR]),
      .data               (AXI_Masters[DATA]),
      // Interrupt inputs
      .irq_i              (irq),
      // CLINT interrupts + CLINT extension interrupts
      .irq_ack_o          (irq_ack),
      .irq_id_o           (irq_id),
      // Debug Interface
      .debug_req_i        (debug_req),
      .debug_havereset_o  (debug_havereset),
      .debug_running_o    (debug_running),
      .debug_halted_o     (debug_halted),
      // CPU Control Signals
      .fetch_enable_i     (fetch_enable_i),
      .core_sleep_o       (core_sleep)
  );

  axi_mm_ram #(
      .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
      .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
      .AXI_ID_WIDTH(AXI_ID_WIDTH),
      .AXI_USER_WIDTH(AXI_USER_WIDTH),
      .MASTER_NUM(MASTER_NUM),
      .CLK_FREQ(OUTPUT_CLK_FREQ)
  ) u_axi_mm_ram (
      .clk_i (clk),
      .rst_ni(rst_ni),
      /// Number of AXI masters connected to the xbar. (Number of slave ports)
      .AXI_Masters(AXI_Masters),

      // Interrupt outputs
      .irq_o    (irq),
      // CLINT interrupts + CLINT extension interrupts
      .irq_ack_i(irq_ack),
      .irq_id_i (irq_id),

      // Debug Interface
      .exit_valid_o(exit_valid_o),
      .exit_zero_o (exit_zero_o),
      .rx_i        (rx_i),
      .tx_o        (tx_o)
  );

endmodule
