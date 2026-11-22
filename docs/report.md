# Integration and performance report

## Measured result

Local Icarus Verilog 13.0 simulation, November 15, 2026. Both implementations retire the same ten decoded instructions and match an independent sequential reference for all 32 registers.

| Mode | Retired | Cycles | Stalls | CPI |
|---|---:|---:|---:|---:|
| Forwarding + load-use interlock | 10 | 15 | 1 | 1.500 |
| Stall-only RAW interlocks | 10 | 26 | 12 | 2.600 |

Cycle reduction is 11/26 = 42.3%; speedup is 26/15 = 1.73x at an assumed equal clock period. CPI includes four pipeline fill/drain cycles. This dependency-heavy microbenchmark is not a claim about general workloads or post-synthesis timing.

## Verification

`make test` passes 4,194,304 control combinations: every source/MEM/WB register triple for both operands, source-use flags, write enables, load status and both hazard modes. These checks cover zero-register exclusion, forwarding priority, unavailable load data, source masking, mux output and stall-control outputs. The sweep checks complementary and equal source-ID pairs, plus all register triples for each operand. The reserved mux selector falls back to the original operand.

The integration test covers ADD followed by SUB, MEM/WB forwarding, consecutive writers to the same register, both operands selecting the newest producer, LW followed by a consumer, ignored writes to r0 and pipeline drain. A clock-edge assertion checks that a load-use stall holds PC/decode and inserts an invalid EX bubble. A timeout catches deadlock.

## Waveform cases

Open `docs/evidence/pipeline.vcd` in GTKWave or regenerate using `make wave`. Inspect `tb_pipeline.fast` signals `ev`, `mv`, `wv`, `es1`, `es2`, `ed`, `md`, `wd`, `fa`, `fb`, `stall`, `pc`, `a`, `b`, `result`.

- Instruction 1 (SUB r6,r5,r3): EX/MEM supplies r5=3 through `fa=10`.
- Instruction 2 (ADD r7,r4,r5): MEM/WB supplies r5=3 through `fb=01`.
- Instruction 5 (ADD r8,r5,r5): both selectors are `10`; newest r5=10 wins over older r5=8.
- Instruction 7 (ADD r10,r9,r8): one stall while the LW is in EX; PC/decode hold and EX becomes invalid. The consumer later receives loaded r9=103 via MEM/WB.
- Final values include r0=0, r5=10, r8=20, r9=103, r10=r11=123.

The CSV and VCD in `docs/evidence` are captured outputs, not manually entered measurements. Re-running writes fresh outputs under `build/`.

## Scope

The implementation is a simulation-verified educational integration. Seeded instruction streams and reset/restart checks are described in the [verification guide](verification.md). A complete ISA decoder, formal verification, synthesis results, and FPGA timing measurements are outside the current scope.

## Execution without hazard handling

The final edge suite compares the same four instructions in all three modes. In case 8, ADD r5,r1,r2 followed by SUB r6,r5,r3 gives r6=0 in both protected modes. MODE=2 reads stale r5=5 and produces r6=2. It takes 8 cycles but is incorrect; forwarding also takes 8 cycles and is correct, while stall-only requires 10 cycles. This demonstrates both the need for handling and the performance benefit of forwarding.

Nine edge cases verify independent instructions, unused load rs2 fields, load-to-r0, both consumer operands, load-base dependencies, mixed forwarding paths and newest-producer priority. The automated VCD audit confirms the five waveform events listed above. See `evidence/edge-results.csv`, `evidence/waveform-cases.csv` and `evidence/verification.log`.
