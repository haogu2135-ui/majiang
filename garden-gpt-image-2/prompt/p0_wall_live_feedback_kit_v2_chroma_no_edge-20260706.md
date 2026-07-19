# p0_wall_live_feedback_kit_v2_chroma_no_edge

- Output path: `garden-gpt-image-2/image/candidates/p0/wall_live_feedback_kit_v2_candidate_01_chroma_raw.png`
- Clean output path: `garden-gpt-image-2/image/candidates/p0/wall_live_feedback_kit_v2_candidate_01_clean.png`
- Size: `1536x512`
- Mode: A garden local generation, chroma-key source for true-alpha cleanup
- Source brief: `qa/agents/gpt_image_agent.md`
- Replaces rejected cleanup candidate: `garden-gpt-image-2/image/candidates/p0/wall_live_feedback_kit_v1_candidate_01_clean.png`
- Runtime rule: Godot renders all live numbers and state text; this sheet contains only empty materials and effects.

```text
Create a transparent-ready asset sheet for live wall-count feedback in a Chinese guofeng mahjong mobile game.

Output image:
- Exact canvas target: 1536x512 pixels, horizontal asset sheet.
- Render on a perfectly flat chroma-key background: pure solid #ff00ff outside every asset.
- Do not use transparency in the source image; the magenta background will be removed later.
- The #ff00ff background color must not appear inside any asset, bevel, glow, shadow, reflection, texture, or antialiasing fringe.
- No checkerboard pattern, no fake transparency pattern, no gradient background, no paper background, no white/gray matte.
- No drop shadows, outer white glow, or light rim that falls onto the chroma background. Edges must be clean and darker than the background key.

Asset sheet contents, all separated with generous padding:
1. Four slim horizontal wall progress rails:
   - full state: mostly filled dark jade inset, black lacquer base, warm gold bevel.
   - mid state: about half filled muted jade inset, quiet black lacquer remainder.
   - low state: short muted jade/cinnabar warning fill, quiet black lacquer remainder.
   - critical state: very short restrained cinnabar fill, quiet black lacquer remainder.
2. Four empty count badge frames:
   - empty black-lacquer interiors, soft jade/gold frame, no text, no numbers, no icons.
   - centers are low-contrast safe areas for Godot-rendered realtime digits.
3. Three short update pulse glows:
   - compact horizontal soft glows in jade, warm gold, and restrained cinnabar.
   - no center symbol, no sparkle letters, no number-like marks.
4. Two low-wall warning corner accents:
   - small decorative guofeng corner brackets in restrained cinnabar/gold.
   - empty ornaments only, no icon and no readable mark.

Composition:
- Arrange as a clean asset sheet, not a UI screenshot.
- Left half: four rails stacked vertically with consistent width and height.
- Upper right: four badge frames in a row.
- Lower right: three pulse glows and two warning corner accents, separated and easy to crop.
- Every element must be isolated; no connected background panel.
- Keep central interiors of rails and badges low-contrast, calm, and text-safe.
- Keep all elements away from canvas edges so cleanup has clear chroma padding.

Style:
- Premium PBR guofeng mahjong UI material.
- Black lacquer, deep jade, muted teal, warm antique gold bevels, restrained cinnabar for low/critical states only.
- Tactile mobile game material, soft internal highlights, carved brocade microtexture.
- Unified light source and consistent bevel depth.

Functional constraints:
- Godot will draw realtime wall count numbers and any live labels.
- The image must contain no words, no numbers, no Chinese characters, no Latin letters, no logo, no watermark, no UI captions.
- No mahjong tile faces, no tile backs, no tile symbols, no suit marks, no honor characters, no blank tile rectangles.
- No icons, route lines, arrows, tick labels, progress text, button states, or baked "88" style count placeholders.

Avoid completely:
- visible white or light edge residue around assets
- checkerboard or fake transparent background
- gray/white matte, paper cutout outline, glow halo on the background
- neon sci-fi progress bars, digital signal dots, busy route ticks
- large decorative badges with text, readable stamps, random marks
```
