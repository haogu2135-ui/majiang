# AI / Gameplay Round 88 - Exact Quiet Candidate Routes

Date: 2026-07-29  
Validation: `scripts/ai_play_round88_check.gd`,
`scripts/ai_play_round68_check.gd`

## Problem

Quiet all-bot evaluation shared the first far-from-tenpai discard candidate's
hand-plan report with every later candidate. Since each discard changes the
hand, later candidates could inherit the wrong route label and score.

## Fix

- Calculate the plan report from each candidate's simulated hand.
- Keep the existing Top-3/Top-4 quiet evaluation cap, 34-tile scan skips, and
  risk caches intact.
- Add a regression that injects a stale shared route and verifies two quiet
  candidates each match their own direct plan evaluation.

## Resource Impact

The added work is one bounded linear route scan for each already-selected
quiet candidate. It adds no combinatorial search or retained cache. R68 is
the acceptance check for the repository's serial 180-second budget.
