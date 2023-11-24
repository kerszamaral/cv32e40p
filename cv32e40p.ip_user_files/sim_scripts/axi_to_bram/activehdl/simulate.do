transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+axi_to_bram  -L xpm -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O2 xil_defaultlib.axi_to_bram xil_defaultlib.glbl

do {axi_to_bram.udo}

run

endsim

quit -force
