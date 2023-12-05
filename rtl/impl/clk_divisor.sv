module clk_divisor #(
    parameter INPUT_CLK_FREQ  = 100_000_000,
    parameter OUTPUT_CLK_FREQ = 25_000_000
) (
    input  logic clk_i,
    output logic clk_o
);
  localparam DIVISOR = INPUT_CLK_FREQ / OUTPUT_CLK_FREQ;
  logic [$clog2(DIVISOR):0] counter = 0;
  always_ff @(posedge clk_i) begin
    counter <= counter + 1;
    if (counter >= DIVISOR - 1) counter <= 0;
    clk_o <= (counter < DIVISOR / 2) ? 1'b1 : 1'b0;
  end
endmodule
