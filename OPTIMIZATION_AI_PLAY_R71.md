# AI / Gameplay Round 71 - Quiet Two-Away Defense Guard

Date: 2026-07-28  
Validation: `scripts/ai_play_round64_check.gd`, `scripts/ai_play_round68_check.gd`, `scripts/ai_play_round69_check.gd`

## Problem

R68/R69 were green, but the hard all-bot aggregate still showed an undesirable
total deal-in pattern on the commercial pack. Debugging the paired seeds showed
that quiet fast evaluation could rank a dangerous 0/1-shanten push above a
2-away defensive fallback because the quiet path skipped ukeire scans for
shanten-2 candidates to save CPU.

That preserved the low-resource budget, but it made hard AI too willing to push
when a safer two-away hand still had broad recovery.

## Fix

- Add a hard-only quiet guard for selected shanten-2 discard candidates: when a
  candidate is safety-labeled or comparatively lower risk under feed/player
  pressure, compute its ukeire before final scoring instead of leaving it at 0.
- Keep the extra scan bounded to quiet all-bot hard scoring and only for the
  already-pruned candidate set, so normal gameplay and easy-difficulty mistake
  shaping do not pay the cost.
- Slightly increase hard defense/feed discipline and slightly relax easy defense
  weighting to preserve a clearer commercial difficulty separation.
- Add a one-tile safety gate before hard/normal AI rejects a low-value self-draw
  to keep a better wait, preventing the AI from throwing back an immediately
  dangerous drawn winning tile.

## Result

- R68 fixed + shuffled aggregate deal-in improved from hard being worse than
  easy to easy/hard `0.75/0.38` while staying under the 180s serial budget.
- R68 player-target high-danger remains lower on hard: `0.126/0.098`; all-bot
  `humanRon` is `0.00/0.00` in the latest pack.
- R69 fixed human-probe still passes strict no-worse `humanRon`: easy/hard
  `0.25/0.25`, with player-target high-danger `0.110/0.070`.
- R64 fixed-seed safety separation remains green: high-danger easy/hard
  `0.476/0.423`, deal-in `0.50/0.50`, human deal-in `0.00/0.00`.

## Resource Impact

No normal gameplay cost. The additional ukeire scan is restricted to quiet
all-bot hard evidence runs after Top-K pruning. The broadest R68 pack completed
in `151976ms`, under the 180s low-resource serial budget; R69 completed in
`89090ms`, under its 90s budget.

## Run

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round68_check.gd
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round69_check.gd
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round64_check.gd
```

All commands passed on 2026-07-28 under the serial low-resource policy.
