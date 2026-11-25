# Commercial Jiangnan Wave 3 UI Bitmaps · 2026-11-25

Generated with the bundled `imagegen` skill CLI (`image_gen.py`), model `gpt-image-2`, quality `high`, through the repository's configured `.gateway.env` endpoint (credentials not recorded). Zero programmatic texture painting, zero edits to `assets/tiles/`, version remains `1.0.180`. Post-processing limited strictly to chroma-key background removal (`remove_chroma_key.py`, for assets 1, 2, and 5), tight alpha bounding-box crop, and Lanczos resize/padding to target UI dimensions.

Prompts, raw API outputs, and cleaned candidates are retained under `build/qa/art_candidates_wave3_20261125/`; compressed review JPEGs and receipts are under `build/qa/ui_review/art_wave3_20261125/`. Visually audited and approved 6/6 by `ui-auditor` (`#189`).

| Asset (`assets/illustrations/`) | Size / Mode | SHA-256 | Recommended Godot Usage |
| --- | --- | --- | --- |
| `table_tile_back_celadon_gpt.png` | `400×560` RGBA | `331909f15ae5abbc924c1e16f7f57e979b7ef5fa90e4a6ffef0fe1af786ab512` | `5:7` exact 2× match to `tile_back` (`200×280`); `STRETCH_KEEP_ASPECT_CENTERED`, mipmaps (`W3-17`) |
| `toast_scroll_banner_gpt.png` | `1024×256` RGBA | `b5b39cd3466f91c2895bc089b1dcb4ea2366903b269e4885b7dff094b345dbeb` | 9-slice `margin=56..64, scale=0.22..0.25`, bright ivory text `#FAF3E0` (`W3-08`/`W3-22`) |
| `focus_ring_gold_gpt.png` | `96×96` RGBA | `3d72c73e36df62cff6d14d296da6870622d95074b24ced355d3dc5d27bd4a74a` | Hollow center (`max_a=0`), 3.4px ink-gold-ink ring; native 1:1 `StyleBoxTexture` `texture_margin=10..12, draw_center=false` (`W3-13`) |
| `icon_coin_bronze_gpt.png` | `256×256` RGBA | `ad2ef6c9da237dde6e26a0df61631932589c8918579f85604dbcefc5ec4aedd7` | Transparent square-hole `方孔铜钱` icon sprite (`STRETCH_KEEP_ASPECT_CENTERED`, `18–32px`, `W3-25`) |
| `icon_jade_token_gpt.png` | `256×256` RGBA | `ff2beaf3c389760ef12475dc5883740b21a04ab8426b1adc0cae004390aa2765` | Carved hexagonal emerald-jade `玉符` icon sprite (`STRETCH_KEEP_ASPECT_CENTERED`, `18–32px`, `W3-25`) |
| `icon_mic_ink_gpt.png` | `256×256` RGBA | `1e08e71235e88bd8e2f5e4c5b09297d1943ff396ad343675d194a14b1c70d40c` | Deep ink-jade `#163427` mic glyph for `VoiceActionButton` (`icon_max_width=18`, `W3-21`) |
