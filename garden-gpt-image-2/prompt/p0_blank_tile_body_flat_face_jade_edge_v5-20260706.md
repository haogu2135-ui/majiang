Create one isolated blank Chinese mahjong tile body as a production game sprite source.

Output intent:
- A single front-facing blank tile body only.
- The final game asset will be downsampled to 200x280 px.
- Existing in-game tile symbols will be composited later by code.

Camera and silhouette:
- Orthographic front view.
- Perfectly centered upright portrait tile, no rotation, no tilt, no perspective, no isometric angle.
- Rounded rectangle silhouette, thin refined physical depth.
- The tile fills about 86% of the canvas height with even padding.

Face requirements:
- The front face must be almost completely flat, plain, and uninterrupted.
- Warm ivory porcelain / bone-white face.
- No inner inset panel, no recessed rectangle, no carved frame, no raised border, no etched lines.
- No markings, no Chinese characters, no numbers, no dots, no bamboo, no flowers, no icons.
- Keep the center low-contrast and clean so dark red and green symbols can be composited later.

3D treatment:
- Very subtle 3D only: a shallow outer bevel, a narrow right edge, and a narrow lower edge.
- Right and lower edges should be muted dark jade / blue-green jade, visible as a thin side material.
- Avoid gold, brass, brown, tan, metallic trim, black outline, thick extrusion, chunky toy-like depth.
- Soft top-left studio light, minimal ambient occlusion inside the tile silhouette only.
- No cast shadow outside the tile, no floor, no table, no reflection, no glow.

Background for alpha extraction:
- Use one perfectly uniform solid chroma key green background, exactly #00FF00.
- The green background must have no shadows, gradients, texture, vignette, floor plane, or lighting variation.
- Do not use green anywhere on the tile face or side except the muted jade side edge.
- Keep the tile edge crisp and fully separated from the background.

Style:
- Clean premium mobile board-game sprite, restrained realistic 3D material.
- It should feel lighter, thinner, and cleaner than a cinematic product render.
- No watermark, no labels, no extra objects.

Reject conditions:
- Reject if there is any inner frame or face inset.
- Reject if there are any symbols or text.
- Reject if the side edge is gold, brown, metallic, or too thick.
- Reject if the background is not flat pure green.
