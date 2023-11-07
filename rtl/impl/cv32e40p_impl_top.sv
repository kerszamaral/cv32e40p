

module cv32e40p_impl_top #(
    parameter CLOCK_RATE = 25000000,
    parameter BAUD_RATE = 9600,
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

    input logic fetch_enable_i,
    output logic tests_passed_o,
    output logic tests_failed_o,
    output logic exit_valid_o,

    input logic Rx,
    output logic Tx
);

    localparam DEFAULT_CLOCK_RATE = 100000000;
    localparam DIVISOR = DEFAULT_CLOCK_RATE / CLOCK_RATE;

    logic clk = 1'b0;
    reg[27:0] counter=28'd0;
    // The frequency of the output clk_out
    //  = The frequency of the input clk_in divided by DIVISOR
    // For example: Fclk_in = 50Mhz, if you want to get 1Hz signal to blink LEDs
    // You will modify the DIVISOR parameter value to 28'd50.000.000
    // Then the frequency of the output clk_out = 50Mhz/50.000.000 = 1Hz
    always @(posedge clk_i)
    begin
        counter <= counter + 28'd1;
        if(counter >= (DIVISOR-1))
            counter <= 28'd0;
        clk <= (counter<DIVISOR/2)?1'b1:1'b0;
    end

    cv32e40p_subsystem #(
      .INSTR_RDATA_WIDTH(INSTR_RDATA_WIDTH),
      .RAM_ADDR_WIDTH   (RAM_ADDR_WIDTH),
      .BOOT_ADDR        (BOOT_ADDR),
      .PULP_XPULP       (PULP_XPULP),
      .PULP_CLUSTER     (PULP_CLUSTER),
      .FPU              (FPU),
      .ZFINX            (ZFINX),
      .NUM_MHPMCOUNTERS (NUM_MHPMCOUNTERS),
      .DM_HALTADDRESS   (DM_HALTADDRESS)
    ) subsystem (
      .clk_i         (clk),
      .rst_ni        (rst_ni),
      .fetch_enable_i(fetch_enable_i),
      .tests_passed_o(tests_passed_o),
      .tests_failed_o(tests_failed_o),
      .exit_valid_o  (exit_valid_o),
      .exit_value_o  (exit_value),
      .print_wdata_o (print_wdata),
      .print_valid_o (print_valid)
  ) ;

    wire [31:0] print_wdata;
    wire print_valid;
    wire [31:0] exit_value;

    Uart8 #(
    .CLOCK_RATE(CLOCK_RATE),
    .BAUD_RATE(BAUD_RATE)
    ) uart (
    .clk(clk),

    .rx(rx),
    .rxEn('1),
    .out(),
    .rxDone(),
    .rxBusy(),
    .rxErr(),

    .tx(tx),
    .txEn('1),
    .txStart(print_valid),
    .in(print_wdata[7:0]),
    .txDone(),
    .txBusy()
    );
    
endmodule