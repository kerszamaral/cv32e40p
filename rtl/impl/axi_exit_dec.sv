module axi_exit_dec #(
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ID_WIDTH   = 16,
    parameter AXI_USER_WIDTH = 10
) (
    input logic clk_i,
    input logic rst_ni,

    AXI_BUS.Slave AXI_Slave,

    output logic exit_zero_o,
    output logic exit_valid_o  //,
    // output logic [31:0] exit_value_o
);

  logic exit_req;
  logic exit_we;
  logic [31:0] exit_addr;
  logic [31:0] exit_wrdata;

  axi_to_mem_intf #(
      /// See `axi_to_mem`, parameter `AddrWidth`.
      .ADDR_WIDTH    (AXI_ADDR_WIDTH),
      /// See `axi_to_mem`, parameter `DataWidth`.
      .DATA_WIDTH    (AXI_DATA_WIDTH),
      /// AXI4+ATOP ID width.
      .ID_WIDTH      (AXI_ID_WIDTH),
      /// AXI4+ATOP user width.
      .USER_WIDTH    (AXI_USER_WIDTH),
      /// See `axi_to_mem`, parameter `NumBanks`.
      .NUM_BANKS     (1),
      /// See `axi_to_mem`, parameter `BufDepth`.
      .BUF_DEPTH     (1),
      /// Hide write requests if the strb == '0
      .HIDE_STRB     (0),
      /// Depth of output fifo/fall_through_register. Increase for asymmetric backpressure (contention) on banks.
      .OUT_FIFO_DEPTH(1)
  ) u_axi_to_mem_intf (
      /// Clock input.
      .clk_i (clk_i),
      /// Asynchronous reset, active low.
      .rst_ni(rst_ni),
      /// See `axi_to_mem`, port `busy_o`.
      .busy_o(),
      /// AXI4+ATOP slave interface port.
      .slv   (AXI_Slave),

      /// See `axi_to_mem`, port `mem_req_o`.
      .mem_req_o   (exit_req),
      /// See `axi_to_mem`, port `mem_gnt_i`.
      .mem_gnt_i   ('1),
      /// See `axi_to_mem`, port `mem_addr_o`.
      .mem_addr_o  (exit_addr),
      /// See `axi_to_mem`, port `mem_wdata_o`.
      .mem_wdata_o (exit_wrdata),
      /// See `axi_to_mem`, port `mem_strb_o`.
      .mem_strb_o  (),
      /// See `axi_to_mem`, port `mem_atop_o`.
      .mem_atop_o  (),
      /// See `axi_to_mem`, port `mem_we_o`.
      .mem_we_o    (exit_we),
      /// See `axi_to_mem`, port `mem_rvalid_i`.
      .mem_rvalid_i('0),
      /// See `axi_to_mem`, port `mem_rdata_i`.
      .mem_rdata_i ('0)
  );

  logic [31:0] exit_value;
  logic exit_valid;

  always_comb begin
    exit_valid = 0;
    exit_value = '0;

    if (exit_req && exit_we) begin
      if (exit_addr[0+:8] == 'h4) begin
        exit_valid = '1;
        exit_value = exit_wrdata;
      end else if (exit_addr[0+:8] == 'h10) begin
        exit_valid = '1;
        exit_value = '0;
      end
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      exit_valid_o <= 0;
      // exit_value_o <= '0;
      exit_zero_o  <= 0;
    end else begin
      if (exit_valid) begin
        exit_valid_o <= exit_valid;
        // exit_value_o <= exit_value;
        exit_zero_o  <= (exit_value == '0);
      end
    end
  end

endmodule
