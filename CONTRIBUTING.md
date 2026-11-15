# Team contributions

All five members should understand the full pipeline and own a substantive workstream. The allocation below records team responsibilities, not a reconstruction of past Git authorship.

| Member | Workstream | Relevant files |
|---|---|---|
| Ishita Thakur | Five-stage integration and valid-bit flow | `rtl/pipeline_demo.v`, `docs/architecture.md` |
| Aditya Verma | Comparators, operand muxes and forwarding interfaces | `rtl/register_match.v`, `rtl/forward_mux.v`, `rtl/forwarding_unit.v` |
| Yug Johri | Core load-use hazard control, holds and bubble insertion | `rtl/hazard_detection.v`, `rtl/stall_control.v`, `docs/phase1/yug-explanation.md` |
| Anshvardhan | Verification, scoreboards, reset and waveform checks | `tb/`, `scripts/check_waveform.py` |
| Swagato Bauri | Measurements, literature and project report | `docs/evidence/`, `docs/phase1/ieee-report.tex`, `docs/report.md` |

## Make a real contribution

1. Join the repository when the owner sends your invitation.
2. Use your own GitHub account and configure your real Git identity in this checkout. Use a verified email or the exact GitHub-provided noreply address from your account settings.
3. Make a substantive change in your workstream: add and explain a meaningful test, improve an interface or implementation, validate a missing boundary case, or improve the technical report with evidence. Read the existing coverage before adding a test.
4. Run `make verify` for RTL/test changes. Rebuild and inspect the PDF for report changes.
5. Commit with a descriptive message under your own identity, push a branch, and open a pull request describing the change and verification.

The current initial development history uses a single author identity. Inviting members or listing their names does not change that history. Do not rewrite authorship, backdate commits, or add empty commits to manufacture contribution evidence.

## Report editing

The report uses IEEEtran conference mode. Its source and build instructions are under `docs/phase1/`. Keep role statements consistent with the team's actual work and keep numerical claims consistent with captured simulation outputs.
