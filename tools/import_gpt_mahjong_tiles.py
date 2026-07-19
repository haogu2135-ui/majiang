#!/usr/bin/env python3
"""Import GPT-generated mahjong tile candidates into the game asset names."""

from __future__ import annotations

import argparse
from pathlib import Path
import tempfile

from PIL import Image, ImageOps


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / ".tmp" / "gpt-generated-mahjong-tiles"
OUT_DIR = ROOT / "assets" / "tiles"
WIDTH = 200
HEIGHT = 280


EXPECTED_TILES = [
    "tile_back.png",
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


def fit_to_canvas(image: Image.Image) -> Image.Image:
    """Normalize a generated portrait candidate to the game sprite size."""
    image = image.convert("RGBA")
    return ImageOps.fit(
        image,
        (WIDTH, HEIGHT),
        method=Image.Resampling.LANCZOS,
        centering=(0.5, 0.5),
    )


def write_png_atomically(image: Image.Image, output: Path) -> None:
    temp_path: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(
            dir=OUT_DIR,
            prefix=f".{output.stem}.",
            suffix=".png",
            delete=False,
        ) as temp_file:
            temp_path = Path(temp_file.name)
            image.save(temp_file, format="PNG")
        temp_path.replace(output)
    finally:
        if temp_path is not None and temp_path.exists():
            temp_path.unlink()


def validate_sources(source_dir: Path) -> list[Path]:
    if not source_dir.exists():
        raise FileNotFoundError(f"missing GPT candidate directory: {source_dir}")

    missing = [name for name in EXPECTED_TILES if not (source_dir / name).exists()]
    if missing:
        missing_list = "\n  ".join(missing)
        raise FileNotFoundError(f"missing GPT candidate tile(s):\n  {missing_list}")

    return [source_dir / name for name in EXPECTED_TILES]


def filter_names(names: list[str], only: list[str]) -> list[str]:
    if not only:
        return names

    needles = [value.lower() for value in only]
    selected = [
        name
        for name in names
        if any(needle in name.lower() for needle in needles)
    ]
    if not selected:
        raise ValueError(f"no tile names matched --only value(s): {', '.join(only)}")
    return selected


def main() -> int:
    parser = argparse.ArgumentParser(description="Normalize GPT mahjong tile candidates into assets/tiles.")
    parser.add_argument(
        "--source-dir",
        type=Path,
        default=SOURCE_DIR,
        help=f"Candidate directory, default: {SOURCE_DIR}",
    )
    parser.add_argument(
        "--only",
        action="append",
        default=[],
        help="Import only candidate file names containing this text, for example --only tile_flower",
    )
    args = parser.parse_args()

    source_dir = args.source_dir
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    if args.only:
        if not source_dir.exists():
            raise FileNotFoundError(f"missing GPT candidate directory: {source_dir}")
        sources = [source_dir / name for name in filter_names(EXPECTED_TILES, args.only)]
        missing = [source.name for source in sources if not source.exists()]
        if missing:
            missing_list = "\n  ".join(missing)
            raise FileNotFoundError(f"missing selected GPT candidate tile(s):\n  {missing_list}")
    else:
        sources = validate_sources(source_dir)

    for source in sources:
        with Image.open(source) as source_image:
            tile = fit_to_canvas(source_image)
        write_png_atomically(tile, OUT_DIR / source.name)

    print(f"Imported {len(sources)} GPT-generated mahjong tiles into {OUT_DIR}")
    print(f"Source candidates: {source_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
