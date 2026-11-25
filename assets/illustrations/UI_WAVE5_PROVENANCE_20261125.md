# Commercial Jiangnan Wave 5 Flagship UI Bitmaps · 2026-11-25

Generated with the bundled `imagegen` skill CLI (`image_gen.py`), model `gpt-image-2`, quality `high`, through the repository's configured `.gateway.env` endpoint (credentials not recorded). Zero programmatic texture painting, zero edits to `assets/tiles/`, version remains `1.0.180`. Post-processing limited strictly to chroma-key background removal (`remove_chroma_key.py`), 4-way quadrant mirroring on `daily_milestone_gold_frame_gpt.png` for exact corner symmetry, tight alpha bounding-box crop, and Lanczos resize/padding to target dimensions.

Prompts, raw API outputs, and cleaned candidates are retained under `build/qa/art_candidates_wave5_20261125/`; compressed review JPEGs and receipts are under `build/qa/ui_review/art_wave5_20261125/`. Visually audited and approved **5/5 GO** by `ui-auditor` (`#507`, `#509`), bringing total approved bespoke `gpt-image-2` UI assets across Waves 1–5 to **30/30**.

| Asset (`assets/illustrations/`) | Size / Mode | SHA-256 | Usage & Notes |
| --- | --- | --- | --- |
| `menu_hero_play_vignette_gpt.png` | `512×384` RGBA | `b4631902afa315add2852fa856cacf581fb934084472987254f07df220981e06` | ART-W5-01: Song luminous celadon-back + 三条/五筒 mahjong tiles & bamboo/gold mist vignette (`edgeMaxA=0`, Card 1 dark-jade backdrop) |
| `ui_meter_guofeng_rail_gpt.png` | `512×64` RGBA | `023ddf0043c367a9fb48a844ab895e9b86872c9393fb853c2d5ec01bb5defd42` | ART-W5-02: Carved bronze-jade recessed progress trough 9-slice (`margin_h>=44`, `margin_v=12..16`) |
| `ui_meter_guofeng_fill_jade_gpt.png` | `512×64` RGBA | `72fb65fb75bfce8fb03ed8df987c85062850a64f5651e906beac512cfa41374b` | ART-W5-02: Velvety Song celadon-jade mineral glaze fill bar 9-slice (`margin_h=24..28`, `margin_v=10..12`, `hStretchAvg=1.07`) |
| `ui_scrollbar_guofeng_thumb_gpt.png` | `64×256` RGBA | `3b642bf3f359b223bd8c15ab7e5c3d8b1599af2eafd2bd0167d3604aa21c2608` | ART-W5-03: Vertical beveled Song emerald-jade & antique-gold scrollbar thumb 9-slice (`margin_v=10..24`, `vStretchAvg=0.87`) |
| `daily_milestone_gold_frame_gpt.png` | `512×512` RGBA | `71aa0c04871b577991afda12a79eb8fc98c81013c2fec2d4517247072b70e632` | ART-W5-04: Hollow 4-way symmetric celebratory gold `委角`/`回纹`/cinnabar frame (`draw_center=false`, `symDiffs=0`, `margin=70..76`) |
