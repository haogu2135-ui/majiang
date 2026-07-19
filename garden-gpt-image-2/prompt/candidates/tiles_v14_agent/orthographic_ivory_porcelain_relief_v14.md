{
  "type": "single blank mahjong tile body candidate",
  "goal": "Generate one isolated blank mahjong tile blank for a mobile game asset pipeline, suitable for later programmatic overlay of tile symbols.",
  "candidate_direction": "1) orthographic shallow-relief ivory porcelain tile, completely clean center",
  "subject": {
    "object": "one blank upright mahjong tile blank only",
    "silhouette": "vertical rounded rectangle slab with a strict 200:280 body proportion, near-perfect front orthographic view",
    "face": "large uninterrupted flat center safe area, perfectly plain smooth ivory porcelain, no recess, no panel, no border, no linework",
    "edge": "very shallow rounded outer bevel, porcelain relief only at the outer silhouette, no raised frame around the face",
    "material": "warm ivory ceramic porcelain, soft subsurface-like warmth, smooth glazed finish, not plastic, not stone-veined",
    "scale": "tile body fills about 76 percent of the image height with even transparent margin"
  },
  "camera": {
    "angle": "front-facing orthographic product sprite",
    "perspective": "no perspective distortion, no rotated tabletop angle, no dramatic 3D depth"
  },
  "background": {
    "type": "single flat pure chroma-key cyan background (#00FFFF) across the entire canvas",
    "shadow": "nearly invisible contact softening only at the lower-right silhouette; keep the center face clean; do not draw a ground plane",
    "extras": "no table, no cloth, no props, no other tiles"
  },
  "lighting": {
    "key_light": "large soft frontal light from upper left",
    "fill_light": "broad even front fill so the blank center remains calm and unmarked",
    "highlights": "subtle top-left porcelain rim highlight, extremely restrained"
  },
  "style": {
    "rendering": "clean 2.5D mobile game asset, high resolution PNG, orthographic shallow-relief look",
    "finish": "quiet premium porcelain with crisp but soft silhouette, no heavy 3D wall"
  },
  "constraints": {
    "must_have": [
      "exactly one blank mahjong tile body",
      "strict upright 200:280 tile body proportion",
      "front face close to orthographic",
      "completely blank flat central safe area",
      "single flat pure cyan chroma-key background"
    ],
    "strictly_avoid": [
      "any Chinese characters, letters, numbers, dots, bamboo, circles, flowers, seasons, symbols, logo, watermark, signature, label, text",
      "complete playable mahjong tile face, printed markings, engraved markings, embossed markings",
      "border pattern, decorative frame, inner rectangle, inset panel, groove line, thick raised rim",
      "green wall-tile back texture, green brick back, bamboo back, patterned back face",
      "multiple tiles, dice, hands, tabletop, cloth, scenery",
      "transparent checkerboard preview pattern, alpha grid, gray-white checker squares",
      "strong cast shadow, colored gradient background, thick 3D side wall, dramatic perspective"
    ]
  }
}
