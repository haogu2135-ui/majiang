# AI / Gameplay Round 82 - Score Ledger in Commercial AI Gates

Date: 2026-07-28  
Validation: `scripts/ai_play_round82_check.gd`

## Problem

Quiet all-bot simulations already verified the 144-tile inventory, but a
scoring regression could still create or remove table points while leaving that
physical ledger intact. This left the commercial strength gate unable to catch
non-zero-sum settlement defects.

## Fix

- Add an O(4) four-seat score-ledger report with an optional expected total.
- Snapshot total score before each quiet simulated hand and validate it after
  terminal settlement, including win and wall-draw paths.
- Carry score-conservation results through each difficulty row, benchmark,
  aggregate, evidence-pack row, and commercial gate.
- Add R82 coverage for direct score creation detection and paired easy/normal/
  hard simulations.

## Resource Impact

The invariant sums four integer scores before and after a simulated hand. It
does not alter AI candidate evaluation, add state searches, or retain reports.

## Run

```bash
python3 tools/assemble_main.py --verify
timeout --foreground --signal=TERM --kill-after=15s 180s \
  env GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 \
  nice -n 10 ionice -c 2 -n 7 \
  godot --headless --path . -s scripts/ai_play_round82_check.gd
```
