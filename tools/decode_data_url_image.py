#!/usr/bin/env python3
"""Decode a data:image/... URL into a local image file."""

from __future__ import annotations

import argparse
import base64
import binascii
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT = ROOT / ".tmp" / "flower-reference-from-data-url.jpg"
DATA_URL_RE = re.compile(r"^data:image/(?P<kind>[a-zA-Z0-9.+-]+);base64,(?P<payload>.+)$", re.DOTALL)


def decode_data_url(value: str) -> tuple[str, bytes]:
    match = DATA_URL_RE.match(value.strip())
    if not match:
        raise ValueError("expected a complete data:image/...;base64,... URL")

    image_kind = match.group("kind").lower()
    payload = re.sub(r"\s+", "", match.group("payload"))
    if "..." in payload or "…" in payload:
        raise ValueError("data URL is truncated; paste the complete base64 payload")

    try:
        image_bytes = base64.b64decode(payload, validate=True)
    except binascii.Error as exc:
        raise ValueError(f"invalid base64 payload: {exc}") from exc

    if not image_bytes:
        raise ValueError("decoded image is empty")
    return image_kind, image_bytes


def main() -> int:
    parser = argparse.ArgumentParser(description="Decode a pasted data:image base64 URL into an image file.")
    parser.add_argument(
        "data_url",
        nargs="?",
        help="Complete data:image/...;base64,... URL. If omitted, read it from stdin.",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUTPUT,
        help=f"Output image path, default: {DEFAULT_OUTPUT}",
    )
    parser.add_argument("--force", action="store_true", help="Overwrite the output path if it already exists")
    args = parser.parse_args()

    data_url = args.data_url if args.data_url is not None else sys.stdin.read()
    try:
        image_kind, image_bytes = decode_data_url(data_url)
    except ValueError as exc:
        print(f"decode failed: {exc}", file=sys.stderr)
        return 2

    output = args.output.expanduser()
    if not output.is_absolute():
        output = (Path.cwd() / output).resolve()
    if output.exists() and not args.force:
        print(f"decode failed: output already exists: {output} (use --force to overwrite)", file=sys.stderr)
        return 2
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(image_bytes)
    print(f"Wrote {len(image_bytes)} bytes ({image_kind}) to {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
