# AI / Gameplay Round 94 - Mandatory All-Opponent Danger Gate

Date: 2026-08-19  
Validation: `scripts/ai_play_round94_check.gd`

## Coverage

R93 made avoidable all-opponent danger measurable, but the final
`commercial_strength_ok` expressions did not consume the resulting
`hard_safer_avoidable_high_danger` flag. A benchmark could therefore report a
commercial PASS even when hard AI regressed beyond the declared tolerance.

The per-benchmark and aggregated strength gates now both require that flag.
The regression builds otherwise-green synthetic aggregate evidence and proves
that a nine-point hard-AI regression fails the commercial result, while the
documented inclusive eight-point tolerance still passes. This keeps the test
deterministic and verifies the gate itself rather than hoping a wall seed
happens to cross it.

## Resource Impact

Fixture-driven with no hand simulation. It loads one scene and finalizes two
small aggregate dictionaries, so it remains well inside the serial 180-second
Godot budget.
