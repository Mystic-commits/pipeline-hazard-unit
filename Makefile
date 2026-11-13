IVERILOG ?= iverilog
VVP ?= vvp
RTL := $(wildcard rtl/*.v)
.PHONY: test unit integration wave clean
test: unit integration
build:
	mkdir -p build
build/units: $(RTL) tb/tb_units.sv | build
	$(IVERILOG) -g2012 -Wall -s tb_units -o $@ $^
build/pipeline: $(RTL) tb/tb_pipeline.sv | build
	$(IVERILOG) -g2012 -Wall -s tb_pipeline -o $@ $^
unit: build/units
	$(VVP) $<
integration: build/pipeline
	$(VVP) $<
wave: build/pipeline
	$(VVP) $< +wave
clean:
	rm -rf build
