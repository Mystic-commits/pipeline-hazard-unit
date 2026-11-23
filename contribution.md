# Team Responsibilities and Contributions

All five team members are expected to understand the complete project pipeline while taking ownership of a specific technical area. The following allocation outlines each member's responsibilities and the files associated with their work.

| Team Member | Assigned Responsibilities | Relevant Files |
|---|---|---|
| Ishita Thakur | Pipeline integration, coordination of the five stages, and valid-bit management | `rtl/pipeline_demo.v`, `docs/architecture.md` |
| Aditya Verma | Development of comparators, operand selection multiplexers, and forwarding interfaces | `rtl/register_match.v`, `rtl/forward_mux.v`, `rtl/forwarding_unit.v` |
| Yug Johri | Implementation of load-use hazard detection, pipeline stalls, hold signals, and bubble insertion | `rtl/hazard_detection.v`, `rtl/stall_control.v` |
| Anshvardhan | Verification, testbench development, scoreboards, reset validation, and waveform analysis | `tb/`, `scripts/check_waveform.py` |
| Swagato Bauri | Performance measurements, literature review, evidence collection, and technical report preparation | `docs/evidence/`, `docs/phase1/ieee-report.tex`, `docs/report.md` |

## Contribution Guidelines

Once the repository owner sends an invitation, each member should join using their own GitHub account.

Every member must configure their actual Git identity in the local repository and make a meaningful contribution within their assigned workstream. Contributions may include improving existing RTL logic, adding tests for uncovered scenarios, validating boundary conditions, refining interfaces, or strengthening the technical documentation with supporting evidence.

Before making changes, review the existing implementation and test coverage to avoid duplicating work.

For any RTL or testbench modifications, run:

```bash
make verify
```

If you modify the technical report, rebuild the PDF and inspect the generated document to ensure that the formatting and content are correct.

Once your contribution is complete:

1. Commit your changes using your own GitHub-linked identity.
2. Push your changes to a separate branch.
3. Open a pull request describing what you implemented and how you verified it.

**Important:** The existing development history currently uses a single author identity. Being added as a repository collaborator or having your name listed in the team allocation does not automatically establish individual Git contributions. Do not modify previous commit authorship, create backdated commits, or add empty commits simply to increase contribution counts.

## Report and Documentation Requirements

The project report follows the IEEEtran conference format. All source files and compilation instructions are available in `docs/phase1/`.

When editing the report, ensure that:
- Individual role descriptions accurately represent the work performed by each member.
- Technical explanations remain consistent with the implemented design.
- All numerical results and performance claims are supported by actual simulation outputs.
- The final PDF is rebuilt and reviewed after making changes.

## GitHub Commit Attribution Setup

Before creating your first commit, configure Git with your own name and an email associated with your GitHub account.

Run the following commands from the repository directory:

```bash
git config --local user.name "Your Name"
git config --local user.email "YOUR_ID+YOUR_USERNAME@users.noreply.github.com"
git var GIT_AUTHOR_IDENT
```

Replace the placeholders with your actual details. You can find your exact GitHub-provided noreply email under **GitHub Settings → Emails**.

The initial commits were created using a machine-specific email that GitHub could not associate with an individual account. Configuring a verified email ensures that future commits are correctly attributed to their respective contributors.

Previous commits will remain unchanged, while new commits will appear under the correct GitHub profiles once pushed. Keep in mind that GitHub contribution graphs may take some time to update after pushing.
