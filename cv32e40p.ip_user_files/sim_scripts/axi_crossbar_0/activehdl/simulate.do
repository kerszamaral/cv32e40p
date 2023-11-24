transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+axi_crossbar_0  -L xpm -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O2 xil_defaultlib.axi_crossbar_0 xil_defaultlib.glbl

do {axi_crossbar_0.udo}

run

endsim

quit -force
