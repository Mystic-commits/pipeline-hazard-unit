# Pipeline Hazard Detection and Forwarding Unit

Team Snorlax — Ishita Thakur, Aditya Verma, Yug Johri, Anshvardhan, and Swagato Bauri.

Verilog hazard detection and operand forwarding for a five-stage IF/ID/EX/MEM/WB pipeline. The design handles RAW dependencies using EX/MEM and MEM/WB forwarding, with an interlock for load-use hazards.

## Report and demonstration

- [IEEE project report](docs/phase1/ieee-report.pdf) · [LaTeX source](docs/phase1/ieee-report.tex)
- [Prototype demonstration — 4:51 (MP4)](docs/media/prototype-demo.mp4) · [Direct video download](https://raw.githubusercontent.com/Mystic-commits/pipeline-hazard-unit/main/docs/media/prototype-demo.mp4) · [Chapters](docs/phase1/video.md)
- [Team responsibilities and contributing](CONTRIBUTING.md)

[![Prototype video preview](docs/media/prototype-poster.jpg)](https://raw.githubusercontent.com/Mystic-commits/pipeline-hazard-unit/main/docs/media/prototype-demo.mp4)

## Build and verify

Prerequisites: Icarus Verilog (`iverilog` and `vvp`), Python 3, and Make.

```sh
make verify      # All tests, seeded regression, and waveform checks
make wave        # Generate build/pipeline.vcd for GTKWave
```

`make test` runs the core suite; `make regression` runs additional seeds. To rebuild the report with Tectonic, run `make report`.

## Results

| Mode | Instructions | Cycles | Stalls | CPI |
|---|---:|---:|---:|---:|
| Forwarding with load-use interlock | 10 | 15 | 1 | 1.500 |
| Stall-only interlocks | 10 | 26 | 12 | 2.600 |

Both modes match the sequential reference. Verification includes 4,194,304 unit combinations, nine edge cases, reset/restart, 400 seeded programs, and five waveform checks. Measurements apply to the supplied simulation workload.

## Project files

| Path | Contents |
|---|---|
| `rtl/` | Comparators, forwarding unit, operand mux, hazard detection, stall control, and pipeline harness |
| `tb/` | Unit, integration, randomized, edge-case, and reset testbenches |
| `scripts/` | VCD audit and waveform sample export |
| `docs/evidence/` | Captured VCD, results, and verification log |
| `docs/phase1/` | IEEE report, editable source, and video chapters |
| `docs/media/` | Narrated prototype demonstration |

See the [architecture](docs/architecture.md), [verification guide](docs/verification.md), and [performance analysis](docs/report.md).

The harness supports decoded ADD, SUB, and LW operations with word-indexed memory. A binary ISA decoder, branches, stores, caches, and variable-latency memory are outside its scope. MODE=2 deliberately disables protection to demonstrate incorrect RAW execution; MODE=1 is the intended forwarding design.
