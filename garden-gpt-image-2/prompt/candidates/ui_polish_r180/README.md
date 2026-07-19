# UI polish r180 — GPT plates

## Goal
Replace green/program ColorRect chrome with warm guofeng GPT plates.

## Generated / promoted
- `ui_river_soft_wash.png` — warm ivory river/meld underlay (replaces green wash + title-backplate hack)
- `ui_meld_pad.png` — dark lacquer meld pad (dedicated gpt-image-2)
- Other plates (`ui_progress_signal_strip`, `ui_meter_rail_plate`, `ui_action_role_rail`, `ui_seat_info_plate`, `ui_hand_tray_state_chip`) registered; dedicated gens in progress under this folder.

## Wiring
- `scripts/main_base.gd` registry keys
- `scripts/main_src/render.gd.part`:
  - action button role rail → GPT plate
  - achievement toast route/fill/ticks → GPT signal/meter strips
  - meld group art → GPT pad + kind seal
  - meld lane → river wash + pad
  - seat panel → seat info plate under brocade
  - hand tray state → chip plate under badge

## API
- Sub2API group image gen enabled
- Upstream: abrdns `gpt-image-2` via direct base when Sub2API account cooldown hits
