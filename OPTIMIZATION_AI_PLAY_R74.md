# AI / Gameplay Round 74 - 144-Tile Ledger Integrity Gate

Date: 2026-07-28
Validation: `scripts/ai_play_round74_check.gd`

## Problem

The commercial AI benchmarks verified end-of-hand completion and decision
quality, but did not prove that a simulated hand retained all physical tiles
through draw, flower replacement, discard, calls, gang, and settlement. A
future state-transition regression could therefore lose or duplicate a tile
while still producing a finished benchmark hand.

## Fix

- Add `offline_tile_ledger_report`, which counts all 144 local tiles across the
  wall, concealed hands, rivers, exposed melds, and flower trays.
- Validate standard tiles against four copies and flowers against one copy;
  also reject malformed containers, unknown tile codes, and flower count drift.
- Attach the result to every quiet all-bot simulation and require ledger success
  in single-seed and aggregate commercial-strength gates.
- Add R74 regression coverage for a clean deal, intentional duplicate/unknown
  mutations, and easy/normal/hard paired bot hands.

## Resource Impact

The scan runs only once at the end of a quiet benchmark hand. It visits the
fixed 144-tile table and does not run in interactive gameplay or per-discard
AI evaluation.

## Result

- R74 passed: the clean deal reports `144/144`; deliberate duplicate and
  unknown-tile mutations are rejected; easy, normal, and hard seeded hands all
  completed with ledger integrity.
- R64 strength regression remained green: high-danger easy/hard `0.476/0.463`,
  deal-in `0.50/0.00`.
- R68 multi-seed evidence pack passed with `integrity=true` for the fixed and
  combined aggregates. Aggregate high-danger was `0.356/0.339` and deal-in was
  `0.75/0.375` (easy/hard), completing in `148587ms` under the serial budget.

## Run

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round74_check.gd
```
