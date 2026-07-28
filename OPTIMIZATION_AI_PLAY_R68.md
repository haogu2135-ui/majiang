# AI / Gameplay Round 68 - Multi-Seed Commercial Strength Pack

Date: 2026-07-28  
Validation: `scripts/ai_play_round68_check.gd`

## Problem

Focused R64/R66 gates proved hard is safer on one or two seeds, but commercial
strength still lacked a durable multi-seed evidence pack. Temporary probes were
easy to lose and did not cover shuffled-profile variance.

## Fix

- Add `sample_ai_commercial_strength_pack` for multiple fixed seeds plus one
  low-resource shuffled-profile sample.
- Add `write_ai_commercial_strength_evidence_pack` to write JSON/Markdown under
  `build/qa/ai_play_commercial_evidence/`.
- Add R68 check that runs 2 hands/diff × 3 fixed seeds + shuffled sample, asserts
  the commercial gate, and verifies durable artifacts.

## Resource Impact

No normal gameplay cost. Evidence sampling remains serial, headless, single-thread,
and intentionally small (8 total bot hands across difficulties/seeds).

## Run

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round68_check.gd
```
