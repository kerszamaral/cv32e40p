`include "assign.svh"

module axi_mm_ram #(
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ID_WIDTH = 16,
    parameter AXI_USER_WIDTH = 10,
    parameter MASTER_NUM = 2,
    parameter LOGGING = 0,
    parameter OLD_XBAR_MODE = 0
) (
    input logic clk_i,
    input logic rst_ni,

    /// Number of AXI masters connected to the xbar. (Number of slave ports)
    AXI_BUS.Slave AXI_Masters[MASTER_NUM-1:0],

    // Interrupt outputs
    output logic [31:0] irq_o,      // CLINT interrupts + CLINT extension interrupts
    input  logic        irq_ack_i,
    input  logic [ 4:0] irq_id_i,

    output logic exit_valid_o,
    output logic exit_zero_o,

    input  logic rx_i,
    output logic tx_o
);
  /// Number of AXI slaves connected to the xbar. (Number of master ports)
  localparam SLAVE_NUM = 3;

  // Slave IDs
  localparam MEM = 0;
  localparam UART = 1;
  localparam EXIT = 2;

  // Crossbar configuration
  typedef axi_pkg::xbar_rule_32_t rule_t;

  // Each slave has its own address range:
  function rule_t [SLAVE_NUM-1:0] addr_map_gen();
    addr_map_gen[MEM] = rule_t'{
        idx: unsigned'(MEM),
        start_addr: 32'h0000_0000,
        end_addr: 32'h1000_0000,
        default: '0
    };
    addr_map_gen[UART] = rule_t'{
        idx: unsigned'(UART),
        start_addr: 32'h1000_0000,
        end_addr: 32'h1000_0010,
        default: '0
    };
    addr_map_gen[EXIT] = rule_t'{
        idx: unsigned'(EXIT),
        start_addr: 32'h2000_0000,
        end_addr: 32'h2000_0010,
        default: '0
    };
  endfunction
  localparam rule_t [SLAVE_NUM-1:0] AddrMap = addr_map_gen();

  // AXI4 Interfaces
  AXI_BUS #(
      .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
      .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
      .AXI_ID_WIDTH  (AXI_ID_WIDTH),
      .AXI_USER_WIDTH(AXI_USER_WIDTH)
  ) slave[SLAVE_NUM-1:0] ();

  impl_xbar #(
      .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
      .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
      .AXI_ID_WIDTH(AXI_ID_WIDTH),
      .AXI_USER_WIDTH(AXI_USER_WIDTH),
      .MASTER_NUM(MASTER_NUM),
      .SLAVE_NUM(SLAVE_NUM),
      .OLD(OLD_XBAR_MODE)
  ) xbar (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .addr_map_i(AddrMap),

      .AXI_Slaves (AXI_Masters),
      .AXI_Masters(slave)
  );

  axi_mem #(
      .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
      .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
      .AXI_ID_WIDTH(AXI_ID_WIDTH),
      .AXI_USER_WIDTH(AXI_USER_WIDTH),
      .LOGGING(LOGGING)
  ) mem (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .AXI_Slave(slave[MEM])
  );

  wire interrupt;

  axi_uart #(
      .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
      .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
      .AXI_ID_WIDTH  (AXI_ID_WIDTH),
      .AXI_USER_WIDTH(AXI_USER_WIDTH)
  ) uart (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .AXI_Slave(slave[UART]),

      .interrupt_o(interrupt),
      .rx_i(rx_i),
      .tx_o(tx_o)
  );

  // EXIT AXI Access
  axi_exit_dec #(
      .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
      .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
      .AXI_ID_WIDTH  (AXI_ID_WIDTH),
      .AXI_USER_WIDTH(AXI_USER_WIDTH)
  ) u_exit_dec (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .AXI_Slave(slave[EXIT]),

      .exit_zero_o (exit_zero_o),
      .exit_valid_o(exit_valid_o)
  );

  assign irq_o = '0;

endmodule
