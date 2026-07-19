# p0_pending_claim_status_strip_v2_no_tile_well

- Output path: `garden-gpt-image-2/image/candidates/p0/pending_claim_status_strip_v2_candidate_01_chroma.png`
- Clean output path: `garden-gpt-image-2/image/candidates/p0/pending_claim_status_strip_v2_candidate_01_clean.png`
- Size: `768x120`
- Mode: A garden local generation, chroma-key source for true-alpha cleanup
- Source brief: `qa/agents/gpt_image_agent.md`
- Replaces rejected idea from: `garden-gpt-image-2/prompt/p0_pending_claim_status_strip.md`

```text
Create a compact game UI material strip for a Chinese guofeng mahjong battle screen.

Output image:
- Exact canvas target: 768x120 pixels, horizontal strip.
- Render on a perfectly flat chroma-key background: pure solid #00ff00 only outside the strip silhouette.
- Do not use transparency in the source image; the green background will be removed later.
- No checkerboard pattern, no fake transparency pattern, no texture in the green background.

Subject:
- A slim guofeng status strip material only.
- The strip is a low-profile black-lacquer and dark jade base with subtle warm gold and pale jade bevel edges.
- Left area may contain only an abstract circular or square source-seal backing plate, empty and decorative, not a button.
- Middle and right areas must be quiet low-contrast text-safe lanes for runtime UI overlays.
- Exterior silhouette should be clean, with soft contact shadow and gentle beveled depth.

Critical functional rule:
- Godot will draw the live mahjong tile, source player, all text, focus hints, and interaction state at runtime.
- Therefore the image must NOT include any tile well, tile placeholder, empty tile slot, blank tile rectangle, card frame, tile-shaped frame, tile socket, recessed tile box, or visible place intended for a tile.
- The image must not include any readable tile face, tile symbol, suit mark, honor character, number, label, route line, arrow, button, icon, badge text, watermark, logo, or UI caption.

Composition:
- Keep the strip slender and centered vertically within the canvas.
- Leave transparent-safe green exterior around the strip, especially all four corners.
- Use restrained detail: decorative edges and material variation only at the top/bottom edges and far ends.
- Keep the middle 60% and the right 25% calm, low-contrast, and free of visual focus.
- Do not divide the strip into visible fixed button wells or separate slots.

Style:
- Premium PBR guofeng mahjong UI material.
- Dark ink green, black lacquer, muted jade, brushed antique gold, a tiny amount of cinnabar only as abstract material accent.
- Soft studio lighting, tactile bevels, silk-brocade microtexture, subtle ink mist embedded in the material.

Avoid completely:
- tile well, tile placeholder, empty tile slot, blank tile rectangle, tile-shaped outline, mahjong tile face, tile symbols
- words, numbers, Chinese characters, letters, logo, watermark, stamps with readable marks
- buttons, labels, route lines, arrows, progress bars, HUD data, icons
- checkerboard, gray-white transparency preview, patterned background, non-green background
- large banner, ornate clutter, high-contrast center, neon, sci-fi HUD, sparks everywhere
```
