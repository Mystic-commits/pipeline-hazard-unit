# Demonstration and handoff

## Reproduce from a fresh checkout

```sh
git clone https://github.com/Mystic-commits/pipeline-hazard-unit.git
cd pipeline-hazard-unit
make verify
```

The repository is private, so the GitHub account must have access. Prerequisites: Icarus Verilog (`iverilog` and `vvp`), Python 3 and Make. No Python packages are required. On macOS, install the simulator with `brew install icarus-verilog`; on Debian/Ubuntu use `sudo apt-get install iverilog make python3`.

`make verify` runs all tests, all four recorded random seeds, generates the VCD and checks five waveform cases. Any failed assertion exits with a nonzero status. Fresh results are under `build/`; submitted evidence is under `docs/evidence/`.

## Five-minute demonstration

1. Explain IF → ID → EX → MEM → WB and the RAW dependency in ADD r5,r1,r2 followed by SUB r6,r5,r3. ID initially reads the old r5; the producer's ALU result is ready before WB.
2. Show `rtl/forwarding_unit.v`: nonzero write destination, used source, EX/MEM priority, then MEM/WB. Selectors 00/01/10 mean captured value/WB/MEM.
3. Show `rtl/hazard_detection.v` and `rtl/stall_control.v`: a dependent consumer cannot use a load address as data. Hold PC and IF/ID, insert one invalid EX cycle, and keep older stages moving.
4. Run `make verify`. Highlight the correctness checks before discussing CPI.
5. Open `build/pipeline.vcd` in GTKWave, expand `tb_pipeline.fast`, and add `clk`, `ev`, `ed`, `fa`, `fb`, `stall`, `pc`, `a`, `b`. Alternatively inspect the generated `build/waveform-cases.csv`.
6. Explain the 15 versus 26 cycle result, including four fill/drain cycles. Show edge case 8 in `build/edge-results.csv`: MODE=2 is deliberately unprotected and produces r6=2 instead of 0. Its short runtime is not a valid performance improvement.

## Waveform landmarks

| Time | Event | Observation |
|---|---|---|
| 50 ns | ADD → SUB | fa=10, operand A=3 |
| 60 ns | WB forwarding | fb=01, operand B=3 |
| 90 ns | Two writers to r5 | fa=fb=10, both operands=10 |
| 100 ns | Load-use detection | stall=1, PC=8 |
| 110 ns | Bubble | ev=0, PC still 8 |
| 120 ns | Dependent ADD resumes | fa=01, loaded operand A=103 |

Times are stable falling-edge samples from the supplied testbench, not propagation-delay measurements.

## Likely questions

**Why does MEM win?** It contains the newest preceding producer, so an older WB match must not overwrite it.

**Why exclude r0?** Its architectural value is always zero, so writing it cannot create a true dependency.

**Why is one load-use stall enough?** The demo memory returns data in MEM; after the bubble, the consumer can use that value from MEM/WB. Variable-latency memory would require another interlock.

**What is flushed?** ID/EX's valid bit; invalid instructions cannot write or retire. This is a data-hazard bubble, not a branch-misprediction flush.

**What does the baseline do?** MODE=0 stalls for EX and MEM RAW dependencies, with WB-to-ID bypass. MODE=1 forwards and stalls only for load-use. MODE=2 deliberately disables both and is used only to demonstrate incorrect execution.

**Is this a complete CPU?** No. It is a synthesizable hazard-control block integrated into a decoded-instruction simulation harness. It has no binary decoder, stores, branches or variable-latency memory. No FPGA frequency, area or formal-correctness result is claimed.

## Completion boundary

RTL, automated verification, waveform cases, CPI comparison and the integration report are delivered. Human presentation rehearsal and instructor submission must be performed by the team. The optional Actions workflow remains a template until an account with workflow-write permission enables it; local verification is complete.
