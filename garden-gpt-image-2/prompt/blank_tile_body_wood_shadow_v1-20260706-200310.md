# blank_tile_body_wood_shadow_v1

- Output target if generated: `garden-gpt-image-2/image/candidates/blank_tile_body_wood_shadow_v1-20260706-200310.png`
- Final game target after approval: `assets/tiles_3d/_tile_face_3d_body.png`
- Suggested generation size: `1024x1440`
- Mode: C advisor prompt for GPT Image 2; no PNG generated in this run because Garden Mode A is not enabled.
- Source brief: `qa/agents/gpt_image_agent.md`

```text
Use case: product-mockup
Asset type: production mobile game sprite component, blank Chinese mahjong tile body only
Primary request: Create one isolated blank Chinese mahjong tile body focused on material and lighting. Do not draw any playable tile symbols; assets/tiles/*.png will provide markings later.

Subject:
- A single blank Chinese mahjong tile shell, portrait 5:7 sprite proportion.
- Warm ivory jade / bone-porcelain front face, smooth and empty.
- Soft rounded rectangle silhouette, shallow bevel, slim but believable thickness.
- A faint natural underside warmth as if lit near a dark guofeng wood table, but no visible table object.
- No ornate rim, no gold line, no face decoration.

Composition/framing:
- Centered orthographic render, almost front-on, with a subtle 5 degree top-down view.
- The front face must remain clean, bright, and geometrically stable for symbol compositing.
- Tile fills 84-88% of image height.
- Leave at least 76% of tile height as a plain uninterrupted central face.
- Keep enough margin for later cutout and downscaling to 200x280.

Lighting/mood:
- Soft upper-left studio key light with a restrained warm wood-toned bounce under the bottom edge.
- The tile has gentle depth from bevel shadows and ambient occlusion, not from a heavy cast shadow.
- Premium guofeng board-game material: quiet, tactile, polished, not photoreal clutter.

Color palette:
- Ivory white, pearl gray bevel shadows, very subtle warm brown bounce on the underside only.
- No saturated green face tint, no gold border, no black outline.

Scene/backdrop:
- Pure solid warm off-white background: #F7F3EA.
- Background must be flat and removable: no texture, no visible table grain, no props, no other tiles, no vignette.
- If a shadow appears, it must be extremely soft, close to the tile, and not cross the central face.

Constraints:
- Blank tile body only; no face symbols, no index marks, no random glyphs.
- No Chinese characters, no Arabic numbers, no dots, no bamboo, no flowers, no tile back pattern.
- No text, logo, watermark, signature, engraved marks, cracks, scratches, dirt, inner border, decorative frame, or ornamental relief.
- Avoid dramatic product photography, strong perspective, thick extrusion, heavy shadow, plastic glare, noisy texture, or antique worn edges.
```
