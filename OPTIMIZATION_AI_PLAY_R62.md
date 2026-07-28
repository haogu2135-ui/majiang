# AI / Gameplay Round 62 - Wall-Draw Ba Awareness

Date: 2026-07-28  
Validation: `scripts/ai_play_round62_check.gd`

## Problem

Round 61 added commercial exhaustive-draw tenpai/noten payments, but AI still
scored discards and win accepts as if the wall-end were zero-sum free. Near the
draw, bots could break tenpai or pass modest wins that already covered ba.

## Fix

- Add low-cost `wall_draw_ba_urgency` and tenpai-preservation helpers.
- Bias discard scoring to keep tenpai / chase one-away and de-prioritize deep
  noten when the wall is short.
- Force ron/tsumo pocketing when remaining wall is low and points already cover
  ba, including the previous keep-tenpai pass branch.
- No extra table search: helpers use wall count, shanten, and existing scores.

## Resource Impact

Only scalar math on paths that already compute shanten/win value. No additional
34-tile scans, claim enumeration, or background work.

## Run

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round62_check.gd
```
