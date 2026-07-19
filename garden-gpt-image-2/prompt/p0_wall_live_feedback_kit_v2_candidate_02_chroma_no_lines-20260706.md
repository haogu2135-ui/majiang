# p0_wall_live_feedback_kit_v2_candidate_02_chroma_no_lines

- Output path: `garden-gpt-image-2/image/candidates/p0/wall_live_feedback_kit_v2_candidate_02_chroma_raw.png`
- Clean output path: `garden-gpt-image-2/image/candidates/p0/wall_live_feedback_kit_v2_candidate_02_clean.png`
- Size: `1536x512`
- Mode: A garden local generation, chroma-key source for true-alpha cleanup
- Source brief: `qa/agents/gpt_image_agent.md`
- Prior prompt: `garden-gpt-image-2/prompt/p0_wall_live_feedback_kit_v1.md`
- Candidate 01 rejection addressed: remove all element-between horizontal alpha residue, baseline strokes, connector lines, cast shadows, and glints outside isolated elements.
- Runtime rule: Godot renders all live numbers and state text; this sheet contains only empty materials and effects.

```text
Create a transparent-ready asset sheet for live wall-count feedback in a Chinese guofeng mahjong mobile game.

Output image:
- Exact canvas target: 1536x512 pixels, horizontal asset sheet.
- Render on a perfectly flat chroma-key background: pure solid #00ff00 outside every asset.
- Do not use transparency in the source image; the green background will be removed later.
- The #00ff00 background color must not appear inside any asset, glow, shadow, reflection, texture, or antialiasing fringe.
- No checkerboard pattern, no fake transparency pattern, no gradient background, no paper background, no white/gray matte.
- The background must remain completely flat and untouched: no shadows on it, no glints on it, no guide lines on it.

Asset sheet contents, all separated with very large padding and clear empty chroma space:
1. Four independent slim horizontal wall progress rails:
   - full state: mostly filled dark jade inset, black lacquer base, warm antique gold bevel.
   - mid state: about half filled muted jade inset, quiet black lacquer remainder.
   - low state: short muted jade/cinnabar warning fill, quiet black lacquer remainder.
   - critical state: very short restrained cinnabar fill, quiet black lacquer remainder.
   - Each rail is a self-contained capsule/object. No rail may cast a shadow, reflection, underline, baseline, or thin stroke outside its own silhouette.
2. Four independent empty count badge frames:
   - empty black-lacquer interiors, soft jade/gold frame, no text, no numbers, no icons.
   - centers are low-contrast safe areas for Godot-rendered realtime digits.
   - Each badge is isolated and has no exterior shadow/glow line.
3. Three independent short update pulse glows:
   - compact isolated horizontal glows in jade, warm gold, and restrained cinnabar.
   - each glow is short and local only; no long horizontal trails or guide lines.
   - no center symbol, no sparkle letters, no number-like marks.
4. Two independent low-wall warning corner accents:
   - small decorative guofeng corner brackets in restrained cinnabar/gold.
   - empty ornaments only, no icon and no readable mark.

Strict separation and cleanup rules:
- Every element must be visually independent, separated by large areas of pure #00ff00 chroma background.
- No connector lines.
- No baseline strokes.
- No cast shadows on the background.
- No drop shadows outside the object silhouette.
- No glints outside each individual element.
- No horizontal guide lines between elements.
- No thin horizontal strokes extending beyond an individual rail, badge, glow, or corner accent.
- No shared floor, shared reflection, shared underline, shared highlight, or continuous row separator.
- If an element has an internal highlight, it must stop inside that element's own border.

Composition:
- Arrange as a clean crop-friendly asset sheet, not a UI screenshot.
- Left column: four rails stacked vertically with larger vertical gaps than usual; keep clear chroma background between rails.
- Right upper area: four badge frames in a row with large horizontal gaps.
- Right lower area: three pulse glows and two warning corner accents, separated and easy to crop.
- Keep all elements away from canvas edges.
- Keep central interiors of rails and badges low-contrast, calm, and text-safe.

Style:
- Premium PBR guofeng mahjong UI material.
- Black lacquer, deep jade, muted teal, warm antique gold bevels, restrained cinnabar for low/critical states only.
- Tactile mobile game material, internal highlights, carved brocade microtexture.
- Unified light source and consistent bevel depth.

Functional constraints:
- Godot will draw realtime wall count numbers and any live labels.
- The image must contain no words, no numbers, no Chinese characters, no Latin letters, no logo, no watermark, no UI captions.
- No mahjong tile faces, no tile backs, no tile symbols, no suit marks, no honor characters, no blank tile rectangles.
- No icons, route lines, arrows, tick labels, progress text, button states, or baked "88" style count placeholders.

Avoid completely:
- horizontal residue lines between rails
- long underlines below rails
- white or light edge residue around assets
- checkerboard or fake transparent background
- gray/white matte, paper cutout outline, glow halo on the background
- neon sci-fi progress bars, digital signal dots, busy route ticks
- large decorative badges with text, readable stamps, random marks
```
