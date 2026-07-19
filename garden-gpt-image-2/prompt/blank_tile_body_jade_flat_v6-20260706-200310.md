# blank_tile_body_jade_flat_v6

- Output target if generated: `garden-gpt-image-2/image/candidates/blank_tile_body_jade_flat_v6-20260706-200310.png`
- Final game target after approval: `assets/tiles_3d/_tile_face_3d_body.png`
- Suggested generation size: `1024x1440`
- Mode: C advisor prompt for GPT Image 2; no PNG generated in this run because Garden Mode A is not enabled.
- Source brief: `qa/agents/gpt_image_agent.md`

```text
Use case: product-mockup
Asset type: production mobile game sprite component, blank Chinese mahjong tile body only
Primary request: Create one isolated blank Chinese mahjong tile body with no tile markings. Existing in-game tile symbols from assets/tiles/*.png will be composited later by code.

Subject:
- A single blank Chinese mahjong tile shell, portrait 5:7 sprite proportion.
- Refined ivory white jade / warm bone-porcelain front face, clean and flat.
- Rounded rectangle silhouette with soft corner radius and a subtle shallow bevel.
- Very slight physical thickness visible along the lower edge and right edge only.
- No metal border, no gold rim, no decorative frame.
- The center face is a smooth uninterrupted blank plane for deterministic symbol overlay.

Composition/framing:
- Orthographic product render, centered, no rotation, no diagonal angle.
- Camera is almost front-on with only a tiny 4 degree top-down feel, enough to show material depth without skewing the face.
- Tile fills 86-90% of image height with even safe padding.
- Preserve at least 76% of tile height as a plain central marking area.
- Keep edges crisp and anti-aliased for downscaling to 200x280.

Lighting/mood:
- Soft studio light from upper left, gentle fill from front.
- Restrained edge highlights, subtle ambient occlusion under the bottom lip.
- Polished but quiet premium board-game UI material.

Color palette:
- Warm ivory face, faint pearl-gray bevel shadows, very subtle jade undertone in side shading.
- No saturated colors on the face.

Scene/backdrop:
- Perfectly flat solid chroma key green background: #00FF00.
- Background must have no shadow, reflection, texture, gradient, checkerboard, vignette, or floor plane.
- Do not use #00FF00 anywhere in the tile body.

Constraints:
- The generated image must contain only the blank tile body.
- No Chinese characters, no Arabic numbers, no dots, no bamboo, no flower art, no tile back pattern.
- No text, logo, watermark, signature, index marks, carved marks, cracks, scratches, dirt, decorative line art, or random symbols.
- Do not add a border around the central face.
- Avoid thick extrusion, heavy 3D product-render perspective, black outline, excessive gloss, noisy texture, or a plastic toy look.
```
