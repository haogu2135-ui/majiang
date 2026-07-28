# AI / Gameplay Round 70 - Fast Human-Guard Top-K Pruning

Date: 2026-07-28  
Validation: `scripts/ai_play_round69_check.gd`

## Problem

R69 fixed the diagnostic fairness gap, but quiet all-bot fast evaluation still
ranked discard candidates mostly by overall deal-in risk. In high-pressure hands,
that can prune a candidate that is especially safer for seat0 before full scoring
gets a chance to consider it.

## Fix

- In quiet Top-K discard pruning, keep a lightweight seat0 guard signal in the
  cheap score whenever the active seat is hard difficulty or the table already
  shows enough player pressure.
- Reuse the cached feed-risk / human-pressure helpers instead of adding a new
  scan path, so the fast route stays serial and low-resource.
- Track a combined `fast_safety_rank` so the replacement logic keeps the
  discard that is safer for seat0, not just the one with the lowest overall risk.
- Tighten the R69 fair-probe check to require actual seat0 `humanRon` to be
  strictly no worse, not merely within tolerance.

## Result

- R69 fair-probe aggregate now reaches `humanRon` easy/hard `0.25/0.25`.
- Player-target high-danger easy/hard improves to `0.110/0.062` in the same
  fixed-probe run.
- The fixed-probe check still stays under the 90s budget; current runtime was
  `66098ms`.

## Resource Impact

No normal gameplay cost. The extra guard runs only in quiet all-bot fast
pruning, and it reuses the existing cached feed / pressure helpers.

## Run

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round69_check.gd
```

Both commands passed on 2026-07-28.
