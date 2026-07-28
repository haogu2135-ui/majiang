# AI / Gameplay Round 60 - Full-Win Package Liability

Date: 2026-07-28  
Validation: `scripts/ai_play_round60_check.gd`

## Problem

包三搭 liability was only applied on self-draw. Once a seat had been packaged,
a later ron or rob-gang still billed only the discarder/gang source. That made
AI package-discipline warnings stronger than the actual settlement rule and
diverged from commercial local-table package payment.

## Fix

- Apply package liability to every finish path for the packaged winner:
  tsumo, ron, and rob-gang.
- Keep the existing commercial amount: packager pays the triple total once.
- Record package payer metadata on `last_win_score` and keep the round summary
  package line for all packaged wins.
- Leave ordinary non-package ron/tsumo payment unchanged.
- Document package liability in the rules screen.

## Resource Impact

Settlement still performs one constant-time package lookup and one score write.
No extra shanten, claim search, or table scan is added.

## Run

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round60_check.gd
```
