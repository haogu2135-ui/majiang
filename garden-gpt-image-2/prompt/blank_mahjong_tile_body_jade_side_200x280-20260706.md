Create one production-ready blank Chinese mahjong tile body as a transparent-background PNG game sprite.

Output target:
- Single PNG sprite, 200x280 px final asset target, portrait orientation.
- True transparent alpha background.
- One isolated blank tile only.

Purpose:
- This is only the physical blank tile body for a Godot mahjong game.
- Tile symbols, Chinese characters, dots, bamboo, flowers, and other markings will be composited later by code.
- The generated image must contain no text, no symbols, no indexes, no decorative face art, and no markings of any kind.

Subject and camera:
- One upright front-facing Chinese mahjong tile body, centered.
- Orthographic front view, no rotation, no tilt, no isometric angle, no perspective skew.
- Rounded rectangle silhouette with restrained realistic 3D thickness.
- The tile fills 86-90% of the canvas height, with a small even transparent margin and no cropping.

Material:
- Smooth ivory-white / warm bone-porcelain front face.
- Subtle satin finish, not mirror glossy.
- Side material is restrained dark jade / ink green / blue-green jade, visible only as a narrow right edge and a narrow lower edge.
- No gold rim, no metallic trim, no brown border, no black outline.
- Slight bevel around the tile face, soft rounded corners, clean anti-aliased edges.

Lighting and shading:
- Soft top-left studio light.
- Gentle baked ambient occlusion along the lower lip and right side edge only.
- Very light edge highlights on the bevel.
- No cast shadow outside the tile silhouette.
- No floor shadow, no table shadow, no reflection, no glow, no vignette.

Face safe area:
- The central front face must be flat, bright, clean, and unobstructed.
- Leave at least 76% of the tile height as a plain compositing area.
- Do not add an inner frame, recessed panel, raised border, carved line, texture pattern, cracks, speckles, dirt, scratches, logos, watermarks, or face decoration.
- Keep the face low-contrast and uniform enough for later dark/red/green markings to read clearly.

Style:
- Polished mobile board-game asset.
- Restrained realistic 3D, clean and premium, not cinematic, not chunky, not toy-like.
- It should look like a refined modern mahjong tile shell suitable for deterministic 2D symbol compositing.

Strict negatives:
- No Chinese characters, no Arabic numbers, no dots, no bamboo, no flowers, no dragon/wind symbols, no tile back pattern.
- No gold rim, no metallic border, no thick side wall, no heavy extrusion, no decorative frame.
- No diagonal view, no dramatic perspective, no squeezed vertical shape.
- No checkerboard pattern, no green screen, no white/gray background, no visible background.
- No cast shadow outside the transparent tile, no table, no hand, no other tiles, no props.
- No excessive gloss, no plastic glare, no noisy texture, no dirt, no scratches.

Post-generation QA requirements:
- The PNG must have real alpha transparency outside the tile.
- The image should downsample cleanly to exactly 200x280 px.
- The center face should remain blank when inspected at 200x280.
- Reject the result if any symbol, text, inner frame, gold edge, thick wall, background, or external shadow appears.
