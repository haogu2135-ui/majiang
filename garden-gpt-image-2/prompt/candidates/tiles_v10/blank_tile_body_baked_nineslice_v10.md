Use case: productivity-visual
Asset type: deterministic reusable game bitmap recipe, blank Chinese mahjong tile body only, intended for overlaying existing 2D tile symbols in Godot
Primary request: Produce a reusable baked-lighting nine-slice / nine-grid blank mahjong tile body design, not a full tile face.

Design recipe:
- Output target size: 200x280 RGBA PNG for immediate preview.
- Geometry: rounded rectangle tile, 5:7 proportion, 13 px corner radius at 200x280.
- Nine-slice guides: fixed 24 px corners, scalable center from x=24..176 and y=24..256.
- Face field: warm ivory center, nearly flat, with very subtle vertical satin gradient.
- Rim: 1 px cool dark edge, 2-3 px warm bevel highlight at top-left, 2 px lower-right ambient shade.
- Side lip: only right and bottom side shading, visually 1-2 px at final size.
- Shadow: optional separate soft drop shadow layer or baked 4 px alpha shadow directly under/right of tile.
- Texture: procedural noise under 2% opacity, no visible pattern, no symbols.

Why this exists:
- If generative output drifts into cheap 3D or inconsistent perspective, this candidate stays reusable.
- The nine-slice approach lets the tile body scale without warping corners or changing center brightness.
- Existing 2D symbols can be composited on top with multiply/normal layers because the center stays quiet.

Constraints:
- No mahjong suit symbols, Chinese characters, numbers, flowers, dots, bamboo, labels, logo, watermark, ornate frame, or decorative motif.
- Avoid perspective, thick 3D side faces, heavy specular highlights, strong shadows, busy marble, noisy paper texture.
- Prefer deterministic reusable lighting over photorealism.
