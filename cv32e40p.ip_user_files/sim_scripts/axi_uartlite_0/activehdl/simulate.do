transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+axi_uartlite_0  -L xpm -L unisims_ver -L unimacro_ver -L secureip -O2 xil_defaultlib.axi_uartlite_0 xil_defaultlib.glbl

do {axi_uartlite_0.udo}

run

endsim

quit -force
