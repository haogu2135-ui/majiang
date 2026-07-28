# AI / Gameplay Round 77 - Special-Hand Scoring Contract

Date: 2026-07-28
Validation: `scripts/ai_play_round77_check.gd`

## Problem

The product advertises local scoring support for several special hands, but
the existing automated suite primarily protected state transitions and only
spot-checked full straight scoring. A regression in a rare hand detector could
therefore reach players without a direct public scoring assertion.

## Contract Coverage

R77 uses legal fixed hand fixtures through the public
`calculate_win_score_from_tiles` boundary and verifies:

- Seven pairs and thirteen orphans.
- Pure one suit versus mixed one suit exclusion.
- All honors and all triplets.
- Big/small three dragons and big/small four winds, including hierarchy
  exclusion so big hands do not also score their small variants.
- All simples, all triplets, and four-open-meld big hanging hand.
- Flower bonus reason and exact additive fan count.

## Result

R77 passed all fixtures under a single low-priority headless Godot process.
It also corrects the test contract to use the game's canonical internal honor
codes: winds `E/S/N/R` and dragons `Z/F/P`.

## Boundary

This protects the implemented public contract. It is not an authoritative
external certification that the selected fan values and local-rule variants
match a specific Gaoyou rules document; that still requires a maintained,
authoritative acceptance matrix.

## Run

```bash
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round77_check.gd
```
