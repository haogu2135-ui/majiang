#!/usr/bin/env python3
"""Validate dynamic reading-assistance screenshots and their runtime metadata."""

from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, ImageStat


ROOT = Path(__file__).resolve().parents[1]
PROFILE_FILES = [
    "01_standard.png",
    "02_large_text.png",
    "03_high_contrast.png",
    "04_reduce_motion.png",
    "05_focused.png",
    "06_clear.png",
]
PROFILE_NAMES = [path[:-4] for path in PROFILE_FILES]
PROFILE_LABELS = ["标准", "大字", "高对比", "减动效", "专注", "清晰"]


def parse_size(value: str) -> tuple[int, int]:
    parts = value.lower().split("x")
    if len(parts) != 2:
        raise argparse.ArgumentTypeError("expected WIDTHxHEIGHT")
    try:
        width, height = int(parts[0]), int(parts[1])
    except ValueError as exc:
        raise argparse.ArgumentTypeError("expected integer WIDTHxHEIGHT") from exc
    if width <= 0 or height <= 0:
        raise argparse.ArgumentTypeError("size must be positive")
    return width, height


def current_state_fingerprint(paths: tuple[str, ...] = ()) -> str:
    path_args = ["--", *paths]
    diff = subprocess.run(
        ["git", "-C", str(ROOT), "diff", "--binary", *path_args],
        check=True,
        capture_output=True,
    ).stdout
    status = subprocess.run(
        ["git", "-C", str(ROOT), "status", "--porcelain", *path_args],
        check=True,
        capture_output=True,
    ).stdout
    return hashlib.sha256(diff + status).hexdigest()


def current_git_state() -> tuple[str, str, str]:
    revision = subprocess.run(
        ["git", "-C", str(ROOT), "rev-parse", "--short", "HEAD"],
        check=True,
        capture_output=True,
        text=True,
    ).stdout.strip()
    status = subprocess.run(
        ["git", "-C", str(ROOT), "status", "--porcelain"],
        check=True,
        capture_output=True,
        text=True,
    ).stdout.strip()
    runtime_status = subprocess.run(
        [
            "git", "-C", str(ROOT), "status", "--porcelain", "--",
            "project.godot", "scripts/main_base.gd", "scripts/main.gd",
            "scripts/main_src", "scripts/ui",
        ],
        check=True,
        capture_output=True,
        text=True,
    ).stdout.strip()
    return revision, ("dirty" if status else "clean"), ("dirty" if runtime_status else "clean")


def image_stats(path: Path) -> dict[str, object]:
    with Image.open(path) as image:
        rgba = image.convert("RGBA")
        grayscale = rgba.convert("L")
        luma = ImageStat.Stat(grayscale)
        alpha_min, alpha_max = rgba.getchannel("A").getextrema()
        pixels = rgba.getdata()
        total = max(1, rgba.size[0] * rgba.size[1])
        magenta = 0
        transparent = 0
        for red, green, blue, alpha in pixels:
            if alpha <= 8:
                transparent += 1
            if red >= 220 and blue >= 220 and green <= 80 and alpha >= 180:
                magenta += 1
        return {
            "size": rgba.size,
            "mean_luma": luma.mean[0],
            "stdev_luma": luma.stddev[0],
            "min_alpha": alpha_min,
            "max_alpha": alpha_max,
            "magenta_ratio": magenta / total,
            "transparent_ratio": transparent / total,
        }


def expected_metadata(expected_size: tuple[int, int]) -> dict[str, object]:
    revision, worktree_state, runtime_source_state = current_git_state()
    return {
        "capture_revision": revision,
        "worktree_state": worktree_state,
        "runtime_source_state": runtime_source_state,
        "worktree_diff_fingerprint": current_state_fingerprint(),
        "runtime_source_diff_fingerprint": current_state_fingerprint(
            ("project.godot", "scripts/main_base.gd", "scripts/main.gd", "scripts/main_src", "scripts/ui")
        ),
        "capture_size": f"{expected_size[0]}x{expected_size[1]}",
        "profile_names": PROFILE_NAMES,
        "profile_labels": PROFILE_LABELS,
    }


