# AI / Gameplay Round 86 - Two-Away Emergency Same-Shanten Fold

Date: 2026-07-28
Validation: `scripts/ai_play_round75_check.gd`,
`scripts/ai_play_round69_check.gd`, and `scripts/ai_play_round68_check.gd`

## Problem

A hard-AI terminal trace retained a two-away discard with risk `37.8`, feed
risk `50.7`, and player pressure `27.3`. Its existing same-shanten option
reduced those values to `3.9`, `0.0`, and `0.0`, but was blocked solely by a
`402.2` evaluation-point gap against the ordinary two-away `300` cap.

## Fix

- When the existing two-away emergency predicate is already true, permit a
  same-shanten safety reroute up to a measured `410` score gap.
- Retain the existing positive pressure-gain threshold, catastrophe handling,
  and prohibition against a shanten-worsening fold.
- Add both sides of the new boundary to R75: the measured near-zero fold is
  promoted, while a `411`-point alternative remains rejected.

## Result

- R75 reroutes the traced `4B -> R` two-away emergency and preserves all
  existing catastrophe and thin-tenpai guards.
- R69 fixed-human aggregate improves hard high danger from `0.307` to `0.243`
  and player-target high danger from `0.119` to `0.074`; actual human ron
  remains `0.25 / 0.00` for easy/hard.
- R68 passes the full commercial pack in `155696ms`: aggregate hard high
  danger improves to `0.254`, player-target high danger is `0.091`, actual
  human ron remains `0.25 / 0.00`, and all tile/score ledgers are conserved.
