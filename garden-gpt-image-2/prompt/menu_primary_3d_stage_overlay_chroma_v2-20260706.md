# menu_primary_3d_stage_overlay chroma v2

- Output path after approval: `assets/illustrations/menu_primary_3d_stage_overlay.png`
- Candidate path: `garden-gpt-image-2/image/candidates/menu/menu_primary_3d_stage_overlay_chroma_v2_candidate_01.png`
- Target size: `1280x720`
- Mode: Mode A local Garden candidate generation
- Source brief: `qa/agents/gpt_image_agent.md`
- Runtime use: `draw_menu_primary_3d_stage()` under `MenuPrimary3DStageGPTOverlay`

```text
Create a production-ready chroma-key PNG foreground overlay for the main menu of a Chinese guofeng 3D mahjong mobile game, target composition 1280x720.

Important output format:
- Render the overlay elements on a perfectly flat pure chroma green background (#00FF00).
- The green background is only a removable keying color for post-processing.
- Do not use green or green spill in the artwork itself except the background.
- No checkerboard pattern, no gray fake transparency, no full-canvas dark rectangle.

Goal:
Create one coherent premium 3D foreground stage that sits between the generated moonlit lobby background and three Godot-rendered main menu cards. It should replace procedural card shadows, tabletop depth, and stage contact lighting.

Subject:
Black lacquer table depth, carved jade inlay, soft card cast shadows, warm gold rim light, subtle brocade contact zones, restrained guofeng ornament, commercial mobile-game material depth.

Composition and screen coordinates:
- Full 1280x720 canvas.
- Draw only the stage, table lip, contact shadows, and soft light under/behind three empty card slots.
- Main stage occupies roughly x=0.10-0.90 and y=0.31-0.82.
- Three empty card contact zones are centered around x=0.24, x=0.50, x=0.76 and y=0.55.
- Leave the upper-left title plaque area, quick-button band, and bottom footer clear as pure green background.
- Do not draw labels, icons, buttons, or card faces inside the three card safe zones.

Style:
High-end commercial 3D mobile game UI, PBR black lacquer, dark jade, carved warm gold trim, restrained guofeng ornament, cinematic moonlight plus lantern rim light, soft ambient occlusion, realistic material depth.

Hard constraints:
- No text, no numbers, no logo, no watermark.
- No people, no readable mahjong tile faces, no dice.
- No buttons, no arrows, no route lines, no dots, no ticks, no technical HUD marks.
- No flat web cards, no sci-fi HUD, no casino style, no bright neon glow.
```
