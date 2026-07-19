# offline_table_3d_overlay chroma v2

- Output path after approval: `assets/illustrations/offline_table_3d_overlay.png`
- Candidate path: `garden-gpt-image-2/image/candidates/p0/offline_table_3d_overlay_chroma_v2_candidate_01.png`
- Target size: `1280x720`
- Mode: Mode A local Garden candidate generation
- Source brief: `qa/agents/gpt_image_agent.md`
- Runtime use: `render_game()` under `OfflineTable3DOverlayTexture`

```text
Create a production-ready chroma-key PNG foreground overlay for a Chinese guofeng 3D mahjong battle table UI, target composition 1280x720.

Important output format:
- Render the overlay elements on a perfectly flat pure chroma green background (#00FF00).
- The green background is only a removable keying color for post-processing.
- Do not use green or green spill in the artwork itself except the background.
- No checkerboard pattern, no gray fake transparency, no full-canvas dark rectangle.

Goal:
Create a full-screen foreground overlay that sits above the generated table backdrop and below engine-rendered mahjong tiles, labels, seats, walls, and HUD. It should replace procedural table rim lines, flat shadow blocks, and route/tick-like decoration with commercial 3D table depth.

Subject:
Realistic 3D table-depth overlay: black lacquer table rails, jade felt inset shadow, near-edge thickness, subtle side-wall darkness, center soft spotlight, brushed gold inlay, and soft contact-shadow zones where Godot-rendered mahjong tiles will sit.

Composition and screen coordinates:
- Full 1280x720 canvas.
- Draw only table depth, rim highlights, soft shadows, and low-contrast material lighting.
- Main playable table occupies roughly x=0.13-0.88 and y=0.14-0.80.
- Keep the center discard river and four wall lanes clean, readable, and low contrast.
- Top HUD band y=0.02-0.11 remains pure green background.
- Bottom hand tray y=0.80-0.99 receives only soft grounding shadow, not a hard frame.
- Side seat panel areas remain clean and readable.

Style:
Commercial 3D mobile mahjong game, PBR jade felt, black lacquer wood, brushed gold inlay, restrained guofeng ornament, realistic soft contact shadows, cinematic but subtle table lighting.

Hard constraints:
- No text, no numbers, no logo, no watermark.
- No people, no readable mahjong tile faces, no dice.
- No buttons, no arrows, no route lines, no dots, no ticks, no technical HUD marks.
- No busy center patterns, no bright reflections under tile faces, no casino carpet, no neon grid, no flat 2D illustration.
```
