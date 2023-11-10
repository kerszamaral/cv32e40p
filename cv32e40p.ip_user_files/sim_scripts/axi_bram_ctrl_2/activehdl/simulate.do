transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+axi_bram_ctrl_2  -L xpm -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.axi_bram_ctrl_2 xil_defaultlib.glbl

do {axi_bram_ctrl_2.udo}

run 1000ns

endsim

quit -force
