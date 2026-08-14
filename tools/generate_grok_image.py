#!/usr/bin/env python3
"""Generate a Grok Imagine candidate image without storing credentials."""

from __future__ import annotations

import argparse
import base64
import json
import os
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path
from urllib.parse import urlparse, urlunparse


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_BASE_URL = "https://chybenzun.top/v1"
DEFAULT_MODEL = "grok-imagine-image-lite"
DEFAULT_USER_AGENT = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/126.0.0.0 Safari/537.36"
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


def read_prompt(args: argparse.Namespace) -> str:
    if args.prompt_file:
        text = Path(args.prompt_file).read_text(encoding="utf-8").strip()
        fenced = re.search(r"```(?:text)?\s*\n(.*?)\n```", text, re.DOTALL)
        return fenced.group(1).strip() if fenced else text
    if args.prompt:
        return args.prompt.strip()
    raise ValueError("Provide --prompt or --prompt-file.")


def browser_headers(api_key: str, base_url: str) -> dict[str, str]:
    origin = base_url.split("/v1", 1)[0].rstrip("/")
    return {
        "Authorization": "Bearer " + api_key,
        "Content-Type": "application/json",
        "Accept": "application/json, text/plain, */*",
        "User-Agent": DEFAULT_USER_AGENT,
        "Origin": origin,
        "Referer": origin + "/",
    }


def sniff_extension(data: bytes, fallback: str = ".bin") -> str:
    if data.startswith(b"\xff\xd8\xff"):
        return ".jpg"
    if data.startswith(b"\x89PNG\r\n\x1a\n"):
        return ".png"
    if data.startswith(b"RIFF") and data[8:12] == b"WEBP":
        return ".webp"
    return fallback


def output_path_for_bytes(requested_path: Path, data: bytes, keep_suffix: bool) -> Path:
    if keep_suffix and requested_path.suffix:
        return requested_path
    actual_suffix = sniff_extension(data, requested_path.suffix or ".jpg")
    if requested_path.suffix.lower() == actual_suffix.lower():
        return requested_path
    return requested_path.with_suffix(actual_suffix)


def request_json(url: str, payload: dict[str, object], headers: dict[str, str], timeout: int) -> dict[str, object]:
    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers=headers,
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            return json.loads(resp.read().decode("utf-8", errors="replace"))
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")[:2000]
        raise RuntimeError(f"HTTP {exc.code}: {body}") from exc


def resolve_sub2api_media_url(url: str, base_url: str) -> str:
    """Map Sub2API's internal media port back to its public local API port."""
    parsed = urlparse(url)
    gateway = urlparse(base_url)
    if parsed.hostname not in {"127.0.0.1", "localhost"}:
        return url
    if parsed.port != 18889 or gateway.hostname not in {"127.0.0.1", "localhost"}:
        return url
    if not gateway.scheme or not gateway.netloc:
        return url
    path = parsed.path
    if path.startswith("/v1/"):
        path = path[3:]
    return urlunparse((gateway.scheme, gateway.netloc, path, parsed.params, parsed.query, parsed.fragment))


def download_url(url: str, user_agent: str, timeout: int, base_url: str = "") -> bytes:
    resolved_url = resolve_sub2api_media_url(url, base_url)
    req = urllib.request.Request(resolved_url, headers={"User-Agent": user_agent})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            return resp.read()
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")[:2000]
        raise RuntimeError(f"download HTTP {exc.code}: {body}") from exc


def extract_image_bytes(data: dict[str, object], headers: dict[str, str], timeout: int, base_url: str) -> bytes:
    items = data.get("data")
    if not isinstance(items, list) or not items:
        raise RuntimeError("API response did not include a non-empty data array")
    first = items[0]
    if not isinstance(first, dict):
        raise RuntimeError("API response data[0] is not an object")

    b64_json = first.get("b64_json")
    if isinstance(b64_json, str) and b64_json:
        return base64.b64decode(b64_json)

    url = first.get("url")
    if isinstance(url, str) and url:
        return download_url(url, headers["User-Agent"], timeout, base_url)

    preview = json.dumps(data, ensure_ascii=False)[:2000]
    raise RuntimeError(f"API response did not include b64_json or url: {preview}")


