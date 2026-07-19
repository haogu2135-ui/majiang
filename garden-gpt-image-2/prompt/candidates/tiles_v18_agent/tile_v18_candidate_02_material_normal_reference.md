Create a material and normal-reference style blank mahjong tile face for a game asset pipeline.

Subject:
- A single square-ish rounded-rectangle blank tile body.
- Front face only, centered, isolated.
- No printed symbols, no text, no pips, no suit icons, no decorative lines.

Geometry:
- Almost flat face, like a thin UI asset rather than a thick 3D object.
- Subtle front bevel only, about 1-2 percent of the tile width.
- The bevel is visible through a narrow top highlight and a very soft edge gradient.
- No visible side wall and no perspective depth.
- Orthographic, aligned straight to the viewer.

Material:
- Ivory-jade ceramic or resin surface.
- Smooth satin finish, slight subsurface jade warmth, not glassy, not metallic.
- Gentle top rim highlight and barely visible lower rim shading to imply form.
- The center face should stay clean and mostly flat for later symbol overlay.

Lighting and background:
- Neutral asset lighting, no environment.
- Pure white background only.
- Do not draw a transparency checkerboard; no gray-and-white grid pattern.
- No cast shadow, no drop shadow, no floor, no vignette.
- No checkerboard background.

Output intent:
- This should read as a normal/material reference for a tile sprite: subtle bevel, clean silhouette, usable under 64 px.
- Keep contrast low and elegant; avoid dramatic 3D.

Strict negatives:
- No thick extrusion, no chunky block, no side face, no isometric angle, no perspective skew.
- No baked shadows, no contact shadows, no table surface.
- No symbols, labels, text, ornaments, cracks, dirt, texture noise, or border decoration.
- No transparency checker pattern.