def validate(directory: Path, expected_size: tuple[int, int]) -> tuple[bool, list[str], list[dict[str, object]]]:
    issues: list[str] = []
    rows: list[dict[str, object]] = []
    metadata_path = directory / "accessibility_capture_metadata.json"
    try:
        metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        metadata = {}
        issues.append(f"missing `{metadata_path}`")
    except (OSError, json.JSONDecodeError) as exc:
        metadata = {}
        issues.append(f"invalid `{metadata_path}`: {exc}")

    expected = expected_metadata(expected_size)
    for key, expected_value in expected.items():
        if metadata.get(key) != expected_value:
            issues.append(f"metadata {key} expected `{expected_value}` got `{metadata.get(key)}`")
    focus_contract = metadata.get("focus_contract")
    expected_focus_contract = {
        "profile_control": "SettingRowButton_阅读辅助",
        "profile_focus_after_rebuild": True,
        "return_control": "MenuSettingsButton",
        "cycle": "standard->large_text->high_contrast->reduce_motion->focused->clear->standard",
    }
    if focus_contract != expected_focus_contract:
        issues.append(f"metadata focus_contract mismatch: {focus_contract}")

    expected_paths = {directory / name for name in PROFILE_FILES}
    for path in sorted(directory.glob("*.png")):
        if path not in expected_paths:
            issues.append(f"unexpected screenshot `{path.name}`")
    for name in PROFILE_FILES:
        path = directory / name
        row: dict[str, object] = {"file": name, "status": "missing"}
        if not path.exists():
            rows.append(row)
            issues.append(f"missing screenshot `{path}`")
            continue
        try:
            stats = image_stats(path)
        except (OSError, ValueError) as exc:
            row["status"] = "invalid"
            rows.append(row)
            issues.append(f"invalid screenshot `{path}`: {exc}")
            continue
        row.update(stats)
        image_issues: list[str] = []
        if stats["size"] != expected_size:
            image_issues.append("wrong-size")
        if float(stats["stdev_luma"]) < 4.0:
            image_issues.append("near-blank")
        if int(stats["max_alpha"]) == 0:
            image_issues.append("fully-transparent")
        if float(stats["transparent_ratio"]) > 0.02:
            image_issues.append("large-transparent-area")
        if float(stats["magenta_ratio"]) > 0.001:
            image_issues.append("magenta-placeholder-color")
        row["status"] = "ok" if not image_issues else ", ".join(image_issues)
        rows.append(row)
        if image_issues:
            issues.append(f"{name}: {', '.join(image_issues)}")
    return not issues, issues, rows


def write_contact_sheet(directory: Path, rows: list[dict[str, object]], output_path: Path) -> None:
    columns = 2
    thumb_width, thumb_height = 480, 270
    label_height, gap = 24, 8
    sheet_rows = (len(rows) + columns - 1) // columns
    sheet = Image.new(
        "RGB",
        (columns * thumb_width + (columns + 1) * gap, sheet_rows * (thumb_height + label_height + gap) + gap),
        (14, 16, 18),
    )
    draw = ImageDraw.Draw(sheet)
    try:
        font = ImageFont.load_default()
    except Exception:
        font = None
    for index, row in enumerate(rows):
        path = directory / str(row["file"])
        if not path.exists() or row.get("status") != "ok":
            continue
        with Image.open(path) as source:
            thumb = source.convert("RGB")
            thumb.thumbnail((thumb_width, thumb_height), Image.Resampling.LANCZOS)
            column = index % columns
            sheet_row = index // columns
            x = gap + column * (thumb_width + gap)
            y = gap + sheet_row * (thumb_height + label_height + gap)
            sheet.paste(thumb, (x, y))
            draw.rectangle((x, y + thumb_height, x + thumb_width, y + thumb_height + label_height), fill=(10, 12, 14))
            draw.text((x + 6, y + thumb_height + 5), str(row["file"]), fill=(224, 226, 220), font=font)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output_path, quality=88)


def write_report(
    report_path: Path,
    directory: Path,
    contact_sheet: Path,
    expected_size: tuple[int, int],
    rows: list[dict[str, object]],
    ok: bool,
    issues: list[str],
) -> None:
    lines = [
        "# Accessibility Profile Manifest Report",
        "",
        f"Profiles directory: `{directory}`",
        f"Expected size: `{expected_size[0]}x{expected_size[1]}`",
        f"Contact sheet: `{contact_sheet}`",
        f"Metadata: `{directory / 'accessibility_capture_metadata.json'}`",
        f"Status: `{'passed' if ok else 'failed'}`",
        "",
        "| Profile | Size | Mean luma | Luma stdev | Alpha range | Status |",
        "|---|---:|---:|---:|---:|---|",
    ]
    for row in rows:
        size = row.get("size")
        size_text = "missing" if size is None else f"{size[0]}x{size[1]}"
        alpha_text = "missing"
        if "min_alpha" in row and "max_alpha" in row:
            alpha_text = f"{row['min_alpha']}-{row['max_alpha']}"
        mean = row.get("mean_luma")
        stdev = row.get("stdev_luma")
        lines.append(
            f"| `{row['file']}` | {size_text} | {float(mean):.1f} | {float(stdev):.1f} | {alpha_text} | {row['status']} |"
            if mean is not None and stdev is not None
            else f"| `{row['file']}` | {size_text} | n/a | n/a | {alpha_text} | {row['status']} |"
        )
    if issues:
        lines.extend(["", "Issues:", ""])
        lines.extend(f"- {issue}" for issue in issues)
    lines.extend(["", "This manifest covers all six profiles, current-source metadata, and non-blank screenshot output.", ""])
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--profiles-dir", type=Path, required=True)
    parser.add_argument("--report", type=Path, required=True)
    parser.add_argument("--expected-size", type=parse_size, required=True)
    args = parser.parse_args()

    contact_sheet = args.profiles_dir / "contact_sheet.jpg"
    ok, issues, rows = validate(args.profiles_dir, args.expected_size)
    write_contact_sheet(args.profiles_dir, rows, contact_sheet)
    write_report(args.report, args.profiles_dir, contact_sheet, args.expected_size, rows, ok, issues)
    print(f"wrote {args.report}")
    if issues:
        for issue in issues:
            print(f"FAIL: {issue}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
