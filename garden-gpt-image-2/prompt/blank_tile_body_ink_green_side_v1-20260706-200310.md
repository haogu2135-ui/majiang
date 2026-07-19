# blank_tile_body_ink_green_side_v1

- Output target if generated: `garden-gpt-image-2/image/candidates/blank_tile_body_ink_green_side_v1-20260706-200310.png`
- Final game target after approval: `assets/tiles_3d/_tile_face_3d_body.png`
- Suggested generation size: `1024x1440`
- Mode: C advisor prompt for GPT Image 2; no PNG generated in this run because Garden Mode A is not enabled.
- Source brief: `qa/agents/gpt_image_agent.md`

```text
Use case: product-mockup
Asset type: production mobile game sprite component, blank Chinese mahjong tile body only
Primary request: Create one isolated blank Chinese mahjong tile body. It must be only the physical blank tile shell; all playable symbols will be composited later from assets/tiles/*.png.

Subject:
- A single blank Chinese mahjong tile, portrait 5:7 sprite proportion.
- Smooth warm ivory front face, plain and unmarked.
- Thin muted ink-green side material, visible only as a narrow side wall on the right and bottom edges.
- Rounded corners, shallow bevel, slim physical depth.
- The ink-green side should feel like lacquered bakelite or jade resin, not a painted border.
- No gold trim, no metallic detail, no ornamental frame.

Composition/framing:
- Orthographic view with a very mild top-left perspective hint, no dramatic isometric angle.
- Front face remains visually rectangular and suitable for deterministic 2D symbol overlay.
- Tile is centered and fills 84-88% of image height.
- Keep generous transparent-removal margin around the tile.
- Keep at least 74% of the tile height as a clean central blank area.

Lighting/mood:
- Upper-left softbox, soft rim on the ivory bevel, tiny shadow transition on the ink-green side.
- Game-ready 3D sprite polish: clean silhouette, readable depth at small size, no busy texture.

Color palette:
- Front face: warm white ivory with very slight jade translucency.
- Side edge: thin dark desaturated green, close to Chinese ink green.
- Shadow: pearl gray and deep green only; no brown, orange, gold, or neon.

Scene/backdrop:
- Perfectly flat solid chroma key green background: #00FF00.
- The background must be one uniform color with no lighting variation, no shadow, no floor, no reflection, no texture, and no checkerboard.
- Do not use #00FF00 in the tile itself.

Constraints:
- Absolutely no mahjong symbols or face markings of any kind.
- No Chinese characters, no Arabic numbers, no dots, no bamboo, no flowers, no tile back pattern.
- No decorative face border, no inner frame, no engraved lines, no logo, no watermark, no text.
- Avoid thick chunky side walls, dramatic perspective, hard black outline, plastic glare, random surface noise, scratches, dirt, or antique wear.
```
