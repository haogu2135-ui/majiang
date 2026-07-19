Use case: product-mockup
Asset type: production-ready game bitmap asset, blank Chinese mahjong tile body only, intended for overlaying existing 2D tile symbols in Godot
Primary request: Generate one isolated blank Chinese mahjong tile body / tile base, no printed symbols, no engraving in the center, no text, no logo.

Visual direction:
- Orthographic low-relief white jade / warm porcelain tile blank.
- Almost perfectly front-facing, only a 1-2 px visible right/bottom side lip when scaled down to 200x280.
- Premium understated material, not toy-like, not cheap glossy 3D.
- Smooth warm ivory face with extremely subtle cloudy jade depth; center must stay clean and low-contrast for later symbol overlay.
- Rounded rectangle proportions close to 5:7, gently rounded corners, thin beveled rim, shallow inner face depression.
- The form should read as a refined physical tile body but stay flat enough for UI layering.

Scene/backdrop:
- Perfectly flat solid #00ff00 chroma-key background for removal.
- No floor plane, no environment, no vignette, no background gradient.

Composition/framing:
- Single tile centered, generous padding, full tile visible, vertical portrait canvas.
- Camera is orthographic, directly in front, no rotation, no perspective tilt.
- Tile occupies about 82-88% of image height.

Lighting/mood:
- Large soft studio light from upper-left, very soft fill from front.
- Micro ambient occlusion inside the beveled rim only.
- No dramatic cast shadow; if any contact shadow appears, keep it extremely subtle and contained directly under the tile.

Materials/textures:
- Warm white jade and porcelain hybrid, satin finish, faint translucency, restrained edge highlight.
- Edge can have a tiny cool jade-green tint, but the main face must remain warm off-white.
- No cracks, no dirty stains, no speckles that will conflict with overlaid symbols.

Constraints:
- Must be a blank base only; absolutely no mahjong suit symbols, Chinese characters, numbers, flowers, dots, bamboo, red/green marks, labels, text, watermark, signature, or decorative pattern in the center.
- Must not look like a thick 3D block, plastic toy, casino chip, soap bar, app icon, button, card, or fantasy artifact.
- Avoid strong perspective, large side wall, hard black outline, heavy shadow, shiny plastic reflections, busy marble veining, embossed motifs, ornate borders, cropped corners.
- Use a uniform chroma-key background: do not use #00ff00 inside the tile.
