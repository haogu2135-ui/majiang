# AI / Gameplay Round 89 - Independent Seed Strength Evidence

Date: 2026-09-25

Validation: `scripts/ai_play_round89_check.gd`

## Coverage

The primary commercial pack validates a representative fixed set plus one
profile shuffle. This independent eight-seed, two-hand-per-seed sample holds
seat 0 at normal difficulty while comparing easy/hard opponents. It covers 16
hands per difficulty (32 simulated hands total) on deterministic walls, and
checks actionable player-target risk, actual player deal-ins, terminal
completion, and both ledgers. The raw player-pressure series remains
diagnostic: a high-pressure discard is only a commercial failure when a
same-shanten, quality-preserving, clearly safer evaluated alternative existed.

The 2026-09-25 commercial run passed R89 in 81.9 seconds: easy/hard actual
deal-ins to the fixed seat0 probe were 1/16 and 2/16. This meets the probe's
one-additional-ron tolerance; it is not a statistical claim about overall win
rate.

## Resource Impact

The probe runs two hands per difficulty for each independent base seed, with no
profile-shuffle row. It uses the existing quiet Top-K limits and must finish
within the repository's serial 180-second budget.
