# Commercial Jiangnan 9-Slice UI Bitmaps · 2026-11-25

Generated with the bundled `imagegen` skill CLI (`image_gen.py`), model `gpt-image-2`, quality `high`, through the repository's configured `.gateway.env` endpoint (credentials not recorded). Zero programmatic texture painting, zero edits to `assets/tiles/`, version remains `1.0.180`. Post-processing limited strictly to chroma-key background removal (`remove_chroma_key.py`, for assets 3 and 4), tight alpha bounding-box crop, and Lanczos resize to target 9-slice dimensions.

Prompts, raw API outputs, and cleaned candidates are retained under `build/qa/art_candidates_20261125/`; compressed review JPEGs and receipts are under `build/qa/ui_review/art_20261125/`. Visually audited and approved 5/5 by `ui-auditor` (`#29`).

| Asset (`assets/illustrations/`) | Size / Mode | SHA-256 | Recommended 9-Slice |
| --- | --- | --- | --- |
| `button_face_danger_cinnabar_gpt.png` | `512×512` RGBA | `e6caf77c7eedb9388a71349611883fef053f761329b2f1c4bea43243c7fc84ac` | `margin=96..100, scale=0.12..0.125` (matches `button_face_jiangnan_gpt` `委角`) |
| `button_face_jiangnan_active_gpt.png` | `512×512` RGBA | `17f741128a5d9e51864aef3412130ee481bacbc21d32f2ba9e5d1f7881a2f14c` | `margin=96..100, scale=0.12..0.125` (matches `button_face_jiangnan_gpt` `委角`) |
| `guofeng_card_frame_gpt.png` | `1024×1024` RGBA | `765aebf2da77849e4ad34393e433e89ae8cbe3d4985f92e56724639c24a1d5dc` | `margin=104, scale=0.20..0.25` (corner brackets within `88×90`px) |
| `input_field_paper_normal_gpt.png` | `1024×256` RGBA | `ca4519f926ba3bc53368251a5a6e5024d18dbe450556932b5e78788639f5da55` | `margin=40, scale=0.25` |
| `input_field_paper_focus_gpt.png` | `1024×256` RGBA | `5824a399bd09382f6d36547e6621f885d0382c660496e510ffc85d3c7634b6e5` | `margin=40, scale=0.25` |
