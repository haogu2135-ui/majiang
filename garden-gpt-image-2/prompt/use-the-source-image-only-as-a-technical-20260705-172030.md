Use the source image only as a technical reference for real transparent PNG behavior. Do not preserve its existing objects or layout. Replace the source with a new production-ready transparent PNG overlay for the main menu of a Chinese guofeng 3D mahjong mobile game.

Output requirement: RGBA-style transparent PNG, 1280x720 composition. Non-art areas must remain real transparent alpha, not black, not white, not checkerboard, not fake transparency.

Goal: a full-screen overlay that sits between the generated background and the three main menu cards. It must visually replace procedural card shadows, tabletop depth, and stage contact lighting.

Subject: one coherent premium 3D foreground stage for three large menu cards, with black lacquer table depth, soft card cast shadows, warm gold rim light, subtle jade reflections, and a grounded commercial tabletop feel.

Composition and screen coordinates:
- Transparent full-screen canvas.
- Draw only the stage, table lip, contact shadows, and soft light under/behind three main card slots.
- Main stage should occupy roughly x=0.10-0.90 and y=0.31-0.82.
- Three empty card contact zones are centered around x=0.24, x=0.50, x=0.76 and y=0.55.
- Leave the upper-left title plaque area, quick-button band, and bottom footer mostly empty and transparent.
- Do not draw labels, icons, buttons, or card faces inside the three card safe zones.

Style: high-end commercial 3D mobile game UI, PBR black lacquer, dark jade, carved warm gold trim, restrained guofeng ornament, cinematic moonlight plus lantern rim light, soft ambient occlusion, realistic material depth.

Hard constraints: no text, no numbers, no logo, no watermark, no people, no readable mahjong tile faces, no dice, no buttons, no arrows, no route lines, no dots, no ticks, no technical HUD marks, no full-canvas backing plate.

Important UI integration constraints:
- This is not a card-frame asset.
- Do not draw card borders, card interiors, glass rectangles, button shapes, icon placeholders, or visible slot outlines.
- Each of the three card regions must stay mostly transparent; only very soft ambient occlusion may appear under the lower edge of each future engine-rendered card.
- No wide translucent horizontal band across the card centers.
- Keep the overlay concentrated near the tabletop lip, floor contact, and low natural shadow areas.
