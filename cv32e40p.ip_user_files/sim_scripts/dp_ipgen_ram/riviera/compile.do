transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vmap -link {C:/Users/kersz/Documents/ufrgs/IC/cv32e40p/cv32e40p.cache/compile_simlib/riviera}
vlib riviera/blk_mem_gen_v8_4_6
vlib riviera/xil_defaultlib

vlog -work blk_mem_gen_v8_4_6  -incr -v2k5 -l blk_mem_gen_v8_4_6 -l xil_defaultlib \
"../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -incr -v2k5 -l blk_mem_gen_v8_4_6 -l xil_defaultlib \
"../../../../cv32e40p.gen/sources_1/ip/dp_ipgen_ram/sim/dp_ipgen_ram.v" \


vlog -work xil_defaultlib \
"glbl.v"

