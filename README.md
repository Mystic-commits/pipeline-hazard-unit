# Pipeline Hazard Detection and Forwarding Unit

Team Snorlax — Ishita Thakur, Aditya Verma, Yug Johri, Anshvardhan, Swagato Bauri.

A five-stage IF/ID/EX/MEM/WB teaching pipeline with RAW forwarding, load-use interlocks, and a stall-only comparison mode.

## Run

Install Icarus Verilog and Python 3, then run `make test`. Run `make wave` to produce `build/pipeline.vcd` for GTKWave. See [architecture](docs/architecture.md), [two-day plan](docs/plan.md), and [integration report](docs/report.md).

The integration harness uses decoded instruction fields rather than a binary ISA decoder. It supports ADD, SUB and LW with word-indexed data memory; branches, stores, caches and exceptions are outside this project.

## Extended verification

Run `make regression` for additional seeded programs. See the [verification guide](docs/verification.md) for reproducible seeds, per-retirement checks and reset coverage.
