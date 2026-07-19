#!/usr/bin/env python3
"""Derive seamless mobile-friendly PBR maps from the promoted table textures."""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageChops, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
TABLE_DIR = ROOT / "assets" / "table"
MAP_SIZE = (512, 512)


def clamp_byte(value: float) -> int:
    return max(0, min(255, int(round(value))))


def derive_maps(source_name: str, stem: str, normal_strength: float, roughness: int, variation: float) -> None:
    source = Image.open(TABLE_DIR / source_name).convert("RGB")
    source = source.resize(MAP_SIZE, Image.Resampling.LANCZOS)
    grayscale = source.convert("L")

    # Removing broad lighting variation keeps the generated normal map tileable and
    # limits it to fibers/grain that should actually react to a moving light.
    blurred = grayscale.filter(ImageFilter.GaussianBlur(radius=5.0))
    height = ImageChops.subtract(grayscale, blurred, scale=1.0, offset=128)
    height_pixels = height.load()
    width, height_px = height.size
    normal = Image.new("RGB", height.size)
    normal_pixels = normal.load()
    roughness_map = Image.new("L", height.size)
    roughness_pixels = roughness_map.load()

    for y in range(height_px):
        ym = (y - 1) % height_px
        yp = (y + 1) % height_px
        for x in range(width):
            xm = (x - 1) % width
            xp = (x + 1) % width
            dx = float(height_pixels[xp, y] - height_pixels[xm, y]) / 255.0
            dy = float(height_pixels[x, yp] - height_pixels[x, ym]) / 255.0
            nx = -dx * normal_strength
            ny = dy * normal_strength
            nz = 1.0
            inv_length = 1.0 / math.sqrt(nx * nx + ny * ny + nz * nz)
            normal_pixels[x, y] = (
                clamp_byte((nx * inv_length * 0.5 + 0.5) * 255.0),
                clamp_byte((ny * inv_length * 0.5 + 0.5) * 255.0),
                clamp_byte((nz * inv_length * 0.5 + 0.5) * 255.0),
            )
            micro_height = abs(float(height_pixels[x, y]) - 128.0)
            roughness_pixels[x, y] = clamp_byte(float(roughness) + micro_height * variation)

    normal.save(TABLE_DIR / f"{stem}_normal.png", optimize=True)
    roughness_map.save(TABLE_DIR / f"{stem}_roughness.png", optimize=True)


def main() -> None:
    derive_maps("table_felt_3d_gpt.png", "table_felt_3d", 4.2, 216, 0.72)
    derive_maps("table_lacquer_3d_gpt.png", "table_lacquer_3d", 1.7, 48, 0.42)
    print("generated seamless 3D material maps in assets/table")


if __name__ == "__main__":
    main()
