# AI / Gameplay Round 67 - Wall-Draw Self-Gang Discipline

Date: 2026-07-28  
Validation: `scripts/ai_play_round67_check.gd`

## Problem

Rounds 61-63 taught discard, win accept, and open-claim paths to respect
exhaustive-draw tenpai ba. Self-gang still allowed late-wall dark/added gangs
that left the seat deep noten, so bots could open a gang and still pay noten ba.

## Fix

- Add `wall_draw_self_gang_discipline_report` on top of existing ba urgency.
- Decline no-improve deep-noten concealed/added gangs when the wall is short;
  keep gangs that reach or preserve tenpai / one-away.
- Store `declined_by_wall_draw` / `wall_draw_gang_penalty` on self-gang reports
  and subtract the penalty from `ai_self_gang_action_score`.
- Recompute self-gang score after the final allow decision so choosers see the
  commercial penalty and decline reason.

## Resource Impact

Only scalar wall/shanten math on the existing self-gang report path. No extra
34-tile scans, claim enumeration, or background work.

## Run

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round67_check.gd
```
