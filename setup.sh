mkdir -p .devcontainer src constraints build

cat << 'EOF' > .devcontainer/devcontainer.json
{
  "name": "Gowin FPGA OpenSource",
  "image": "://microsoft.com",
  "postCreateCommand": "URL=$(curl -s https://github.com | grep browser_download_url | grep linux-x64 | cut -d '\"' -f 4) && wget -qO- $URL | tar -xz -C /opt/",
  "remoteEnv": {
    "PATH": "/opt/oss-cad-suite/bin:${containerEnv:PATH}"
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "mshr-h.veriloghdl"
      ]
    }
  }
}
EOF

cat << 'EOF' > Makefile
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
EOF

cat << 'EOF' > src/blink.v
module blink (
    input clk,
    output reg led
);
    reg [23:0] counter = 0;
    always @(posedge clk) begin
        counter <= counter + 1;
        if (counter == 24'd13_500_000) begin
            counter <= 0;
            led <= ~led;
        end
    end
endmodule
EOF

cat << 'EOF' > constraints/tangnano9k.cst
IO_LOC "clk" 52;
IO_PORT "clk" PULL_MODE=UP;
IO_LOC "led" 10;
IO_PORT "led" DRIVE=8;
EOF

git add .
git commit -m "Estructura inicial FPGA Tang Nano 9K"
git push
