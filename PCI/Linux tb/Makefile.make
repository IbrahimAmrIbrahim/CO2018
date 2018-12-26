all:
	iverilog -o build PCI_tb_linux
	./build
	gtkwave Simulation.vcd 
