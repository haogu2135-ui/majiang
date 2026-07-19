#!/usr/bin/env python3
"""Generate clean GPT mahjong tile sprite candidates from current runtime tiles.

Every candidate must use the existing `assets/tiles/<same name>.png` sprite as
the authoritative reference image. The model may retouch contrast, cleanup,
and edge clarity, but it must not invent tile markings from text alone or add a
fake 3D body style.
"""

from __future__ import annotations

import argparse
import base64
import io
import json
import os
import sys
import tempfile
import time
from dataclasses import dataclass
from pathlib import Path

from openai import OpenAI
from PIL import Image, ImageOps


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / ".tmp" / "gpt-generated-mahjong-tiles"
REFERENCE_DIR = ROOT / "assets" / "tiles"
DEFAULT_MODEL = "gpt-image-2"
REQUEST_SIZE = "1024x1536"


@dataclass(frozen=True)
class TileTask:
    filename: str
    title: str
    face: str
    reference_path: Path | None = None
    reference_kind: str = "none"


@dataclass(frozen=True)
class FlowerSpec:
    label: str
    name: str
    layout: str


FLOWER_SPECS = [
    FlowerSpec("春", "spring", "red number 1 near the top corner, Chinese character '春' on the opposite side, sparse green stems and small red blossoms"),
    FlowerSpec("夏", "summer", "red number 2 near the top corner, Chinese character '夏' on the opposite side, sparse green stems and small red blossoms"),
    FlowerSpec("秋", "autumn", "red number 3 near the top corner, Chinese character '秋' on the opposite side, sparse green stems and small red blossoms"),
    FlowerSpec("冬", "winter", "red number 4 near the top corner, Chinese character '冬' on the opposite side, sparse green stems and small red blossoms"),
    FlowerSpec("梅", "plum", "red number 1 near the top corner, Chinese character '梅' on the opposite side, simple plum branch with green strokes and red flowers"),
    FlowerSpec("兰", "orchid", "red number 2 near the top corner, Chinese character '兰' on the opposite side, simple orchid leaves with green strokes and red flowers"),
    FlowerSpec("竹", "bamboo", "red number 3 near the top corner, Chinese character '竹' on the opposite side, simple bamboo sprig with green strokes and red accents"),
    FlowerSpec("菊", "chrysanthemum", "red number 4 near the top corner, Chinese character '菊' on the opposite side, simple chrysanthemum plant with green strokes and red flowers"),
]


def with_default_reference(filename: str, title: str, face: str) -> TileTask:
    return TileTask(filename, title, face, REFERENCE_DIR / filename, "current_tile")


def number_words(n: int) -> str:
    return ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"][n - 1]


def wan_char(n: int) -> str:
    return ["一", "二", "三", "四", "五", "六", "七", "八", "九"][n - 1]


def pin_layout(n: int) -> str:
    if n == 7:
        return (
            "exactly seven circular coin pips arranged as a traditional 7-dot mahjong tile: "
            "three dark blue/black pips diagonally across the upper half and four red pips in a compact 2x2 block in the lower half; "
            "only these seven circular flower-like pips may appear on the tile face; do not add any Arabic numeral, corner index, Chinese numeral, label, caption, or extra mark"
        )
    return (
        f"{number_words(n)} circular coin pips arranged in the standard mahjong {n}-dot layout; "
        "each pip is a crisp ring with blue, red, and green enamel accents; "
        "do not add Arabic numerals, corner indexes, labels, captions, or any extra text"
    )


def sou_layout(n: int) -> str:
    if n == 1:
        return (
            "the traditional one-bamboo bird motif, centered and crisp, with green body, "
            "red beak accent, and blue-green tail details"
        )
    if n == 8:
        return (
            "the 8-bamboo face shown in the current in-game reference tile: exactly two large green interlaced bamboo-knot symbols, "
            "one in the upper half and one in the lower half, each symbol shaped like a flowing W/M made from thick curved bamboo strokes; "
            "do not draw eight separate stick pips, do not add small bamboo sticks, numbers, labels, or extra marks; "
            "the two symbols are bold, centered, symmetrical, and painted in deep green enamel with subtle red accent cuts"
        )
    return (
        f"{number_words(n)} bamboo stick pips arranged in the standard mahjong {n}-bamboo layout; "
        "each bamboo pip is a clean green stalk with small red or blue accent bands"
    )


