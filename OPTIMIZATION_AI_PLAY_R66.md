# AI / Gameplay Round 66 - Self-Contained Strength Evidence

Date: 2026-07-28  
Validation: `scripts/ai_play_round66_check.gd`

## Problem

The commercial strength benchmark could be called from an already-initialized
scene, but a fresh headless evidence script with an empty `players` array crashed
before producing any AI strength evidence. That made the evidence helper less
reliable for CI and external QA runs.

## Fix

- Add `ensure_ai_benchmark_players` to build a minimal four-seat offline table
  for benchmark-only use.
- Reset hands, melds, flowers, scores, pending claims, last discard state, and AI
  report cache before strength samples.
- Call the initializer from both `sample_bot_strength_across_difficulties` and
  `sample_bot_match_winrates`.
- Add a fresh-scene R66 check that clears `players`, then verifies strength and
  match samples initialize themselves, finish, and stay within low-resource
  timing budgets.

## Resource Impact

No normal gameplay cost. The initializer only runs when benchmark helpers are
called, and it performs constant-size four-seat table setup.

## Run

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round66_check.gd
```
