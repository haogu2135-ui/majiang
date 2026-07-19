Generate one isolated blank mahjong tile body for a game asset pipeline.

Subject:
- A single blank mahjong tile shell with no printed suit, no text, no symbols, no decorative pattern, no engraved characters.
- Front face is nearly orthographic, upright portrait orientation, gently rounded rectangle, proportion close to 5:7 for later 200x280 scaling.
- The tile should feel like pale ivory mixed with white jade: warm off-white face, faint translucent jade depth near the bevel, subtle subsurface glow, clean polished ceramic-jade material.

Geometry and camera:
- Near-front orthographic camera, only a very slight top and side reveal.
- Thin visible side edge, not a thick block, not dramatic perspective.
- Shallow-relief construction: raised outer rim and softly recessed central face, low bevels, smooth radius corners.
- The center face must remain broad, blank, readable, and flat enough for programmatic glyph compositing.

Lighting and rendering:
- Soft studio light from upper left, gentle contact shadow, delicate ambient occlusion around rim and bottom edge.
- Crisp asset silhouette with smooth alpha-friendly edges.
- High quality pre-rendered 3D/PBR look, clean and practical for a game UI tile.

Background:
- Use a flat solid chroma green background, exact key color #00ff00, filling the entire canvas behind the tile.
- Do not create a transparency checkerboard preview pattern. Do not use grey/white checks. Do not use black, dark vignette, scenery, table, floor, or gradient.
- Keep any shadow extremely soft and tight to the tile edge so the green background remains easy to key out.

Negative constraints:
- No characters, no Chinese text, no numbers, no suit marks, no red/green/blue printed markings.
- No table, no hand, no pile of tiles, no whole tile set.
- No heavy perspective, no thick side wall, no dramatic shadow, no complex marble veins, no scratches, no grime, no ornate border.
- Do not crop the tile. Leave small transparent margin around the full tile.
- No transparency checkerboard pattern; the background must be one continuous pure chroma green field.
