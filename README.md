# Pipeline Hazard Detection and Forwarding Unit

Team Snorlax — Ishita Thakur, Aditya Verma, Yug Johri, Anshvardhan, Swagato Bauri.

A five-stage IF/ID/EX/MEM/WB teaching pipeline with RAW forwarding, load-use interlocks, a stall-only comparison mode, and an intentionally unprotected mode for demonstrating RAW errors.

## Run

Install Icarus Verilog and Python 3, then run `make verify` for the complete audit. `make test` runs the core suite. Run `make wave` to produce `build/pipeline.vcd` for GTKWave. See [architecture](docs/architecture.md), [two-day plan](docs/plan.md), and [integration report](docs/report.md).

The integration harness uses decoded instruction fields rather than a binary ISA decoder. It supports ADD, SUB and LW with word-indexed data memory; branches, stores, caches and exceptions are outside this project.

## Extended verification

Run `make regression` for additional seeded programs. See the [verification guide](docs/verification.md) for reproducible seeds, per-retirement checks and reset coverage.

## Final delivery — November 15, 2026

All local checks pass: 4,194,304 unit combinations, nine edge scenarios, reset/restart, 400 seeded programs (51,200 checked retirements across both protected modes), and five captured waveform cases. The directed workload takes 15 cycles with forwarding versus 26 with stall-only interlocks.

Start with the [demo guide](docs/demo.md), [requirements and audit record](docs/acceptance.md), and [integration report](docs/report.md). The optional GitHub Actions configuration is a template at `docs/ci-workflow.yml`; hosted CI is not enabled because the current credential lacks workflow permission.
