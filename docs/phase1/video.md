# Phase I prototype video

**Video URL: not added yet.** The team will record and upload the video, then replace this status with the working URL here and in the README. Do not submit until the uploaded video is viewable without an access request and is no longer than 5 minutes.

## Recording script — target 4 minutes 30 seconds

### 0:00–0:25 — Introduce the idea and all five members

“Hello, we are Team Snorlax: Ishita Thakur, Aditya Verma, Yug Johri, Anshvardhan, and Swagato Bauri. Our project is Pipeline Hazard Detection and Forwarding Unit. We detect register dependencies in a five-stage processor pipeline and resolve them with forwarding or controlled stalls.”

Show the README and the report title/author block. Say all five names clearly even if one person narrates. The rubric does not state that all five must appear on camera.

### 0:25–1:00 — Explain the block diagram

Show Figure 1 in the IEEE report or the architecture diagram in `docs/architecture.md`.

“Instructions move through fetch, decode, execute, memory, and writeback. A dependent instruction may reach execute before the previous result has been written to the register file. Our forwarding paths send available results from EX/MEM or MEM/WB directly to the ALU operand muxes.”

### 1:00–1:45 — Explain forwarding

Show `rtl/forwarding_unit.v` and `rtl/forward_mux.v`.

“We compare each used source register with valid producer destinations. Register zero is excluded. Selector 10 chooses the newer EX/MEM ALU result; selector 01 chooses MEM/WB's final value; 00 uses the captured register value. If two instructions write the same destination, the newest producer takes priority. A load's effective address must never be forwarded as loaded data.”

### 1:45–2:30 — Explain Yug's hazard-control section

Show `rtl/hazard_detection.v`, `rtl/stall_control.v`, and the three-row load-use table in the report.

“I am Yug, and my core responsibility is hazard control. If the instruction in execute is a load and decode uses its nonzero destination, the load data is not available yet. We hold the program counter and IF/ID register, invalidate the next EX slot, and let older instructions continue. That creates one bubble. The consumer then uses the loaded value from MEM/WB. LW uses only its base source, so an unused rs2 field must not cause a false stall.”

If another person narrates the full video, say “Yug's core responsibility is hazard control” instead of “I am Yug.”

### 2:30–3:30 — Demonstrate the working prototype

Prepare the terminal in the repository before recording and run `make verify`. Let it finish; do not present pasted output as a live run. Show the PASS lines for the unit combinations, pipeline comparison, random programs, reset/restart, nine edge cases, and waveform audit.

“The protected modes are checked against a sequential reference, including every retirement in the random programs. The ten-instruction demo gives the same correct result in both modes. Forwarding takes 15 cycles with one stall, while stall-only takes 26 cycles with 12 stalls.”

Show `docs/evidence/results.csv`. If the live test takes longer than expected, shorten the earlier explanations rather than exceeding five minutes.

### 3:30–4:10 — Show the load-use evidence and negative comparison

Show `docs/evidence/waveform-cases.csv` or the VCD in GTKWave. At 100 ns, stall=1 and PC=8; at 110 ns, EX is invalid and PC still equals 8; at 120 ns, operand A is the loaded value 103.

“The held PC and invalid EX slot show the bubble. We also test a mode with handling deliberately disabled: it uses stale data and gives r6=2 instead of 0. This shows why correctness must be checked before comparing CPI.”

### 4:10–4:30 — Close with scope and repository

“The standalone hazard RTL is integrated into a simulation harness supporting ADD, SUB, and LW. This is a decoded-instruction teaching prototype, not a complete ISA implementation. The public repository contains the IEEE report, RTL, testbenches, captured waveforms, and reproducible commands. Thank you.”

## Before uploading

- Confirm total duration is at most 5:00; target 4:30 leaves margin.
- Confirm all five names and the project title are audible.
- Confirm the terminal/code and block diagram are legible at normal playback size.
- Ensure the screen recording does not reveal browser notifications, credentials, or unrelated windows.
- Use a shareable YouTube/Drive or equivalent URL; test playback while signed out.
- Add that URL to this file and to the README, then commit it.
