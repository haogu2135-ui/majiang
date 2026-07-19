#!/usr/bin/env python3
"""Clean fake transparent GPT PNG assets into true-alpha sprites."""

from __future__ import annotations

import argparse
import tempfile
from pathlib import Path

from PIL import Image, ImageFilter, ImageOps


def parse_size(value: str) -> tuple[int, int]:
    width, height = value.lower().split("x", 1)
    return int(width), int(height)


def atomic_save(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temp_path: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(dir=path.parent, prefix=f".{path.stem}.", suffix=".png", delete=False) as temp:
            temp_path = Path(temp.name)
            image.save(temp, format="PNG")
        temp_path.replace(path)
    finally:
        if temp_path is not None and temp_path.exists():
            temp_path.unlink()


def fake_transparency_alpha(source: Image.Image) -> Image.Image:
    rgba = source.convert("RGBA")
    src = rgba.load()
    alpha = Image.new("L", rgba.size, 0)
    dst = alpha.load()

    for y in range(rgba.height):
        for x in range(rgba.width):
            r, g, b, a = src[x, y]
            luma = 0.2126 * r + 0.7152 * g + 0.0722 * b
            chroma = max(r, g, b) - min(r, g, b)
            if a <= 8:
                out_a = 0
            elif chroma <= 10 and luma >= 230:
                out_a = 0
            elif chroma <= 14 and luma >= 205:
                out_a = int(max(0.0, min(255.0, (230.0 - luma) / 25.0 * 255.0)))
            else:
                out_a = 255
            dst[x, y] = out_a

    alpha = alpha.filter(ImageFilter.GaussianBlur(0.55))
    return alpha.point(lambda value: 0 if value < 10 else value)


def clean_asset(source_path: Path, target_size: tuple[int, int], pad: int) -> Image.Image:
    source = ImageOps.exif_transpose(Image.open(source_path)).convert("RGBA")
    alpha = fake_transparency_alpha(source)
    source.putalpha(alpha)
    bbox = alpha.getbbox()
    if bbox is None:
        raise ValueError(f"could not isolate non-background pixels from {source_path}")

    left = max(0, bbox[0] - pad)
    top = max(0, bbox[1] - pad)
    right = min(source.width, bbox[2] + pad)
    bottom = min(source.height, bbox[3] + pad)
    cropped = source.crop((left, top, right, bottom))
    cropped_alpha = cropped.getchannel("A")

    contained = ImageOps.contain(cropped, target_size, method=Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", target_size, (0, 0, 0, 0))
    x = (target_size[0] - contained.width) // 2
    y = (target_size[1] - contained.height) // 2
    canvas.alpha_composite(contained, (x, y))

    if cropped_alpha.getbbox() is None:
        raise ValueError(f"cleaned asset became fully transparent: {source_path}")
    return canvas


def main() -> int:
    parser = argparse.ArgumentParser(description="Convert fake transparent GPT asset PNGs to true-alpha target-sized PNGs.")
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--size", required=True, help="Target size, e.g. 1024x160")
    parser.add_argument("--pad", type=int, default=8, help="Source crop padding in pixels")
    args = parser.parse_args()

    image = clean_asset(args.source, parse_size(args.size), args.pad)
    atomic_save(image, args.output)
    alpha_min, alpha_max = image.getchannel("A").getextrema()
    print(f"wrote {args.output} size={image.width}x{image.height} alpha={alpha_min}-{alpha_max}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