def maybe_normalize_png(image_bytes: bytes, target_size: str, out_path: Path) -> tuple[bytes, Path]:
    if not target_size:
        return image_bytes, out_path

    try:
        from PIL import Image, ImageOps
    except ImportError as exc:
        raise RuntimeError("--normalize-size requires Pillow") from exc

    width_text, height_text = target_size.lower().split("x", 1)
    target = (int(width_text), int(height_text))
    from io import BytesIO

    with Image.open(BytesIO(image_bytes)) as source:
        image = ImageOps.exif_transpose(source).convert("RGBA")
        normalized = ImageOps.fit(image, target, method=Image.Resampling.LANCZOS, centering=(0.5, 0.5))
        output = BytesIO()
        normalized.save(output, format="PNG")
        return output.getvalue(), out_path.with_suffix(".png")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Generate one Grok Imagine candidate image through an OpenAI-compatible images endpoint."
    )
    parser.add_argument("--prompt", help="Prompt text to send.")
    parser.add_argument("--prompt-file", help="UTF-8 prompt file to send.")
    parser.add_argument(
        "--out",
        default="garden-gpt-image-2/image/candidates/grok/grok_imagine_candidate",
        help="Output path. The suffix is adjusted to the actual returned image type unless --keep-output-suffix is set.",
    )
    parser.add_argument("--size", default="1024x1024", help="Requested API size. The provider may ignore it.")
    parser.add_argument("--n", type=int, default=1, help="Number of images to request; this tool saves only the first.")
    parser.add_argument("--model", default=None, help=f"Default: GROK_IMAGE_MODEL or {DEFAULT_MODEL}.")
    parser.add_argument("--base-url", default=None, help=f"Default: GROK_IMAGE_BASE_URL or {DEFAULT_BASE_URL}.")
    parser.add_argument("--timeout", type=int, default=240)
    parser.add_argument(
        "--normalize-size",
        default="",
        help="Optional final WxH PNG normalization for project review. Leave empty to preserve provider output.",
    )
    parser.add_argument(
        "--keep-output-suffix",
        action="store_true",
        help="Write to --out exactly even if the returned image type differs from the suffix.",
    )
    args = parser.parse_args()

    load_project_env()
    api_key = os.environ.get("GROK_IMAGE_API_KEY")
    if not api_key:
        print("GROK_IMAGE_API_KEY is not set. Export it before generating Grok images.", file=sys.stderr)
        return 2

    base_url = (args.base_url or os.environ.get("GROK_IMAGE_BASE_URL") or DEFAULT_BASE_URL).rstrip("/")
    model = args.model or os.environ.get("GROK_IMAGE_MODEL") or DEFAULT_MODEL
    prompt = read_prompt(args)
    headers = browser_headers(api_key, base_url)
    payload = {
        "model": model,
        "prompt": prompt,
        "n": args.n,
        "size": args.size,
    }

    data = request_json(base_url + "/images/generations", payload, headers, args.timeout)
    image_bytes = extract_image_bytes(data, headers, args.timeout, base_url)
    requested_out = Path(args.out)
    if not requested_out.is_absolute():
        requested_out = ROOT / requested_out
    requested_out.parent.mkdir(parents=True, exist_ok=True)
    final_out = output_path_for_bytes(requested_out, image_bytes, args.keep_output_suffix)
    image_bytes, final_out = maybe_normalize_png(image_bytes, args.normalize_size, final_out)
    final_out.write_bytes(image_bytes)

    print("saved:", final_out.relative_to(ROOT) if final_out.is_relative_to(ROOT) else final_out)
    print("bytes:", final_out.stat().st_size)
    print("type:", sniff_extension(image_bytes, final_out.suffix).lstrip("."))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
