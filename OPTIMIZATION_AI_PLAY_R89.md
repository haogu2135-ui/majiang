# AI / Gameplay Round 89 - Independent Seed Strength Evidence

Date: 2026-07-29  
Validation: `scripts/ai_play_round89_check.gd`

## Coverage

The primary commercial pack validates a representative fixed set plus one
profile shuffle. This independent four-seed, two-hand-per-seed sample holds
seat 0 at normal difficulty while comparing easy/hard opponents. It uses the
same 16 paired simulations as the main pack, avoiding one-hand outliers while
checking actionable player-target risk, actual player deal-ins, terminal
completion, and both ledgers on different deterministic walls. The raw
player-pressure series remains in the output as diagnosis: a high-pressure
discard is only a commercial failure when a same-shanten, quality-preserving,
clearly safer evaluated alternative existed.

## Resource Impact

The probe runs two paired hands per difficulty for each independent base seed,
with no profile-shuffle row. It uses the existing quiet Top-K limits and must
finish within the repository's serial 180-second budget.
