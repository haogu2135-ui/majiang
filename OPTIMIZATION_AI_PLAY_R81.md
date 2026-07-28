# AI / Gameplay Round 81 - Near-Free Extreme One-Away Fold

Date: 2026-07-28  
Validation: `scripts/ai_play_round81_check.gd`

## Problem

The hard danger guard required at least 14 pressure points of improvement for
every one-away fallback. In an extreme player-facing danger state, this could
retain a high-risk discard even when a same-shanten alternative cost only a few
evaluation points and was measurably safer.

## Fix

- Detect the narrow combination of one-away, extreme deal-in risk, high feed
  risk, and meaningful seat0 pressure.
- For same-shanten alternatives only, accept a small positive safety gain of at
  least two pressure points.
- Keep the previous threshold for ordinary pressure and every shanten-worsening
  candidate.

## Resource Impact

The guard only reorders already-scored reports. It adds scalar comparisons and
does not expand the candidate set, run extra scans, or allocate diagnostic data
outside explicit trace mode.

## Result

- R81 passed both its direct reroute and non-broadening boundary checks.
- R75 passed unchanged, including catastrophic two-away and thin-tenpai folds.
- R69 fixed-human aggregate remained green: actual human ron was `0.25/0.00`
  (easy/hard) and completed in `93158ms` under the `180s` serial budget.

## Run

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round81_check.gd
```
