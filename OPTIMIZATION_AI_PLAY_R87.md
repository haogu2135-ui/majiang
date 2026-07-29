# AI / Gameplay Round 87 - Guard Pure-Suit Route Weight

Date: 2026-07-29  
Validation: `scripts/ai_play_round87_check.gd`

## Coverage

The pure-suit hand-plan score uses one 72-point exclusivity bonus once eight
same-suit tiles are present with no off-suit tiles. A focused regression now
pins that value and checks the adjacent near-pure route still ranks lower.

## Resource Impact

The check runs only in headless QA. It changes no player-facing runtime work,
allocations, searches, or caches.

## Run

```bash
python3 tools/assemble_main.py --verify
timeout --foreground --signal=TERM --kill-after=15s 180s \
  env GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 \
  nice -n 10 ionice -c 2 -n 7 \
  godot --headless --path . -s scripts/ai_play_round87_check.gd
```
