`define OKAY 2'b00
`define EXOKAY 2'b01
`define SLVERR 2'b10
`define DECERR 2'b11

// construct with or
`define PROT_UNPRIV 3'b000
`define PROT_PRIV 3'b001
`define PROT_INSECURE 3'b010
`define PROT_SECURE 3'b000
`define PROT_INSTR 3'b100
`define PROT_DATA 3'b000

module core2axi #(
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ID_WIDTH   = 16,
    parameter AXI_USER_WIDTH = 10
) (
    // Clock and Reset
    input logic clk_i,
    input logic rst_ni,

    // Core interface
    input  logic                        data_req_i,
    output logic                        data_gnt_o,
    output logic                        data_rvalid_o,
    input  logic [  AXI_ADDR_WIDTH-1:0] data_addr_i,
    input  logic                        data_we_i,
    input  logic [AXI_DATA_WIDTH/8-1:0] data_be_i,
    output logic [  AXI_DATA_WIDTH-1:0] data_rdata_o,
    input  logic [  AXI_DATA_WIDTH-1:0] data_wdata_i,

    // AXI Interface 
    AXI_BUS.Master AXI_Master
);

  typedef logic [AXI_ID_WIDTH-1:0] id_t;
  typedef logic [AXI_ADDR_WIDTH-1:0] addr_t;
  typedef logic [AXI_DATA_WIDTH-1:0] data_t;
  typedef logic [AXI_DATA_WIDTH/8-1:0] strb_t;
  typedef logic [AXI_USER_WIDTH-1:0] user_t;

  `AXI_TYPEDEF_AW_CHAN_T(aw_chan_t, addr_t, id_t, user_t)
  `AXI_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t, user_t)
  `AXI_TYPEDEF_B_CHAN_T(b_chan_t, id_t, user_t)
  `AXI_TYPEDEF_AR_CHAN_T(ar_chan_t, addr_t, id_t, user_t)
  `AXI_TYPEDEF_R_CHAN_T(r_chan_t, data_t, id_t, user_t)
  `AXI_TYPEDEF_REQ_T(axi_req_t, aw_chan_t, w_chan_t, ar_chan_t)
  `AXI_TYPEDEF_RESP_T(axi_resp_t, b_chan_t, r_chan_t)

  axi_req_t  mst_req;
  axi_resp_t mst_resp;

  `AXI_ASSIGN_FROM_REQ(AXI_Master, mst_req)
  `AXI_ASSIGN_TO_RESP(mst_resp, AXI_Master)

  axi_from_mem #(
      .MemAddrWidth(AXI_ADDR_WIDTH),
      .AxiAddrWidth(AXI_ADDR_WIDTH),
      .DataWidth(AXI_DATA_WIDTH),
      .MaxRequests(1),
      .AxiProt(3'b000),
      .axi_req_t(axi_req_t),
      .axi_rsp_t(axi_resp_t)
  ) conv (
      .clk_i(clk_i),
      .rst_ni(rst_ni),
      .mem_req_i(data_req_i),
      .mem_addr_i(data_addr_i),
      .mem_we_i(data_we_i),
      .mem_wdata_i(data_wdata_i),
      .mem_be_i(data_be_i),
      .mem_gnt_o(data_gnt_o),
      .mem_rsp_valid_o(data_rvalid_o),
      .mem_rsp_rdata_o(data_rdata_o),
      .mem_rsp_error_o(),
      .slv_aw_cache_i(0),
      .slv_ar_cache_i(0),
      .axi_req_o(mst_req),
      .axi_rsp_i(mst_resp)
  );

endmodule
