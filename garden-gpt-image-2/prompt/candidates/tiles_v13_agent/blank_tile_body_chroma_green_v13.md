{
  "type": "single blank mahjong tile body candidate",
  "goal": "Generate one blank 3D mahjong tile body sprite on a clean chroma key background, designed to replace an overly frame-like tile body.",
  "subject": {
    "object": "one blank mahjong tile blank, no symbols or decoration",
    "shape": "simple upright rounded rectangular tile slab, front face nearly straight-on, only a mild visible side thickness on right and bottom",
    "face": "broad plain central face taking most of the tile area, flat and empty, no inner border or recessed center",
    "bevel": "thin continuous soft bevel around the outer contour only, light ivory jade edge, not a frame",
    "material": "premium off-white ivory ceramic with subtle pale jade translucency, smooth PBR-inspired game asset material",
    "scale": "centered single sprite, about 70 percent of image height, enough margin for clean keying"
  },
  "camera": {
    "angle": "near orthographic front view with tiny 2.5D depth",
    "perspective": "minimal perspective, no dramatic 3D pose, no tilted product-shot angle"
  },
  "background": {
    "type": "solid pure chroma green background, uniform #00ff00",
    "shadow": "barely visible small soft contact shadow at the lower-right underside only",
    "extras": "no floor plane, no studio sweep, no gradient, no texture"
  },
  "lighting": {
    "key_light": "soft upper-left light creating a gentle top-left bevel highlight",
    "fill_light": "even front fill preserving a bright empty center",
    "ambient": "clean mobile-game asset lighting, no harsh specular bands"
  },
  "style": {
    "rendering": "mobile game sprite, clean 2.5D PBR-inspired render, guofeng ivory jade, readable at 200x280 px",
    "finish": "simple slab silhouette, restrained material, soft edges, high utility for compositing"
  },
  "constraints": {
    "must_have": [
      "exactly one blank mahjong tile body",
      "large undecorated central face",
      "uniform chroma green background",
      "light ivory/jade ceramic bevel only on the outside edge",
      "subtle right-bottom contact shadow"
    ],
    "strictly_avoid": [
      "any characters, symbols, dots, bamboo, circles, flowers, numbers, logo, watermark, signature, text",
      "thick border, picture frame look, metal edge, gold trim, inner frame, inset panel, double outline, decorative groove",
      "other tiles, table surface, cloth texture, props, hands, dice",
      "strong perspective, dramatic shadows, heavy ambient occlusion, glossy plastic toy look"
    ]
  }
}
