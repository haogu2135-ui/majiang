# AI / Gameplay Round 58 - Claim Kuikae Bans

Date: 2026-07-28  
Validation: `scripts/ai_play_round58_check.gd`

## Problem

After a chi or peng, players and AI could immediately discard the just-claimed
tile, and edge chows could also dump the opposite swap tile on the same beat.
Commercial local-rule tables treat that as 食替 and ban it; without the hard
rule, claim decisions and advice could recommend illegal tempo plays.

## Fix

- Track per-seat short-lived `offline_claim_discard_bans` after chi/peng.
- Ban the claimed tile always; for edge chow also ban the opposite-end swap tile.
- Gate `is_valid_offline_discard`, human discard feedback, hand clickability,
  and AI discard candidates through the same ban helper.
- Clear bans on successful discard, real draw, open-gang supplement, and new deal.
- Keep post-claim AI pressure evaluation aware of the same simulated bans.
- Align rules copy with full-wait furiten/pass and the new kuikae line.

## Resource Impact

Bans are a tiny per-seat dictionary. Candidate filtering is O(hand unique tiles)
and only active in the immediate post-claim discard window. No extra shanten
search, wall scan, or background work is added.

## Run

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round58_check.gd
```
