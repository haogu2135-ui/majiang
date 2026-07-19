{
  "type": "isolated transparent game asset",
  "goal": "Generate one reusable blank mahjong tile body for a 2D game UI. The tile will later receive deterministic suit markings in code, so the image must be only the blank physical body.",
  "subject": {
    "object": "blank Chinese mahjong tile body, no engraved symbols, no printed marks, no numbers, no text",
    "shape": "rounded vertical rectangle with large flat front face, very shallow 3D thickness visible only on the bottom and right edge",
    "view": "near-orthographic front view, only 6-8 degrees of top/right perspective, not a dramatic product render",
    "material": "warm ivory bone/ceramic face with a subtle jade-gray side edge, satin finish, very clean"
  },
  "lighting": {
    "style": "soft studio lighting for game sprites",
    "shadow": "tiny contact shadow integrated into alpha, no large cast shadow"
  },
  "composition": {
    "background": "fully transparent alpha",
    "framing": "single tile centered, vertical, fits inside canvas with 10% transparent padding, clean edges suitable for downscaling to small UI tiles",
    "front_face": "front face occupies most of the tile, plain and readable, no texture noise"
  },
  "style": {
    "rendering": "premium mobile game asset, polished but restrained, subtle bevels, crisp silhouette",
    "avoid": ["gold trim", "thick side walls", "photorealistic camera perspective", "engraved lines", "symbols", "text", "patterns", "background", "multiple tiles", "dramatic shadow", "cartoon outline"]
  }
}
