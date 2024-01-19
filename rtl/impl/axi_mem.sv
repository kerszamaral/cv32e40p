module axi_mem #(
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ID_WIDTH = 16,
    parameter AXI_USER_WIDTH = 10,
    parameter OLD = 0
) (
    input logic clk_i,
    input logic rst_ni,

    AXI_BUS.Slave AXI_Slave
);
  generate
    ;
    if (OLD == 0) begin

      wire mem_req_o;
      wire mem_gnt_i;
      wire [AXI_ADDR_WIDTH-1:0] mem_addr_o;
      wire [AXI_DATA_WIDTH-1:0] mem_wdata_o;
      wire [AXI_DATA_WIDTH/8-1:0] mem_strb_o;
      wire mem_we_o;
      wire [AXI_DATA_WIDTH/8-1:0] mem_we;
      wire mem_rvalid_i;
      wire [AXI_DATA_WIDTH-1:0] mem_rdata_i;
      logic mem_r_valid_q;

      axi_to_mem_intf #(
          .ADDR_WIDTH(AXI_ADDR_WIDTH),
          .DATA_WIDTH(AXI_DATA_WIDTH),
          .ID_WIDTH(AXI_ID_WIDTH),
          .USER_WIDTH(AXI_USER_WIDTH),
          .NUM_BANKS(1),
          .BUF_DEPTH(2),
          .HIDE_STRB(0),
          .OUT_FIFO_DEPTH(1)
      ) axi_to_mem (
          .clk_i(clk_i),
          .rst_ni(rst_ni),
          .busy_o(),
          .slv(AXI_Slave),

          .mem_req_o(mem_req_o),
          .mem_gnt_i('1),
          .mem_addr_o(mem_addr_o),
          .mem_wdata_o(mem_wdata_o),
          .mem_strb_o(mem_strb_o),
          .mem_atop_o(),
          .mem_we_o(mem_we_o),
          .mem_rvalid_i(mem_rvalid_i),
          .mem_rdata_i(mem_rdata_i)
      );

      assign mem_we = mem_strb_o & mem_we_o;
      always @(posedge clk_i) begin
        if (rst_ni == 0) begin
          mem_r_valid_q <= 0;
        end else begin
          mem_r_valid_q <= mem_req_o;
        end
      end

      assign mem_rvalid_i = mem_r_valid_q;

      localparam MEM_SIZE = 17;
      wire [MEM_SIZE-1:0] mem_addr;
      // assign mem_addr = {2'b00, mem_addr_o[2+:MEM_SIZE-2]};
      assign mem_addr = mem_addr_o[2+:MEM_SIZE];

      xilinx_simple_dual_port_byte_write_1_clock_ram #(
          .NB_COL(AXI_DATA_WIDTH / 8),  // Specify number of columns (number of bytes)
          .COL_WIDTH(8),  // Specify column width (byte width, typically 8 or 9)
          .ADDR_WIDTH(MEM_SIZE),  // Specify RAM depth (number of entries)
          .RAM_PERFORMANCE("LOW_LATENCY"),  // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
          .INIT_FILE("C:/Users/kersz/Documents/ufrgs/IC/cv32e40p/programs/basic/basic.hex") // Specify name/location of RAM initialization file if using one (leave blank if not)
      ) memory (
          .clka(clk_i),  // Clock
          .addra(mem_addr),  // Write address bus, width determined from RAM_DEPTH
          .addrb(mem_addr),  // Read address bus, width determined from RAM_DEPTH
          .dina(mem_wdata_o),  // RAM input data, width determined from NB_COL*COL_WIDTH
          .wea(mem_we),  // Byte-write enable, width determined from NB_COL
          .enb(mem_req_o),  // Read Enable, for additional power savings, disable when not in use
          .rstb(),  // Output reset (does not affect memory contents)
          .regceb(),  // Output register enable
          .doutb(mem_rdata_i)  // RAM output data, width determined from NB_COL*COL_WIDTH
      );

    end else begin
      wire rsta_busy;
      wire rstb_busy;

      dp_axi_bram mem (
          .rsta_busy(rsta_busy),  // output wire rsta_busy
          .rstb_busy(rstb_busy),  // output wire rstb_busy

          .s_aclk   (clk_i),  // input wire s_aclk
          .s_aresetn(rst_ni), // input wire s_aresetn

          .s_axi_awid   (AXI_Slave.aw_id),     // input wire [1 : 0] s_axi_awid
          .s_axi_awaddr (AXI_Slave.aw_addr),   // input wire [31 : 0] s_axi_awaddr
          .s_axi_awlen  (AXI_Slave.aw_len),    // input wire [7 : 0] s_axi_awlen
          .s_axi_awsize (AXI_Slave.aw_size),   // input wire [2 : 0] s_axi_awsize
          .s_axi_awburst(AXI_Slave.aw_burst),  // input wire [1 : 0] s_axi_awburst
          .s_axi_awvalid(AXI_Slave.aw_valid),  // input wire s_axi_awvalid
          .s_axi_awready(AXI_Slave.aw_ready),  // output wire s_axi_awready
          .s_axi_wdata  (AXI_Slave.w_data),    // input wire [31 : 0] s_axi_wdata
          .s_axi_wstrb  (AXI_Slave.w_strb),    // input wire [3 : 0] s_axi_wstrb
          .s_axi_wlast  (AXI_Slave.w_last),    // input wire s_axi_wlast
          .s_axi_wvalid (AXI_Slave.w_valid),   // input wire s_axi_wvalid
          .s_axi_wready (AXI_Slave.w_ready),   // output wire s_axi_wready
          .s_axi_bid    (AXI_Slave.b_id),      // output wire [1 : 0] s_axi_bid
          .s_axi_bresp  (AXI_Slave.b_resp),    // output wire [1 : 0] s_axi_bresp
          .s_axi_bvalid (AXI_Slave.b_valid),   // output wire s_axi_bvalid
          .s_axi_bready (AXI_Slave.b_ready),   // input wire s_axi_bready
          .s_axi_arid   (AXI_Slave.ar_id),     // input wire [1 : 0] s_axi_arid
          .s_axi_araddr (AXI_Slave.ar_addr),   // input wire [31 : 0] s_axi_araddr
          .s_axi_arlen  (AXI_Slave.ar_len),    // input wire [7 : 0] s_axi_arlen
          .s_axi_arsize (AXI_Slave.ar_size),   // input wire [2 : 0] s_axi_arsize
          .s_axi_arburst(AXI_Slave.ar_burst),  // input wire [1 : 0] s_axi_arburst
          .s_axi_arvalid(AXI_Slave.ar_valid),  // input wire s_axi_arvalid
          .s_axi_arready(AXI_Slave.ar_ready),  // output wire s_axi_arready
          .s_axi_rid    (AXI_Slave.r_id),      // output wire [1 : 0] s_axi_rid
          .s_axi_rdata  (AXI_Slave.r_data),    // output wire [31 : 0] s_axi_rdata
          .s_axi_rresp  (AXI_Slave.r_resp),    // output wire [1 : 0] s_axi_rresp
          .s_axi_rlast  (AXI_Slave.r_last),    // output wire s_axi_rlast
          .s_axi_rvalid (AXI_Slave.r_valid),   // output wire s_axi_rvalid
          .s_axi_rready (AXI_Slave.r_ready)    // input wire s_axi_rready
      );

      assign AXI_Slave.b_user = AXI_Slave.w_user;
      assign AXI_Slave.r_user = AXI_Slave.ar_user;
    end
  endgenerate
endmodule
