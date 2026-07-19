# shop_charm_icon_set_v2_candidate_02_chroma

- Output chroma path: `garden-gpt-image-2/image/candidates/shop/shop_charm_icon_set_v2_candidate_02_chroma.png`
- Output clean path: `garden-gpt-image-2/image/candidates/shop/shop_charm_icon_set_v2_candidate_02_clean.png`
- Size: `1024x1024` asset sheet, four equal `512x512` cells.
- Background: pure chroma-key green `#00ff00`, to be removed locally into true alpha.
- Source brief: `qa/agents/gpt_image_agent.md`
- Prior attempt: `candidate_01` rejected because the generated image baked a gray checkerboard into opaque RGB pixels.

Prompt:

```text
Create a production-ready PNG asset sheet for a premium Chinese guofeng 3D Mahjong game shop UI.

Canvas and export:
- Exact 1024x1024 square canvas.
- 2x2 layout with four equal 512x512 cells.
- Each charm is centered in its cell with 42px safe padding on every side.
- The entire background outside the four charms must be a single perfectly flat pure chroma-key green color: #00ff00.
- Use #00ff00 only for the background. Do not use #00ff00 anywhere inside the charms, reflections, highlights, shadows, bevels, ornaments, jade, gold, lacquer, porcelain, tassels, coins, arrows, or any other foreground detail.
- Background must be flat solid #00ff00 only: no shadows on the background, no cast shadows touching the background, no gradient, no checkerboard, no texture, no floor, no reflection, no vignette, no haze, no decorative backing layer.
- No visible grid lines, no labels, no text, no numbers, no watermark, no logo.
- Keep foreground edges clean enough for chroma-key removal.

Game context:
- A dark jade, black lacquer, warm gold, porcelain and cinnabar guofeng Mahjong mobile game.
- The charms sit on shop item rows beside native Godot text and buttons.
- They must read as premium game items, not generic app icons.

Four charm concepts, left to right, top to bottom:
1. shop_charm_huan / swap card: jade-and-gold talisman with two curved exchange arrows around a small blank Mahjong tile silhouette. Theme: replace one tile. Palette: blue jade, pale porcelain, warm gold.
2. shop_charm_kan / peek card: carved violet jade eye lens over a sealed blank Mahjong tile, with a subtle fan-shaped reveal slit. Theme: inspect an opponent tile. Palette: violet jade, black lacquer, warm gold.
3. shop_charm_yun / lucky charm: lucky knot and cloud-shaped jade seal with a tiny clover-like motif abstracted into guofeng cloud curls. Theme: luck / fortune. Palette: green jade that is muted teal or pale jade, never #00ff00, plus cinnabar thread and warm gold.
4. shop_charm_bei / double coins: paired ancient round coins and a folded reward slip, with a subtle double-reward feeling expressed by two coins only, not by text. Theme: double coin reward. Palette: amber gold, black lacquer, muted jade, cinnabar tassel.

Style:
- Premium skeuomorphic 3D game UI asset.
- Carved jade, glazed porcelain, black lacquer backing, gold foil rim, soft bevels, crisp silhouette.
- Unified top-left warm key light.
- If a foreground contact shadow is needed, keep it entirely within the charm itself or as a dark foreground halo that does not tint the green background.
- Moderate contrast against a future dark green/black shop row after the green background is removed.
- Clean silhouettes readable at 72px to 96px height.
- Same material language, same camera angle, same scale for all four charms.

Composition:
- Each charm is a compact emblem with a rounded or seal-like silhouette, not a rectangular button.
- No decorative background card that fills the whole 512x512 cell.
- Make the four concepts distinct at a glance by silhouette and accent color.
- Do not crop any ornament or tassel at the cell edge.

Strict avoid:
- Any Chinese or English text, random letters, random numbers, labels, UI button text, fake price tags.
- Baked checkerboard background, white background, gray background, transparent preview pattern, textured background, floor plane, reflections on background.
- Any use of #00ff00 in the foreground charms.
- Generic flat vector icons, neon sci-fi HUD, modern app icon gradients, cartoon stickers.
- Readable Mahjong tile faces; only blank or abstract tile silhouettes.
- Overly thin lines that disappear at 72px.
```
