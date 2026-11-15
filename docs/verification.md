# Verification guide

## Reproduce

Run `make verify` for the complete suite, multi-seed regression, VCD generation and automated waveform audit.

- `make test`: combinational unit sweep, directed integration, deterministic random streams, reset/restart test and nine edge cases.
- `make regression`: repeat random verification with seeds 1, 42 and 20261114.
- `make random ARGS='+seed=1234'`: run another nonzero 32-bit decimal seed.
- `make regression SEEDS='7 99'`: select a seed list. A failing simulation stops the target.
- `make wave`: regenerate the original ten-instruction demo waveform.

Icarus Verilog and its `vvp` runtime must be on PATH. Override `IVERILOG` and `VVP` if needed. `make clean` removes generated files only.

## Added coverage

The random harness generates 100 programs of 64 instructions per seed, with ADD, SUB and LW; all register IDs; ignored r0 destinations; arbitrary 32-bit immediates; and deliberately frequent adjacent dependencies and repeated writers. Memory contains distinct high-bit values to exercise wraparound arithmetic and data forwarding. A deterministic xorshift generator makes streams reproducible within this harness.

An independent sequential model computes every expected write. Each pipeline's WB destination and value are checked on every valid retirement, then all 32 registers are compared at program completion. Checks also require exact instruction counts, no timeout, cycles = instructions + four fill/drain cycles + stalls, forwarding cycles no greater than stall-only cycles, and stable counters after completion. Each program resets the pipeline before execution.

A separate test interrupts an active load-use hazard with synchronous reset. It checks that PC, valid bits and counters clear, that the fixture register state returns, and that restarting the same program produces correct values and timing without stale writes.

## Captured results

Four seeds passed: 400 programs, 25,600 instructions in each mode, or 51,200 total instruction retirements checked.

| Seed | Forwarding cycles | Stall-only cycles |
|---|---:|---:|
| 1511506142 (default) | 7,706 | 12,258 |
| 1 | 7,677 | 12,371 |
| 42 | 7,706 | 12,299 |
| 20261114 | 7,711 | 12,303 |

These totals include fill/drain overhead for every program. The original directed benchmark remains 15 versus 26 cycles. Raw console evidence is in [verification.log](evidence/verification.log).

Random testing complements the 4,194,304 unit combinations and directed tests; it does not establish formal correctness or synthesis timing. Nine targeted edge cases and five machine-checked waveform events are included in the suite. See the [performance analysis](report.md) and [video outline](phase1/video.md).

The unit sweep now tests both complementary and equal operand register IDs, plus the reserved mux selector fallback. The final clean-build log is `evidence/verification.log`.
