# AI / Gameplay Round 80 - Quiet Simulation Report Cache Bypass

Date: 2026-07-28  
Validation: `scripts/ai_play_round80_check.gd`

## Problem

Quiet all-bot simulations advance the table after every discard, making each
state-keyed discard report unique. The existing cache therefore built a long
table-state key, deep-copied every retained Top-K report, and held up to 256
unreusable entries during a benchmark hand.

## Fix

- Skip report-cache key construction, lookup, deep-copy storage, and hit/miss
  accounting while `offline_sim_quiet` is active.
- Keep the cache unchanged for interactive turns, where redraws and advisor
  controls can ask for the same report more than once.
- Add a focused regression that proves quiet simulation retains no report cache
  entries while interactive calls still miss once then hit once.

## Resource Impact

The quiet AI still scores the exact same retained candidates. It only removes
unreusable string allocation and report retention from serial benchmark hands.

## Result

- R80 passed: quiet simulations produced candidates with zero report-cache
  entries and no cache accounting; interactive repeated queries still produced
  one miss followed by one hit.
- R78 fixed-human probe remained green after the change: all four paired hands
  finished with tile-ledger integrity, actual human ron was `0.00/0.00`
  (easy/hard), and elapsed time was `60883ms` under the `110s` serial budget.
- R75 catastrophic-push regression remained green, including its hard-AI
  safety reroutes and terminal trace checks.

## Run

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round80_check.gd
```
