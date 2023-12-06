module axi_exit_dec (
    input logic s_axi_aclk,
    input logic s_axi_aresetn,

    input wire [31 : 0] s_axi_awaddr,
    input wire [2 : 0] s_axi_awprot,
    input wire s_axi_awvalid,
    output wire s_axi_awready,
    input wire [31 : 0] s_axi_wdata,
    input wire [3 : 0] s_axi_wstrb,
    input wire s_axi_wvalid,
    output wire s_axi_wready,
    output wire [1 : 0] s_axi_bresp,
    output wire s_axi_bvalid,
    input wire s_axi_bready,
    input wire [31 : 0] s_axi_araddr,
    input wire [2 : 0] s_axi_arprot,
    input wire s_axi_arvalid,
    output wire s_axi_arready,
    output wire [31 : 0] s_axi_rdata,
    output wire [1 : 0] s_axi_rresp,
    output wire s_axi_rvalid,
    input wire s_axi_rready,

    output logic exit_zero_o,
    output logic exit_valid_o  //,
    // output logic [31:0] exit_value_o
);
  localparam ADDRWIDTH = 20;

  logic exit_en;
  logic [3:0] exit_we;
  logic [ADDRWIDTH-1:0] exit_addr;
  logic [31:0] exit_wrdata;

  logic [31:0] exit_value;
  logic exit_valid;

  axi_to_bram exit_axi_ctrl (
      .s_axi_aclk   (s_axi_aclk),     // input wire s_axi_aclk
      .s_axi_aresetn(s_axi_aresetn),  // input wire s_axi_aresetn

      .s_axi_awaddr(s_axi_awaddr[0+:ADDRWIDTH]),  // input wire [19 : 0] s_axi_awaddr
      .s_axi_awprot(s_axi_awprot),  // input wire [2 : 0] s_axi_awprot
      .s_axi_awvalid(s_axi_awvalid),  // input wire s_axi_awvalid
      .s_axi_awready(s_axi_awready),  // output wire s_axi_awready
      .s_axi_wdata(s_axi_wdata),  // input wire [31 : 0] s_axi_wdata
      .s_axi_wstrb(s_axi_wstrb),  // input wire [3 : 0] s_axi_wstrb
      .s_axi_wvalid(s_axi_wvalid),  // input wire s_axi_wvalid
      .s_axi_wready(s_axi_wready),  // output wire s_axi_wready
      .s_axi_bresp(s_axi_bresp),  // output wire [1 : 0] s_axi_bresp
      .s_axi_bvalid(s_axi_bvalid),  // output wire s_axi_bvalid
      .s_axi_bready(s_axi_bready),  // input wire s_axi_bready
      .s_axi_araddr(s_axi_araddr[0+:ADDRWIDTH]),  // input wire [19 : 0] s_axi_araddr
      .s_axi_arprot(s_axi_arprot),  // input wire [2 : 0] s_axi_arprot
      .s_axi_arvalid(s_axi_arvalid),  // input wire s_axi_arvalid
      .s_axi_arready(s_axi_arready),  // output wire s_axi_arready
      .s_axi_rdata(s_axi_rdata),  // output wire [31 : 0] s_axi_rdata
      .s_axi_rresp(s_axi_rresp),  // output wire [1 : 0] s_axi_rresp
      .s_axi_rvalid(s_axi_rvalid),  // output wire s_axi_rvalid
      .s_axi_rready(s_axi_rready),  // input wire s_axi_rready

      .bram_rst_a   (),     // output wire bram_rst_a
      .bram_clk_a   (),     // output wire bram_clk_a
      .bram_en_a    (exit_en),      // output wire bram_en_a
      .bram_we_a    (exit_we),      // output wire [3 : 0] bram_we_a
      .bram_addr_a  (exit_addr),    // output wire [19 : 0] bram_addr_a
      .bram_wrdata_a(exit_wrdata),  // output wire [31 : 0] bram_wrdata_a
      .bram_rddata_a('0)   // input wire [31 : 0] bram_rddata_a
  );

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

  always_ff @(posedge s_axi_aclk or negedge s_axi_aresetn) begin
    if (~s_axi_aresetn) begin
      exit_valid_o <= 0;
      // exit_value_o <= '0;
      exit_zero_o  <= 0;
    end else if (s_axi_aclk) begin
      if (exit_valid) begin
        exit_valid_o <= exit_valid;
        // exit_value_o <= exit_value;
        exit_zero_o  <= (exit_value == '0);
      end
    end
  end

endmodule
