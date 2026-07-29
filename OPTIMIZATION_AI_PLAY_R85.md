# AI / Gameplay Round 85 - Eligible Self-Gang Evaluation

Date: 2026-07-28
Validation: `scripts/ai_play_round13_check.gd`,
`scripts/ai_play_round67_check.gd`, `scripts/ai_play_round69_check.gd`, and
`scripts/ai_play_round68_check.gd`

## Problem

Each bot draw asked both self-gang selectors to build reports for all 34 tile
types. The report calculated shanten and route information before checking
whether the tile could actually be a concealed gang or an added gang. Nearly
all of those reports were guaranteed to be illegal.

## Fix

- Concealed-gang selection enumerates only hand counts of four.
- Added-gang selection enumerates only existing triplet melds with a matching
  hand tile, while retaining canonical tile-order tie-breaking.
- The report itself now rejects an ineligible gang before evaluating shanten,
  route, pressure, or wait width, protecting other direct callers too.

## Result

- R13 preserves both AI and human rob-gang protection.
- R67 preserves late-wall gang discipline and still selects a useful tenpai
  concealed gang.
- R69 remains green with the same aggregate strength and actual human ron
  `0.25 / 0.00` for easy/hard; runtime improved from `68786ms` to `65901ms`.
- R68 passed the full 16-hand commercial pack in `150573ms`, with aggregate
  high danger `0.367 / 0.270`, player-target high danger `0.150 / 0.091`,
  actual human ron `0.25 / 0.00`, and full tile/score ledger conservation.
