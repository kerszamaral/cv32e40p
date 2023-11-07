module new_tb_impl_top #(
);
    // comment to record execution trace
  //`define TRACE_EXECUTION

  const time          CLK_PHASE_HI = 5ns;
  const time          CLK_PHASE_LO = 5ns;
  const time          CLK_PERIOD = CLK_PHASE_HI + CLK_PHASE_LO;

  const time          STIM_APPLICATION_DEL = CLK_PERIOD * 0.1;
  const time          RESP_ACQUISITION_DEL = CLK_PERIOD * 0.9;
  const time          RESET_DEL = STIM_APPLICATION_DEL;
  const int           RESET_WAIT_CYCLES = 4;

  // clock and reset for tb
  logic               clk = 'b1;
  logic               rst_n = 'b0;

  // cycle counter
  int unsigned        cycle_cnt_q;

  // testbench result
  logic               tests_passed;
  logic               tests_failed;
  logic               exit_valid;
  logic        [31:0] exit_value;

  // signals for ri5cy
  logic               fetch_enable;

  // stdout pseudo peripheral
  logic [7:0]        print_wdata;
  logic              print_valid;


  // make the core start fetching instruction immediately
  assign fetch_enable = '1;

  // allow vcd dump
  initial begin
    if ($test$plusargs("vcd")) begin
      $dumpfile("riscy_tb.vcd");
      $dumpvars(0, new_tb_impl_top);
    end
  end

  // we either load the provided firmware or execute a small test program that
  // doesn't do more than an infinite loop with some I/O
  initial begin : load_prog
    automatic string firmware;
    automatic int prog_size = 6;

    if ($value$plusargs("firmware=%s", firmware)) begin
      if ($test$plusargs("verbose"))
        $display("[TESTBENCH] %t: loading firmware %0s ...", $time, firmware);
      // $readmemh(firmware, wrapper_i.ram_i.dp_ram_i.mem);

    end else begin
      $display("No firmware specified");
      $finish;
    end
  end

  // clock generation
  initial begin : clock_gen
    forever begin
      #CLK_PHASE_HI clk = 1'b0;
      #CLK_PHASE_LO clk = 1'b1;
    end
  end : clock_gen

  // reset generation
  initial begin : reset_gen
    rst_n = 1'b0;

    // wait a few cycles
    repeat (RESET_WAIT_CYCLES) begin
      @(posedge clk);
    end

    // start running
    #RESET_DEL rst_n = 1'b1;
    if ($test$plusargs("verbose")) $display("reset deasserted", $time);

  end : reset_gen

  // set timing format
  initial begin : timing_format
    $timeformat(-9, 0, "ns", 9);
  end : timing_format

  // abort after n cycles, if we want to
  always_ff @(posedge clk, negedge rst_n) begin
    automatic int maxcycles;
    if ($value$plusargs("maxcycles=%d", maxcycles)) begin
      if (~rst_n) begin
        cycle_cnt_q <= 0;
      end else begin
        cycle_cnt_q <= cycle_cnt_q + 1;
        if (cycle_cnt_q >= maxcycles) begin
          $fatal(2, "Simulation aborted due to maximum cycle limit");
        end
      end
    end
  end

  // check if we succeded
  always_ff @(posedge clk, negedge rst_n) begin
    if (tests_passed) begin
      $display("ALL TESTS PASSED");
      $finish;
    end
    if (tests_failed) begin
      $display("TEST(S) FAILED!");
      $finish;
    end
    if (exit_valid) begin
      if (exit_value == 0) $display("EXIT SUCCESS");
      else $display("EXIT FAILURE: %d", exit_value);
      $finish;
    end
  end

  // print to stdout pseudo peripheral
  always_ff @(posedge clk, negedge rst_n) begin : print_peripheral
    if (print_valid) begin
      $write("%c", print_wdata);
    end
  end

    wire rx;

  // wrapper for riscv, the memory system and stdout peripheral
  cv32e40p_impl_top #(
  ) wrapper_i (
      .clk_i         (clk),
      .rst_ni        (rst_n),
      .fetch_enable_i(fetch_enable),
      .tests_passed_o(tests_passed),
      .tests_failed_o(tests_failed),
      .exit_valid_o  (exit_valid),
      .exit_value_o  (exit_value),

      .Tx(rx),
      .Rx(tx)
  );

  Uart8 #(
    .CLOCK_RATE(100000000),
    .BAUD_RATE(9600)
    ) uart (
    .clk(clk),
    .rx(rx),
    .rxEn('1),
    .out(print_wdata),
    .rxDone(print_valid),
    .txEn('0)
    );
endmodule