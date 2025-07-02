# Updated Makefile for Spartan 6 and Xilinx ISE

CROSS=riscv32-unknown-elf-
CFLAGS=

spartan6demo.bit: spartan6demo.v spartan6_spram.v picosoc.v ../picorv32.v
	@echo "Running Xilinx ISE Flow for Spartan 6"
	@xst -ifn spartan6demo.xst
	@ngdbuild -uc spartan6demo.ucf spartan6demo.ngc
	@map spartan6demo.ngd
	@par -w spartan6demo.ncd spartan6demo_routed.ncd
	@bitgen -w spartan6demo_routed.ncd spartan6demo.bit

clean:
	rm -f *.bit *.ncd *.ngc *.ngd *.xst *.srp *.map *.par *.bgn

.PHONY: clean