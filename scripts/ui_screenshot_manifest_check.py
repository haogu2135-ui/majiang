#!/usr/bin/env python3
"""Validate UI page screenshots captured by scripts/page_screenshot_capture.gd."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, ImageStat


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_PAGES_DIR = ROOT / "build" / "qa" / "pages"
DEFAULT_REPORT = ROOT / "build" / "qa" / "ui_screenshot_manifest_report.md"
DEFAULT_CONTACT_SHEET_NAME = "contact_sheet.jpg"
EXPECTED_SCREENS = [
    "01_menu.png",
    "02_menu_settings.png",
    "03_offline_battle.png",
    "04_rules.png",
    "05_stats.png",
    "06_achievements.png",
    "07_shop.png",
    "08_online_lobby.png",
    "09_daily_login.png",
    "10_loading.png",
    "11_exit_confirm.png",
    "12_toast.png",
    "13_round_summary.png",
    "14_danger_discard.png",
    "15_pending_claim_full.png",
    "16_win_detail.png",
    "17_hand_tutorial.png",
    "18_update_dialog.png",
    "19_reset_progress.png",
    "20_chat_panel.png",
    "21_diagnostic.png",
    "22_advisor.png",
    "23_online_lobby_connected.png",
    "24_online_lobby_disconnect_recovery.png",
    "25_replay_import_empty.png",
    "26_replay_import.png",
    "27_online_game.png",
    "28_online_game_pending.png",
    "29_online_game_chat.png",
    "30_online_game_disconnect.png",
    "31_telemetry_default.png",
    "32_telemetry_consented.png",
    "33_telemetry_revoked.png",
    "34_telemetry_exported.png",
]
REQUIRED_INTERACTIVE_STATE_CONTRACTS = {
    "23_online_lobby_connected": {
        "fixture_seed": "seed_preview_online_lobby_connected",
        "required_nodes": ["OnlineLobbyLowFrequencyPagePlate", "OnlineLobbyHostEdit", "OnlineLobbyRoomEdit", "OnlineLobbyConnectButton", "OnlineLobbyPrimaryStartButton", "OnlineLobbyStatusLabel"],
        "default_focus": "OnlineLobbyConnectButton",
        "state_text": "房间同步完成",
    },
    "24_online_lobby_disconnect_recovery": {
        "fixture_seed": "seed_preview_online_lobby_disconnect_recovery",
        "required_nodes": ["OnlineLobbyLowFrequencyPagePlate", "OnlineLobbyHostEdit", "OnlineLobbyRoomEdit", "OnlineLobbyConnectButton", "OnlineLobbyStatusLabel"],
        "default_focus": "OnlineLobbyConnectButton",
        "state_text": "连接已断开",
    },
    "25_replay_import_empty": {
        "fixture_seed": "show_replay_import_screen",
        "required_nodes": ["ReplayImportPanel", "ReplayImportCodeInput", "ReplayImportButton", "ReplayImportTimeline", "ReplayImportTimelineScroll"],
        "default_focus": "ReplayImportCodeInput",
        "state_text": "等待导入",
    },
    "26_replay_import": {
        "fixture_seed": "seed_preview_replay_import",
        "required_nodes": ["ReplayImportPanel", "ReplayImportCodeInput", "ReplayImportButton", "ReplayImportTimeline", "ReplayImportTimelineScroll", "ReplayArchivePane", "ReplayArchiveScroll", "ReplayImportEventList"],
        "default_focus": "ReplayImportCodeInput",
        "state_text": "校验通过",
    },
    "27_online_game": {
        "fixture_seed": "seed_preview_online_game:awaitDiscard",
        "required_nodes": ["TopHudStatus", "TopHudWallText", "HandTray", "ActionButtonDock"],
        "default_focus": "HandTile_",
        "state_text": "轮到你出牌",
    },
    "28_online_game_pending": {
        "fixture_seed": "seed_preview_online_game:pendingClaim",
        "required_nodes": ["TopHudStatus", "PendingClaimIllustration", "PendingClaimResponseGrid", "ActionButtonDock"],
        "default_focus": "PendingClaimPrimaryButton",
        "state_text": "等待响应",
    },
    "29_online_game_chat": {
        "fixture_seed": "seed_preview_online_game:awaitDiscard+seed_preview_online_game_chat",
        "required_nodes": ["TopHudStatus", "HandTray", "ActionButtonDock", "ChatPanel", "ChatPanelCloseButton", "ChatInput", "ChatSendButton"],
        "default_focus": "ChatInput",
        "state_text": "房间消息",
    },
    "30_online_game_disconnect": {
        "fixture_seed": "seed_preview_online_game:awaitDiscard+seed_preview_online_game_disconnect",
        "required_nodes": ["TopHudStatus", "HandTray", "ActionButtonDock"],
        "default_focus": "OnlineReconnectGameButton",
        "state_text": "连接已断开",
    },
    "31_telemetry_default": {
        "fixture_seed": "seed_preview_telemetry:default",
        "required_nodes": ["TelemetryDataSheet", "TelemetryDataSheetCard", "TelemetryConsentButton", "TelemetryExportButton", "TelemetryClearButton", "TelemetryDataSheetCloseButton", "TelemetryDataStatus", "TelemetryExportStatus"],
        "default_focus": "TelemetryConsentButton",
        "state_text": "未同意 · 默认不记录",
    },
    "32_telemetry_consented": {
        "fixture_seed": "seed_preview_telemetry:consented",
        "required_nodes": ["TelemetryDataSheet", "TelemetryDataSheetCard", "TelemetryConsentButton", "TelemetryExportButton", "TelemetryClearButton", "TelemetryDataSheetCloseButton", "TelemetryDataStatus", "TelemetryExportStatus"],
        "default_focus": "TelemetryConsentButton",
        "state_text": "已同意 · 本地队列",
    },
    "33_telemetry_revoked": {
        "fixture_seed": "seed_preview_telemetry:revoked",
        "required_nodes": ["TelemetryDataSheet", "TelemetryDataSheetCard", "TelemetryConsentButton", "TelemetryExportButton", "TelemetryClearButton", "TelemetryDataSheetCloseButton", "TelemetryDataStatus", "TelemetryExportStatus"],
        "default_focus": "TelemetryConsentButton",
        "state_text": "已关闭 · 不记录",
    },
    "34_telemetry_exported": {
        "fixture_seed": "seed_preview_telemetry:exported",
        "required_nodes": ["TelemetryDataSheet", "TelemetryDataSheetCard", "TelemetryConsentButton", "TelemetryExportButton", "TelemetryClearButton", "TelemetryDataSheetCloseButton", "TelemetryDataStatus", "TelemetryExportStatus"],
        "default_focus": "TelemetryExportButton",
        "state_text": "匿名诊断数据已复制",
    },
}
DEFAULT_EXPECTED_SIZE = (1280, 720)
CONTACT_SHEET_COLUMNS = 2
CONTACT_SHEET_THUMB_SIZE = (480, 270)
CONTACT_SHEET_LABEL_HEIGHT = 24
CONTACT_SHEET_GAP = 8


def image_stats(path: Path) -> dict[str, object]:
	with Image.open(path) as image:
		rgba = image.convert("RGBA")
		grayscale = rgba.convert("L")
		luma_stat = ImageStat.Stat(grayscale)
		alpha_min, alpha_max = rgba.getchannel("A").getextrema()
		pixels = rgba.getdata()
		total = max(1, rgba.size[0] * rgba.size[1])
		magenta_pixels = 0
		transparent_pixels = 0
		for red, green, blue, alpha in pixels:
			if alpha <= 8:
				transparent_pixels += 1
			if red >= 220 and blue >= 220 and green <= 80 and alpha >= 180:
				magenta_pixels += 1
		return {
			"size": rgba.size,
			"mode": image.mode,
			"mean_luma": luma_stat.mean[0],
			"stdev_luma": luma_stat.stddev[0],
			"min_alpha": alpha_min,
			"max_alpha": alpha_max,
			"magenta_ratio": magenta_pixels / total,
			"transparent_ratio": transparent_pixels / total,
		}


def parse_size(value: str) -> tuple[int, int]:
    parts = value.lower().split("x")
    if len(parts) != 2:
        raise argparse.ArgumentTypeError("expected WIDTHxHEIGHT")
    try:
        width = int(parts[0])
        height = int(parts[1])
    except ValueError as exc:
        raise argparse.ArgumentTypeError("expected integer WIDTHxHEIGHT") from exc
    if width <= 0 or height <= 0:
        raise argparse.ArgumentTypeError("size must be positive")
    return width, height


def validate(pages_dir: Path, expected_size: tuple[int, int]) -> tuple[bool, list[dict[str, object]]]:
    rows: list[dict[str, object]] = []
    ok = True
    for name in EXPECTED_SCREENS:
        path = pages_dir / name
        row: dict[str, object] = {"file": name, "path": path, "status": "missing"}
        if not path.exists():
            rows.append(row)
            ok = False
            continue
        stats = image_stats(path)
        row.update(stats)
        issues: list[str] = []
        if stats["size"] != expected_size:
            issues.append("wrong-size")
        if float(stats["stdev_luma"]) < 4.0:
            issues.append("near-blank")
        if int(stats["max_alpha"]) == 0:
            issues.append("fully-transparent")
        if float(stats["transparent_ratio"]) > 0.02:
            issues.append("large-transparent-area")
        if float(stats["magenta_ratio"]) > 0.001:
            issues.append("magenta-placeholder-color")
        row["status"] = "ok" if not issues else ", ".join(issues)
        rows.append(row)
        if issues:
            ok = False
    return ok, rows


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


def validate_capture_metadata(pages_dir: Path, expected_size: tuple[int, int]) -> tuple[bool, list[str]]:
    metadata_path = pages_dir / "capture_metadata.json"
    if not metadata_path.exists():
        return False, [f"missing `{metadata_path}`"]
    try:
        metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        return False, [f"invalid `{metadata_path}`: {exc}"]
    try:
        revision, worktree_state, runtime_source_state = current_git_state()
        worktree_diff_fingerprint = current_state_fingerprint()
        runtime_source_diff_fingerprint = current_state_fingerprint(
            ("project.godot", "scripts/main_base.gd", "scripts/main.gd", "scripts/main_src", "scripts/ui")
        )
    except (OSError, subprocess.CalledProcessError) as exc:
        return False, [f"unable to read current git state: {exc}"]
    expected = {
        "capture_revision": revision,
        "worktree_state": worktree_state,
        "runtime_source_state": runtime_source_state,
        "worktree_diff_fingerprint": worktree_diff_fingerprint,
        "runtime_source_diff_fingerprint": runtime_source_diff_fingerprint,
        "capture_size": f"{expected_size[0]}x{expected_size[1]}",
    }
    issues = []
    for key, expected_value in expected.items():
        actual_value = str(metadata.get(key, ""))
        if actual_value != expected_value:
            issues.append(f"{key} expected `{expected_value}` got `{actual_value}`")
    contract = metadata.get("interactive_state_contract")
    if not isinstance(contract, dict):
        issues.append("interactive_state_contract is missing or not an object")
    else:
        issues.extend(validate_interactive_state_contract(contract))
    capture_batch_id = str(metadata.get("capture_batch_id", ""))
    expected_batch_id = os.environ.get("YUNZHUO_CAPTURE_BATCH_ID", "")
    if not capture_batch_id:
        issues.append("capture_batch_id is missing")
    elif expected_batch_id and capture_batch_id != expected_batch_id:
        issues.append(f"capture_batch_id expected `{expected_batch_id}` got `{capture_batch_id}`")
    return not issues, issues


def validate_interactive_state_contract(contract: dict[object, object]) -> list[str]:
    issues: list[str] = []
    for screen_name, expected in REQUIRED_INTERACTIVE_STATE_CONTRACTS.items():
        actual = contract.get(screen_name)
        if not isinstance(actual, dict):
            issues.append(f"interactive_state_contract missing `{screen_name}`")
            continue
        for key in ("fixture_seed", "default_focus", "state_text"):
            expected_value = expected[key]
            actual_value = actual.get(key, "")
            if actual_value != expected_value:
                issues.append(f"{screen_name}.{key} expected `{expected_value}` got `{actual_value}`")
        expected_nodes = set(expected["required_nodes"])
        actual_nodes = actual.get("required_nodes", [])
        if not isinstance(actual_nodes, list) or not expected_nodes.issubset({str(node) for node in actual_nodes}):
            issues.append(f"{screen_name}.required_nodes is incomplete")
    return issues


def write_report(
    report_path: Path,
    pages_dir: Path,
    contact_sheet: Path,
    expected_size: tuple[int, int],
    rows: list[dict[str, object]],
    ok: bool,
    metadata_ok: bool,
    metadata_issues: list[str],
) -> None:
    report_path.parent.mkdir(parents=True, exist_ok=True)
    lines = [
        "# UI Screenshot Manifest Report",
        "",
        f"Pages directory: `{pages_dir}`",
        f"Expected size: `{expected_size[0]}x{expected_size[1]}`",
        f"Contact sheet: `{contact_sheet}`",
        f"Capture metadata: `{pages_dir / 'capture_metadata.json'}`",
        f"Capture metadata status: `{'passed' if metadata_ok else 'failed'}`",
        f"Status: `{'passed' if ok else 'failed'}`",
        "",
        "| File | Size | Mean luma | Luma stdev | Alpha range | Status |",
        "|---|---:|---:|---:|---:|---|",
    ]
    for row in rows:
        size = row.get("size")
        size_text = "missing" if size is None else f"{size[0]}x{size[1]}"
        mean = row.get("mean_luma")
        stdev = row.get("stdev_luma")
        alpha_text = "missing"
        if "min_alpha" in row and "max_alpha" in row:
            alpha_text = f"{row['min_alpha']}-{row['max_alpha']}"
        mean_text = "n/a" if mean is None else f"{float(mean):.1f}"
        stdev_text = "n/a" if stdev is None else f"{float(stdev):.1f}"
        lines.append(
            f"| `{row['file']}` | {size_text} | {mean_text} | {stdev_text} | {alpha_text} | {row['status']} |"
        )
    if metadata_issues:
        lines.extend(["", "Capture metadata issues:", ""])
        lines.extend(f"- {issue}" for issue in metadata_issues)
    lines.extend(
        [
            "",
            "This check proves that the screenshot set is present, has the expected render size, is not blank, and has a freshly rebuilt contact sheet.",
            "It does not replace human visual review for style, overlap, density, contrast, or Android device safe areas.",
            "",
        ]
    )
    report_path.write_text("\n".join(lines), encoding="utf-8")


def write_contact_sheet(pages_dir: Path, rows: list[dict[str, object]], out_path: Path) -> bool:
    valid_rows = [row for row in rows if row.get("status") == "ok"]
    if len(valid_rows) != len(EXPECTED_SCREENS):
        return False
    columns = CONTACT_SHEET_COLUMNS
    rows_count = (len(valid_rows) + columns - 1) // columns
    thumb_w, thumb_h = CONTACT_SHEET_THUMB_SIZE
    label_h = CONTACT_SHEET_LABEL_HEIGHT
    gap = CONTACT_SHEET_GAP
    sheet_w = columns * thumb_w + (columns + 1) * gap
    sheet_h = rows_count * (thumb_h + label_h) + (rows_count + 1) * gap
    sheet = Image.new("RGB", (sheet_w, sheet_h), (14, 16, 18))
    draw = ImageDraw.Draw(sheet)
    try:
        font = ImageFont.load_default()
    except Exception:
        font = None
    for index, row in enumerate(valid_rows):
        source_path = pages_dir / str(row["file"])
        with Image.open(source_path) as source:
            thumb = source.convert("RGB")
            thumb.thumbnail(CONTACT_SHEET_THUMB_SIZE, Image.Resampling.LANCZOS)
            col = index % columns
            row_index = index // columns
            x = gap + col * (thumb_w + gap)
            y = gap + row_index * (thumb_h + label_h + gap)
            sheet.paste(thumb, (x, y))
            label_bar = Image.new("RGB", (thumb_w, label_h), (10, 12, 14))
            sheet.paste(label_bar, (x, y + thumb_h))
            draw.text((x + 6, y + thumb_h + 5), str(row["file"]), fill=(224, 226, 220), font=font)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(out_path, quality=88)
    return True


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--pages-dir", type=Path, default=DEFAULT_PAGES_DIR)
    parser.add_argument("--report", type=Path, default=DEFAULT_REPORT)
    parser.add_argument("--contact-sheet", type=Path, default=None)
    parser.add_argument("--expected-size", type=parse_size, default=DEFAULT_EXPECTED_SIZE)
    args = parser.parse_args()

    contact_sheet = args.contact_sheet if args.contact_sheet is not None else args.pages_dir / DEFAULT_CONTACT_SHEET_NAME
    ok, rows = validate(args.pages_dir, args.expected_size)
    metadata_ok, metadata_issues = validate_capture_metadata(args.pages_dir, args.expected_size)
    contact_ok = write_contact_sheet(args.pages_dir, rows, contact_sheet)
    ok = ok and contact_ok and metadata_ok
    write_report(args.report, args.pages_dir, contact_sheet, args.expected_size, rows, ok, metadata_ok, metadata_issues)
    print(f"wrote {args.report}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
