# Requirements and audit record — November 15, 2026

| Requirement | Implementation | Verification/evidence |
|---|---|---|
| Register-ID dependencies and RAW hazards | `register_match.v` | Every source/MEM/WB triple, zero register and enable masks |
| EX/MEM and MEM/WB forwarding | `forwarding_unit.v`, `forward_mux.v` | Unit sweep, mixed-path edge case 5, captured waveforms |
| Priority for newest producer | EX/MEM wins; unavailable newer load blocks older WB | Edge cases 6–7 and repeated-writer waveform |
| Load-use detection | `hazard_detection.v` | Operand B consumer, load base consumer, false rs2 masking |
| Controlled stall/flush | `stall_control.v`, valid-bit integration | PC/decode freeze assertion, one EX bubble, restart during stall |
| Five-stage integration | `pipeline_demo.v` | Directed program and 400 random programs, both correct modes |
| With/without handling comparison | MODE 1/0/2 | Edge CSV: mode 2 demonstrates wrong RAW result |
| Correctness and performance | Retirement and register scoreboards, cycle accounting | 15 vs 26 cycles; 1.500 vs 2.600 CPI on directed workload |
| Testbench, waveform cases, report | `tb/`, waveform auditor, documentation | `make verify`, VCD, CSVs, final verification log |

## Audit findings and changes

1. Invalid pipeline slots previously evaluated a memory read and propagated irrelevant data. Valid bits prevented architectural writes, but could leave unknown values in bubble metadata. Invalid MEM slots now emit zero data, and invalid EX slots clear result/load metadata.
2. Some testbench timing comparisons used `!=`, which can evaluate to unknown and fail to reject X/Z values. They now use case inequality (`!==`). Failure to open the directed results CSV is also fatal.
3. The comparison covered two correct modes but did not directly demonstrate execution with all hazard handling disabled. MODE=2 and a directed negative demonstration now expose the wrong answer without treating it as a performance win.
4. Unit sweeps used complementary source IDs only. Equal source pairs and reserved mux selector behavior are now checked too: 4,194,304 combinations plus the reserved selector.
5. Waveforms existed but were not automatically audited. A standard-library Python tool now checks five concrete cases and exports stable cycle samples.
6. Invalid demo parameters are rejected explicitly. The harness requires N≥1 and MODE in {0,1,2}.

No incorrect architectural result was observed in either protected mode during the final verification suite. This is a test-based conclusion, not a proof of perfection. The exact supported scope and timing contract are in `architecture.md`.

## Final deliverable status

All requested technical deliverables are present and pass local verification. The optional GitHub Actions template cannot be activated with the current CLI credential, which lacks workflow scope. No hosted CI success is claimed. No teammate invitations, presentation attendance or instructor submission are claimed.
