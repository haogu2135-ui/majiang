#!/usr/bin/env python3
"""Normalize generated GPT illustration PNGs to the brief's target sizes."""

from __future__ import annotations

import argparse
import tempfile
from pathlib import Path

from PIL import Image, ImageOps

from generate_gpt_images import BRIEF_PATH, ROOT, parse_tasks


def parse_size(size: str) -> tuple[int, int]:
    width, height = size.lower().split("x", 1)
    return int(width), int(height)


def atomic_save_png(image: Image.Image, path: Path) -> None:
    temp_path: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(
            dir=path.parent,
            prefix=f".{path.stem}.",
            suffix=".png",
            delete=False,
        ) as temp_file:
            temp_path = Path(temp_file.name)
            image.save(temp_file, format="PNG")
        temp_path.replace(path)
    finally:
        if temp_path is not None and temp_path.exists():
            temp_path.unlink()


def normalize_image(path: Path, target_size: tuple[int, int]) -> bool:
    with Image.open(path) as source:
        image = ImageOps.exif_transpose(source).convert("RGBA")
        if image.size == target_size:
            return False

        normalized = ImageOps.fit(
            image,
            target_size,
            method=Image.Resampling.LANCZOS,
            centering=(0.5, 0.5),
        )

    atomic_save_png(normalized, path)
    return True


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Resize/crop GPT illustration assets to GPT_IMAGE_ASSET_BRIEF.md target sizes."
    )
    parser.add_argument("--check", action="store_true", help="Report nonconforming files without changing them")
    parser.add_argument("--only", action="append", default=[], help="Normalize only matching file names or paths")
    args = parser.parse_args()

    tasks = parse_tasks(BRIEF_PATH)
    if args.only:
        needles = [value.lower() for value in args.only]
        tasks = [
            task
            for task in tasks
            if any(needle in task.name.lower() or needle in str(task.path.relative_to(ROOT)).lower() for needle in needles)
        ]

    missing: list[Path] = []
    mismatched: list[tuple[Path, tuple[int, int], tuple[int, int]]] = []
    changed: list[Path] = []

    for task in tasks:
        target_size = parse_size(task.size)
        if not task.path.exists():
            missing.append(task.path)
            continue

        with Image.open(task.path) as image:
            current_size = image.size

        if current_size != target_size:
            mismatched.append((task.path, current_size, target_size))
            if not args.check and normalize_image(task.path, target_size):
                changed.append(task.path)

    if missing:
        print("Missing GPT illustration assets:")
        for path in missing:
            print(f"- {path.relative_to(ROOT)}")

    if args.check:
        if mismatched:
            print("GPT illustration assets with non-target dimensions:")
            for path, current_size, target_size in mismatched:
                print(
                    f"- {path.relative_to(ROOT)}: "
                    f"{current_size[0]}x{current_size[1]} != {target_size[0]}x{target_size[1]}"
                )
        return 1 if missing or mismatched else 0

    for path in changed:
        print(f"normalized: {path.relative_to(ROOT)}")

    print(f"Checked {len(tasks)} GPT illustration assets; normalized {len(changed)}.")
    return 1 if missing else 0


if __name__ == "__main__":
    raise SystemExit(main())
