# AI / Gameplay Round 57 - Full-Wait Furiten

Date: 2026-07-27  
Validation: `scripts/ai_play_round57_check.gd`

## Problem

Discard furiten and temporary passed-win furiten were checked only against the
same tile. In a multi-wait hand, that allowed ron on an alternate wait after
discarding or declining another valid wait, which violates standard Mahjong
furiten behavior and made AI/UI claim options inconsistent with the rules.

## Fix

- Evaluate whether any unique tile in the seat's river completes the current
  hand structure; if so, block every ron wait.
- Treat any recorded passed win as temporary furiten for every ron wait until
  the seat's next actual draw.
- Keep self draw separate: `can_win_for_seat` remains unaffected.
- Gate the extra river scan behind an already-valid ron hand, avoiding work for
  ordinary non-winning claim checks.

## Resource Impact

The wait-wide discard scan runs only for candidate tiles that already complete
the hand, and checks each unique own discard once. Ordinary claim evaluation
still exits after its existing structural win check.

## Run

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round57_check.gd
```
