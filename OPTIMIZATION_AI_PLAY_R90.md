# AI / Gameplay Round 90 - Actionable Player-Pressure Gate

Date: 2026-07-29  
Validation: `scripts/ai_play_round90_check.gd`

## Coverage

The commercial benchmark now keeps raw player-pressure counts as diagnostics
and separately counts avoidable pressure. A discard is avoidable only when a
fully evaluated alternative has the same shanten, reduces player pressure by
at least `max(8, 35%)`, and keeps score, ukeire, and tenpai wait quality within
the bounded loss budget.

The regression covers both sides of that contract: a low-loss same-shanten
safe alternative counts, while a shanten regression or material efficiency loss
does not. The commercial gate uses the avoidable high-pressure rate together
with actual deal-ins to the fixed player probe, so forced late-game decisions
cannot mask an actual defensive regression or falsely fail one.
