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
    parameter AXI_USER_WIDTH = 10,
    parameter REGISTERED_GRANT = "FALSE", // "TRUE" or "FALSE"
    parameter OLD = 1
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

  generate
    ;
    if (OLD == 0) begin : g_new_conv
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
          .slv_aw_cache_i(4'b0),
          .slv_ar_cache_i(4'b0),
          .axi_req_o(mst_req),
          .axi_rsp_i(mst_resp)
      );
    end else begin : g_old_conv
      (* keep = "true" *) enum logic [2:0] {
        IDLE,
        READ_WAIT,
        WRITE_DATA,
        WRITE_ADDR,
        WRITE_WAIT
      }
          CS, NS;

      logic [31:0] rdata;
      logic        valid;
      logic        granted;

      // main FSM
      always_comb begin
        NS                  = CS;
        granted             = 1'b0;
        valid               = 1'b0;

        AXI_Master.aw_valid = 1'b0;
        AXI_Master.ar_valid = 1'b0;
        AXI_Master.r_ready  = 1'b0;
        AXI_Master.w_valid  = 1'b0;
        AXI_Master.b_ready  = 1'b0;

        case (CS)
          // wait for a request to come in from the core
          IDLE: begin
            // the same logic is also inserted in READ_WAIT and WRITE_WAIT, if you
            // change it here, take care to change it there too!
            if (data_req_i) begin
              // send address over aw channel for writes,
              // over ar channels for reads
              if (data_we_i) begin
                AXI_Master.aw_valid = 1'b1;
                AXI_Master.w_valid  = 1'b1;

                if (AXI_Master.aw_ready) begin
                  if (AXI_Master.w_ready) begin
                    granted = 1'b1;
                    NS = WRITE_WAIT;
                  end else begin
                    NS = WRITE_DATA;
                  end
                end else begin
                  if (AXI_Master.w_ready) begin
                    NS = WRITE_ADDR;
                  end else begin
                    NS = IDLE;
                  end
                end
              end else begin
                AXI_Master.ar_valid = 1'b1;

                if (AXI_Master.ar_ready) begin
                  granted = 1'b1;
                  NS = READ_WAIT;
                end else begin
                  NS = IDLE;
                end
              end
            end else begin
              NS = IDLE;
            end
          end

          // if the bus has not accepted our write data right away, but has
          // accepted the address already
          WRITE_DATA: begin
            AXI_Master.w_valid = 1'b1;
            if (AXI_Master.w_ready) begin
              granted = 1'b1;
              NS = WRITE_WAIT;
            end
          end

          // the bus has accepted the write data, but not yet the address
          // this happens very seldom, but we still have to deal with the
          // situation
          WRITE_ADDR: begin
            AXI_Master.aw_valid = 1'b1;

            if (AXI_Master.aw_ready) begin
              granted = 1'b1;
              NS = WRITE_WAIT;
            end
          end

          // we have sent the address and data and just wait for the write data to
          // be done
          WRITE_WAIT: begin
            AXI_Master.b_ready = 1'b1;

            if (AXI_Master.b_valid) begin
              valid = 1'b1;

              NS = IDLE;
            end
          end

          // we wait for the read response, address has been sent successfully
          READ_WAIT: begin
            if (AXI_Master.r_valid) begin
              valid              = 1'b1;
              AXI_Master.r_ready = 1'b1;

              NS                 = IDLE;
            end
          end

          default: begin
            NS = IDLE;
          end
        endcase
      end

      // registers
      always_ff @(posedge clk_i, negedge rst_ni) begin
        if (~rst_ni) begin
          CS <= IDLE;
        end else begin
          CS <= NS;
        end
      end

      // take care of read data adaption
      if (AXI_DATA_WIDTH == 32) begin
        assign rdata = AXI_Master.r_data[31:0];
      end else if (AXI_DATA_WIDTH == 64) begin
        logic [0:0] addr_q;

        always_ff @(posedge clk_i, negedge rst_ni) begin
          if (~rst_ni) addr_q <= '0;
          else if (data_gnt_o)  // only update when we give the grant
            addr_q <= data_addr_i[2:2];
        end

        assign rdata = addr_q[0] ? AXI_Master.r_data[63:32] : AXI_Master.r_data[31:0];
`ifndef SYNTHESIS
        initial $error("AXI_DATA_WIDTH has an invalid value");
`endif
      end

      // take care of write data adaption
      genvar w;
      for (w = 0; w < AXI_DATA_WIDTH / 32; w++) begin
        assign AXI_Master.w_data[w*32+31:w*32+0] = data_wdata_i;  // just replicate the wdata to fill the bus
      end

      // take care of write strobe
      if (AXI_DATA_WIDTH == 32) begin
        assign AXI_Master.w_strb = data_be_i;
      end else if (AXI_DATA_WIDTH == 64) begin
        assign AXI_Master.w_strb = data_addr_i[2] ? {data_be_i, 4'b0000} : {4'b0000, data_be_i};
      end else begin
`ifndef SYNTHESIS
        initial $error("AXI_DATA_WIDTH has an invalid value");
`endif
      end

      // AXI interface assignments
      assign AXI_Master.aw_id     = '0;
      assign AXI_Master.aw_addr   = data_addr_i;
      assign AXI_Master.aw_size   = 3'b010;
      assign AXI_Master.aw_len    = '0;
      assign AXI_Master.aw_burst  = '0;
      assign AXI_Master.aw_lock   = '0;
      assign AXI_Master.aw_cache  = '0;
      assign AXI_Master.aw_prot   = '0;
      assign AXI_Master.aw_region = '0;
      assign AXI_Master.aw_atop   = '0;
      assign AXI_Master.aw_user   = '0;
      assign AXI_Master.aw_qos    = '0;

      assign AXI_Master.ar_id     = '0;
      assign AXI_Master.ar_addr   = data_addr_i;
      assign AXI_Master.ar_size   = 3'b010;
      assign AXI_Master.ar_len    = '0;
      assign AXI_Master.ar_burst  = '0;
      assign AXI_Master.ar_prot   = '0;
      assign AXI_Master.ar_region = '0;
      assign AXI_Master.ar_lock   = '0;
      assign AXI_Master.ar_cache  = '0;
      assign AXI_Master.ar_qos    = '0;
      assign AXI_Master.ar_user   = '0;

      assign AXI_Master.w_last    = 1'b1;
      assign AXI_Master.w_user    = '0;

      if (REGISTERED_GRANT == "TRUE") begin
        logic        valid_q;
        logic [31:0] rdata_q;

        always_ff @(posedge clk_i, negedge rst_ni) begin
          if (~rst_ni) begin
            valid_q <= 1'b0;
            rdata_q <= '0;
          end else begin
            valid_q <= valid;

            if (valid) rdata_q <= rdata;
          end
        end

        assign data_rdata_o  = rdata_q;
        assign data_rvalid_o = valid_q;
        assign data_gnt_o    = valid;
      end else begin
        assign data_rdata_o  = rdata;
        assign data_rvalid_o = valid;
        assign data_gnt_o    = granted;
      end
    end
  endgenerate
endmodule
