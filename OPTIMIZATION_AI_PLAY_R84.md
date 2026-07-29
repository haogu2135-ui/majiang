# AI / Gameplay Round 84 - One-Shot Quiet Report Ownership

Date: 2026-07-28
Validation: `scripts/ai_play_round80_check.gd`,
`scripts/ai_play_round76_check.gd`, `scripts/ai_play_round69_check.gd`, and
`scripts/ai_play_round68_check.gd`

## Problem

All-bot quiet simulation deliberately bypasses the state-unique AI report
cache. It nevertheless made a shallow copy of every candidate dictionary on
return, even though the synchronous simulator reads that ranking once and
immediately advances the table state.

## Fix

- Return the fresh candidate array directly for `offline_sim_quiet` plus
  `offline_all_bot_mode`.
- Keep the cached/defensive-copy return path unchanged for interactive AI,
  advisor UI, and standalone quiet fixtures.
- Add a regression that mutates one quiet caller result, then verifies the
  next fresh ranking cannot observe that mutation.

## Result

- R76 fixed-seed trace retains the same decisions, guard outcomes, tile
  integrity, and terminal result.
- R69 fixed-human probe stays green: player-target high danger is
  `0.127 / 0.119` and actual human ron is `0.25 / 0.00` for easy/hard.
- R69 elapsed time improved from `72501ms` to `68786ms` on the same serial
  low-priority host setup.
- R68 passed the full 16-hand commercial pack in `155861ms`; the combined
  aggregate remains green with high danger `0.367 / 0.270`, player-target high
  danger `0.150 / 0.091`, and actual human ron `0.25 / 0.00` for easy/hard.
