{
  "type": "single blank mahjong tile body candidate",
  "goal": "Generate one isolated blank mahjong tile blank for a mobile game asset pipeline, suitable for later programmatic overlay of tile symbols.",
  "candidate_direction": "2) non-perspective low-thickness 2.5D white jade tile, only lower-right side shadow",
  "subject": {
    "object": "one blank upright mahjong tile blank only",
    "silhouette": "vertical rounded rectangle with a strict 200:280 body proportion, straight vertical alignment, almost flat front",
    "face": "large smooth white-jade face, completely empty central safe area, no recessed center and no decorative border",
    "edge": "ultra-low physical thickness, just a hairline pale side lip visible on the right edge and bottom edge, less than 3 percent of tile width",
    "side_shadow": "a tiny soft occlusion shadow only on the lower-right side edge, not across the front face and not on the background",
    "material": "milky white jade ceramic, faint translucent warmth, very smooth and clean, no visible veins, no speckles",
    "scale": "tile body fills about 78 percent of the image height with transparent-working margin"
  },
  "camera": {
    "angle": "non-perspective front view with minimal 2.5D cue",
    "perspective": "orthographic feel, no vanishing lines, no tilted tabletop, no foreshortening"
  },
  "background": {
    "type": "single flat pure chroma-key cyan background (#00FFFF) across the entire canvas",
    "shadow": "only a faint lower-right side shadow attached to the tile body; no broad ground shadow and no floor plane",
    "extras": "no table, no cloth, no other game props"
  },
  "lighting": {
    "key_light": "very soft upper-left frontal light",
    "fill_light": "even fill to keep center face clean and bright",
    "highlights": "minimal jade edge highlight on top-left and left edge; lower-right edge gently shaded"
  },
  "style": {
    "rendering": "restrained 2.5D mobile sprite, clean PBR-inspired material, readable at 200x280 px",
    "finish": "white jade tile blank with low thickness and minimal side cue, no thick block feeling"
  },
  "constraints": {
    "must_have": [
      "exactly one blank mahjong tile body",
      "strict upright 200:280 tile body proportion",
      "flat blank center with no marks",
      "only right and lower-right side-edge shadow",
      "single flat pure cyan chroma-key background"
    ],
    "strictly_avoid": [
      "any Chinese characters, letters, numbers, dots, bamboo, circles, flowers, seasons, symbols, logo, watermark, signature, label, text",
      "complete playable mahjong tile face, printed markings, engraved markings, embossed markings",
      "inner border, decorative frame, inset center panel, raised front rim, groove line",
      "green wall-tile back texture, green brick back, patterned back face",
      "multiple tiles, dice, hands, tabletop, cloth, scenery",
      "transparent checkerboard preview pattern, alpha grid, gray-white checker squares",
      "wide side wall, thick slab perspective, dark ground shadow, colored gradient background"
    ]
  }
}
