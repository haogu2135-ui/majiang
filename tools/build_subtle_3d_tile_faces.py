#!/usr/bin/env python3
"""Build subtle 3D mahjong tile candidates from a blank body.

This is the replacement workflow for the old full-GPT tile set. The default
path uses a deterministic thin-bevel body because it stays cleaner at gameplay
sprite scale. Generated blank bodies can still be used explicitly as direct
materials or as silhouette masks for experiments. The playable markings are
extracted from `assets/tiles/*.png` and composited deterministically, so symbol
identity and layout stay under source control.
"""

from __future__ import annotations

import argparse
import tempfile
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageOps


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "assets" / "tiles"
DEFAULT_BODY = ROOT / "garden-gpt-image-2/image/candidates/tiles_v15_agent/baked_ui_depth_layer_v15.png"
DEFAULT_OUT_DIR = ROOT / ".tmp" / "subtle_3d_tiles"
DEFAULT_CONTACT_SHEET = ROOT / "build/qa/subtle_3d_tile_contact_sheet.png"
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


def has_true_alpha(image: Image.Image) -> bool:
    if image.mode != "RGBA":
        return False
    low, high = image.getchannel("A").getextrema()
    return low < 255 and high > 0


def prepare_body(path: Path) -> Image.Image:
    source = ImageOps.exif_transpose(Image.open(path)).convert("RGBA")
    if source.size == (WIDTH, HEIGHT) and has_true_alpha(source):
        return source

    alpha = source.getchannel("A")
    if alpha.getextrema()[0] == 255:
        alpha = infer_neutral_background_alpha(source)
        source.putalpha(alpha)

    bbox = source.getchannel("A").getbbox()
    if bbox is None:
        raise ValueError(f"could not isolate tile body from {path}")
    cropped = source.crop(bbox)
    fitted = ImageOps.contain(cropped, (WIDTH, HEIGHT), method=Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    canvas.alpha_composite(fitted, ((WIDTH - fitted.width) // 2, (HEIGHT - fitted.height) // 2))
    return canvas


def infer_green_screen_alpha(source: Image.Image) -> Image.Image:
    alpha = Image.new("L", source.size, 0)
    src = source.load()
    dst = alpha.load()
    for y in range(source.height):
        for x in range(source.width):
            r, g, b, _a = src[x, y]
            green_score = g - max(r, b)
            dst[x, y] = 0 if g > 120 and green_score > 30 else 255
    return alpha


def fitted_alpha_mask(source_alpha: Image.Image) -> Image.Image:
    alpha = source_alpha.filter(ImageFilter.MinFilter(5)).filter(ImageFilter.MaxFilter(11)).filter(ImageFilter.MinFilter(7))
    bbox = alpha.getbbox()
    if bbox is None:
        raise ValueError("could not isolate generated tile body mask")
    left = max(0, bbox[0] - 2)
    top = max(0, bbox[1] - 2)
    right = min(alpha.width, bbox[2] + 2)
    bottom = min(alpha.height, bbox[3] + 2)
    cropped = alpha.crop((left, top, right, bottom))
    fitted = ImageOps.contain(cropped, (WIDTH, HEIGHT), method=Image.Resampling.LANCZOS)
    mask = Image.new("L", (WIDTH, HEIGHT), 0)
    mask.paste(fitted, ((WIDTH - fitted.width) // 2, (HEIGHT - fitted.height) // 2))
    return mask.filter(ImageFilter.GaussianBlur(0.45)).point(lambda value: 0 if value < 8 else (255 if value > 248 else value))


def build_generated_mask_material_body(path: Path) -> Image.Image:
    """Use a generated blank tile only for silhouette, then rebuild clean RGB.

    GPT outputs often look clean at large size but contain tiny gray or black
    texture flecks that become dirty at 200x280. This mode keeps the generated
    rounded slab geometry while discarding all generated RGB pixels.
    """
    source = ImageOps.exif_transpose(Image.open(path)).convert("RGBA")
    if has_true_alpha(source):
        source_alpha = source.getchannel("A")
    else:
        source_alpha = infer_neutral_background_alpha(source)
    mask = fitted_alpha_mask(source_alpha)
    bbox = mask.getbbox()
    if bbox is None:
        raise ValueError(f"could not isolate generated tile body mask from {path}")

    eroded = mask.filter(ImageFilter.MinFilter(9))
    edge_ring = ImageChops.subtract(mask, eroded).filter(ImageFilter.GaussianBlur(1.1))
    body = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    pixels = body.load()
    mask_pixels = mask.load()
    ring_pixels = edge_ring.load()
    x0, y0, x1, y1 = bbox
    body_w = max(1, x1 - x0)
    body_h = max(1, y1 - y0)

    for y in range(HEIGHT):
        for x in range(WIDTH):
            alpha = mask_pixels[x, y]
            if alpha <= 0:
                continue
            nx = (x - x0) / float(body_w)
            ny = (y - y0) / float(body_h)
            base_r = 254 - int(8 * ny)
            base_g = 251 - int(10 * ny)
            base_b = 240 - int(14 * ny)
            edge = ring_pixels[x, y] / 255.0
            right = max(0.0, (nx - 0.76) / 0.24)
            bottom = max(0.0, (ny - 0.82) / 0.18)
            top_highlight = max(0.0, (0.18 - ny) / 0.18) * max(0.0, (0.78 - nx) / 0.78)
            left_highlight = max(0.0, (0.13 - nx) / 0.13) * max(0.0, (0.88 - ny) / 0.88)
            shade = -18.0 * edge - 18.0 * right - 16.0 * bottom + 10.0 * top_highlight + 5.0 * left_highlight
            if 0.17 < nx < 0.78 and 0.13 < ny < 0.78:
                shade = max(shade, -5.0)
            pixels[x, y] = (
                int(max(0.0, min(255.0, base_r + shade))),
                int(max(0.0, min(255.0, base_g + shade * 0.88))),
                int(max(0.0, min(255.0, base_b + shade * 0.62))),
                alpha,
            )

    draw = ImageDraw.Draw(body, "RGBA")
    draw.rounded_rectangle((x0 + 5, y1 - 7, x1 - 5, y1 - 2), radius=4, fill=(126, 113, 76, 28))
    draw.rounded_rectangle((x0 + 3, y0 + 2, x1 - 3, y1 - 2), radius=14, outline=(255, 255, 250, 42), width=1)
    return body


def infer_neutral_background_alpha(source: Image.Image) -> Image.Image:
    alpha = Image.new("L", source.size, 0)
    src = source.load()
    dst = alpha.load()
    for y in range(source.height):
        for x in range(source.width):
            r, g, b, _a = src[x, y]
            luma = 0.2126 * r + 0.7152 * g + 0.0722 * b
            chroma = max(r, g, b) - min(r, g, b)
            green_score = g - max(r, b)
            blue_score = b - max(r, g)
            if g > 120 and green_score > 45:
                out_a = 0
            elif b > 120 and blue_score > 45:
                out_a = 0
            elif chroma <= 12 and luma >= 230:
                out_a = 0
            elif g > 90 and green_score > 18:
                out_a = int(max(0.0, min(255.0, (45.0 - green_score) / 27.0 * 255.0)))
            elif b > 90 and blue_score > 18:
                out_a = int(max(0.0, min(255.0, (45.0 - blue_score) / 27.0 * 255.0)))
            elif chroma <= 15 and luma >= 204:
                out_a = int(max(0.0, min(255.0, (230.0 - luma) / 26.0 * 255.0)))
            else:
                out_a = 255
            dst[x, y] = out_a
    return alpha.filter(ImageFilter.GaussianBlur(0.7)).point(lambda value: 0 if value < 10 else value)


def lerp_channel(a: int, b: int, t: float) -> int:
    return int(round(a + (b - a) * t))


def lerp_color(top: tuple[int, int, int, int], bottom: tuple[int, int, int, int], t: float) -> tuple[int, int, int, int]:
    return (
        lerp_channel(top[0], bottom[0], t),
        lerp_channel(top[1], bottom[1], t),
        lerp_channel(top[2], bottom[2], t),
        lerp_channel(top[3], bottom[3], t),
    )


def rounded_mask(rect: tuple[int, int, int, int], radius: int, blur: float = 0.0) -> Image.Image:
    mask = Image.new("L", (WIDTH, HEIGHT), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle(rect, radius=radius, fill=255)
    if blur > 0.0:
        mask = mask.filter(ImageFilter.GaussianBlur(blur))
    return mask


def alpha_scaled(mask: Image.Image, opacity: float) -> Image.Image:
    return mask.point(lambda value: int(max(0.0, min(255.0, value * opacity))))


def gradient_layer(
    mask: Image.Image,
    top: tuple[int, int, int, int],
    bottom: tuple[int, int, int, int],
) -> Image.Image:
    layer = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    pixels = layer.load()
    mask_pixels = mask.load()
    for y in range(HEIGHT):
        t = y / float(max(1, HEIGHT - 1))
        r, g, b, a = lerp_color(top, bottom, t)
        for x in range(WIDTH):
            ma = mask_pixels[x, y]
            if ma > 0:
                pixels[x, y] = (r, g, b, int(a * ma / 255))
    return layer


def build_procedural_body() -> Image.Image:
    """Draw a consistent thin-bevel tile body without relying on GPT pixels."""
    canvas = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    front = (18, 13, 180, 262)
    radius = 15

    shadow = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    shadow.putalpha(alpha_scaled(rounded_mask((21, 21, 187, 270), radius + 2, 4.0), 0.16))
    canvas.alpha_composite(shadow)

    side_bottom = (31, 62, 50, 255)
    side_top = (105, 130, 96, 255)
    for depth in range(5, 0, -1):
        t = depth / 5.0
        ox = depth
        oy = int(round(depth * 0.58))
        rect = (front[0] + ox, front[1] + oy, front[2] + ox, front[3] + oy)
        side_mask = rounded_mask(rect, radius)
        side = gradient_layer(side_mask, lerp_color(side_top, side_bottom, 0.16 + t * 0.20), lerp_color(side_top, side_bottom, 0.58 + t * 0.18))
        canvas.alpha_composite(side)

    front_mask = rounded_mask(front, radius)
    face = gradient_layer(front_mask, (255, 253, 244, 255), (244, 235, 215, 255))
    canvas.alpha_composite(face)

    draw = ImageDraw.Draw(canvas, "RGBA")
    draw.rounded_rectangle(front, radius=radius, outline=(118, 111, 82, 105), width=1)
    draw.rounded_rectangle((front[0] + 2, front[1] + 2, front[2] - 2, front[3] - 2), radius=radius - 2, outline=(255, 255, 248, 56), width=1)

    bottom_ao = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    bottom_ao.putalpha(alpha_scaled(rounded_mask((front[0] + 9, front[3] - 13, front[2] - 7, front[3] - 1), 8, 2.0), 0.07))
    canvas.alpha_composite(bottom_ao)

    top_sheen = Image.new("RGBA", (WIDTH, HEIGHT), (255, 255, 248, 0))
    top_sheen_mask = Image.new("L", (WIDTH, HEIGHT), 0)
    top_draw = ImageDraw.Draw(top_sheen_mask)
    top_draw.rounded_rectangle((front[0] + 11, front[1] + 8, front[2] - 25, front[1] + 28), radius=8, fill=32)
    top_sheen.putalpha(top_sheen_mask.filter(ImageFilter.GaussianBlur(2.2)))
    canvas.alpha_composite(top_sheen)

    right_sheen = Image.new("RGBA", (WIDTH, HEIGHT), (210, 235, 204, 0))
    right_sheen_mask = Image.new("L", (WIDTH, HEIGHT), 0)
    right_draw = ImageDraw.Draw(right_sheen_mask)
    right_draw.rounded_rectangle((front[2] - 5, front[1] + 18, front[2] + 2, front[3] - 18), radius=5, fill=28)
    right_sheen.putalpha(right_sheen_mask.filter(ImageFilter.GaussianBlur(1.0)))
    canvas.alpha_composite(right_sheen)
    return canvas


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
            chroma = maxc - minc
            sat = 0.0 if maxc == 0 else float(maxc - minc) / float(maxc)
            dark_score = max(0.0, (132.0 - luma) / 86.0)
            neutral_ink_score = max(0.0, (145.0 - luma) / 70.0) if chroma <= 28 else 0.0
            sat_score = max(0.0, (sat - 0.16) / 0.50) * (1.0 if luma < 242.0 else 0.0)
            if luma > 150.0 and sat < 0.22:
                neutral_ink_score = 0.0
            score = max(dark_score, sat_score)
            if neutral_ink_score > score and luma < 130.0:
                score = neutral_ink_score
            if score <= 0.08:
                continue
            dst[x, y] = int(max(0.0, min(255.0, (score - 0.08) / 0.60 * 255.0)))
    return mask.filter(ImageFilter.MaxFilter(3)).filter(ImageFilter.GaussianBlur(0.35))


def extract_markings(tile_path: Path) -> tuple[Image.Image, Image.Image]:
    original = Image.open(tile_path).convert("RGBA")
    mask = marking_mask(original)
    markings = Image.new("RGBA", original.size, (0, 0, 0, 0))
    markings.alpha_composite(original)
    markings.putalpha(ImageChops.multiply(markings.getchannel("A"), mask))
    return markings, mask


def apply_subtle_engrave_shadow(markings: Image.Image, mask: Image.Image) -> Image.Image:
    shadow = Image.new("RGBA", markings.size, (0, 0, 0, 0))
    shadow_alpha = mask.filter(ImageFilter.GaussianBlur(1.0)).point(lambda value: int(value * 0.18))
    shadow.putalpha(shadow_alpha)
    shifted = ImageChops.offset(shadow, 1, 2)
    canvas = Image.new("RGBA", markings.size, (0, 0, 0, 0))
    canvas.alpha_composite(shifted)
    canvas.alpha_composite(markings)
    return canvas


def composite_tile(body: Image.Image, tile_path: Path) -> Image.Image:
    markings, mask = extract_markings(tile_path)
    result = body.copy()
    result.alpha_composite(apply_subtle_engrave_shadow(markings, mask))
    return result


def filter_tile_files(only: list[str]) -> list[str]:
    if not only:
        return TILE_FILES
    needles = [value.lower() for value in only]
    selected = [name for name in TILE_FILES if any(needle in name.lower() for needle in needles)]
    if not selected:
        raise ValueError(f"no tile files matched --only: {', '.join(only)}")
    return selected


def make_contact_sheet(paths: list[Path], output: Path, columns: int) -> None:
    if not paths:
        return
    cell_w = 118
    cell_h = 168
    header_h = 34
    rows = (len(paths) + columns - 1) // columns
    sheet = Image.new("RGBA", (columns * cell_w, header_h + rows * cell_h), (20, 22, 20, 255))
    draw = ImageDraw.Draw(sheet)
    draw.text((14, 10), "subtle 3D body + deterministic source markings", fill=(236, 225, 190, 255))
    for index, path in enumerate(paths):
        row = index // columns
        col = index % columns
        x0 = col * cell_w
        y0 = header_h + row * cell_h
        tile = Image.open(path).convert("RGBA")
        tile.thumbnail((78, 110), Image.Resampling.LANCZOS)
        sheet.alpha_composite(tile, (x0 + (cell_w - tile.width) // 2, y0 + 10))
        label = path.stem.replace("tile_", "")
        draw.text((x0 + 8, y0 + 126), label[:16], fill=(216, 206, 176, 255))
    atomic_save(sheet, output)


def main() -> int:
    parser = argparse.ArgumentParser(description="Build subtle 3D candidate mahjong tile faces.")
    parser.add_argument("--body", type=Path, default=DEFAULT_BODY, help="Generated blank tile body PNG")
    parser.add_argument(
        "--body-mode",
        choices=["procedural", "generated", "generated-mask-material"],
        default="procedural",
        help="Use a deterministic body, a supplied generated body, or generated silhouette with deterministic material",
    )
    parser.add_argument("--source-dir", type=Path, default=SOURCE_DIR, help="Authoritative flat tile source directory")
    parser.add_argument("--out-dir", type=Path, default=DEFAULT_OUT_DIR, help="Candidate output directory")
    parser.add_argument("--only", action="append", default=[], help="Build only matching tile file names")
    parser.add_argument("--contact-sheet", type=Path, default=DEFAULT_CONTACT_SHEET, help="Contact sheet output path")
    parser.add_argument("--columns", type=int, default=7, help="Contact sheet columns")
    args = parser.parse_args()

    if args.body_mode in ["generated", "generated-mask-material"] and not args.body.exists():
        raise FileNotFoundError(f"missing blank tile body: {args.body}")
    if not args.source_dir.exists():
        raise FileNotFoundError(f"missing source tile directory: {args.source_dir}")

    if args.body_mode == "generated":
        body = prepare_body(args.body)
    elif args.body_mode == "generated-mask-material":
        body = build_generated_mask_material_body(args.body)
    else:
        body = build_procedural_body()
    args.out_dir.mkdir(parents=True, exist_ok=True)
    atomic_save(body, args.out_dir / "_tile_body_subtle_3d.png")

    built: list[Path] = []
    for filename in filter_tile_files(args.only):
        source = args.source_dir / filename
        if not source.exists():
            raise FileNotFoundError(f"missing source tile: {source}")
        output = args.out_dir / filename
        atomic_save(composite_tile(body, source), output)
        built.append(output)

    make_contact_sheet(built, args.contact_sheet, max(1, args.columns))
    print(f"Built {len(built)} subtle 3D tile candidates in {args.out_dir}")
    print(f"Body mode: {args.body_mode}")
    if args.body_mode in ["generated", "generated-mask-material"]:
        print(f"Body: {args.body}")
    print(f"Contact sheet: {args.contact_sheet}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