def build_tasks() -> list[TileTask]:
    tasks: list[TileTask] = []

    tasks.append(
        with_default_reference(
            "tile_back.png",
            "mahjong tile back",
            "the back side of a real mahjong tile: dark jade green recessed panel, subtle woven texture, thin gold border, no readable symbols",
        )
    )

    for n in range(1, 10):
        tasks.append(
            with_default_reference(
                f"tile_man{n}.png",
                f"{n}-characters tile",
                f"top Chinese numeral '{wan_char(n)}' in red and large lower character '萬' in black, exactly like a traditional {n}-characters mahjong tile",
            )
        )
    for n in range(1, 10):
        tasks.append(with_default_reference(f"tile_pin{n}.png", f"{n}-dots tile", pin_layout(n)))
    for n in range(1, 10):
        tasks.append(with_default_reference(f"tile_sou{n}.png", f"{n}-bamboo tile", sou_layout(n)))

    tasks.extend(
        [
            with_default_reference("tile_honor_east.png", "east wind tile", "single large black Chinese character '东' centered on the face"),
            with_default_reference("tile_honor_south.png", "south wind tile", "single large black Chinese character '南' centered on the face"),
            with_default_reference("tile_honor_west.png", "west wind tile", "single large black Chinese character '西' centered on the face"),
            with_default_reference("tile_honor_north.png", "north wind tile", "single large black Chinese character '北' centered on the face"),
            with_default_reference("tile_honor_red.png", "red dragon tile", "single large red Chinese character '中' centered on the face"),
            with_default_reference("tile_honor_green.png", "green dragon tile", "single large green Chinese character '發' centered on the face"),
            with_default_reference("tile_honor_white.png", "white dragon tile", "plain white dragon face with a centered black rectangular frame, no text"),
        ]
    )

    for idx, spec in enumerate(FLOWER_SPECS, start=1):
        tasks.append(
            TileTask(
                f"tile_flower_h{idx}.png",
                f"{spec.name} flower tile",
                (
                    f"traditional Chinese mahjong flower tile for '{spec.label}'. Follow the provided real flower tile photo's "
                    f"overall layout: {spec.layout}. Use a small, simplified hand-painted plant motif, not a full scenic illustration."
                ),
                REFERENCE_DIR / f"tile_flower_h{idx}.png",
                "current_tile",
            )
        )

    return tasks


def load_env_file(path: Path) -> None:
    try:
        text = path.read_text(encoding="utf-8")
    except FileNotFoundError:
        return

    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        if key and key not in os.environ:
            os.environ[key] = value


def load_project_env() -> None:
    for path in (ROOT / ".env", ROOT / ".gateway.env", Path.home() / ".gateway.env"):
        load_env_file(path)


def prompt_for(task: TileTask) -> str:
    reference_instruction = (
        "Reference image: this is the current in-game mahjong tile sprite and it is authoritative. "
        "Use it as the primary source for every marking: symbol identity, exact count, placement, color order, character shape, flower numbering, and overall tile-face layout. "
        "Do not invent, reinterpret, simplify away, add, remove, or move any playable marking from the reference. "
        "Redraw it only as a clean flat 2D game sprite with crisp markings; preserve gameplay readability above style.\n"
    )

    return (
        "Create one isolated, front-facing Chinese mahjong tile as a clean mobile game sprite.\n"
        f"Tile identity: {task.title}.\n"
        f"Face specification: {task.face}.\n"
        f"{reference_instruction}"
        "Tile body: ivory white face, soft rounded rectangle silhouette, minimal bevel only, no visible side wall, no heavy thickness, no gold edge, no metallic rim.\n"
        "Composition: portrait 2:3 canvas, the tile fills almost the entire image height, perfectly centered, straight-on orthographic view, no rotation.\n"
        "Rendering: crisp flat/enamel symbols, high contrast, clean anti-aliased edges, restrained porcelain shading, production-ready mobile game asset.\n"
        "Background: transparent or plain very light neutral background only.\n"
        "Strict constraints: exactly one tile, no 3D extrusion, no dramatic perspective, no hands, no table, no other tiles, no watermark, no logo, no corner indexes, no extra text outside the specified tile face, no blur, no cropped edges."
    )


