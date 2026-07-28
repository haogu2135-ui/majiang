# AI / Gameplay Round 56 - Forced Tsumo-Pass Discard Path

Date: 2026-07-27  
Validation: `scripts/ai_play_round56_check.gd`

## Problem

When synchronous all-bot simulation deliberately declined a low-value tsumo,
the drawn tile was already the required preserve-tenpai discard. The loop still
built a full Top-K discard report only to update danger telemetry, repeating
shanten and candidate work that could not affect the action.

## Fix

- Skip `get_ai_discard_reports` when `ai_tsumo_continue_discard` supplies the
  forced tile.
- Record equivalent danger telemetry with one direct table-risk and feed-risk
  evaluation.
- Keep normal discard selection and its existing Top-K reports unchanged.

## Resource Impact

The rare but expensive tsumo-pass branch no longer runs full candidate scoring.
It performs one snapshot-backed danger check, preserving benchmark statistics
without changing the mandated discard or ordinary decision quality.

## Run

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round56_check.gd
```
