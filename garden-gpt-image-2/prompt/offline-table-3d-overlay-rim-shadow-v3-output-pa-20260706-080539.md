# offline_table_3d_overlay rim-shadow v3

- Output path after approval: `assets/illustrations/offline_table_3d_overlay.png`
- Candidate path: `garden-gpt-image-2/image/candidates/p0/offline_table_3d_overlay_rim_shadow_v3_candidate_01.png`
- Target size: `1280x720`
- Mode: Mode A local Garden candidate generation
- Source brief: `qa/agents/gpt_image_agent.md`
- Runtime use: `render_game()` under `OfflineTable3DOverlayTexture`

```text
Create a production-ready chroma-key PNG overlay for a Chinese guofeng 3D mahjong battle table UI, target composition 1280x720.

Important output format:
- Render sparse overlay elements on a perfectly flat pure chroma green background (#00FF00).
- The green background is only a removable keying color for post-processing.
- Do not use green or green spill in the artwork itself except the background.
- No checkerboard pattern, no fake transparency, no gray background, no full-canvas dark rectangle.

Critical composition rule:
- This is NOT a complete table image.
- Do NOT draw a full felt surface, full tabletop, full rectangular board, or any center panel.
- The central 70 percent of the canvas must remain pure green and empty so the existing Godot table backdrop stays visible.
- Draw only edge-local overlay elements: table rim highlights, corner depth, near-edge thickness, tiny gold inlay accents on the border, and soft contact shadows where walls and tiles sit.

Goal:
Create a lightweight foreground depth overlay that sits above the generated table backdrop and below engine-rendered mahjong tiles, labels, seats, walls, and HUD. It should enrich the table edges/corners without changing the readable center discard river.

Subject:
Sparse black-lacquer rail glints, carved jade corner caps, warm brushed-gold hairline inlay along the outer edge, subtle side-wall darkness, and soft low-alpha contact-shadow wisps near the four wall lanes.

Composition and screen coordinates:
- Full 1280x720 canvas.
- Top HUD band y=0.00-0.12 stays pure green.
- Center zone x=0.22-0.78 and y=0.22-0.72 stays pure green.
- Keep four broad wall lanes and discard river low contrast and mostly transparent.
- Place visual weight only at x=0.08-0.20 left edge, x=0.80-0.92 right edge, y=0.12-0.20 top edge, and y=0.72-0.86 near edge.
- Bottom hand tray band y=0.86-1.00 stays pure green except for very soft shadow fade at y=0.82-0.88.
- Side seat panel areas must remain pure green or nearly empty.

Style:
Commercial 3D mobile mahjong game, PBR black lacquer, dark jade, brushed gold inlay, restrained Chinese guofeng ornament, realistic soft contact shadows, cinematic but subtle table lighting.

Hard constraints:
- No text, no numbers, no logo, no watermark.
- No people, no readable mahjong tile faces, no dice.
- No buttons, no arrows, no route lines, no dots, no ticks, no technical HUD marks.
- No full felt surface, no full table surface, no center spotlight, no complete rectangular tabletop.
- No busy center patterns, no bright reflections under tile faces, no casino carpet, no neon grid, no flat 2D illustration.
```
