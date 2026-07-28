# AI / Gameplay Round 64 - Commercial Strength Evidence Gate

Date: 2026-07-28  
Validation: `scripts/ai_play_round64_check.gd`

## Problem

The project had AI danger-rate telemetry, but the commercial evidence remained
too weak: the benchmark booleans were not surfaced as a single gate, and there
was no deterministic proof that hard difficulty creates a materially larger
safety gap under human pressure.

## Fix

- Extend `sample_ai_strength_benchmark` with finished-hand counts,
  `finished_all`, and `commercial_strength_ok`.
- Add a deterministic pressure-table check proving hard difficulty chooses the
  visible safe tile and penalizes high-risk/human-feed discards much harder than
  easy.
- Keep the fixed-seed sample at 2 hands per difficulty for low-resource CI while
  still checking high-danger, deal-in, human deal-in, completion, and runtime.

## Resource Impact

No runtime AI cost in normal play. The added benchmark fields reuse already
computed sample summaries; the R64 check runs serially and low-priority.

## Run

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round64_check.gd
```
