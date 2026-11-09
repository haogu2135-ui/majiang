#!/usr/bin/env python3

import argparse
import copy
import json
from pathlib import Path
import struct

from verify_reading_capture_manifests import runtime_fingerprint


PROFILES = {
    f"{width}x{height}{suffix}": (width, height, bool(suffix))
    for width, height in [(960, 540), (1280, 720), (1920, 1080)]
    for suffix in ["", "_large_contrast"]
}
STATES = {
    "short_0", "short_1", "short_12", "short_99plus", "long_0", "long_99plus",
    "detail_top", "detail_end", "error_minimum_dwell", "animation_entry",
    "animation_exit", "settings", "settings_released", "menu", "shop",
}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def encloses(outer, inner, inset=0.0):
    return (
        inner[0] >= outer[0] + inset - 0.15
        and inner[1] >= outer[1] + inset - 0.15
        and inner[0] + inner[2] <= outer[0] + outer[2] - inset + 0.15
        and inner[1] + inner[3] <= outer[1] + outer[3] - inset + 0.15
    )


def overlaps(first, second, clearance=0.0):
    return (
        first[0] < second[0] + second[2] + clearance - 0.15
        and first[0] + first[2] > second[0] - clearance + 0.15
        and first[1] < second[1] + second[3] + clearance - 0.15
        and first[1] + first[3] > second[1] - clearance + 0.15
    )


def validate_state(name, state):
    require(state["queue_entries"] <= 24 and state["queue_bytes"] <= 4096 and state["queue_count"] <= 24 * 999, "queue budget")
    require(state["toast_scale"] == [1.0, 1.0], "moving visual bounds")
    require(state["surface"] in ["settings_readable_gpt", "shop_existing_footer"], "quiet existing surface")
    if not state["toast_visible"]:
        require(name == "settings" and state["safe_layout_waiting"] and not state["dwell_running"], "hidden notification expired instead of holding for modal reading")
        return
    require(not state["safe_layout_waiting"], "visible waiting slot")
    rect = state["toast_rect"]
    labels = []
    for label_name in ["ToastMessageLabel", "ToastPendingLabel"]:
        label = state[label_name]
        if not label["visible"]:
            continue
        require(label["rect"][3] >= label["minimum_height"] - 0.15, "native line clipped")
        require(label["native_lines"] == label["visible_lines"] == 1, "missing native line")
        require(encloses(rect, label["rect"], 6.0), "native paper inset")
        labels.append(label["rect"])
    if len(labels) == 2:
        require(not overlaps(*labels), "pending and message overlap")
    pending = state["ToastPendingLabel"]
    expected_pending = ("还有99+条" if state["queue_count"] > 99 else f"还有{state['queue_count']}条") if state["queue_count"] else ""
    require(pending["text"] == expected_pending and pending["visible"] == bool(state["queue_count"]), "pending status belongs to wrong queue state")
    if state["detail_button_visible"]:
        detail = state["detail_button_rect"]
        require(detail[2] >= 44.0 and detail[3] >= 44.0 and encloses(rect, detail, 6.0), "full-text touch lane or inset")
        require(not overlaps(detail, state["ToastMessageLabel"]["rect"]), "full-text action covers message")
        require(state["full_text_route"] == "ToastDetailButton", "missing explicit full-text route")
    else:
        require(state["full_text_route"] == "native_complete_message", "short notice full-text owner")
    if state["mode"] in ["offline", "online_game"]:
        require(state["obstacles"], "missing actual page obstacles")
        for obstacle in state["obstacles"]:
            require(not overlaps(rect, obstacle["rect"], 6.0), f"visible bounds obscure {obstacle['name']}")
    if name.startswith("short_"):
        expected_count = {"short_0": 0, "short_1": 1, "short_12": 12, "short_99plus": 100}[name]
        require(state["queue_count"] == expected_count and state["toast_text"] == "已定位：1万", "short state fixture identity")
        require(state["ToastMessageLabel"]["text"] == state["toast_text"] and not state["detail_button_visible"], "short notification hides its actual located tile behind details")
    if name.startswith("long_") or name.startswith("detail_"):
        require(state["toast_text"].count("\n") >= 10 and state["ToastMessageLabel"]["full_text"] == state["toast_text"], "multiline full notification lost")
        require(state["detail_button_visible"], "long notification has no complete route")
    if name.startswith("detail_"):
        require(state["detail_open"] and state["detail_text"] == state["toast_text"] and not state["dwell_running"], "detail reading snapshot or paused dwell")
        if name == "detail_end":
            body = state["detail_body_rect"]
            scroll = state["detail_scroll_rect"]
            require(body[1] + body[3] <= scroll[1] + scroll[3] + 1.0, "last notification line unreachable")
    if name == "error_minimum_dwell":
        require(state["minimum_dwell_msec"] >= 2600, "important notification dwell removed")
    if name == "animation_exit":
        require(0.0 < state["toast_alpha"] < 1.0, "exit evidence is not a partially visible fading frame")


