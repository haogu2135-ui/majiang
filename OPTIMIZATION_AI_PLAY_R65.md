# AI / Gameplay Round 65 - Ron Arbitration Policy Clarity

Date: 2026-07-28  
Validation: `scripts/ai_play_round65_check.gd`

## Problem

Claim arbitration already preserved the human hu window when another AI could
also ron, but the rules copy only said hu had priority. That made the product
policy ambiguous: users could read it as full multi-ron settlement even though
the implementation settles one submitted winner.

## Fix

- Document the current policy in README and the in-game rules: hu outranks other
  claims; peng/gang/chi ties use nearest seat; if multiple seats can ron, the
  player hu window is preserved, and the submitted winner is settled as a single
  winner.
- Add a focused behavior check covering nearest AI ron, preserved human hu,
  human-submit settlement, and human-pass-to-cached-AI settlement.
- Keep the existing R12 interaction model; no unsupported multi-ron metadata is
  advertised.

## Resource Impact

Documentation plus one focused headless script. No runtime cost in gameplay.

## Run

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round65_check.gd
```
