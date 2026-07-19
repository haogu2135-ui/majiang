Use the source image only as a technical reference for real transparent PNG behavior. Do not preserve its existing objects or layout. Replace the source with a new production-ready transparent PNG overlay for a Chinese guofeng 3D mahjong battle table UI.

Output requirement: RGBA-style transparent PNG, 1280x720 composition. Non-art areas must remain real transparent alpha, not black, not white, not checkerboard, not fake transparency.

Goal: a full-screen overlay that sits above the generated table backdrop and below engine-rendered mahjong tiles, labels, seats, and HUD. It must replace procedural table rim lines, fake route/tick decorations, and flat shadow blocks with commercial 3D table depth.

Subject: realistic 3D table depth overlay: black lacquer table rails, jade felt inset shadow, near-edge thickness, subtle side-wall darkness, center soft spotlight, brushed gold inlay, and soft contact-shadow zones where engine-rendered mahjong tiles will sit.

Composition and screen coordinates:
- Transparent full-screen canvas.
- Draw only table depth, rim highlights, soft shadows, and low-contrast material lighting.
- The main playable table should occupy roughly x=0.13-0.88 and y=0.14-0.80.
- Keep the center discard river and four wall lanes clean, readable, and low contrast.
- Top HUD band y=0.02-0.11 should remain mostly transparent.
- Bottom hand tray y=0.80-0.99 should receive only a soft grounding shadow, not a hard frame.
- Side seat panel areas must remain readable.

Style: commercial 3D mobile mahjong game, PBR jade felt, black lacquer wood, brushed gold inlay, restrained guofeng ornament, realistic soft contact shadows, cinematic but subtle table lighting.

Hard constraints: no text, no numbers, no logo, no watermark, no people, no readable mahjong tile faces, no dice, no buttons, no arrows, no route lines, no dots, no ticks, no technical HUD marks, no busy center patterns, no full-canvas backing plate.

Important UI integration constraints:
- Do not generate mahjong tiles, tile backs, tile walls, placeholder tile rectangles, dice, compass marks, wind glyphs, center medallions, route graphics, progress tracks, or HUD panels.
- Tile lanes and discard river zones should remain transparent except for broad, low-opacity natural contact shadows.
- The center area must be calm jade felt material only, with no ornamental focal object.
- Engine UI will render all wind, wall-count, discard, action-state, tile, and text information.
