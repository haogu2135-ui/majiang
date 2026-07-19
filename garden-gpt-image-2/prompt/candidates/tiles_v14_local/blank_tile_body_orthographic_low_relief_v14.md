{
  "type": "single isolated game asset",
  "goal": "blank mahjong tile body for a 2D Godot UI, later composited with authoritative flat mahjong markings",
  "subject": {
    "object": "one blank Chinese mahjong tile body only",
    "shape": "vertical rounded rectangle, 5:7 aspect ratio, front face almost orthographic",
    "material": "warm ivory porcelain with a very subtle white jade depth cue",
    "surface": "clean flat center safe area, shallow low-relief bevel only on the outside edge"
  },
  "composition": {
    "camera": "front-facing orthographic, no dramatic perspective, no tilted tabletop view",
    "layout": "single centered asset with generous empty margin, full object visible",
    "background": "solid pure blue chroma-key background #005BFF, no floor, no shadow touching the image boundary"
  },
  "lighting": {
    "style": "soft studio UI asset lighting",
    "highlights": "small restrained top-left porcelain highlight, faint right and bottom contact shading",
    "depth": "2.5D baked depth, thin side edge only, never a thick 3D block"
  },
  "constraints": {
    "must": [
      "blank center with no text and no symbols",
      "no Chinese characters, no numbers, no dots, no bamboo, no flowers",
      "no logo, no decorative border pattern, no inner frame drawing",
      "no green wall-tile back pattern",
      "clean edge suitable for alpha cutout",
      "must read as a premium game UI tile body at 200x280 pixels"
    ],
    "avoid": [
      "full playable mahjong tile face",
      "photorealistic tabletop scene",
      "heavy perspective",
      "dark dirty grime",
      "fake checkerboard transparency",
      "thick emerald side wall",
      "visible background gradient"
    ]
  }
}
