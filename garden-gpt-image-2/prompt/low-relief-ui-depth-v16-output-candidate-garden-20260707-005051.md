# low_relief_ui_depth_v16

- Output candidate: `garden-gpt-image-2/image/candidates/tiles_v16_agent/low_relief_ui_depth_v16_raw.png`
- Size: `1024x1536`
- Mode: GPT Image 2 candidate for deterministic tile compositing
- Source brief: `qa/agents/gpt_image_agent.md`

```text
Generate one blank 3D mahjong tile body candidate for a deterministic game UI compositing pipeline.

Subject:
A single blank Chinese mahjong tile body only, centered in a vertical portrait canvas. The tile is a 5:7 rounded rectangle, near-orthographic front view, very shallow 2.5D relief depth. It should read as a polished UI sprite base for a mahjong game, not a realistic tabletop photo and not a thick physical block.

Geometry:
- One continuous smooth front face with rounded outer corners.
- The center face must be completely flat, empty, uninterrupted, and safe for later programmatic symbol overlay.
- Subtle volume only on the outer silhouette, lower edge, and right edge.
- A thin low-relief body, with only 2-4 px perceived side thickness after downscaling to 200x280.
- Slightly flatter top face than a product render, more like a baked normal/depth UI asset.
- No inner frame, no recessed center, no groove, no decorative border, no bevel stripe.

Material and lighting:
- Warm ivory porcelain mixed with soft white jade ceramic.
- Satin smooth surface, clean and premium, no visible dirt, speckles, pores, cracks, scratches, or noisy texture.
- Soft studio UI lighting from upper left.
- Very delicate highlight falloff and ambient occlusion near the lower/right contour.
- Keep the upper-left face bright and the lower-right contour gently shaded, but never use a black or dark outline.
- No strong cast shadow outside the tile.

Background:
- Pure chroma-key green background exactly #00ff00.
- The background must be perfectly flat, uniform, untextured, and unlit.
- No gradient, no vignette, no checkerboard transparency, no floor, no table, no reflection, no contact shadow.

Strict exclusions:
- No Chinese characters.
- No text of any language.
- No numbers.
- No dots, circles, bamboo, wan/man symbols, flowers, dragons, winds, suits, labels, icons, logos, or printed markings.
- No decorative border pattern.
- No inner border, no inset line, no rim line, no top hairline.
- No black outline, no dark frame, no grime, no aged surface.
- No multiple tiles, no tile set, no hand, no tabletop scene.

Output:
A clean production-ready opaque PNG asset, full tile visible with small even margin, suitable for chroma-key extraction and downscaling to 200x280. The center must remain blank because the game will overlay authoritative mahjong symbols from existing source art.
```
