# Yug's core section — hazard control

Your workstream is the central load-use hazard-control path. Learn the logic and timing below before presenting it; a responsibility label alone does not demonstrate understanding or GitHub contribution.

## Thirty-second explanation

“When a load is in EX, only its address has been calculated. If decode needs that load's destination, forwarding cannot supply the memory data yet. I compare the used decode sources against the valid, nonzero load destination. On a match I hold PC and IF/ID, invalidate the next EX slot, and let older stages advance. After one bubble, the dependent instruction reaches EX and receives the loaded value from MEM/WB.”

## The three conditions to remember

1. The EX instruction is a valid load that writes a nonzero destination.
2. A source of the ID instruction actually uses that destination.
3. The match causes a single stall: `pc_write=0`, `if_id_write=0`, `id_ex_flush=1`.

Read the real implementation in `rtl/hazard_detection.v` and `rtl/stall_control.v`. Integration qualifies producer writes with stage valid bits in `rtl/pipeline_demo.v`.

## Example to explain on screen

```text
LW  r9, 3(r0)       -> memory[3] = 103
ADD r10, r9, r8     -> must use 103, not the old r9 = 9
```

In the supplied demo r8=20, so ADD must produce r10=123.

| Stable sample | What to say |
|---|---|
| 100 ns | LW is in EX; the dependent ADD is held in decode. Stall=1, PC=8. |
| 110 ns | EX valid=0: this is the bubble. PC is still 8. Older load continues. |
| 120 ns | ADD is in EX; fa=01 selects loaded data 103 from MEM/WB. PC resumes. |

## Questions you should be able to answer

**Why not forward the EX/MEM load value?** At that point it is the address, not the loaded data.

**Why hold only the front of the pipeline?** The older load must progress so the dependency can become ready. Freezing every stage would prevent progress.

**Why clear a valid bit?** It turns the EX slot into a bubble that cannot retire or modify a register; clearing every operand field is not needed for architectural correctness.

**Why is LW rs2 ignored?** LW uses a base register and immediate, so matching an unused field is a false dependency.

**Why is r0 excluded?** It always reads as zero and writes to it have no architectural effect.

**Why exactly one stall?** This harness has fixed, single-stage memory access. Variable-latency memory requires a ready/valid or equivalent backpressure scheme.

**What if two older instructions write the same register?** Newest available producer wins. A newer load must mask an older WB value until its own data is ready.

**How is your logic tested?** Unit predicates, operand-B and load-base cases, false aliases, PC/decode-hold and bubble assertions, reset during a stall, and sequential scoreboards in random programs.