def atomic_save_png(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
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


def normalize_candidate(image_bytes: bytes) -> Image.Image:
    with Image.open(io.BytesIO(image_bytes)) as source:
        image = ImageOps.exif_transpose(source).convert("RGBA")
        return image


def validate_reference_images(tasks: list[TileTask]) -> None:
    checked: set[Path] = set()
    for task in tasks:
        if task.reference_path is None or task.reference_path in checked:
            continue
        checked.add(task.reference_path)
        if not task.reference_path.exists():
            raise FileNotFoundError(f"{task.filename}: missing reference image {task.reference_path}")
        with Image.open(task.reference_path) as image:
            ImageOps.exif_transpose(image).verify()


def format_exception(exc: Exception) -> str:
    details = [f"{exc.__class__.__name__}: {exc}"]
    response = getattr(exc, "response", None)
    if response is not None:
        status_code = getattr(response, "status_code", None)
        headers = getattr(response, "headers", None)
        text = getattr(response, "text", None)
        if status_code is not None:
            details.append(f"status_code={status_code}")
        if headers:
            interesting = {
                key: headers[key]
                for key in headers
                if key.lower() in {"content-type", "x-request-id", "retry-after"}
            }
            if interesting:
                details.append("headers=" + json.dumps(interesting, ensure_ascii=False, sort_keys=True))
        if text:
            details.append(f"body={text}")
    return " | ".join(details)


def generate_one(client: OpenAI, model: str, task: TileTask) -> None:
    if task.reference_path is None:
        raise RuntimeError(f"{task.filename}: missing current tile reference path")
    with task.reference_path.open("rb") as reference_file:
        result = client.images.edit(
            model=model,
            image=reference_file,
            prompt=prompt_for(task),
            size=REQUEST_SIZE,
            n=1,
            input_fidelity="high",
        )
    image = result.data[0]
    if not image.b64_json:
        raise RuntimeError(f"{task.filename}: API response did not include b64_json image data")
    candidate = normalize_candidate(base64.b64decode(image.b64_json))
    atomic_save_png(candidate, OUT_DIR / task.filename)


def generate_with_retry(client: OpenAI, model: str, task: TileTask, retries: int) -> None:
    for attempt in range(1, retries + 1):
        try:
            generate_one(client, model, task)
            return
        except Exception as exc:
            if attempt >= retries:
                print(f"fatal error for {task.filename}: {format_exception(exc)}", file=sys.stderr)
                raise
            wait_seconds = min(20, 2 ** attempt)
            print(
                f"retry {attempt}/{retries - 1} for {task.filename}: {format_exception(exc)}; waiting {wait_seconds}s",
                file=sys.stderr,
            )
            time.sleep(wait_seconds)


def filter_tasks(tasks: list[TileTask], only: list[str]) -> list[TileTask]:
    if not only:
        return tasks
    needles = [value.lower() for value in only]
    return [
        task
        for task in tasks
        if any(needle in task.filename.lower() or needle in task.title.lower() for needle in needles)
    ]


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate a full GPT mahjong tile candidate set.")
    parser.add_argument("--model", default=None, help=f"OpenAI image model, default: OPENAI_IMAGE_MODEL or {DEFAULT_MODEL}")
    parser.add_argument("--only", action="append", default=[], help="Generate only matching tile file names or titles")
    parser.add_argument("--force", action="store_true", help="Overwrite existing candidate PNG files")
    parser.add_argument("--list", action="store_true", help="List tile generation tasks without calling the API")
    parser.add_argument("--probe", action="store_true", help="Generate the first selected tile only")
    parser.add_argument("--retries", type=int, default=3, help="Retries per tile")
    args = parser.parse_args()

    tasks = filter_tasks(build_tasks(), args.only)
    if args.probe:
        tasks = tasks[:1]
    if not tasks:
        print("No matching mahjong tile tasks found.", file=sys.stderr)
        return 1

    for index, task in enumerate(tasks, start=1):
        reference = f" [{task.reference_kind}: {task.reference_path.relative_to(ROOT)}]" if task.reference_path else ""
        print(f"{index:02d}. {task.filename} - {task.title}{reference}")
    if args.list:
        return 0

    try:
        validate_reference_images(tasks)
    except Exception as exc:
        print(f"Reference image validation failed: {format_exception(exc)}", file=sys.stderr)
        return 2

    load_project_env()
    if not os.environ.get("OPENAI_API_KEY"):
        print("OPENAI_API_KEY is not set. Export it before generating images.", file=sys.stderr)
        return 2

    model = args.model or os.environ.get("OPENAI_IMAGE_MODEL") or DEFAULT_MODEL
    client = OpenAI(base_url=os.environ.get("OPENAI_BASE_URL") or None)
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    for task in tasks:
        output = OUT_DIR / task.filename
        if output.exists() and not args.force:
            print(f"skip existing: {output.relative_to(ROOT)}")
            continue
        print(f"generate: {output.relative_to(ROOT)}")
        generate_with_retry(client, model, task, args.retries)

    print(f"Generated candidates in {OUT_DIR}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
