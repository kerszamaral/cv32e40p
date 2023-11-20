transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+dp_blk_ram  -L xpm -L blk_mem_gen_v8_4_6 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.dp_blk_ram xil_defaultlib.glbl

do {dp_blk_ram.udo}

run 1000ns

endsim

quit -force
