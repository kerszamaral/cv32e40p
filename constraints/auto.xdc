#File created from Constraints Wizard

create_clock -period 10.000 -name clk_i -waveform {0.000 5.000} [get_ports clk_i]
create_generated_clock -name u_clk_div/clk_o -source [get_ports clk_i] -divide_by 4 [get_pins u_clk_div/clk_o_reg/Q]
create_clock -period 40.000 -name VIRTUAL_u_clk_div/clk_o -waveform {0.000 20.000}
set_input_delay -clock [get_clocks VIRTUAL_u_clk_div/clk_o] -min -add_delay 0.000 [get_ports fetch_enable_i]
set_input_delay -clock [get_clocks VIRTUAL_u_clk_div/clk_o] -max -add_delay 0.000 [get_ports fetch_enable_i]
set_input_delay -clock [get_clocks VIRTUAL_u_clk_div/clk_o] -min -add_delay 0.000 [get_ports rst_ni]
set_input_delay -clock [get_clocks VIRTUAL_u_clk_div/clk_o] -max -add_delay 0.000 [get_ports rst_ni]
set_input_delay -clock [get_clocks VIRTUAL_u_clk_div/clk_o] -min -add_delay 0.000 [get_ports rx_i]
set_input_delay -clock [get_clocks VIRTUAL_u_clk_div/clk_o] -max -add_delay 0.000 [get_ports rx_i]
set_output_delay -clock [get_clocks VIRTUAL_u_clk_div/clk_o] -min -add_delay 0.000 [get_ports exit_valid_o]
set_output_delay -clock [get_clocks VIRTUAL_u_clk_div/clk_o] -max -add_delay 0.000 [get_ports exit_valid_o]
set_output_delay -clock [get_clocks VIRTUAL_u_clk_div/clk_o] -min -add_delay 0.000 [get_ports exit_zero_o]
set_output_delay -clock [get_clocks VIRTUAL_u_clk_div/clk_o] -max -add_delay 0.000 [get_ports exit_zero_o]
set_output_delay -clock [get_clocks VIRTUAL_u_clk_div/clk_o] -min -add_delay 0.000 [get_ports tx_o]
set_output_delay -clock [get_clocks VIRTUAL_u_clk_div/clk_o] -max -add_delay 0.000 [get_ports tx_o]

set_property PACKAGE_PIN E3 [get_ports clk_i]
set_property PACKAGE_PIN U9 [get_ports rst_ni]
set_property PACKAGE_PIN U8 [get_ports fetch_enable_i]
set_property PACKAGE_PIN T8 [get_ports exit_valid_o]
set_property PACKAGE_PIN V9 [get_ports exit_zero_o]
set_property PACKAGE_PIN C4 [get_ports rx_i]
set_property PACKAGE_PIN D4 [get_ports tx_o]
set_property IOSTANDARD LVCMOS33 [get_ports tx_o]
set_property IOSTANDARD LVCMOS33 [get_ports rx_i]
set_property IOSTANDARD LVCMOS33 [get_ports rst_ni]
set_property IOSTANDARD LVCMOS33 [get_ports fetch_enable_i]
set_property IOSTANDARD LVCMOS33 [get_ports exit_zero_o]
set_property IOSTANDARD LVCMOS33 [get_ports exit_valid_o]
set_property IOSTANDARD LVCMOS33 [get_ports clk_i]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_i_IBUF]
