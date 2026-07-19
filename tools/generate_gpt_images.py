#!/usr/bin/env python3
"""Generate GPT image assets from GPT_IMAGE_ASSET_BRIEF.md."""

from __future__ import annotations

import argparse
import base64
import io
import json
import os
import re
import sys
import time
import tempfile
from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageOps
from openai import OpenAI


ROOT = Path(__file__).resolve().parents[1]
BRIEF_PATH = ROOT / "GPT_IMAGE_ASSET_BRIEF.md"
DEFAULT_MODEL = "gpt-image-2"


@dataclass(frozen=True)
class ImageTask:
    index: int
    name: str
    path: Path
    size: str
    prompt: str
    source: str = "brief"


def parse_tasks(brief_path: Path) -> list[ImageTask]:
    text = brief_path.read_text(encoding="utf-8")
    sections = re.split(r"\n###\s+(\d+)\.\s+`([^`]+)`\n", text)
    tasks: list[ImageTask] = []

    for offset in range(1, len(sections), 3):
        index = int(sections[offset])
        name = sections[offset + 1]
        body = sections[offset + 2]

        path_match = re.search(r"- 保存路径：`([^`]+)`", body)
        size_match = re.search(r"- 推荐尺寸：`([^`]+)`", body)
        prompt_match = re.search(r"Prompt:\s*\n\n```text\n(.*?)\n```", body, re.DOTALL)
        if not (path_match and size_match and prompt_match):
            continue

        tasks.append(
            ImageTask(
                index=index,
                name=name,
                path=ROOT / path_match.group(1),
                size=size_match.group(1),
                prompt=prompt_match.group(1).strip(),
            )
        )

    return tasks


def parse_registered_illustration_tasks() -> list[ImageTask]:
    main_base_path = ROOT / "scripts" / "main_base.gd"
    text = main_base_path.read_text(encoding="utf-8")
    match = re.search(r"const ILLUSTRATION_ASSET_PATHS := \{(.*?)\n\}", text, re.DOTALL)
    if not match:
        raise RuntimeError(f"Could not find ILLUSTRATION_ASSET_PATHS in {main_base_path}")

    pairs = re.findall(r'"([^"]+)":\s*"res://([^"]+)"', match.group(1))
    tasks: list[ImageTask] = []
    for offset, (name, rel_path) in enumerate(pairs, start=1):
        path = ROOT / rel_path
        size = image_size(path)
        display_name = name.replace("_", " ")
        prompt = (
            "Create a Chinese guofeng mobile mahjong game UI illustration asset.\n"
            f"Asset name and purpose cue: {display_name}.\n"
            f"Asset type: reusable PNG game UI texture, {size}.\n"
            "Style/medium: polished premium game UI illustration, Chinese ink wash, dark jade silk, warm gold foil, restrained cinnabar accents.\n"
            "Composition/framing: match the named UI purpose, keep the main shape readable at small size, preserve generous safe padding, no hard engine-rendered button labels.\n"
            "Lighting/mood: calm, elegant, tactile, suitable for overlaying under Godot UI controls.\n"
            "Color palette: deep jade, ink black, muted teal, warm gold, tiny cinnabar details only.\n"
            "Constraints: no words, no numbers, no logo, no watermark, no real brands, no people, no readable mahjong tile symbols.\n"
            "Avoid: placeholder vector art, flat programmatic gradients, casino neon, western fantasy styling, beige parchment dominance, cluttered centers."
        )
        tasks.append(
            ImageTask(
                index=offset,
                name=name,
                path=path,
                size=size,
                prompt=prompt,
                source="fixed-registry",
            )
        )

    return tasks


def image_size(path: Path) -> str:
    with Image.open(path) as image:
        width, height = image.size
    return f"{width}x{height}"


def parse_size(size: str) -> tuple[int, int]:
    width, height = size.lower().split("x", 1)
    return int(width), int(height)


def api_size_for_target(target_size: str) -> str:
    """Use model-supported canvas sizes, then normalize locally."""
    width, height = parse_size(target_size)
    ratio = width / height
    if ratio >= 1.18:
        return "1536x1024"
    if ratio <= 0.85:
        return "1024x1536"
    return "1024x1024"


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


