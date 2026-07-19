#!/usr/bin/env python3
"""Extract exact transparent face decals from the baked subtle-3D tile set."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageChops


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "assets" / "tiles_subtle_3d"
OUTPUT_DIR = ROOT / "assets" / "tile_decals_3d"
BLANK_PATH = SOURCE_DIR / "_tile_body_subtle_3d.png"
TRANSPARENT_THRESHOLD = 5
OPAQUE_THRESHOLD = 30


def alpha_from_difference(tile: Image.Image, blank: Image.Image) -> Image.Image:
    difference = ImageChops.difference(tile.convert("RGB"), blank.convert("RGB"))
    red, green, blue = difference.split()
    strength = ImageChops.lighter(ImageChops.lighter(red, green), blue)

    def matte(value: int) -> int:
        if value <= TRANSPARENT_THRESHOLD:
            return 0
        if value >= OPAQUE_THRESHOLD:
            return 255
        return round((value - TRANSPARENT_THRESHOLD) * 255 / (OPAQUE_THRESHOLD - TRANSPARENT_THRESHOLD))

    alpha = strength.point(matte)
    # Tile art never reaches the baked shell edges. This guard removes compression
    # differences from the source border without touching any legal tile symbol.
    edge_guard = Image.new("L", tile.size, 0)
    guard_pixels = edge_guard.load()
    width, height = tile.size
    for y in range(22, height - 42):
        for x in range(34, width - 34):
            guard_pixels[x, y] = 255
    return ImageChops.multiply(alpha, edge_guard)


def extract_decal(source_path: Path, blank: Image.Image) -> tuple[Path, float]:
    tile = Image.open(source_path).convert("RGBA")
    if tile.size != blank.size:
        raise ValueError(f"unexpected tile size for {source_path}: {tile.size} != {blank.size}")
    alpha = alpha_from_difference(tile, blank)
    output = tile.copy()
    output.putalpha(alpha)
    output_path = OUTPUT_DIR / source_path.name
    output.save(output_path, optimize=True)
    alpha_histogram = alpha.histogram()
    visible_pixels = sum(alpha_histogram[1:])
    coverage = visible_pixels / float(tile.width * tile.height)
    if coverage < 0.008 or coverage > 0.45:
        raise ValueError(f"implausible decal coverage for {source_path.name}: {coverage:.3%}")
    if alpha.getpixel((0, 0)) != 0 or alpha.getpixel((tile.width - 1, tile.height - 1)) != 0:
        raise ValueError(f"decal corners are not transparent: {source_path.name}")
    return output_path, coverage


def main() -> None:
    blank = Image.open(BLANK_PATH).convert("RGBA")
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    source_paths = sorted(path for path in SOURCE_DIR.glob("tile_*.png") if path.is_file())
    if not source_paths:
        raise RuntimeError("no source tiles found")
    coverages: list[float] = []
    for source_path in source_paths:
        _, coverage = extract_decal(source_path, blank)
        coverages.append(coverage)
    print(
        "generated %d exact 3D tile decals (coverage %.1f%%-%.1f%%)"
        % (len(source_paths), min(coverages) * 100.0, max(coverages) * 100.0)
    )


if __name__ == "__main__":
    main()
