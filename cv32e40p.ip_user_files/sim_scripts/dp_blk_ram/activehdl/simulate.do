transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+dp_blk_ram  -L xpm -L blk_mem_gen_v8_4_7 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O2 xil_defaultlib.dp_blk_ram xil_defaultlib.glbl

do {dp_blk_ram.udo}

run

endsim

quit -force
