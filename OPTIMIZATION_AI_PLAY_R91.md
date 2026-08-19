# AI / Gameplay Round 91 - Public-Information Added Gang

Date: 2026-08-11  
Validation: `scripts/ai_play_round91_check.gd`

## Coverage

The added-gang decision must be built from public information only, while real
gameplay still has to open a genuine chankan window. The regression separates
those two concerns on the same fixture.

Two states share an identical public board and differ only in the concealed
hand behind seat 0: one can actually rob the gang, the other cannot. The threat
report declares its public-information boundary, and risk score, rob-risk flag,
allow decision, and the added-gang selector are all invariant across the swap.
The report also refuses to name an exact concealed winner, so no seat, human, or
AI robber flag leaks from the hidden fixture.

Invariance alone would be satisfied by an AI that never reacts, so the second
case drives risk from public evidence instead: a late wall, three opponent
melds, and twelve discards push the same tile past the chankan risk gate, and
the AI declines the added gang. The third case declares the gang for real and
confirms the response window opens as a chankan with `hu` offered to the
actual concealed winner.

## Resource Impact

All three cases run on hand-built fixtures with no simulated hands, so the
check stays far inside the repository's serial 180-second Godot budget.
