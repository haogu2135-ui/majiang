# Commercial Jiangnan Wave 4 Flagship UI Bitmaps · 2026-11-25

Generated with the bundled `imagegen` skill CLI (`image_gen.py`), model `gpt-image-2`, quality `high`, through the repository's configured `.gateway.env` endpoint (credentials not recorded). Zero programmatic texture painting, zero edits to `assets/tiles/`, version remains `1.0.180`. Post-processing limited strictly to chroma-key/white-paper background cleanup (`remove_chroma_key.py` / ink-on-white matte extraction), 4-way quadrant mirroring on `menu_hero_frame_gold_gpt.png` for exact corner symmetry, tight alpha bounding-box crop, and Lanczos resize/padding to target dimensions.

Prompts, raw API outputs, and cleaned candidates are retained under `build/qa/art_candidates_wave4_20261125/`; compressed review JPEGs and receipts are under `build/qa/ui_review/art_wave4_20261125/`. Visually audited and approved **14/14 GO** by `ui-auditor` (`#346`, `#357`, `#366`).

| Asset (`assets/illustrations/`) | Size / Mode | SHA-256 | Usage & Notes |
| --- | --- | --- | --- |
| `icon_dock_rules_gpt.png` | `256×256` RGBA | `42a6b48d5b39ed21d25dc62298a9a4962d30ac24283b7bef408220b856856adb` | ART-W4-01: Open Song imperial brocade book cutout (24–44px on dark jade dock) |
| `icon_dock_stats_gpt.png` | `256×256` RGBA | `a61d80c4a73c6651ce4db8560764584275a0c479e9ece2dbf3da107a13c0376a` | ART-W4-01: Two-handled gilded-bronze/celadon trophy chalice cutout |
| `icon_dock_achievements_gpt.png` | `256×256` RGBA | `fcbf71863e49e2f8efa6a72ea76fd1a5317a45eb78347f81e910a8378631cc42` | ART-W4-01: Carved celadon jade medallion + gold loop cutout |
| `icon_dock_daily_gpt.png` | `256×256` RGBA | `d53edde4b9f38e1bac5f2bda50ecde5e169b380d7d6ea3514444466d0263f386` | ART-W4-01: Jiangnan hanging calendar + vermilion seal dot cutout (no text/dates) |
| `icon_dock_replay_gpt.png` | `256×256` RGBA | `4d76250bb67b2d18728d62a33a74b1ff35d25066fd7778416198a1bf3719b62e` | ART-W4-01: Unfurled scroll + emerald clockwise replay arrow cutout |
| `table_compass_plate_gpt.png` | `512×512` RGBA | `7c3d932d79f7c33737474f8c85e37fb891a0821d77bae329aced47c500090e3b` | ART-W4-02: Song bronze-jade chamfered compass bezel + quiet dark well (CR>=14:1) |
| `hand_rail_rosewood_gpt.png` | `1024×256` RGBA | `f9c9b40c9c2e841a6c59a4186ca52e543fe66c7f1ab59f90ba8ec40342a70ec0` | ART-W4-03: Carved dark rosewood tile rail 9-slice (`margin=56, scale=0.25`) |
| `table_log_dark_jade_gpt.png` | `1024×256` RGBA | `86b108d961b012d2f4e0d0946fce427eef21e39495d88ed08db774fb02d586ed` | ART-W4-03: Deep forest-jade silk ledger strip 9-slice (`margin=48..56, scale=0.25`) |
| `seal_cinnabar_cap_gpt.png` | `256×256` RGBA | `a70022538f45b0166c9191ac02bd7b04dedfed488a7ef28402465bc4bcc9ba47` | ART-W4-04: Carved vermilion lacquer `封顶` ivory `白文印` stamp (28–44px) |
| `seal_cinnabar_done_gpt.png` | `256×256` RGBA | `043f985f1f1450d7d52093e471e5beedaee62be188c7bf3676ad101326dff5b2` | ART-W4-04: Carved vermilion lacquer `达` ivory `白文印` stamp (24–44px) |
| `seal_cinnabar_claimed_gpt.png` | `256×256` RGBA | `ab1d552a88c8f3479dbd8ddf9a3f9a09baa5b2cb0944600550c15a5a4cdb70f3` | ART-W4-04: Carved vermilion lacquer `已签` ivory `白文印` stamp (28–44px) |
| `menu_hero_frame_gold_gpt.png` | `1024×512` RGBA | `80c71cbe63849c1e8ce36e21c17bbd65bf156dc27cc431b41612929ddf6fbdaa` | ART-W4-05: 4-way symmetric hollow gilded Song `委角` frame (`draw_center=false, margin=88, scale=0.25`) |
| `empty_parlor_ink_gpt.png` | `512×384` RGBA | `6cfe6a09bc781c921a863056ff714beee54b48923fc31718819777c15ec16966` | ART-W4-06: Song ink-wash lakeside tea parlor vignette (0% alpha edges) |
| `empty_scroll_ink_gpt.png` | `512×384` RGBA | `95ca3f6fdd9e6a6a4cb14418076ad5fe134af258e994da2deb566ecccb94b3c8` | ART-W4-06: Song ink-wash blank scroll & bamboo brush vignette (0% alpha edges) |
