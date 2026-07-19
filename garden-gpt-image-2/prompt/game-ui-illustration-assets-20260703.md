# GPT Image Prompts for Yunzhuo Mahjong Assets

Current mode: Mode C / advisor. This environment has no callable host image generation tool, so these are production prompts for GPT Image. Generate each image with GPT Image, then save it to the listed project path.

Global visual direction for every asset:
- Chinese mahjong game UI illustration, premium ink-and-jade board game aesthetic.
- Dark teal lacquer base, warm gold accents, jade green secondary glow, subtle rice-paper fibers, soft silk brocade texture.
- No readable text, no logos, no watermarks, no real brand marks.
- Keep the center relatively calm so the Godot UI remains readable over the image.
- Output PNG, 16:9 or square as specified, high detail, game-ready background layer.

## 1. Main Menu Hero Backdrop

Target path: `assets/illustrations/menu_hero_gpt_backdrop.png`

Prompt:
```text
Create a polished game main-menu hero backdrop for a Chinese mahjong video game. A cinematic mahjong table seen from a slightly elevated angle, dark teal lacquer tabletop, ivory mahjong tiles arranged in an elegant incomplete hand, gold filigree, jade wind compass hints, warm lantern reflections, soft ink wash around the edges, refined board-game luxury mood. Keep a clean readable central area and darker corners for UI overlays. No readable text, no logos, no watermark, no people, no modern objects. PNG, 16:9, high detail, premium game UI background.
```

## 2. Table Backdrop

Target path: `assets/illustrations/table_gpt_backdrop.png`

Prompt:
```text
Create an in-game mahjong table backdrop for a mobile/desktop Godot mahjong game. Top-down square composition, dark jade felt center, lacquered wooden rim, subtle gold inlay, faint wind direction compass, delicate silk pattern, soft ambient glow under tile areas. The middle must stay calm and readable for gameplay pieces. No readable text, no logos, no watermark, no characters, no hands. PNG, square 1:1, game-ready background plate.
```

## 3. Rules Scroll Panel

Target path: `assets/illustrations/rules_gpt_scroll.png`

Prompt:
```text
Create a translucent illustration background for a mahjong rules screen. Ancient Chinese scroll paper blended with dark teal UI glass, gold rule-path lines, small abstract mahjong tile silhouettes, jade separators, ink wash borders, subtle educational guide feeling. Leave large calm areas for text blocks, avoid busy detail behind the center. No readable text, no logos, no watermark. PNG, 16:9, refined game UI panel artwork.
```

## 4. Action Dock

Target path: `assets/illustrations/action_gpt_dock.png`

Prompt:
```text
Create a horizontal action dock background for mahjong claim buttons. Dark lacquer bar with four subtle empty action sockets, gold and jade edge lighting, silk ribbon texture, tiny sparks around the right side for win/confirm emphasis. It should feel tactile and premium but not contain labels. Transparent-looking dark center, readable over UI buttons. No text, no logos, no watermark. PNG, wide 4:1 composition, game UI overlay asset.
```

## 4B. Hand Completion Bus

Target path: `assets/illustrations/hand_completion_gpt_bus.png`

Prompt:
```text
Create a slim hand-completion bus overlay for a Chinese mahjong game hand tray. Horizontal dark lacquer route with a left hand-source seal, four small branching progress sockets, a right archive gate, subtle jade and warm gold edge lighting, silk-paper grain, tiny directional motes moving along the route. It must be quiet enough to sit behind live mahjong tiles and UI controls, with no readable text, no numbers, no logos, no watermark. Leave the center mostly transparent-looking and uncluttered. PNG, ultra-wide 5:1 game UI overlay asset.
```

## 5. Pending Claim Trail

Target path: `assets/illustrations/claim_response_trail.png`

Prompt:
```text
Create a dynamic claim-response trail illustration for a mahjong game. Curving gold-and-jade energy ribbon moving from a discarded tile position toward a response panel, ink particles, faint tile silhouettes, premium Chinese board-game aesthetic, dark teal background kept minimal. Use motion language and directional flow, but no readable text or symbols. PNG, wide 16:9, game VFX overlay background.
```

## 6. Discard Splash Wash

Target path: `assets/illustrations/discard_splash_wash.png`

Prompt:
```text
Create a compact ink splash VFX asset for a mahjong tile discard impact. Circular brush-ink burst with gold dust and jade highlights, crisp center impact, soft fading outer wash, no tile in the artwork, no text, no watermark. Make it suitable for alpha-style compositing over a dark table. PNG, square 1:1, centered VFX element on a flat dark neutral background.
```

## 7. Win Celebration Burst

Target path: `assets/illustrations/win_celebration_gpt_burst.png`

Prompt:
```text
Create a celebratory win burst for a Chinese mahjong game UI. Radiating gold light, jade arcs, tasteful fireworks-like ink particles, abstract mahjong tile silhouettes flying outward, premium festival energy without clutter. Leave center usable for a large win label added by the game. No readable text, no logos, no watermark, no characters. PNG, 16:9, high-impact game celebration overlay.
```

## 8. Achievement Gallery

Target path: `assets/illustrations/achievement_gpt_gallery.png`

Prompt:
```text
Create an achievements gallery background for a mahjong game. Dark museum-like display wall, gold medal frames, jade-lit shelves, subtle scroll archive motif, small abstract trophy silhouettes, refined and quiet so achievement rows remain readable. No readable text, no logos, no watermark. PNG, 16:9, premium game UI background panel.
```

## 9. Stats Dashboard

Target path: `assets/illustrations/stats_gpt_dashboard.png`

Prompt:
```text
Create a statistics dashboard background for a mahjong game. Dark teal analytical board, gold data rails, jade progress arcs, subtle mahjong tile probability motifs, elegant grid lines, silk-paper texture. Keep it understated and readable for numeric labels and rows. No readable text, no logos, no watermark. PNG, 16:9, refined game UI dashboard artwork.
```

## 10. Loading Scene Backdrop

Target path: `assets/illustrations/loading_scene_gpt_backdrop.png`

Prompt:
```text
Create a loading screen backdrop for a Chinese mahjong game. Quiet cinematic table before a match, tiles stacked like a wall, soft lantern bokeh, dark teal and warm gold palette, subtle jade glow, calm anticipation, center safe for a loading spinner and tip. No readable text, no logos, no watermark, no people. PNG, 16:9, high-quality game loading background.
```

## Optional Animation Source Frames

Use these prompts if you want GPT-generated source frames for short video/animation compositing outside this environment.

### A. Tile Draw Motion Keyframe Sheet

Suggested output path: `assets/illustrations/gpt_tile_draw_keyframes.png`

Prompt:
```text
Create a 4-panel keyframe sheet for a mahjong tile draw animation, same tile represented as a glowing hidden tile back moving from wall to hand: frame 1 idle at wall, frame 2 lift with jade trail, frame 3 fast motion arc with gold particles, frame 4 settles into hand area. Dark teal background, no readable text, no logos, consistent lighting, each panel separated by clean gutters. PNG, 16:9 keyframe sheet for game animation reference.
```

### B. Claim Response Motion Keyframe Sheet

Suggested output path: `assets/illustrations/gpt_claim_response_keyframes.png`

Prompt:
```text
Create a 4-panel keyframe sheet for mahjong claim response animation: discarded tile energy pulse, response ribbon activates, gold-jade route connects to player area, final confirmation seal glow. Premium Chinese mahjong UI aesthetic, dark teal lacquer base, no readable text, no logos, consistent camera and lighting. PNG, 16:9 keyframe sheet for game animation reference.
```
