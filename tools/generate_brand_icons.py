#!/usr/bin/env python3
from pathlib import Path

from PIL import Image, ImageDraw, ImageEnhance, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets/tiles/tile_honor_east.png"
OUTPUT = ROOT / "assets/branding"
SIZE = 1024


def rounded_mask(size: int | tuple[int, int], radius: int) -> Image.Image:
    dimensions = (size, size) if isinstance(size, int) else size
    mask = Image.new("L", dimensions, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, dimensions[0] - 1, dimensions[1] - 1), radius, fill=255)
    return mask


def radial_glow(size: int) -> Image.Image:
    glow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    pixels = glow.load()
    center = (size - 1) * 0.5
    for y in range(size):
        for x in range(size):
            distance = (((x - center) / center) ** 2 + ((y - center) / center) ** 2) ** 0.5
            strength = max(0.0, 1.0 - distance)
            pixels[x, y] = (42, 112, 87, int(150 * strength * strength))
    return glow


def build_foreground() -> Image.Image:
    tile = Image.open(SOURCE).convert("RGBA")
    tile = tile.crop((9, 3, tile.width - 10, tile.height - 9))
    tile.putalpha(rounded_mask(tile.size, 18))
    target_height = 610
    target_width = round(tile.width * target_height / tile.height)
    tile = tile.resize((target_width, target_height), Image.Resampling.LANCZOS)
    tile = ImageEnhance.Contrast(tile).enhance(1.08)
    foreground = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    x = (SIZE - tile.width) // 2
    y = (SIZE - tile.height) // 2 - 8
    shadow = Image.new("RGBA", foreground.size, (0, 0, 0, 0))
    shadow.paste((0, 0, 0, 190), (x + 22, y + 32, x + tile.width + 22, y + tile.height + 32), tile.getchannel("A"))
    foreground.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(28)))
    foreground.alpha_composite(tile, (x, y))
    return foreground


def build_background() -> Image.Image:
    background = Image.new("RGBA", (SIZE, SIZE), (16, 27, 24, 255))
    background.alpha_composite(radial_glow(SIZE))
    draw = ImageDraw.Draw(background)
    draw.rounded_rectangle((36, 36, SIZE - 37, SIZE - 37), 190, outline=(116, 86, 39, 255), width=18)
    draw.rounded_rectangle((58, 58, SIZE - 59, SIZE - 59), 170, outline=(208, 169, 82, 180), width=5)
    return background


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    foreground = build_foreground()
    background = build_background()
    icon = background.copy()
    icon.alpha_composite(foreground)
    mask = rounded_mask(SIZE, 190)
    icon.putalpha(mask)
    icon.save(OUTPUT / "app_icon_1024.png", optimize=True)
    foreground.save(OUTPUT / "app_icon_foreground_1024.png", optimize=True)
    background.convert("RGB").save(OUTPUT / "app_icon_background_1024.png", optimize=True)


if __name__ == "__main__":
    main()
