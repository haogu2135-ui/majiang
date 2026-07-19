#!/usr/bin/env python3
"""Generate images via https://img.regenin.online and optionally strip corner watermarks.

API (public, no key required as of 2026-07-12):
  GET  /api/status
  GET  /api/models
  POST /api/chat   (SSE) payload:
    {prompt, type:"image"| "video", model, ratio, resolution, duration?, audio?}

Response SSE events:
  start / ping / generating(result markdown image) / end

Notes for engineering use:
  - CDN assets often need SSL verify disabled or a custom CA on some hosts.
  - Reported resolution (1K/2K/4K) may not match true pixel size (observed 1K=512, 2K=1024).
  - Output is usually JPEG without alpha; convert/normalize before Godot import.
  - Watermark removal is heuristic (corner/bottom strip inpaint). Always visual-QA.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import ssl
import sys
import tempfile
import time
import urllib.error
import urllib.request
from pathlib import Path
from typing import Any

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageOps


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_BASE_URL = "https://img.regenin.online"
DEFAULT_MODEL = "GPT Image 2.0"
DEFAULT_RATIO = "1:1"
DEFAULT_RESOLUTION = "1K"
DEFAULT_USER_AGENT = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/126.0.0.0 Safari/537.36"
)
URL_RE = re.compile(r"https?://[^\s\)\]\"']+")
MEDIA_RE = re.compile(r"https?://\S+\.(?:png|jpe?g|webp|gif)(?:\?\S*)?", re.I)


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


def ssl_context(insecure: bool) -> ssl.SSLContext | None:
    if insecure:
        return ssl._create_unverified_context()
    return None


def browser_headers(base_url: str, api_key: str = "") -> dict[str, str]:
    origin = base_url.rstrip("/")
    headers = {
        "Content-Type": "application/json",
        "Accept": "text/event-stream, application/json",
        "User-Agent": DEFAULT_USER_AGENT,
        "Origin": origin,
        "Referer": origin + "/",
    }
    if api_key:
        headers["Authorization"] = f"Bearer {api_key}"
    return headers


def http_json(url: str, headers: dict[str, str], timeout: int, insecure: bool, payload: dict | None = None) -> Any:
    data = None if payload is None else json.dumps(payload).encode("utf-8")
    method = "GET" if payload is None else "POST"
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=timeout, context=ssl_context(insecure)) as resp:
            return json.loads(resp.read().decode("utf-8", errors="replace"))
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")[:2000]
        raise RuntimeError(f"HTTP {exc.code} for {url}: {body}") from exc


def sniff_extension(data: bytes, fallback: str = ".bin") -> str:
    if data.startswith(b"\xff\xd8\xff"):
        return ".jpg"
    if data.startswith(b"\x89PNG\r\n\x1a\n"):
        return ".png"
    if data.startswith(b"RIFF") and data[8:12] == b"WEBP":
        return ".webp"
    if data[:6] in (b"GIF87a", b"GIF89a"):
        return ".gif"
    return fallback


def atomic_write_bytes(path: Path, data: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temp_path: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(dir=path.parent, prefix=f".{path.stem}.", suffix=".tmp", delete=False) as temp:
            temp_path = Path(temp.name)
            temp.write(data)
        temp_path.replace(path)
    finally:
        if temp_path is not None and temp_path.exists():
            temp_path.unlink(missing_ok=True)


def download_url(url: str, headers: dict[str, str], timeout: int, insecure: bool) -> bytes:
    req = urllib.request.Request(
        url,
        headers={
            "User-Agent": headers.get("User-Agent", DEFAULT_USER_AGENT),
            "Referer": headers.get("Referer", DEFAULT_BASE_URL + "/"),
            "Accept": "image/avif,image/webp,image/apng,image/*,*/*;q=0.8",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout, context=ssl_context(insecure)) as resp:
            return resp.read()
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")[:1000]
        raise RuntimeError(f"download HTTP {exc.code}: {body}") from exc


def parse_sse_events(raw_text: str) -> list[dict[str, Any]]:
    events: list[dict[str, Any]] = []
    for line in raw_text.splitlines():
        text = line.strip()
        if text.startswith("data:"):
            text = text[5:].strip()
        if not text or text == "[DONE]" or not text.startswith("{"):
            continue
        try:
            events.append(json.loads(text))
        except json.JSONDecodeError:
            continue
    return events


def extract_answer_from_events(events: list[dict[str, Any]]) -> str:
    answer = ""
    for event in events:
        if event.get("error"):
            raise RuntimeError(f"API error: {event.get('error')}")
        if event.get("event") != "generating":
            continue
        data = event.get("data") or {}
        result = data.get("result")
        if isinstance(result, str) and result.strip():
            answer = result
    return answer


def extract_media_urls(answer: str) -> list[str]:
    urls: list[str] = []
    for match in re.finditer(r"!\[.*?\]\((.*?)\)", answer):
        urls.append(match.group(1).strip())
    for match in MEDIA_RE.finditer(answer):
        urls.append(match.group(0))
    for match in URL_RE.finditer(answer):
        urls.append(match.group(0))
    # de-dupe preserve order
    seen: set[str] = set()
    unique: list[str] = []
    for url in urls:
        if url not in seen:
            seen.add(url)
            unique.append(url)
    return unique


def generate_image(
    *,
    base_url: str,
    prompt: str,
    model: str,
    ratio: str,
    resolution: str,
    timeout: int,
    insecure: bool,
    api_key: str = "",
    task_type: str = "image",
    duration: int | None = None,
    audio: bool | None = None,
) -> tuple[str, list[str], list[dict[str, Any]]]:
    headers = browser_headers(base_url, api_key)
    payload: dict[str, Any] = {
        "prompt": prompt,
        "type": task_type,
        "model": model,
        "ratio": ratio,
        "resolution": resolution,
    }
    if task_type == "video":
        if duration is not None:
            payload["duration"] = int(duration)
        if audio is not None:
            payload["audio"] = bool(audio)

    req = urllib.request.Request(
        base_url.rstrip("/") + "/api/chat",
        data=json.dumps(payload).encode("utf-8"),
        headers=headers,
        method="POST",
    )
    started = time.time()
    try:
        with urllib.request.urlopen(req, timeout=timeout, context=ssl_context(insecure)) as resp:
            content_type = resp.headers.get("content-type", "")
            raw = resp.read().decode("utf-8", errors="replace")
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")[:2000]
        raise RuntimeError(f"HTTP {exc.code}: {body}") from exc

    if "application/json" in content_type and raw.lstrip().startswith("{"):
        # Non-SSE JSON fallback
        data = json.loads(raw)
        if data.get("error"):
            raise RuntimeError(f"API error: {data['error']}")
        answer = str(data.get("result") or data.get("data") or "")
        events = [{"event": "json", "data": data}]
    else:
        events = parse_sse_events(raw)
        answer = extract_answer_from_events(events)

    urls = extract_media_urls(answer)
    if not urls:
        raise RuntimeError(
            f"no media URL in response after {time.time() - started:.1f}s; answer={answer[:300]!r}"
        )
    return answer, urls, events


def mean(values: list[float]) -> float:
    return sum(values) / max(1, len(values))


def _gray_mean(image: Image.Image) -> float:
    # Avoid Image.getdata deprecation; sample via histogram for speed/stability.
    hist = image.histogram()
    total = sum(hist) or 1
    acc = 0
    for value, count in enumerate(hist):
        acc += value * count
    return acc / total


def region_high_frequency(gray: Image.Image, box: tuple[int, int, int, int]) -> float:
    crop = gray.crop(box)
    blur = crop.filter(ImageFilter.GaussianBlur(2.0))
    diff = ImageChops.difference(crop, blur)
    return _gray_mean(diff)


def region_edge(gray: Image.Image, box: tuple[int, int, int, int]) -> float:
    crop = gray.crop(box)
    edges = crop.filter(ImageFilter.FIND_EDGES)
    return _gray_mean(edges)


def detect_watermark_boxes(image: Image.Image, strength: float = 1.0) -> list[tuple[str, tuple[int, int, int, int], float]]:
    """Heuristic corner/bottom watermark detector.

    Returns (name, box, score) candidates. Tuned for common translucent logo/text
    strips, not full-frame visible subjects.
    """
    rgb = image.convert("RGB")
    gray = rgb.convert("L")
    width, height = gray.size
    full_hf = region_high_frequency(gray, (0, 0, width, height))
    full_ed = region_edge(gray, (0, 0, width, height))

    regions = {
        "br": (int(width * 0.55), int(height * 0.75), width, height),
        "bl": (0, int(height * 0.75), int(width * 0.45), height),
        "tr": (int(width * 0.55), 0, width, int(height * 0.25)),
        "tl": (0, 0, int(width * 0.45), int(height * 0.25)),
        "bc": (int(width * 0.18), int(height * 0.86), int(width * 0.82), height),
    }

    threshold = 1.30 / max(0.5, strength)
    min_hf = 1.0 / max(0.5, strength)
    candidates: list[tuple[str, tuple[int, int, int, int], float]] = []
    for name, box in regions.items():
        hf = region_high_frequency(gray, box)
        ed = region_edge(gray, box)
        ratio_hf = hf / max(1e-6, full_hf)
        ratio_ed = ed / max(1e-6, full_ed)
        score = 0.62 * ratio_hf + 0.38 * ratio_ed
        if score >= threshold and hf >= min_hf:
            # Prefer a thinner bottom band for classic footer watermarks.
            x0, y0, x1, y1 = box
            if name in {"br", "bl", "bc"}:
                band_y0 = max(y0, int(height * 0.88))
                box = (x0, band_y0, x1, y1)
            elif name in {"tr", "tl"}:
                band_y1 = min(y1, int(height * 0.12))
                box = (x0, y0, x1, band_y1)
            candidates.append((name, box, score))
    candidates.sort(key=lambda item: item[2], reverse=True)
    return candidates


def inpaint_box(image: Image.Image, box: tuple[int, int, int, int], expand: int = 2) -> Image.Image:
    """Feathered local fill from surrounding blur (no OpenCV dependency)."""
    x0, y0, x1, y1 = box
    x0 = max(0, x0 - expand)
    y0 = max(0, y0 - expand)
    x1 = min(image.width, x1 + expand)
    y1 = min(image.height, y1 + expand)
    if x1 <= x0 or y1 <= y0:
        return image

    out = image.convert("RGBA").copy()
    pad = max(10, (x1 - x0) // 5, (y1 - y0) // 3)
    sample_box = (
        max(0, x0 - pad),
        max(0, y0 - pad),
        min(out.width, x1 + pad),
        min(out.height, y1 + pad),
    )
    sample = out.crop(sample_box)
    fill = sample.filter(ImageFilter.GaussianBlur(radius=max(5.0, pad / 2.2)))
    sx0 = x0 - sample_box[0]
    sy0 = y0 - sample_box[1]
    patch = fill.crop((sx0, sy0, sx0 + (x1 - x0), sy0 + (y1 - y0)))

    mask = Image.new("L", (x1 - x0, y1 - y0), 0)
    drawer = ImageDraw.Draw(mask)
    radius = max(2, min(x1 - x0, y1 - y0) // 8)
    drawer.rounded_rectangle((0, 0, x1 - x0 - 1, y1 - y0 - 1), radius=radius, fill=255)
    mask = mask.filter(ImageFilter.GaussianBlur(2.8))
    out.paste(patch, (x0, y0), mask)
    return out


def remove_watermarks(image: Image.Image, strength: float = 1.0, force_corners: bool = False) -> tuple[Image.Image, list[dict[str, Any]]]:
    work = ImageOps.exif_transpose(image).convert("RGBA")
    boxes = detect_watermark_boxes(work, strength=strength)
    report: list[dict[str, Any]] = []
    if not boxes and force_corners:
        width, height = work.size
        boxes = [
            ("br_force", (int(width * 0.70), int(height * 0.90), width, height), 0.0),
            ("bc_force", (int(width * 0.25), int(height * 0.92), int(width * 0.75), height), 0.0),
        ]
    for name, box, score in boxes:
        work = inpaint_box(work, box)
        report.append({"name": name, "box": list(box), "score": round(float(score), 3)})
    return work, report


def normalize_image(image: Image.Image, size: str = "", keep_alpha: bool = True) -> Image.Image:
    image = ImageOps.exif_transpose(image)
    if keep_alpha:
        image = image.convert("RGBA")
    else:
        image = image.convert("RGB")
    if not size:
        return image
    width_text, height_text = size.lower().split("x", 1)
    target = (int(width_text), int(height_text))
    return ImageOps.fit(image, target, method=Image.Resampling.LANCZOS, centering=(0.5, 0.5))


def image_from_bytes(data: bytes) -> Image.Image:
    from io import BytesIO

    with Image.open(BytesIO(data)) as source:
        return ImageOps.exif_transpose(source).copy()


def save_image(image: Image.Image, path: Path, fmt: str = "") -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    suffix = path.suffix.lower()
    if not fmt:
        if suffix in {".jpg", ".jpeg"}:
            fmt = "JPEG"
        elif suffix == ".webp":
            fmt = "WEBP"
        else:
            fmt = "PNG"
            if suffix != ".png":
                path = path.with_suffix(".png")
    if fmt.upper() == "JPEG" and image.mode == "RGBA":
        background = Image.new("RGB", image.size, (255, 255, 255))
        background.paste(image, mask=image.getchannel("A"))
        image = background
    elif fmt.upper() == "PNG":
        image = image.convert("RGBA")

    with tempfile.NamedTemporaryFile(dir=path.parent, prefix=f".{path.stem}.", suffix=path.suffix or ".png", delete=False) as temp:
        temp_path = Path(temp.name)
        save_kwargs: dict[str, Any] = {}
        if fmt.upper() == "JPEG":
            save_kwargs.update({"quality": 92, "optimize": True})
        image.save(temp, format=fmt.upper(), **save_kwargs)
    temp_path.replace(path)
    return path


def read_prompt(args: argparse.Namespace) -> str:
    if args.prompt_file:
        text = Path(args.prompt_file).read_text(encoding="utf-8").strip()
        fenced = re.search(r"```(?:text)?\s*\n(.*?)\n```", text, re.DOTALL)
        return fenced.group(1).strip() if fenced else text
    if args.prompt:
        return args.prompt.strip()
    raise SystemExit("provide --prompt or --prompt-file")


def cmd_models(args: argparse.Namespace) -> int:
    headers = browser_headers(args.base_url, args.api_key)
    data = http_json(args.base_url.rstrip("/") + "/api/models", headers, args.timeout, args.insecure)
    print(json.dumps(data, ensure_ascii=False, indent=2))
    return 0


def cmd_status(args: argparse.Namespace) -> int:
    headers = browser_headers(args.base_url, args.api_key)
    data = http_json(args.base_url.rstrip("/") + "/api/status", headers, args.timeout, args.insecure)
    print(json.dumps(data, ensure_ascii=False, indent=2))
    return 0


def cmd_generate(args: argparse.Namespace) -> int:
    prompt = read_prompt(args)
    if args.no_watermark_hint:
        pass
    else:
        # Soft prompt steer: reduce provider-side branded captions when possible.
        if "no watermark" not in prompt.lower() and "无水印" not in prompt:
            prompt = prompt.rstrip() + "\n\nNo watermark, no logo, no caption text, no website URL."

    print(f"base_url: {args.base_url}")
    print(f"model: {args.model}")
    print(f"ratio/resolution: {args.ratio} / {args.resolution}")
    t0 = time.time()
    answer, urls, events = generate_image(
        base_url=args.base_url,
        prompt=prompt,
        model=args.model,
        ratio=args.ratio,
        resolution=args.resolution,
        timeout=args.timeout,
        insecure=args.insecure,
        api_key=args.api_key,
        task_type=args.type,
        duration=args.duration,
        audio=args.audio,
    )
    print(f"sse_events: {len(events)} elapsed_s: {time.time() - t0:.1f}")
    print(f"answer: {answer[:240]}")
    print(f"urls: {urls}")

    headers = browser_headers(args.base_url, args.api_key)
    image_bytes = download_url(urls[0], headers, args.timeout, args.insecure)
    raw_image = image_from_bytes(image_bytes)
    print(f"raw_image: {raw_image.size[0]}x{raw_image.size[1]} mode={raw_image.mode} bytes={len(image_bytes)}")

    out_path = Path(args.out)
    if not out_path.is_absolute():
        out_path = ROOT / out_path
    raw_path = out_path.with_name(out_path.stem + ".raw" + sniff_extension(image_bytes, out_path.suffix or ".jpg"))
    if args.save_raw:
        atomic_write_bytes(raw_path, image_bytes)
        print(f"saved_raw: {raw_path}")

    image = raw_image
    report: list[dict[str, Any]] = []
    if args.remove_watermark:
        image, report = remove_watermarks(image, strength=args.watermark_strength, force_corners=args.force_corner_clean)
        print(f"watermark_boxes: {json.dumps(report, ensure_ascii=False)}")
    image = normalize_image(image, size=args.normalize_size, keep_alpha=not args.flatten_alpha)
    final_path = save_image(image, out_path, fmt=args.format)
    print(f"saved: {final_path}")
    print(f"final: {image.size[0]}x{image.size[1]} mode={image.mode} bytes={final_path.stat().st_size}")
    if args.report_json:
        report_path = Path(args.report_json)
        if not report_path.is_absolute():
            report_path = ROOT / report_path
        payload = {
            "base_url": args.base_url,
            "model": args.model,
            "ratio": args.ratio,
            "resolution": args.resolution,
            "prompt": prompt,
            "answer": answer,
            "urls": urls,
            "raw_size": list(raw_image.size),
            "final_size": list(image.size),
            "watermark_boxes": report,
            "saved": str(final_path),
            "elapsed_s": round(time.time() - t0, 2),
        }
        report_path.parent.mkdir(parents=True, exist_ok=True)
        report_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"report: {report_path}")
    return 0


def cmd_dewmark(args: argparse.Namespace) -> int:
    source = Path(args.input)
    if not source.is_absolute():
        source = ROOT / source
    image = ImageOps.exif_transpose(Image.open(source))
    cleaned, report = remove_watermarks(image, strength=args.watermark_strength, force_corners=args.force_corner_clean)
    cleaned = normalize_image(cleaned, size=args.normalize_size, keep_alpha=not args.flatten_alpha)
    out_path = Path(args.out)
    if not out_path.is_absolute():
        out_path = ROOT / out_path
    final_path = save_image(cleaned, out_path, fmt=args.format)
    print(f"watermark_boxes: {json.dumps(report, ensure_ascii=False)}")
    print(f"saved: {final_path}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    common = argparse.ArgumentParser(add_help=False)
    common.add_argument("--base-url", default=None, help=f"Default: REGENIN_BASE_URL or {DEFAULT_BASE_URL}")
    common.add_argument("--api-key", default=None, help="Optional. REGENIN_API_KEY / OPENAI_API_KEY if needed later.")
    common.add_argument("--timeout", type=int, default=240)
    common.add_argument("--insecure", action="store_true", help="Disable TLS certificate verification (CDN sometimes needed).")

    parser = argparse.ArgumentParser(description="img.regenin.online image generation + watermark cleanup", parents=[common])
    sub = parser.add_subparsers(dest="command", required=True)

    p_status = sub.add_parser("status", parents=[common], help="GET /api/status")
    p_status.set_defaults(func=cmd_status)

    p_models = sub.add_parser("models", parents=[common], help="GET /api/models")
    p_models.set_defaults(func=cmd_models)

    p_gen = sub.add_parser("generate", parents=[common], help="Generate one image and optionally remove watermark")
    p_gen.add_argument("--prompt")
    p_gen.add_argument("--prompt-file")
    p_gen.add_argument("--out", required=True, help="Output path (png/jpg/webp)")
    p_gen.add_argument("--model", default=None)
    p_gen.add_argument("--ratio", default=DEFAULT_RATIO)
    p_gen.add_argument("--resolution", default=DEFAULT_RESOLUTION, help="1K / 2K / 4K depending on model")
    p_gen.add_argument("--type", default="image", choices=["image", "video"])
    p_gen.add_argument("--duration", type=int, default=None)
    p_gen.add_argument("--audio", action=argparse.BooleanOptionalAction, default=None)
    p_gen.add_argument("--remove-watermark", action=argparse.BooleanOptionalAction, default=True)
    p_gen.add_argument("--watermark-strength", type=float, default=1.0)
    p_gen.add_argument("--force-corner-clean", action="store_true", help="Always clean bottom-right/bottom-center strips")
    p_gen.add_argument("--no-watermark-hint", action="store_true", help="Do not append anti-watermark prompt suffix")
    p_gen.add_argument("--normalize-size", default="", help="Optional WxH fit, e.g. 1024x1024")
    p_gen.add_argument("--flatten-alpha", action="store_true")
    p_gen.add_argument("--format", default="", help="PNG/JPEG/WEBP override")
    p_gen.add_argument("--save-raw", action=argparse.BooleanOptionalAction, default=True)
    p_gen.add_argument("--report-json", default="")
    p_gen.set_defaults(func=cmd_generate)

    p_dw = sub.add_parser("dewmark", parents=[common], help="Remove watermark from an existing image")
    p_dw.add_argument("--input", required=True)
    p_dw.add_argument("--out", required=True)
    p_dw.add_argument("--watermark-strength", type=float, default=1.0)
    p_dw.add_argument("--force-corner-clean", action="store_true")
    p_dw.add_argument("--normalize-size", default="")
    p_dw.add_argument("--flatten-alpha", action="store_true")
    p_dw.add_argument("--format", default="")
    p_dw.set_defaults(func=cmd_dewmark)
    return parser


def main() -> int:
    load_project_env()
    parser = build_parser()
    args = parser.parse_args()
    args.base_url = (args.base_url or os.environ.get("REGENIN_BASE_URL") or DEFAULT_BASE_URL).rstrip("/")
    args.api_key = args.api_key or os.environ.get("REGENIN_API_KEY") or os.environ.get("OPENAI_API_KEY") or ""
    if args.command == "generate":
        args.model = args.model or os.environ.get("REGENIN_IMAGE_MODEL") or DEFAULT_MODEL
        # CDN certs on this host often fail without --insecure.
        if not args.insecure:
            args.insecure = True
    if args.command == "dewmark" and not args.insecure:
        pass
    # default insecure for network subcommands on this environment
    if args.command in {"status", "models"} and "--insecure" not in sys.argv:
        # status/models work with valid certs usually; leave default False
        pass
    if args.command == "generate" and not any(a.startswith("--insecure") for a in sys.argv):
        args.insecure = True
    return int(args.func(args))


if __name__ == "__main__":
    raise SystemExit(main())
