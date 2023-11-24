vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xpm
vlib questa_lib/msim/xil_defaultlib

vmap xpm questa_lib/msim/xpm
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xpm -64 -incr -mfcu  -sv \
"/opt/xilinx/Vivado/2023.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/opt/xilinx/Vivado/2023.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93  \
"/opt/xilinx/Vivado/2023.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib -64 -incr -mfcu  \
"../../../../cv32e40p.gen/sources_1/ip/axi_to_bram/axi_to_bram_sim_netlist.v" \

vlog -work xil_defaultlib \
"glbl.v"

