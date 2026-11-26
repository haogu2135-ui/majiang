# Commercial Jiangnan Wave 6 Flagship UI Bitmaps · 2026-11-26

Generated with the bundled `imagegen` skill CLI (`image_gen.py`), model `gpt-image-2`, quality `high`, through the repository's configured `.gateway.env` endpoint (credentials not recorded). Zero programmatic texture painting, zero edits to `assets/tiles/`, version remains `1.0.180`. Post-processing limited strictly to chroma-key background removal (`remove_chroma_key.py`), 4-way quadrant mirroring for exact `委角` corner symmetry (`symDiffs=0`), tight alpha bounding-box crop, and Lanczos resize to target 9-slice dimensions.

Prompts, raw API outputs, and cleaned candidates are retained under `build/qa/art_candidates_wave6_20261126/`; compressed review JPEGs and receipts are under `build/qa/ui_review/art_wave6_20261126/`. Visually audited and approved **3/3 FIRST-TRY GO** by `ui-auditor` (`#648`, `#649`), bringing total approved bespoke `gpt-image-2` UI assets across Waves 1–6 to **33/33**.

| Asset (`assets/illustrations/`) | Size / Mode | SHA-256 | Usage & Notes |
| --- | --- | --- | --- |
| `chat_bubble_guofeng_gpt.png` | `512×128` RGBA | `b512871d7e9e821cfd2b35ca02a200572ffc2f3659ac7b59a3d8b06b47e4324c` | ART-W6-01: Chamfered Song silk-ivory Xuan-paper speech plaque w/ celadon hairline & gold corner ticks (`CR_ink=14.29:1`, `margin=24..28`) |
| `yaku_chip_plaque_gpt.png` | `512×128` RGBA | `258fc541098f822dcfaeaeb0bdec88f1f313179137eaac15bed74ac95bcfb2a2` | ART-W6-02: Chamfered warm champagne-gold Song silk weave fan-tag plaque w/ bronze-gold rim (`CR_ink=11.89:1`, `margin=28..32`) |
| `battle_dock_lacquer_gpt.png` | `1024×256` RGBA | `0e4a8699062650e8ef5a399bd834abeea43ea25a0f5a5c77ef07518c3197ec2d` | ART-W6-03: Carved deep Song-jade lacquer battle dock tray w/ antique-gold rim & `回纹` corners (`CR_iv=13.13:1`, `margin>=60, scale=0.22..0.25`) |
