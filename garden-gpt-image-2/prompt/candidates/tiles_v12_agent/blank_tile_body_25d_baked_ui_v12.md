Generate one isolated blank mahjong tile body as a 2.5D baked game UI asset.

Subject:
- A single blank mahjong tile shell with no printed suit, no text, no symbols, no decorative pattern, no engraved marks.
- Portrait upright tile, rounded rectangle, proportion close to 5:7 so it can scale cleanly to 200x280.
- Clean milky white ceramic face with a very light jade-tinted side edge, restrained material detail, no busy texture.

Geometry and camera:
- Flat 2.5D pre-rendered UI angle, almost front-facing, slightly above the tile.
- Thinner and flatter than a physical tabletop mahjong block.
- Minimal side thickness, compact bevel, broad empty central plane designed for later programmatic glyph overlay.
- Stable icon-like silhouette, suitable for sprite extraction and atlas composition.

Lighting and rendering:
- Baked UI lighting, soft ambient occlusion in the inner rim and under the tile.
- Soft edge highlights, controlled contrast, no glossy glare over the central face.
- Looks like a polished game interface asset rather than a realistic product photograph.

Background:
- Use a flat solid chroma green background, exact key color #00ff00, filling the entire canvas behind the tile.
- Do not create a transparency checkerboard preview pattern. Do not use grey/white checks. Do not use black, dark vignette, scenery, table, floor, or gradient.
- Keep any shadow extremely soft and tight to the tile edge so the green background remains easy to key out.

Negative constraints:
- No characters, no Chinese text, no numbers, no suit marks, no red/green/blue printed markings.
- No table, no hand, no pile of tiles, no whole tile set.
- No heavy perspective, no thick 3D block, no complex texture, no cracks, no stains, no ornamental frame.
- Do not crop the tile. Leave small transparent margin around the full tile.
- No transparency checkerboard pattern; the background must be one continuous pure chroma green field.
