# AI / Gameplay Round 68 - Multi-Seed Commercial Strength Pack

Date: 2026-07-28  
Validation: `scripts/ai_play_round68_check.gd`

## Problem

Focused R64/R66 gates proved hard is safer on one or two seeds, but commercial
strength still lacked a durable multi-seed evidence pack. Temporary probes were
easy to lose and did not cover shuffled-profile variance.

The first R68 evidence pass also exposed a benchmark trap: in all-bot sampling
seat0 is a bot too, so actual `deal_ins_to_human` changes when the global
difficulty changes. That value remains useful diagnostic telemetry, but it is
not a fair hard-vs-easy gate for "does the AI avoid feeding the player".

## Fix

- Add `sample_ai_commercial_strength_pack` for multiple fixed seeds plus one
  low-resource shuffled-profile sample, with easy/hard compared on paired wall
  seeds and paired persona maps.
- Add difficulty-independent `human_target_pressure` telemetry for chosen
  discards. R68 gates on hard not exceeding easy for overall high-danger and
  player-target high-danger rates; actual human ron count is still written as
  `humanRon` for diagnostics.
- Add `write_ai_commercial_strength_evidence_pack` to write JSON/Markdown under
  `build/qa/ai_play_commercial_evidence/`.
- Add R68 check that runs 2 hands/diff × easy/hard × 3 fixed seeds plus one
  shuffled sample, asserts fixed and total aggregate gates, and verifies durable
  artifacts.

## Result

- Aggregate commercial gate: `PASS`.
- Latest fixed-profile aggregate after the R71 quiet-guard rerun: high-danger
  easy/hard `0.317/0.327`, player-target high-danger `0.151/0.116`, deal-in
  `0.67/0.50`, `humanRon` `0.00/0.00`.
- Latest fixed + shuffled aggregate after the R71 quiet-guard rerun: high-danger
  easy/hard `0.356/0.317`, player-target high-danger `0.126/0.098`, deal-in
  `0.75/0.38`, `humanRon` `0.00/0.00`.
- `humanRon` is still treated as diagnostic in this all-bot pack because seat0
  strength is intentionally tied to the sampled difficulty; R69 remains the fair
  fixed-probe comparator.

## Resource Impact

No normal gameplay cost. Evidence sampling remains serial, headless, single-thread,
and intentionally small (16 total bot hands across fixed/shuffled rows). R68 skips
the normal difficulty inside the commercial pack because the gate only compares
easy versus hard, keeping the pack within the 180s budget. The R71 rerun finished
in `151976ms` after adding the hard-only 2-away quiet guard.

## Run

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round68_check.gd
```

Both commands passed on 2026-07-28. Related helper regressions were also checked
with R64 and R66 under the same low-resource serial policy.
