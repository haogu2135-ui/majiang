# AI / Gameplay Round 59 - Kuikae Deadlock Release

Date: 2026-07-28  
Validation: `scripts/ai_play_round59_check.gd`

## Problem

Round 58 introduced commercial kuikae bans after chi/peng. In the rare case
where every remaining hand tile was banned, AI selection could return empty and
the all-bot simulator still fell back to raw `hand[0]`. The commit path then
rejected the discard and left the seat stuck in `await_discard`.

## Fix

- Auto-release claim bans when installing them would leave no free hand tile.
- Add `choose_legal_offline_discard_tile` / deadlock release helpers.
- Route AI discard choice, visible AI turns, and quiet bot simulation through
  the legal chooser instead of bare `hand[0]`.
- Keep ordinary kuikae bans intact whenever at least one free tile remains.

## Resource Impact

Helpers scan only the current seat hand once. No extra shanten, ukeire, or
table-wide threat work is added. Deadlock release is a constant-time erase of a
tiny per-seat dictionary.

## Run

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round59_check.gd
```
