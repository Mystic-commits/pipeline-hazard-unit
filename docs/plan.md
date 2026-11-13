# Two-day delivery plan

## Day 1 — November 14, 2026
- Agree on interfaces and pipeline timing.
- Implement dependency comparators, priority forwarding and muxes.
- Implement load-use interlocks and pipeline control.
- Run exhaustive register-ID unit tests and directed integration cases.

## Day 2 — November 15, 2026
- Inspect waveforms for consecutive ALU dependencies and load-use bubbles.
- Compare stall-only and forwarding modes for the same workload.
- Review the integration report, reproduce CI and rehearse the demo.

Suggested ownership (team can change): Ishita — integration; Aditya — forwarding; Yug — hazard control; Anshvardhan — verification; Swagato — measurements/report.

Commit policy: commit completed, reviewable changes with descriptive messages. Do not backdate or manufacture activity. Current commits record actual work; the second day remains a review/demo milestone.
