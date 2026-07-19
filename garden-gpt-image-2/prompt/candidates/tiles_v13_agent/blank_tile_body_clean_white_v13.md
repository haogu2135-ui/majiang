{
  "type": "single blank mahjong tile body candidate",
  "goal": "Generate one clean blank 3D mahjong tile body sprite for a mobile game, optimized for later programmatic overlay of existing tile symbols.",
  "subject": {
    "object": "one blank mahjong tile blank, no markings",
    "shape": "upright rounded rectangle slab, near front-facing, very subtle 2.5D thickness visible only along the right edge and bottom edge",
    "face": "large uninterrupted flat central face, smooth continuous surface, no recessed panel, no inner border, no frame line",
    "bevel": "very shallow ivory ceramic / pale jade bevel, soft rounded corners, continuous edge highlight, no thick rim",
    "material": "guofeng ivory jade ceramic, warm off-white body with a faint translucent jade feel, clean PBR-inspired mobile game sprite",
    "scale": "tile fills about 72 percent of the image height, centered with comfortable transparent-working margin"
  },
  "camera": {
    "angle": "almost orthographic front view, only a tiny 2.5D thickness cue",
    "perspective": "no dramatic perspective, no rotation beyond a few degrees, no fisheye"
  },
  "background": {
    "type": "pure white background only",
    "shadow": "extremely light contact shadow touching only the lower-right underside, soft and small",
    "extras": "no table, no cloth, no props, no texture"
  },
  "lighting": {
    "key_light": "large softbox from upper left front",
    "fill_light": "gentle front fill to keep the center blank face bright",
    "highlights": "thin soft bevel highlight on top-left edge, very subtle lower-right occlusion"
  },
  "style": {
    "rendering": "mobile game sprite, clean PBR-inspired 2.5D asset, readable at 200x280 px",
    "finish": "polished but restrained, soft edge highlights, crisp silhouette, no baked decorative frame"
  },
  "constraints": {
    "must_have": [
      "exactly one blank mahjong tile body",
      "very large empty central face for later glyph overlay",
      "pure white background",
      "soft rounded ivory/jade ceramic bevel",
      "light right-bottom contact shadow"
    ],
    "strictly_avoid": [
      "any Chinese characters, letters, numbers, dots, bamboo, circles, flowers, logo, watermark, signature, label, text",
      "thick picture-frame border, metal rim, gold edge, decorative frame, inset panel, inner rectangle, groove line, raised frame",
      "complex tabletop background, cloth, coins, other tiles, hands, dice",
      "dramatic camera angle, deep 3D perspective, dark cast shadow, colored gradient background"
    ]
  }
}
