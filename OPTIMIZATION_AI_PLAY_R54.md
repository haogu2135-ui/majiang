# AI / Gameplay Round 54 - Snapshot Risk Reuse

Date: 2026-07-27  
Validation: `scripts/ai_play_round54_check.gd`

## Problem

`single_opponent_deal_in_risk_components` accepted a visible-tile snapshot, but
when the caller did not separately provide a count it still scanned live
discards and melds. Threat-card evaluation therefore repeated table walks for
each candidate and could disagree with the caller's captured snapshot.

## Fix

- Reuse `visible_tile_count_from_counts` when a snapshot is available.
- Keep the existing live-table fallback for callers with no snapshot.
- Add a focused regression comparing the implicit snapshot path with an
  equivalent explicit visible count.

## Resource Impact

Batch AI and threat-card analysis no longer re-walks all players' discards and
melds when visibility is already captured. No new search, allocation-heavy
report, or rendering work is added.

## Run

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round54_check.gd
```
