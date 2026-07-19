#!/usr/bin/env python3
"""Deprecated helper for the old 3D-looking mahjong tile sprite approach.

The GPT model provides only the blank physical tile body. Playable markings are
extracted from the current authoritative assets/tiles sprites and composited
back in place, so tile identity and readability stay under deterministic code.

Runtime playable tiles now use `assets/tiles/*.png` plus Godot-native
shadow/highlight layers. Keep this script only for archival experiments.
"""

from __future__ import annotations

import argparse
import math
import sys
import tempfile
from pathlib import Path

from PIL import Image, ImageChops, ImageFilter, ImageOps


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "assets" / "tiles"
OUT_DIR = ROOT / "assets" / "tiles_3d"
DEFAULT_BODY = ROOT / "garden-gpt-image-2/image/candidates/p0/blank_tile_face_body_v1_candidate_01.png"
BODY_OUT = OUT_DIR / "_tile_face_3d_body.png"
WIDTH = 200
HEIGHT = 280
FACE_RECT = (21, 17, 179, 258)


TILE_FILES = [
    *[f"tile_man{n}.png" for n in range(1, 10)],
    *[f"tile_pin{n}.png" for n in range(1, 10)],
    *[f"tile_sou{n}.png" for n in range(1, 10)],
    "tile_honor_east.png",
    "tile_honor_south.png",
    "tile_honor_west.png",
    "tile_honor_north.png",
    "tile_honor_red.png",
    "tile_honor_green.png",
    "tile_honor_white.png",
    *[f"tile_flower_h{n}.png" for n in range(1, 9)],
]


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


def normalize_body(path: Path) -> Image.Image:
    source = ImageOps.exif_transpose(Image.open(path)).convert("RGBA")
    pixels = source.load()
    alpha = Image.new("L", source.size, 0)
    alpha_pixels = alpha.load()
    for y in range(source.height):
        for x in range(source.width):
            r, g, b, _a = pixels[x, y]
            luma = 0.2126 * r + 0.7152 * g + 0.0722 * b
            chroma = max(r, g, b) - min(r, g, b)
            if luma <= 9.0 and chroma <= 10.0:
                a = 0
            elif luma <= 42.0 and chroma <= 18.0:
                a = int(max(0.0, min(255.0, (luma - 9.0) / 33.0 * 180.0)))
            else:
                a = 255
            alpha_pixels[x, y] = a
    alpha = alpha.filter(ImageFilter.GaussianBlur(0.45))
    source.putalpha(alpha)
    bbox = alpha.getbbox()
    if bbox is None:
        raise ValueError(f"could not isolate tile body from {path}")
    cropped = source.crop(bbox)
    fitted = ImageOps.fit(cropped, (WIDTH, HEIGHT), method=Image.Resampling.LANCZOS, centering=(0.5, 0.52))
    return fitted


def marking_mask(tile: Image.Image) -> Image.Image:
    tile = tile.convert("RGBA")
    mask = Image.new("L", tile.size, 0)
    src = tile.load()
    dst = mask.load()
    left, top, right, bottom = FACE_RECT
    for y in range(top, bottom):
        for x in range(left, right):
            r, g, b, a = src[x, y]
            if a <= 16:
                continue
            luma = 0.2126 * r + 0.7152 * g + 0.0722 * b
            maxc = max(r, g, b)
            minc = min(r, g, b)
            sat = 0.0 if maxc == 0 else float(maxc - minc) / float(maxc)
            dark_score = max(0.0, (172.0 - luma) / 112.0)
            sat_score = sat * (1.25 if luma < 232.0 else 0.35)
            score = max(dark_score, sat_score)
            if score <= 0.20:
                continue
            dst[x, y] = int(max(0.0, min(255.0, (score - 0.20) / 0.55 * 255.0)))
    mask = mask.filter(ImageFilter.MaxFilter(3)).filter(ImageFilter.GaussianBlur(0.35))
    return mask


def apply_subtle_engrave_shadow(markings: Image.Image, mask: Image.Image) -> Image.Image:
    shadow = Image.new("RGBA", markings.size, (0, 0, 0, 0))
    shadow_alpha = mask.filter(ImageFilter.GaussianBlur(1.0)).point(lambda value: int(value * 0.22))
    shadow.putalpha(shadow_alpha)
    shifted = ImageChops.offset(shadow, 1, 2)
    canvas = Image.new("RGBA", markings.size, (0, 0, 0, 0))
    canvas.alpha_composite(shifted)
    canvas.alpha_composite(markings)
    return canvas


def composite_tile(body: Image.Image, tile_path: Path) -> Image.Image:
    original = Image.open(tile_path).convert("RGBA")
    mask = marking_mask(original)
    markings = Image.new("RGBA", original.size, (0, 0, 0, 0))
    markings.alpha_composite(original)
    existing_alpha = markings.getchannel("A")
    markings.putalpha(ImageChops.multiply(existing_alpha, mask))
    markings = apply_subtle_engrave_shadow(markings, mask)
    result = body.copy()
    result.alpha_composite(markings)
    return result


def filter_tile_files(only: list[str]) -> list[str]:
    if not only:
        return TILE_FILES
    needles = [value.lower() for value in only]
    selected = [name for name in TILE_FILES if any(needle in name.lower() for needle in needles)]
    if not selected:
        raise ValueError(f"no tile files matched --only: {', '.join(only)}")
    return selected


def main() -> int:
    parser = argparse.ArgumentParser(description="Deprecated: build deterministic 3D composite mahjong tile faces.")
    parser.add_argument("--body", type=Path, default=DEFAULT_BODY, help="Blank GPT tile body candidate")
    parser.add_argument("--out-dir", type=Path, default=OUT_DIR, help="Output directory")
    parser.add_argument("--only", action="append", default=[], help="Build only matching tile file names")
    parser.add_argument(
        "--allow-deprecated-3d",
        action="store_true",
        help="Explicitly allow regenerating the archived 3D tile experiment.",
    )
    args = parser.parse_args()

    if not args.allow_deprecated_3d:
        print(
            "Refusing to regenerate deprecated 3D tile faces. "
            "Use tools/generate_gpt_mahjong_tiles.py for clean flat sprites, "
            "or pass --allow-deprecated-3d for archival experiments.",
            file=sys.stderr,
        )
        return 2

    if not args.body.exists():
        raise FileNotFoundError(f"missing blank tile body candidate: {args.body}")

    body = normalize_body(args.body)
    args.out_dir.mkdir(parents=True, exist_ok=True)
    atomic_save(body, args.out_dir / BODY_OUT.name)

    built = []
    for filename in filter_tile_files(args.only):
        source = SOURCE_DIR / filename
        if not source.exists():
            raise FileNotFoundError(f"missing source tile: {source}")
        result = composite_tile(body, source)
        output = args.out_dir / filename
        atomic_save(result, output)
        built.append(output)

    print(f"Built {len(built)} 3D tile face sprites in {args.out_dir}")
    print(f"Blank body: {args.body}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
