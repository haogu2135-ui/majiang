# AI / Gameplay Round 63 - Wall-Draw Claim Discipline

Date: 2026-07-28  
Validation: `scripts/ai_play_round63_check.gd`

## Problem

Round 61/62 made exhaustive-draw tenpai ba real and taught discard / win accept
paths to respect it. Claim decisions still allowed dirty late-wall chi/peng that
left the seat deep noten, so bots could open and still pay noten ba.

## Fix

- Add `wall_draw_claim_discipline_report` on top of existing ba urgency.
- Decline no-improve deep-noten claims when the wall is short; keep claims that
  reach tenpai or one-away.
- Store `declined_by_wall_draw` / `wall_draw_claim_penalty` on claim reports and
  subtract the penalty from `ai_claim_action_score`.
- Leave deep-wall claim thresholds and useful late claims unchanged.

## Resource Impact

Only scalar wall/shanten/shape math on the existing claim-report path. No extra
34-tile scans, claim enumeration, or background work.

## Run

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round63_check.gd
```