def normalize_png_bytes(image_bytes: bytes, target_size: str) -> Image.Image:
    with Image.open(io.BytesIO(image_bytes)) as source:
        image = ImageOps.exif_transpose(source).convert("RGBA")
        return ImageOps.fit(
            image,
            parse_size(target_size),
            method=Image.Resampling.LANCZOS,
            centering=(0.5, 0.5),
        )


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


def generate_image(client: OpenAI, task: ImageTask, model: str) -> None:
    task.path.parent.mkdir(parents=True, exist_ok=True)
    request_size = api_size_for_target(task.size)
    result = client.images.generate(
        model=model,
        prompt=task.prompt,
        size=request_size,
        n=1,
    )

    image = result.data[0]
    if not image.b64_json:
        raise RuntimeError(f"{task.name}: API response did not include b64_json image data")

    generated = base64.b64decode(image.b64_json)
    normalized = normalize_png_bytes(generated, task.size)
    atomic_save_png(normalized, task.path)


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
                if key.lower() in {"content-type", "x-request-id", "x-ratelimit-limit-requests", "x-ratelimit-remaining-requests", "retry-after"}
            }
            if interesting:
                details.append("headers=" + json.dumps(interesting, ensure_ascii=False, sort_keys=True))
        if text:
            details.append(f"body={text}")
    return " | ".join(details)


def generate_image_with_retry(client: OpenAI, task: ImageTask, model: str, retries: int = 3) -> None:
    for attempt in range(1, retries + 1):
        try:
            generate_image(client, task, model)
            return
        except Exception as exc:
            if attempt >= retries:
                print(f"fatal error for {task.name}: {format_exception(exc)}", file=sys.stderr)
                raise
            wait_seconds = min(10, 2 ** (attempt - 1))
            print(
                f"retry {attempt}/{retries - 1} for {task.name} after error: {format_exception(exc)}; waiting {wait_seconds}s",
                file=sys.stderr,
            )
            time.sleep(wait_seconds)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Generate GPT illustration PNG assets listed in GPT_IMAGE_ASSET_BRIEF.md."
    )
    parser.add_argument(
        "--model",
        default=None,
        help=f"OpenAI image model, default: OPENAI_IMAGE_MODEL or {DEFAULT_MODEL}",
    )
    parser.add_argument("--only", action="append", default=[], help="Generate only matching file names or paths")
    parser.add_argument("--force", action="store_true", help="Overwrite existing PNG files")
    parser.add_argument("--list", action="store_true", help="List parsed image tasks without generating")
    parser.add_argument("--probe", action="store_true", help="Attempt only the first generated task and stop after the first error")
    parser.add_argument(
        "--include-fixed-registry",
        action="store_true",
        help="Also generate fixed assets from ILLUSTRATION_ASSET_PATHS in scripts/main_base.gd.",
    )
    parser.add_argument(
        "--fixed-only",
        action="store_true",
        help="Generate only fixed registry assets. Implies --include-fixed-registry.",
    )
    args = parser.parse_args()

    tasks: list[ImageTask] = []
    if not args.fixed_only:
        tasks.extend(parse_tasks(BRIEF_PATH))
    if args.include_fixed_registry or args.fixed_only:
        tasks.extend(parse_registered_illustration_tasks())
    if args.only:
        needles = [value.lower() for value in args.only]
        tasks = [
            task
            for task in tasks
            if any(needle in task.name.lower() or needle in str(task.path.relative_to(ROOT)).lower() for needle in needles)
        ]

    if not tasks:
        print("No matching GPT image tasks found.", file=sys.stderr)
        return 1

    for task in tasks:
        rel_path = task.path.relative_to(ROOT)
        print(f"{task.index:02d}. {rel_path} ({task.size}, {task.source})")

    if args.list:
        return 0

    load_project_env()

    if not os.environ.get("OPENAI_API_KEY"):
        print("OPENAI_API_KEY is not set. Export it before generating images.", file=sys.stderr)
        return 2

    model = args.model or os.environ.get("OPENAI_IMAGE_MODEL") or DEFAULT_MODEL
    client = OpenAI(base_url=os.environ.get("OPENAI_BASE_URL") or None)
    for task in tasks:
        rel_path = task.path.relative_to(ROOT)
        if task.path.exists() and not args.force:
            print(f"skip existing: {rel_path}")
            continue

        print(f"generate: {rel_path}")
        generate_image_with_retry(client, task, model)
        if args.probe:
            break

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
