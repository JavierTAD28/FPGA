TOP = blink
DEVICE = GW1NR-LV9QN88PC6/I5
FAMILY = GW1N-9C

SRC = src/$(TOP).v
CST = constraints/tangnano9k.cst

all: build/$(TOP).fs

build/$(TOP).json: $(SRC)
	mkdir -p build
	yosys -p "read_verilog $(SRC); synth_gowin -top $(TOP) -json $@"

build/$(TOP)_pnr.json: build/$(TOP).json $(CST)
	nextpnr-himbaechel --json $< --write $@ --device $(DEVICE) --vopt family=$(FAMILY) --vopt cst=$(CST)

build/$(TOP).fs: build/$(TOP)_pnr.json
	gowin_pack -d $(FAMILY) -o $@ $<

clean:
	rm -rf build/*
