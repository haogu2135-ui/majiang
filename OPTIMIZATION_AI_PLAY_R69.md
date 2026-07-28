# AI / Gameplay Round 69 - Fixed Human-Probe Benchmark

Date: 2026-07-28  
Validation: `scripts/ai_play_round69_check.gd`

## Problem

R68 correctly moved the commercial gate to difficulty-independent `humanHD`, but
actual `humanRon` remained diagnostic only: in all-bot sampling seat0 also used
the sampled global difficulty, so easy/hard rows compared against different
"player" strength.

For commercial acceptance we still need a fair low-resource way to ask: with the
same wall, same persona map, and the same player-probe strength, does hard AI
avoid feeding seat0 at least as well as easy AI?

## Fix

- Add benchmark-only per-seat difficulty routing:
  - `ai_benchmark_base_difficulty` is the sampled opponent difficulty.
  - `ai_benchmark_probe_seat` / `ai_benchmark_probe_difficulty` can pin seat0 to
    a fixed probe strength during all-bot evidence runs.
- Apply the effective seat difficulty at AI turn entry and while evaluating
  claim candidates, so discards, tsumo decisions, gangs, ron passes, and calls
  are scored from the intended seat perspective.
- Extend `sample_ai_strength_benchmark` with optional `probe_seat` and
  `probe_difficulty` parameters.
- Add R69 low-resource check with seat0 pinned to normal difficulty while easy
  and hard opponents share paired wall seeds and paired persona maps.

## Result

- Fixed-probe aggregate over 2 seeds × 2 hands/difficulty: `PASS`.
- Overall high-danger easy/hard: `0.260/0.219`.
- Player-target high-danger easy/hard: `0.110/0.062`.
- Actual `humanRon` easy/hard with fixed seat0 probe: `0.25/0.25`; this now
  passes a strict no-worse comparator and is a fair diagnostic comparator.
- Runtime: `66098ms`, below the 90s R69 budget.

## Resource Impact

No normal gameplay cost. Probe routing is inactive unless benchmark fields are
set, and the R69 evidence run is 8 total bot hands under the serial low-resource
Godot command.

## Run

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round69_check.gd
```

Both commands passed on 2026-07-28. R68 was rerun after the shared benchmark
change and remained green.
