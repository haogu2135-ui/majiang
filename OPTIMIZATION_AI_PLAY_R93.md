# AI / Gameplay Round 93 - Avoidable All-Opponent Danger Telemetry

Date: 2026-08-18  
Validation: `scripts/ai_play_round93_check.gd`

## Coverage

Round 90 gated avoidable pressure against the fixed player probe. This round
holds the same contract for danger measured against all opponents, and proves
the telemetry itself rather than only its aggregate rate. Three fixtures drive
`_ai_sim_note_avoidable_danger_report` and `_ai_sim_avoidable_danger_report`
directly, so the classifier is tested without depending on a wall seed.

Forced danger stays diagnostic: when the only alternatives regress shanten or
give up material ukeire, neither the avoidable counter nor the actionable
high-danger counter moves. A same-shanten alternative that keeps score and
ukeire within budget and cuts combined risk and feed risk by a material margin
is classified as avoidable, is reported with the candidate tile and the pressure
gain that justified it, and increments each counter exactly once per selected
discard.

The third fixture connects the telemetry to the hard guard. A cheap, nearly dead
tenpai wait pushed into high risk is avoidable before `apply_hard_danger_push_guard`
runs; after the guard, the safer same-shanten candidate sits at the front of the
report list with an auditable moved marker, and the newly selected report no
longer carries avoidable danger. That ordering is what keeps the guard and the
telemetry from disagreeing about the same decision.

## Resource Impact

Fixture-driven with no hand simulation. Recorded elapsed time in the commercial
evidence log is about 14 seconds, dominated by scene load.
