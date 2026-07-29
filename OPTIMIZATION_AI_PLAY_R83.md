# AI / Gameplay Round 83 - Bounded Quiet Candidate Evaluation

Date: 2026-07-28  
Validation: `scripts/ai_play_round34_check.gd`,
`scripts/ai_play_round69_check.gd`, and `scripts/ai_play_round68_check.gd`

## Problem

The 16-hand multi-seed commercial evidence pack no longer completed inside the
repository's 180-second single-thread budget. Quiet simulations fully scored
four discard candidates on every all-bot turn, multiplying expensive shanten,
wait-value, and risk calculations that do not occur on the foreground path.

## Fix

- Reduce ordinary quiet all-bot full evaluation from Top-4 to Top-3
  fast-ranked candidates.
- Keep Top-4 only under the existing high-pressure detector, so a material
  defensive fold and a lower-shanten attack alternative can both be compared.
- Leave interactive AI untouched: it continues to evaluate every legal
  candidate and retain its player-facing report cache.

## Resource Impact

Ordinary quiet benchmark turns perform at most three complete candidate
evaluations instead of four, a 25 percent reduction in that hot section.
Acute pressure deliberately restores the fourth comparison because dropping
either the fold or the attack branch harms decision quality. No additional
allocations, searches, or runtime work are added.

## Acceptance

R34 must still retain its intentionally low-efficiency safe fold under high
pressure, R69 must retain the fixed-human defensive gate, and R68 must finish
the complete multi-seed evidence pack inside the serial 180-second budget.

## Result

- R34 passed: the acute-pressure path retains four candidates and preserves
  both the low-efficiency safe fold and the lower-shanten attack alternative.
- R69 passed in `67073ms` (previously `86679ms` for the same fixed-human
  probe). Its aggregate actual human ron stayed `0.25/0.00` (easy/hard), and
  player-target high danger was `0.127/0.119`.
- R68 passed its complete 16-hand evidence pack in `159733ms`; fixed and
  combined aggregates both report tile integrity and score conservation for
  every easy/hard hand, with the commercial gate at PASS.
