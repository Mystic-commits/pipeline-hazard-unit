# Pipeline Hazard Detection and Forwarding Unit

Team Snorlax — Ishita Thakur, Aditya Verma, Yug Johri, Anshvardhan, Swagato Bauri.

A five-stage IF/ID/EX/MEM/WB teaching pipeline with RAW forwarding, load-use interlocks, a stall-only comparison mode, and an intentionally unprotected mode for demonstrating RAW errors.

## Phase I submission

**Public repository:** https://github.com/Mystic-commits/pipeline-hazard-unit

- **[IEEE project report PDF](docs/phase1/ieee-report.pdf)** · [Editable LaTeX](docs/phase1/ieee-report.tex)
- **Prototype video:** not added yet — [recording script and link location](docs/phase1/video.md)
- [Submission checklist](docs/phase1/submission-checklist.md) · [Team responsibilities and contribution guide](CONTRIBUTING.md)

The report includes an abstract, literature review, proposed solution, results, individual workstream allocation, conclusion, and numbered references. The video and member-owned Git contributions are the remaining team actions before submission. **Phase I deadline: November 16, 2026, 11:59 PM IST.**

## Run

Install Icarus Verilog and Python 3, then run `make verify` for the complete audit. `make test` runs the core suite. Run `make wave` to produce `build/pipeline.vcd` for GTKWave. See [architecture](docs/architecture.md), [two-day plan](docs/plan.md), and [integration report](docs/report.md).

The integration harness uses decoded instruction fields rather than a binary ISA decoder. It supports ADD, SUB and LW with word-indexed data memory; branches, stores, caches and exceptions are outside this project.

## Extended verification

Run `make regression` for additional seeded programs. See the [verification guide](docs/verification.md) for reproducible seeds, per-retirement checks and reset coverage.

## Final delivery — November 15, 2026

All local checks pass: 4,194,304 unit combinations, nine edge scenarios, reset/restart, 400 seeded programs (51,200 checked retirements across both protected modes), and five captured waveform cases. The directed workload takes 15 cycles with forwarding versus 26 with stall-only interlocks.

Start with the [demo guide](docs/demo.md), [requirements and audit record](docs/acceptance.md), and [integration report](docs/report.md). The optional GitHub Actions configuration is a template at `docs/ci-workflow.yml`; hosted CI is not enabled because the current credential lacks workflow permission.
