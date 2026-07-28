# AI / Gameplay Round 75 - Catastrophic Push Guard

Date: 2026-07-28
Validation: `scripts/ai_play_round75_check.gd`

## Problem

Hard AI could continue a two-away push when the selected discard combined
extreme deal-in risk, feed risk, and player-target pressure. The diagnostic
seed `20260811` selected `4W` at risk `61.2`, feed risk `50.7`, and player
pressure `37.7`, despite same-shanten defensive alternatives being present.

## Fix

- Extend the hard danger push guard to compare a one-step defensive fallback
  from two-away hands when any emergency pressure signal is present.
- Allow a larger efficiency concession only when risk, feed risk, and
  player-target pressure are all catastrophic; normal high-pressure hands
  retain the existing tighter limits.
- Add a thin, low-value tenpai fold condition. High-value or thick tenpai is
  not folded by this rule.
- Lower the pressure-gain cutoff only for the catastrophic two-away path,
  avoiding a floating-point boundary that rejected a materially safer choice.
- Add opt-in compact trace metadata. It is allocated only by explicit
  benchmark diagnostics, never in normal gameplay or commercial strength runs.

## Resource Impact

The guard reorders the existing evaluated candidate reports. It does not add
candidate evaluations, tile scans, or normal-play trace allocation.

## Result

- R75 passed its direct catastrophic two-away and thin-tenpai guard checks.
- The fixed diagnostic hand executed real safety reroutes, including
  `4W -> 9T` and `4W -> 9B`; the former terminal path no longer occurs at its
  original two-away decision state.
- R64 passed: high-danger easy/hard `0.476/0.382`, deal-in `0.50/0.00`, with
  hard average simulation time `13462ms`.
- R68 passed its low-resource aggregate gate in `157788ms` with ledger
  integrity throughout. Aggregate high-danger was `0.356/0.318` and deal-in
  was `0.75/0.75` (easy/hard).
- The isolated `20260827` hard trace still contains forced high-risk one-away
  pushes where the retained alternative had no net safety gain. This remains
  visible in R76 rather than being hidden by the aggregate gate.

## Run

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round75_check.gd
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round64_check.gd
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round68_check.gd
```
