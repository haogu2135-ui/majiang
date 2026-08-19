# AI / Gameplay Round 92 - Catastrophic Thin-Tenpai Guard

Date: 2026-08-17  
Validation: `scripts/ai_play_round92_check.gd`

## Coverage

Round 90 made player pressure actionable in aggregate. This round pins the worst
individual case: a tenpai hand whose wait is both cheap and nearly dead, being
pushed into high risk and high feed risk at once. Folding costs little there, so
the hard difficulty must not push.

The check replays one deterministic all-bot hard hand with discard tracing on
and classifies every step from the trace. A catastrophic thin-tenpai case is
shanten at or below zero, risk at least `AI_DANGER_RISK_HIGH + 22`, feed risk at
least `AI_DANGER_FEED_SOFT + 32`, a best wait worth no more than two fan, and at
most four live tiles remaining on that wait.

The seed must expose at least one such case, so the guard cannot pass by never
being reached, and every exposed case must carry either the catastrophe marker
or the moved marker from the hard guard. Uncovered steps are printed with seat,
tile, risk, feed, shanten, and wait detail, so a regression names the decision
that slipped through instead of only failing a count.

## Resource Impact

One traced hand with a 700-step cap, at quiet Top-K limits. Recorded elapsed
time in the commercial evidence log is about 29 seconds, well inside the serial
180-second budget.
