{
  "type": "single blank mahjong tile body candidate",
  "goal": "Generate one isolated blank mahjong tile blank for a mobile game UI asset pipeline, suitable for later programmatic overlay of tile symbols.",
  "candidate_direction": "3) UI baked normal-map style, extremely light normal highlights, no real 3D thick-wall feeling",
  "subject": {
    "object": "one blank upright mahjong tile UI sprite only",
    "silhouette": "vertical rounded rectangle tile body with strict 200:280 proportion, clean orthographic front",
    "face": "perfectly blank central safe area, smooth off-white face with very subtle baked normal-map shading, no printed or engraved content",
    "edge": "almost flat UI bevel suggested by tiny normal-map highlights along the silhouette, no visible physical side wall",
    "material": "soft off-white porcelain UI material, matte-gloss balance, no visible stone grain, no plastic toy look",
    "scale": "tile body fills about 76 percent of the image height with transparent-working margin"
  },
  "camera": {
    "angle": "front orthographic UI sprite",
    "perspective": "zero perspective, zero tabletop rotation, no visible back face"
  },
  "background": {
    "type": "single flat pure chroma-key cyan background (#00FFFF) across the entire canvas",
    "shadow": "no real cast shadow; only a microscopic baked lower-right ambient occlusion on the bevel; no floor plane",
    "extras": "no environment, no props, no table, no other tiles"
  },
  "lighting": {
    "key_light": "soft UI light from upper left",
    "fill_light": "flat frontal fill",
    "highlights": "extremely light normal-map highlights on upper-left bevel; center remains neutral and plain"
  },
  "style": {
    "rendering": "game UI baked normal-map sprite, clean PNG asset, subtle normal highlights, flat physical profile",
    "finish": "polished but understated UI tile blank, no photorealistic heavy depth"
  },
  "constraints": {
    "must_have": [
      "exactly one blank mahjong tile body",
      "strict upright 200:280 tile body proportion",
      "front face close to orthographic",
      "large clean blank center safe area",
      "baked normal-map style shading only",
      "single flat pure cyan chroma-key background"
    ],
    "strictly_avoid": [
      "any Chinese characters, letters, numbers, dots, bamboo, circles, flowers, seasons, symbols, logo, watermark, signature, label, text",
      "complete playable mahjong tile face, printed markings, engraved markings, embossed markings",
      "decorative border, inner rectangle, inset panel, raised rim, groove line, ornate edge",
      "green wall-tile back texture, green brick back, patterned back face",
      "multiple tiles, dice, hands, tabletop, cloth, scenery",
      "transparent checkerboard preview pattern, alpha grid, gray-white checker squares",
      "true 3D block thickness, heavy side wall, dramatic perspective, strong cast shadow, colored gradient background"
    ]
  }
}
