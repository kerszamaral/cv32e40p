vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xpm
vlib questa_lib/msim/xil_defaultlib

vmap xpm questa_lib/msim/xpm
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xpm  -incr -mfcu  -sv  +define+VERILATOR=VERILATOR "+incdir+../../../../cv32e40p.gen/sources_1/ip/axi_crossbar_0/hdl" \
"C:/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm  -93  \
"C:/Xilinx/Vivado/2023.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -incr -mfcu   +define+VERILATOR=VERILATOR "+incdir+../../../../cv32e40p.gen/sources_1/ip/axi_crossbar_0/hdl" \
"../../../../cv32e40p.gen/sources_1/ip/axi_crossbar_0/axi_crossbar_0_sim_netlist.v" \

vlog -work xil_defaultlib \
"glbl.v"

