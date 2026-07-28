# AI / Gameplay Round 73 - Hard AI Danger Push Guard Tuning

Date: 2026-07-28  
Validation: `scripts/ai_play_round64_check.gd`, `scripts/ai_play_round68_check.gd`, `scripts/ai_play_round69_check.gd`

## Problem

The R72 runtime fixes left the AI gates green, but the latest multi-seed
strength evidence still exposed seed-level hard-AI edge cases:

- Hard difficulty could keep pushing a high-risk tenpai/one-away discard when a
  lower-pressure candidate was available just outside the fast Top-K shortlist.
- A broad defensive adjustment fixed some deal-ins but made benchmark games too
  long, threatening the serial low-resource budget.
- The quiet fast-pruning path computed full feed-risk reports for every rough
  candidate, adding cost in all-bot commercial evidence runs.

## Fix

- Keep one clearly safest rough candidate in hard high-pressure quiet sims when
  any candidate has a large danger spike, so Top-K pruning cannot hide the fold
  option before full scoring.
- Add a hard-only post-sort danger-push guard that may promote a lower-pressure
  candidate when the current best discard is high-risk, while requiring any
  shanten-worsening candidate to also materially reduce seat0 pressure.
- Replace the rough fast-pruning human-pressure calculation with a lightweight
  risk/readiness estimate and cache the readiness value per report build. Full
  Top-K scoring still uses the detailed feed-risk and human-pressure reports.

## Result

- R64 fixed-seed gate passed again: high-danger easy/hard `0.476/0.463`, deal-in
  `0.50/0.00`, human deal-in `0.00/0.00`, hard avg `9005ms`, finished `2/2/2`.
- R68 durable strength pack passed and refreshed latest artifacts: all-row
  high-danger `0.356/0.339`, player-target high-danger `0.126/0.100`, deal-in
  `0.75/0.38`, actual humanRon `0.00/0.00`, elapsed `161880ms`.
- R69 fixed seat0 human-probe gate passed: high-danger `0.260/0.274`,
  player-target high-danger `0.110/0.084`, actual humanRon `0.25/0.00`, elapsed
  `77788ms`.

## Resource Impact

Normal gameplay keeps the full detailed discard scoring path. The new lightweight
estimate only affects quiet all-bot fast pruning, where it reduces repeated
feed-risk scans while preserving detailed scoring for retained Top-K candidates.
All validation was run serially with `LP_NUM_THREADS=1`, `nice`, and `ionice`.

## Run

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round64_check.gd
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round69_check.gd
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round68_check.gd
```

All commands passed on 2026-07-28 under the serial low-resource policy.
