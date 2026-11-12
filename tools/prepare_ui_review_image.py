#!/usr/bin/env python3
"""Compress an existing QA screenshot for Codex review; never create game art."""

import argparse
import hashlib
import io
import json
from pathlib import Path

from PIL import Image, ImageOps


ROOT = Path(__file__).resolve().parents[1]
QA_ROOT = ROOT / "build" / "qa"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    source = args.source.resolve()
    if not source.is_file():
        parser.error(f"Screenshot does not exist: {source}")
    if not source.is_relative_to(QA_ROOT):
        parser.error("Only screenshots under build/qa are accepted; assets are excluded")
    target = (args.output or QA_ROOT / "ui_review" / source.relative_to(QA_ROOT).with_suffix(".jpg")).resolve()
    if not target.is_relative_to(QA_ROOT / "ui_review") or target.suffix.lower() != ".jpg":
        parser.error("Output must be a JPEG under build/qa/ui_review")
    if source == target or target.with_suffix(".json") == source:
        parser.error("Review output must not overwrite its source")

    original = source.read_bytes()
    with Image.open(io.BytesIO(original)) as screenshot:
        oriented = ImageOps.exif_transpose(screenshot)
        # Review copies must show transparent bitmap edges as they composite,
        # rather than exposing arbitrary RGB hidden beneath nearly zero alpha.
        if "A" in oriented.getbands() or "transparency" in oriented.info:
            rgba = oriented.convert("RGBA")
            backdrop = Image.new("RGBA", rgba.size, (242, 237, 222, 255))
            rgb = Image.alpha_composite(backdrop, rgba).convert("RGB")
        else:
            rgb = oriented.convert("RGB")
        original_size = rgb.size
        rgb.thumbnail((1280, 1280), Image.Resampling.LANCZOS)
        for quality in (85, 75, 65, 55):
            encoded = io.BytesIO()
            rgb.save(encoded, format="JPEG", quality=quality, optimize=True)
            data = encoded.getvalue()
            if len(data) <= 600_000:
                break
        else:
            parser.error("Image exceeds the 600 KB review budget; select a smaller detail crop")

    if target.exists() and target.read_bytes() != data:
        parser.error("Review file already exists with different content; choose a new output path")
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(data)
    receipt = {
        "purpose": "compressed review only; original PNG/JSON remains acceptance evidence",
        "source": str(source.relative_to(ROOT)),
        "source_bytes": len(original),
        "source_sha256": hashlib.sha256(original).hexdigest(),
        "source_dimensions": original_size,
        "review": str(target.relative_to(ROOT)),
        "review_bytes": len(data),
        "review_sha256": hashlib.sha256(data).hexdigest(),
        "review_dimensions": rgb.size,
        "jpeg_quality": quality,
    }
    target.with_suffix(".json").write_text(json.dumps(receipt, ensure_ascii=False, indent=2) + "\n")
    assert source.read_bytes() == original, "Source screenshot changed during review conversion"
    print(json.dumps(receipt, ensure_ascii=False))


if __name__ == "__main__":
    main()