def self_test():
    label = {"visible": True, "rect": [16, 16, 150, 32], "minimum_height": 27, "native_lines": 1, "visible_lines": 1, "text": "已定位：1万", "full_text": "已定位：1万"}
    state = {"queue_entries": 0, "queue_bytes": 0, "queue_count": 0, "toast_scale": [1.0, 1.0], "surface": "settings_readable_gpt", "toast_visible": True, "safe_layout_waiting": False, "toast_rect": [10, 10, 240, 44], "ToastMessageLabel": label, "ToastPendingLabel": {"visible": False, "text": ""}, "detail_button_visible": False, "full_text_route": "native_complete_message", "mode": "offline", "obstacles": [{"name": "TopHud3DShell", "rect": [10, 60, 900, 50]}], "toast_text": "已定位：1万"}
    state["ToastPendingLabel"] = {**label, "visible": False, "text": "", "rect": [176, 16, 68, 32]}
    validate_state("short_0", state)
    mutations = [
        lambda data: data.update(toast_scale=[0.9, 0.9]),
        lambda data: data["ToastMessageLabel"].update(visible_lines=0),
        lambda data: data["ToastMessageLabel"].update(rect=[10, 10, 150, 32]),
        lambda data: data["obstacles"][0].update(rect=[10, 58, 900, 50]),
        lambda data: data.update(queue_bytes=4097),
        lambda data: data.update(detail_button_visible=True, detail_button_rect=[200, 10, 44, 44], full_text_route="ToastDetailButton"),
        lambda data: data.update(toast_visible=False, safe_layout_waiting=True, dwell_running=True),
        lambda data: data["ToastPendingLabel"].update(text="还有1条", visible=True),
        lambda data: data["ToastMessageLabel"].update(text="已定位…"),
    ]
    for index, mutation in enumerate(mutations):
        bad = copy.deepcopy(state)
        mutation(bad)
        try:
            validate_state("short_0", bad)
        except ValueError:
            continue
        raise ValueError(f"negative selfcheck {index} was accepted")
    print("SELFTEST OK: 1 synthetic positive and 9 rejected mutations; not product captures")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("directory", type=Path, nargs="?")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        self_test()
    if args.directory is None:
        require(args.self_test, "capture directory required")
        return
    directory = args.directory
    fingerprint = (directory / "runtime.sha256").read_text().strip()
    batch = (directory / "batch.id").read_text().strip()
    require(fingerprint == runtime_fingerprint(), "current runtime fingerprint differs from capture batch")
    count = 0
    for profile, (width, height, large) in PROFILES.items():
        folder = directory / "toast" / profile
        require({path.stem for path in folder.glob("*.json")} == STATES, f"{profile}: incomplete or unexpected capture state set")
        require({path.stem for path in folder.glob("*.png")} == STATES, f"{profile}: PNG/metadata pairs differ")
        for name in sorted(STATES):
            path = folder / f"{name}.json"
            state = json.loads(path.read_text())
            require(state["runtime_source_diff_fingerprint"] == fingerprint and state["capture_batch_id"] == batch, f"{path}: wrong source or batch")
            require(state["viewport_size"] == [width, height] and state["large_text_enabled"] is large and state["high_contrast_enabled"] is large, f"{path}: wrong viewport or accessibility profile")
            require(state["game_version"] == "1.0.180-godot" and state["capture_time_utc"], f"{path}: missing version or capture time")
            header = path.with_suffix(".png").read_bytes()[:24]
            require(header[:8] == b"\x89PNG\r\n\x1a\n" and struct.unpack(">II", header[16:24]) == (width, height), f"{path}: PNG identity")
            try:
                validate_state(name, state)
            except ValueError as error:
                raise ValueError(f"{path}: {error}") from error
            count += 1
    print(f"TOAST CAPTURES VALID: {count} source-bound PNG/JSON pairs across six profiles")


if __name__ == "__main__":
    main()
