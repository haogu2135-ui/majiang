# AI / Gameplay Round 61 - Exhaustive Draw Tenpai Check

Date: 2026-07-28  
Validation: `scripts/ai_play_round61_check.gd`

## Problem

When the wall emptied, settlement only repeated the dealer and zeroed score
deltas. Tenpai seats earned nothing and noten seats paid nothing, so late-game
defense/push decisions and commercial draw-game expectations diverged from the
table result.

## Fix

- On `finish_wall_draw`, classify each seat as tenpai or noten with one cached
  shanten check.
- If both sides exist, each noten seat pays `WALL_DRAW_NOTEN_BA` and tenpai seats
  split the pool; all-tenpai or all-noten remains zero.
- Keep dealer repeat, no winner seat, and no fabricated win fan.
- Store a wall-draw summary on `last_win_score` and mention tenpai/noten in the
  round text; update rules copy.
- Adjust R19/R20 expectations to accept the new draw-game summary while still
  forbidding stale win details.

## Resource Impact

At most four shanten evaluations, and only at exhaustive-draw termination. No
extra work on ordinary discard, claim, or mid-hand AI paths.

## Run

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round61_check.gd
```
