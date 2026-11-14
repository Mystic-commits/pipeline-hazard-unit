IVERILOG ?= iverilog
VVP ?= vvp
SEEDS ?= 1 42 20261114
RTL := $(wildcard rtl/*.v)
.PHONY: test unit integration wave random reset regression clean
test: unit integration random reset
build:
	mkdir -p build
build/units: $(RTL) tb/tb_units.sv | build
	$(IVERILOG) -g2012 -Wall -s tb_units -o $@ $^
build/pipeline: $(RTL) tb/tb_pipeline.sv | build
	$(IVERILOG) -g2012 -Wall -s tb_pipeline -o $@ $^
build/random: $(RTL) tb/tb_random.sv | build
	$(IVERILOG) -g2012 -Wall -s tb_random -o $@ $^
random: build/random
	$(VVP) $< $(ARGS)
build/reset: $(RTL) tb/tb_reset.sv | build
	$(IVERILOG) -g2012 -Wall -s tb_reset -o $@ $^
regression: build/random
	@set -e; for seed in $(SEEDS); do $(VVP) $< +seed=$$seed; done
reset: build/reset
	$(VVP) $<
unit: build/units
	$(VVP) $<
integration: build/pipeline
	$(VVP) $<
wave: build/pipeline
	$(VVP) $< +wave
clean:
	rm -rf build
