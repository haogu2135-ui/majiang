# shop_charm_icon_set_v2

- Output targets:
  - `assets/illustrations/shop_charm_huan_v2.png`
  - `assets/illustrations/shop_charm_kan_v2.png`
  - `assets/illustrations/shop_charm_yun_v2.png`
  - `assets/illustrations/shop_charm_bei_v2.png`
- Current stable paths:
  - `assets/illustrations/shop_charm_huan.png`
  - `assets/illustrations/shop_charm_kan.png`
  - `assets/illustrations/shop_charm_yun.png`
  - `assets/illustrations/shop_charm_bei.png`
- Size: `1024x1024` asset sheet, four equal 512x512 cells, transparent PNG.
- Mode: B/C prompt handoff for GPT Image 2. Current check-mode result is `B-or-C`; Garden generation is not enabled.
- Source brief: `qa/agents/gpt_image_agent.md`
- UI target: shop item rows in `_show_shop_screen_impl()` and `draw_shop_item_row_art()`.

Prompt:

```text
Create a production-ready transparent PNG asset sheet for a premium Chinese guofeng 3D Mahjong game shop UI.

Canvas and export:
- 1024x1024 transparent PNG.
- 2x2 grid of four isolated item charm emblems.
- Each cell is exactly 512x512, centered, with 42px safe padding on every side.
- No visible grid lines, no labels, no text, no numbers, no watermark, no logo.
- Each charm must work when cropped into its own 512x512 transparent PNG and displayed at 72px to 96px height inside a dark jade/gold shop row.

Game context:
- A dark jade, black lacquer, warm gold, porcelain and cinnabar guofeng Mahjong mobile game.
- The charms sit on shop item rows beside native Godot text and buttons.
- They must read as premium game items, not generic app icons.

Four charm concepts, left to right, top to bottom:
1. `shop_charm_huan` / swap card: jade-and-gold talisman with two curved exchange arrows around a small Mahjong tile silhouette. Theme: replace one tile. Palette: blue jade, pale porcelain, warm gold.
2. `shop_charm_kan` / peek card: carved jade eye lens over a sealed Mahjong tile, with a subtle fan-shaped reveal slit. Theme: inspect an opponent tile. Palette: violet jade, black lacquer, warm gold.
3. `shop_charm_yun` / lucky charm: lucky knot and cloud-shaped jade seal with a tiny clover-like motif abstracted into guofeng cloud curls. Theme: luck / fortune. Palette: green jade, cinnabar thread, warm gold.
4. `shop_charm_bei` / double coins: paired ancient round coins and a folded reward slip, with a subtle x2 feeling expressed by two coins only, not by text. Theme: double coin reward. Palette: amber gold, black lacquer, muted jade.

Style:
- Premium skeuomorphic 3D game UI asset.
- Carved jade, glazed porcelain, black lacquer backing, gold foil rim, soft bevels, contact shadows.
- Unified top-left warm key light and lower-right soft shadow.
- Moderate contrast against a dark green/black shop row.
- Clean silhouettes readable at small UI size.
- Same material language, same camera angle, same scale for all four charms.

Composition:
- Each charm is a compact emblem with a rounded or seal-like silhouette, not a rectangular button.
- Each emblem should have a subtle suspended shadow and transparent edge.
- Keep center strong, edge clean, no decorative background cards that fill the whole cell.
- Make the four concepts distinct at a glance by shape and accent color.

Strict avoid:
- Any Chinese or English text, random letters, random numbers, labels, UI button text, fake price tags.
- Baked checkerboard background, white/gray solid background, drop shadow clipped at cell edge.
- Generic flat vector icons, neon sci-fi HUD, modern app icon gradients, cartoon stickers.
- Readable Mahjong tile faces; only use abstract tile silhouettes if needed.
- Overly thin lines that disappear at 72px.
```

Acceptance:

- Crop each quadrant to 512x512 and save as the four target `_v2` PNGs first.
- Verify true alpha transparency and no checkerboard pixels.
- Compare at 96px against `build/qa/pages/07_shop.png`; each item must be identifiable without reading the name.
- Promote to stable `shop_charm_*.png` only after screenshot review passes.
