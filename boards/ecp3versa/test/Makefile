SOURCES=$(wildcard *.v) \
	$(wildcard ../../../cores/gmii2fifo9/rtl/*.v) \
	$(wildcard ../../../cores/fifo9togmii/rtl/*.v) \
	$(wildcard ../rtl/ecp3/ipnuma.v) \
	$(wildcard ../rtl/ecp3/server.v) \
	$(wildcard ../rtl/ecp3/requester.v) \
	$(wildcard ../rtl/ecp3/pcie_tlp.v)

#all: cversim
all: tlp_data.hex phy_data.hex isim

gtk: all
	gtkwave test.vcd

isim: tb_system
	./tb_system

cversim: $(SOURCES)
	cver $(SOURCES)

clean:
	rm -f tb_system verilog.log test.vcd

tb_system: $(SOURCES)
	iverilog -o tb_system $(SOURCES)

.PHONY: clean isim cversim gtk
