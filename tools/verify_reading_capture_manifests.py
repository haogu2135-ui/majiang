#!/usr/bin/env python3

import argparse
import datetime
import hashlib
import json
from pathlib import Path
import re
import struct
import subprocess
import sys


ROOT = Path(__file__).resolve().parent.parent
RUNTIME_PATHS = [
    "project.godot",
    "scripts/main_base.gd",
    "scripts/main.gd",
    "scripts/main_src",
    "scripts/ui",
]
BATTLE_NAMES = {
    "table_ledger", "table_archive_end", "table_archive_scrolled", "table_pending",
    "advisor_top", "advisor_end", "advisor_located", "advisor_restored",
    "advisor_no_recommendation", "chat_open", "chat_compose", "chat_max_count",
    "advisor_restricted", "advisor_unrestricted",
    "chat_sent", "chat_meld_1", "chat_meld_2", "lobby_chat_open",
    "lobby_chat_compose", "chat_redraw_compose", "lobby_chat_redraw_compose",
}
READING_NAMES = {
    "rules_top", "rules_chapter_3", "rules_chapter_6", "rules_tab_chapter_3",
    "rules_tab_chapter_6", "lobby_full_unready", "lobby_long_server_error",
    "lobby_long_sync_failure", "lobby_empty_room",
}
HOME_NAMES = {"home", "home_keyboard", "settings", "home_tutorial"}
SHOP_NAMES = {"shop_shortage", "shop_recovery", "shop_available", "shop_purchased"}
GUOFENG_BATTLE_NAMES = {
    "battle_healthy", "battle_keyboard", "battle_low_wall", "battle_pending", "battle_claimed",
    "table_ledger", "table_archive_end", "table_archive_scrolled", "table_pending",
}
GUOFENG_ACTION_NAMES = {
    "action_seats_pending", "action_seats_focus", "action_chi_keyboard_c",
    "action_chi_0_mouse", "action_chi_1_touch", "action_chi_2_key",
    "action_dock_idle", "action_seats_capacity", "action_countdown_open", "action_countdown_expired",
}
GUOFENG_SETTLEMENT_NAMES = {"win_top", "win_end", "retained", "match_complete", "wall_draw", "normal_self_draw", "normal_ron_win", "normal_deal_in", "normal_uninvolved"}
GUOFENG_HAND_NAMES = {
    "hand_idle", "hand_keyboard", "hand_low_wall", "hand_pending", "hand_tutorial",
    "hand_tutorial_finish", "hand_online_waiting", "hand_online_disconnected",
}
GUOFENG_SECONDARY_NAMES = {
    "rules_top", "rules_chapter_3", "rules_chapter_6", "rules_tab_chapter_3", "rules_tab_chapter_6",
    "achievements_top", "achievements_page_down", "achievements_end", "achievements_focus_last",
    "stats_overview", "stats_rule", "lobby_initial", "lobby_recovery", "lobby_connected", "lobby_long_name_detail",
}
GUOFENG_AUXILIARY_NAMES = {
    "daily_available", "daily_claimed", "loading_progress", "loading_error", "exit_confirm",
    "update_downloading", "update_notes_end", "update_error", "diagnostic_top", "diagnostic_end",
    "privacy_default", "privacy_consented", "privacy_exported", "privacy_clear_confirm",
    "replay_empty", "replay_verified", "replay_end",
}
RUNTIME_ERROR = re.compile(
    r"^(?:SCRIPT )?ERROR:|ObjectDB instances leaked|resources still in use|"
    r"RIDs of type .* leaked|RID allocations .* leaked|Leaked instance:",
    re.MULTILINE,
)


def require(condition, message):
    if not condition:
        raise ValueError(message)


def report_field(report, name):
    found = re.search(r"^- " + re.escape(name) + r": (.+)$", report, re.MULTILINE)
    require(found is not None, f"report field missing: {name}")
    return found.group(1).strip("`*")


def runtime_fingerprint():
    source = subprocess.check_output(
        ["git", "diff", "--binary", "--", *RUNTIME_PATHS], cwd=ROOT
    )
    source += subprocess.check_output(
        ["git", "status", "--porcelain", "--", *RUNTIME_PATHS], cwd=ROOT
    )
    return hashlib.sha256(source).hexdigest()


def validate_report(report, fingerprint, expected_checks):
    require(report_field(report, "Result") == "PASS", "report is not PASS")
    require(
        report_field(report, "Runtime source diff fingerprint") == fingerprint,
        "report fingerprint does not match current runtime source",
    )
    require(
        int(report_field(report, "Passed checks")) == expected_checks
        and report_field(report, "Failed checks") == "0",
        f"report must contain {expected_checks} passing checks and no failures",
    )
    require(report.count("| PASS |") == expected_checks, "report gate rows disagree with its counters")


def validate_advisor_state(name, state, path):
    require(state["advisor_surface"] == "settings_readable_gpt", f"{path}: advisor has no opaque authored paper")
    cards = state["cards"]
    collapsed = state["compact_layout_mode"] == "detail_only"
    require((collapsed and not cards) or (not collapsed and len(cards) == 3 and len({card["heading"] for card in cards}) == 3), f"{path}: advisor cards disagree with its actual reading layout")
    for card in cards:
        require(card["visual_descendants"] == 0, f"{path}: advisor card contains fake visual signals")
        extra = 4 if state["large_text_enabled"] else 0
        require(card["primary_font_size"] >= 16 + extra and card["secondary_font_size"] >= 14 + extra and card["heading_font_size"] >= 12 + extra, f"{path}: advisor reading fonts are too small")
        require(card["primary"].replace("\n", "").replace("·", "").replace(" ", "") == card["primary_full"].replace(" · ", ""), f"{path}: advisor primary loses a source clause")
        require(
            card["primary_wrap_mode"] > 0
            and card["primary_visible_lines"] == card["primary_line_count"] >= len(card["primary"].split("\n"))
            and 1 <= card["primary_line_count"] <= 2,
            f"{path}: advisor core conclusion is actually clipped or reset to one line",
        )
        require(card["secondary_full"] and card["secondary_full"] == card["secondary_tooltip"], f"{path}: live advisor refresh loses full evidence")
        card_left, card_top, card_width, card_height = card["rect"]
        require(card_width > 0 and card_height > 0, f"{path}: advisor has an empty reading lane")
        for field in ("primary_rect", "secondary_rect"):
            text_left, text_top, text_width, text_height = card[field]
            require(
                text_width > 0 and text_height > 0
                and text_left >= card_left - 0.5 and text_top >= card_top - 0.5
                and text_left + text_width <= card_left + card_width + 0.5
                and text_top + text_height <= card_top + card_height + 0.5,
                f"{path}: advisor text escapes its real card",
            )
    if name in {"advisor_restricted", "advisor_unrestricted"}:
        restricted = name == "advisor_restricted"
        require(state["restricted"] is restricted and state["candidate_tile"] == "9T", f"{path}: incorrect real-analysis fixture identity")
        require(state["compact_visible"] is True and "detail_source" not in state, f"{path}: restriction must be readable in the compact cards")
        progress = next((card for card in cards if card["heading"] == "势"), None)
        require(progress is not None and progress["primary"].startswith("听牌"), f"{path}: ready-hand conclusion is missing")
        require(("仅自摸" in progress["primary"]) is restricted, f"{path}: primary restriction disagrees with the actual candidate")
        require(("仅自摸" in progress["secondary_full"]) is restricted, f"{path}: complete evidence disagrees with the primary restriction")
        require(re.fullmatch(r"待(?:牌)?\d+张(?:\n听口\d+种)?", progress["secondary"]) is not None, f"{path}: wait count and unit must remain one intact short row")
        return
    if name == "advisor_restored":
        require(state["compact_visible"] is True and "detail_source" not in state, f"{path}: advisor close fails to restore the compact reading owner")
        return
    require(state["compact_visible"] is False and state["detail_surface"] == "settings_readable_gpt", f"{path}: advisor detail has duplicate visible owners or a transparent reading surface")
    require(state["detail_text"] == state["detail_source"] == state["detail_tooltip"] and state["detail_source"], f"{path}: structured advisor body changes or loses source text")
    expected_fields = [line.split("：", 1)[0] for line in state["detail_source"].splitlines() if "：" in line]
    require(state["detail_fields"] == expected_fields, f"{path}: advisor loses its real semantic field hierarchy")
    if name in {"advisor_top", "advisor_end", "advisor_located"}:
        require("振听限制" in state["detail_fields"] and "整手所有听口均仅可自摸，不可接炮" in state["detail_text"], f"{path}: advisor loses the live all-wait self-draw restriction")
    if name == "advisor_top":
        expected_hint = "向下查看" if state["reading_range"] > 1 else "已到底"
        require(state["reading_value"] <= 1 and state["detail_hint"].startswith(expected_hint), f"{path}: advisor first reading position is stale")
    if name == "advisor_end":
        require(state["reading_value"] >= state["reading_range"] - 1 and state["detail_hint"].startswith("已到底"), f"{path}: advisor end evidence is not at the actual final line")


def validate_battle_state(name, state, path):
    if name.startswith("advisor_"):
        validate_advisor_state(name, state, path)
    if name == "table_archive_end":
        row = state["latest_row_rect"]
        viewport = state["scroll_rect"]
        require(row[1] >= viewport[1] - 1 and row[1] + row[3] <= viewport[1] + viewport[3] + 1, f"{path}: latest archive event is not completely visible after initial reflow")
        require(state["scroll_value"] >= int(state["scroll_range"]), f"{path}: archive stopped at an obsolete initial range")
    if name == "advisor_located":
        require(
            state["selected_index"] == state["expected_index"] >= 0
            and state["focused_control"].startswith("AdvisorDetail"),
            f"{path}: recommended tile or modal focus is wrong",
        )
    elif name == "advisor_restored":
        require(
            state["focused_hand_source_index"] == state["expected_index"] >= 0,
            f"{path}: recommended hand focus was not restored",
        )
    elif name == "advisor_no_recommendation":
        require(state["recommendation_disabled"] is True, f"{path}: unavailable recommendation is active")
    elif name == "chat_max_count":
        require(state["counter"].endswith("64/64"), f"{path}: full character count is missing")
    elif name == "chat_sent":
        require(
            state["latest_message"] == "你: 可读性验证"
            and state["chat_writes"] == 1 and state["table_writes"] == 0,
            f"{path}: chat did not send exactly once without a table action",
        )
    elif name in {"chat_meld_1", "chat_meld_2"}:
        require(state["route"] != "upper_meld_safe_drawer", f"{path}: chat uses an obstructed meld route")
    elif name in {"chat_redraw_compose", "lobby_chat_redraw_compose"}:
        require(
            state["focused_control"] == "ChatInput" and state["draft"] == "动态草稿甲乙丙"
            and state["caret"] == 4 and state["selection_from"] == 1
            and state["selection_to"] == 4 and state["counter"].endswith("7/64")
            and abs(state["body_scroll_value"] - state["expected_body_scroll"]) <= 1,
            f"{path}: live redraw did not preserve native editing and composing state",
        )


def validate_home_state(name, state, path):
    if name == "home":
        require(state["background_key"] == "menu_guofeng_moonlit", f"{path}: incorrect garden artwork")
        faces = state["faces"]
        require(len(faces) == 3 and len({face["name"] for face in faces}) == 3, f"{path}: missing or duplicate home actions")
        require(
            faces[0]["name"] == "MenuPrimaryOfflineCard"
            and faces[0]["texture_key"] == "menu_ink_primary"
            and faces[0]["title"] == "入席开局"
            and all(face["texture_key"] == "menu_card_readable_gpt" for face in faces[1:]),
            f"{path}: primary and secondary hierarchy disagrees with the authored faces",
        )
        require(state["focused_control"] == "MenuPrimaryOfflineCard", f"{path}: missing default offline focus")
    elif name == "home_keyboard":
        require(state["focused_control"] not in ["", "MenuPrimaryOfflineCard"], f"{path}: keyboard focus did not move")
    elif name == "settings":
        require(state["surface_key"] == "settings_readable_gpt", f"{path}: incorrect settings surface")
        rows = state["rows"]
        require(len(rows) == 13 and len({row["name"] for row in rows}) == 13, f"{path}: missing or duplicate settings actions")
        require(all(row["face_key"] in ["menu_ink_primary", "menu_card_readable_gpt"] for row in rows), f"{path}: incorrect settings action artwork")
    elif name == "settings_end":
        require(state["scroll_value"] > 0 and state["reset_visible"] is True, f"{path}: settings end does not reach the reset action")
    elif name == "home_tutorial":
        require(state["tutorial_step"] == 1, f"{path}: missing resumable tutorial evidence")
        require(state["title_luminance"] <= 0.24 and state["status_luminance"] <= 0.24, f"{path}: unreadable tutorial ink")
        require(state["card_clearance"] >= 12, f"{path}: tutorial banner crowds the primary action")


def validate_shop_state(name, state, path):
    require(name in SHOP_NAMES, f"{path}: unexpected shop capture")
    require(state["surface_key"] == "settings_readable_gpt", f"{path}: incorrect shop surface")
    require(state["coins"] == 100, f"{path}: shop changed the coin balance")
    expected_gems = {"shop_shortage": 0, "shop_recovery": 0, "shop_available": 100, "shop_purchased": 85}[name]
    require(state["gems"] == expected_gems, f"{path}: incorrect purchase debit")
    rows = state["rows"]
    item_ids = {"swap_card", "peek_card", "lucky_charm", "double_coins"}
    require(len(rows) == 4 and {row["item_id"] for row in rows} == item_ids, f"{path}: missing or duplicate shop items")
    shortage = name in {"shop_shortage", "shop_recovery"}
    for row in rows:
        require(row["disabled"] is shortage, f"{path}: incorrect purchase availability")
        require(row["face_key"] == ("menu_card_readable_gpt" if shortage else "menu_ink_primary"), f"{path}: incorrect purchase face")
        require(row["command"].startswith("不足 " if shortage else "购买 ") and row["command"].endswith("玉符"), f"{path}: missing visible purchase or shortage reason")
        expected_inventory = (5 if name == "shop_purchased" else 2) if row["item_id"] == "swap_card" else 0
        require(row["inventory_count"] == expected_inventory, f"{path}: incorrect owned inventory")
    expected_focus = "ShopItemBuyButton_swap_card" if name == "shop_purchased" else ("ShopGetGemsButton" if name == "shop_recovery" else "ShopBackButton")
    require(state["focused_control"] == expected_focus, f"{path}: purchase did not preserve the native focus route")
    require(state["visible_focus_markers"] == 1, f"{path}: missing or ambiguous native focus marker")
    expected_toast = "购买成功" if name == "shop_purchased" else ("玉符获取" if name == "shop_recovery" else "")
    require(state["toast_text"].startswith(expected_toast) if expected_toast else state["toast_text"] == "", f"{path}: incorrect feedback lifecycle")


def validate_guofeng_battle_state(name, state, path):
    if not name.startswith("battle_"):
        validate_battle_state(name, state, path)
        if name == "table_pending":
            require(state["phase"] == "pending_claim", f"{path}: incorrect table response phase")
        return
    require(state["hud_surface_key"] == state["ledger_surface_key"] == "menu_card_readable_gpt", f"{path}: incorrect paper surfaces")
    require(state["center_surface_key"] == "menu_ink_primary", f"{path}: incorrect ink center")
    require(bool(state["self_name"]), f"{path}: missing self-seat identity")
    if state["advisor_visible"]:
        left, top, width, height = state["advisor_rect"]
        for obstacle in state["advisor_obstacles"]:
            x, y, w, h = obstacle["rect"]
            require(left + width <= x - 5.5 or x + w <= left - 5.5 or top + height <= y - 5.5 or y + h <= top - 5.5, f"{path}: advisor covers actual {obstacle['name']}")
        require(state["advisor_layout_mode"] in {"sidebar", "header", "detail_only"}, f"{path}: missing occupied-channel analysis route")
    require(state["wall_total"] == 144 and state["hand_number"] == 1, f"{path}: incorrect battle fixture")
    expected_wall = 18 if name == "battle_low_wall" else 64
    require(state["wall_count"] == expected_wall, f"{path}: incorrect live wall count")
    expected_phase = "pending_claim" if name == "battle_pending" else "await_discard"
    require(state["phase"] == expected_phase, f"{path}: incorrect response phase")
    require(state["meld_count"] == int(name == "battle_claimed"), f"{path}: missing or duplicate meld commit")
    require(state["ledger_visible"] is (name != "battle_pending"), f"{path}: ledger does not yield to the response")
    expected_state = "状态 · 将尽 · 上张3万" if name == "battle_low_wall" else "状态 · 充足 · 上张" + ("无" if name == "battle_claimed" else "3万")
    require(state["wall_state"] == expected_state, f"{path}: incorrect native wall state")
    compact = state["viewport_size"][0] <= 960 or state["viewport_size"][1] < 720
    expected_center_state = ("低墙" if compact else "牌墙将尽") if name == "battle_low_wall" else ("牌墙" if compact else "牌墙充足")
    require(state["center_wall_state"] == expected_center_state, f"{path}: stale center wall state")
    if name == "battle_keyboard":
        require(state["focused_control"] == "TopHudSettingsButton", f"{path}: incorrect native HUD focus")


def validate_action_seat_state(name, state, path):
    require(name in GUOFENG_ACTION_NAMES, f"{path}: unexpected action capture")
    require(state["hud_surface_key"] == "menu_card_readable_gpt", f"{path}: incorrect battle paper surface")
    require(state["center_surface_key"] == "menu_ink_primary", f"{path}: incorrect battle ink surface")
    require(state["dock_surface"] == "menu_card_readable_gpt", f"{path}: incorrect action dock surface")
    facts = state["seat_facts"]
    require(len(facts) == 4 and {fact["seat"] for fact in facts} == set(range(4)), f"{path}: missing or duplicate seat facts")
    for fact in facts:
        require(fact["surface"] == "menu_card_readable_gpt", f"{path}: incorrect seat surface")
        require(f"手{fact['hand_count']}" in fact["meta_text"] and f"花{fact['flower_count']}" in fact["meta_text"], f"{path}: stale native hand or flower count")
    if name in {"action_dock_idle", "action_seats_capacity", "action_countdown_open", "action_countdown_expired"}:
        require(state["meld_count"] == 0 and not state["self_melds"], f"{path}: chrome test unexpectedly committed a meld")
        require(state["phase"] == ("pending_claim" if name == "action_countdown_open" else "await_discard"), f"{path}: incorrect chrome lifecycle phase")
        if name == "action_seats_capacity":
            require(all(fact["flower_count"] == 8 and fact["score"] == 32000 + fact["seat"] * 1000 for fact in facts), f"{path}: capacity cache fixture is stale")
        if name == "action_countdown_open":
            require(state["pending_seconds"] >= 4 and state["timer_text"].startswith("剩余 ") and state["timer_text"].endswith("秒"), f"{path}: missing live countdown")
            require(state["warning_text"] == "到0自动过", f"{path}: default timeout consequence is not visible")
        if name == "action_countdown_expired":
            require(state["timer_text"] == state["warning_text"] == "" and state["pending_seconds"] == -1, f"{path}: expired countdown remains live")
        return
    pending = name in {"action_seats_pending", "action_seats_focus"}
    require(state["phase"] == ("pending_claim" if pending else "await_discard"), f"{path}: incorrect native response lifecycle")
    require(state["meld_count"] == len(state["self_melds"]) == int(not pending), f"{path}: missing or duplicate chi commit")
    for action in state["actions"]:
        require(action["face"] in {"menu_card_readable_gpt", "menu_ink_primary"}, f"{path}: incorrect native action face")
    if pending:
        choices = [action for action in state["actions"] if action["choice"]]
        require(len(choices) == 3 and sum(action["shortcut"] == "C" for action in choices) == 1, f"{path}: ambiguous chi shortcut ownership")
        require(len({tuple(action["choice"]["meld"]) for action in choices}) == 3, f"{path}: duplicate chi payloads")
        scores = {score["seat"]: score for score in state["scores"]}
        require(scores[1]["text"] == "3.2万" and scores[3]["text"] == "2.3万", f"{path}: clipped or stale score magnitude")
        require(scores[1]["font_size"] >= 11 and scores[3]["font_size"] >= 11, f"{path}: unreadable side score")
    else:
        require(len(state["self_melds"][0]) == 3 and "3W" in state["self_melds"][0], f"{path}: incorrect chi target")
    if name == "action_seats_focus":
        require(state["focused_control"] == "PendingClaimButton_chi_01", f"{path}: second chi choice did not receive native focus")


def validate_action_seat_sequence(folder):
    states = {name: json.loads((folder / f"{name}.json").read_text()) for name in GUOFENG_ACTION_NAMES}
    marked = [action["choice"]["meld"] for action in states["action_seats_pending"]["actions"] if action["shortcut"] == "C"]
    require(len(marked) == 1, f"{folder}: C does not have exactly one marked payload")
    require(states["action_chi_keyboard_c"]["self_melds"] == marked, f"{folder}: real C input disagrees with the marked payload")
    committed = [states[name]["self_melds"][0] for name in ["action_chi_0_mouse", "action_chi_1_touch", "action_chi_2_key"]]
    require(len({tuple(meld) for meld in committed}) == 3, f"{folder}: different native targets submitted the same combination")
    legal = {tuple(action["choice"]["meld"]) for action in states["action_seats_pending"]["actions"] if action["choice"]}
    require({tuple(meld) for meld in committed} == legal, f"{folder}: native input lost one of the legal combinations")


def validate_hand_state(name, state, path):
    require(name in GUOFENG_HAND_NAMES, f"{path}: unexpected hand capture")
    require(state["tray_surface"] == "menu_card_readable_gpt" and not state["redundant_wall_count"], f"{path}: incorrect paper surface or redundant wall text")
    tiles = state["tiles"]
    require(len(tiles) == len(state["hand"]) and {tile["index"] for tile in tiles} == set(range(len(tiles))), f"{path}: missing or duplicate hand identity")
    require(all(tile["code"] == state["hand"][tile["index"]] for tile in tiles), f"{path}: hand identity does not match authored tile")
    labels = {label["name"]: label for label in state["labels"]}
    require(labels and all(label["font_size"] >= 11 and label["text"] and label["tooltip"] for label in labels.values()), f"{path}: incomplete native hand text")
    for first_index, first in enumerate(state["labels"]):
        left, top, width, height = first["rect"]
        require(width > 0 and height > 0, f"{path}: empty reading slot")
        for second in state["labels"][first_index + 1:]:
            other_left, other_top, other_width, other_height = second["rect"]
            require(left + width <= other_left or other_left + other_width <= left or top + height <= other_top or other_top + other_height <= top, f"{path}: overlapping hand reading slots")
    tutorial = name in {"hand_tutorial", "hand_tutorial_finish"}
    require(state["tutorial_visible"] is tutorial, f"{path}: incorrect tutorial visibility")
    if tutorial:
        require("HandTrayTutorialHintText" in labels and sum(tile["guide_target"] for tile in tiles) == 1, f"{path}: missing actual tutorial target or native checkpoint")
    if name == "hand_keyboard":
        require(state["selection"] >= 0 and sum(tile["keyboard_selected"] for tile in tiles) == 1 and state["selected_tile"] == state["hand"][state["selection"]], f"{path}: native keyboard selection is absent")
    if name == "hand_low_wall":
        require(state["wall_count"] == 18, f"{path}: missing actual low-wall state")
    if name == "hand_pending":
        require(state["phase"] == "pending_claim" and "过" in labels["HandTrayShortcutHint"]["text"] and "HandTrayStatusText" not in labels, f"{path}: response shortcut or priority is wrong")
    online = name.startswith("hand_online_")
    require((state["mode"] == "online_game") is online, f"{path}: incorrect transport state")
    if online:
        disconnected = name == "hand_online_disconnected"
        require(state["disconnected"] is disconnected and state["waiting_for_server"] is not disconnected, f"{path}: recovery state mismatch")
        require(all(tile["focus_state"] == "read_only" for tile in tiles), f"{path}: online blocked hand exposes selectable tile")
        if disconnected:
            require("HandTrayShortcutHint" not in labels and labels["HandTrayStateBadge"]["text"] == "只读", f"{path}: duplicate recovery shortcut or missing read-only state")


def validate_settlement_state(name, state, path):
    facts = state["facts"]
    require(len(state["rank_rows"]) == 4, f"{path}: missing one of the four accounts")
    require(sum(state["deltas"]) == 0, f"{path}: fixture does not conserve scores")
    for row in state["rank_rows"]:
        delta = state["deltas"][row["seat"]]
        require(row["delta"] == f"{delta:+d}" and row["total"] == str(25000 + delta), f"{path}: imprecise or stale fixture account fact")
    require(facts["RoundSummaryPanel"]["z_index"] > 50, f"{path}: paper is behind the last-discard marker")
    if name == "wall_draw":
        require(state["result_kind"] == "wall_draw" and "WinDetailPanel" not in facts and facts["RoundSummaryTitle"]["text"] == "荒庄结算", f"{path}: stale winning facts in wall draw")
        require(state["deltas"] == [0, 0, 0, 0], f"{path}: wall draw retained the previous winning payment")
    else:
        score = state["score_data"]
        require(facts["WinDetailScoreLabel"]["text"] == f'本局 {state["deltas"][0]:+d}分', f"{path}: primary score disagrees with actual local account delta")
        require(facts["WinDetailYakuStatus"]["text"].startswith(f'{score["fan"]}番 · 基础分{score["points"]}分 · 番种{len(score["reasons"])}项'), f"{path}: missing independent fan/base/count facts")
        extra = 4 if state["large_text_enabled"] else 0
        require(facts["WinDetailScoreLabel"]["font_size"] >= 22 + extra and facts["WinDetailYakuStatus"]["font_size"] >= 13 + extra, f"{path}: result or base facts lost readable font hierarchy")
        if name.startswith("normal_"):
            expected_winner = 0 if name in {"normal_self_draw", "normal_ron_win"} else 1
            expected_from = -1 if name == "normal_self_draw" else (0 if name == "normal_deal_in" else 2)
            require(score["winner"] == expected_winner and score["from_seat"] == expected_from and score["self_draw"] is (name == "normal_self_draw"), f"{path}: incorrect production result identity")
            require(score["points"] > 0 and not score["package_payment"], f"{path}: normal fixture is not an ordinary production payment")
            expected = [-score["points"]] * 4 if score["self_draw"] else [0] * 4
            expected[expected_winner] = score["points"] * 3
            if not score["self_draw"]:
                expected[expected_from] = -score["points"] * 3
            require(state["deltas"] == expected, f"{path}: normal fixture payments do not match the actual rule")
    if name in {"win_end", "retained"}:
        for control_name in ["RoundSummaryBodyScroll", "WinDetailYakuScroll"]:
            scroll = facts[control_name]
            require(scroll["scroll_range"] > 0 and abs(scroll["scroll_value"] - scroll["scroll_range"]) <= 0.5, f"{path}: final content was not reached")
        glyph = facts["RoundSummaryBody"]["last_character_rect"]
        viewport = facts["RoundSummaryBodyScroll"]["rect"]
        require(glyph[2] > 0 and glyph[3] > 0, f"{path}: missing shaped final character")
        require(
            glyph[0] >= viewport[0] - 0.5
            and glyph[1] >= viewport[1] - 0.5
            and glyph[0] + glyph[2] <= viewport[0] + viewport[2] + 0.5
            and glyph[1] + glyph[3] <= viewport[1] + viewport[3] + 0.5,
            f"{path}: actual final character is clipped or outside the reading viewport",
        )
    if name == "match_complete":
        require(facts["RoundSummaryTitle"]["text"] == "全场结算" and "第一名" in facts["RoundSummaryNextDealer"]["text"], f"{path}: wrong terminal account state")


def validate_secondary_state(name, state, path):
    if name.startswith("achievements_"):
        require(state["last"] - state["first"] + 1 == len(state["visible_rows"]), f"{path}: status range disagrees with actual visible rows")
        require(1 <= state["first"] <= state["last"] <= 17, f"{path}: invalid achievement range")
        require("已完成" not in state["status"], f"{path}: unlock completion confused with reading boundary")
        if name == "achievements_top":
            require(state["first"] == 1 and state["last"] < 17 and "已到末尾" not in state["status"], f"{path}: first screen falsely claims every achievement is visible")
        elif name == "achievements_page_down":
            require(state["first"] > 1, f"{path}: PageDown did not advance")
        elif name == "achievements_end":
            require(state["last"] == 17 and "余0" in state["status"] and "已到末尾" in state["status"] and state["scroll_value"] >= int(state["scroll_end"]), f"{path}: incomplete actual reading boundary")
        elif name == "achievements_focus_last":
            require(state["focused_item"] == 17 and state["last"] == 17 and state["final_row_fully_visible"] and "已到末尾" in state["status"], f"{path}: keyboard focus did not reveal and finish the last row")
    elif name.startswith("lobby_"):
        require(state["return_disabled"] is False and state["return_modulate"] == "(1.0, 1.0, 1.0, 1.0)", f"{path}: return is unavailable or dimmed")
        require(state["retry_visible"] is (name == "lobby_recovery"), f"{path}: retry visibility contradicts the actual connection state")
        if name == "lobby_recovery":
            require("断开" in state["feedback"], f"{path}: recovery lost its actual cause")
        elif name in {"lobby_connected", "lobby_long_name_detail"}:
            if name == "lobby_connected":
                visible = state["visible_log_entries"]
                require(visible and f"{visible[0]}-{visible[-1]}/4" in state["log_range"], f"{path}: log range disagrees with actual native line boxes")
            else:
                require(state["full_name"] == "南山听雨观云道友完整昵称" and state["detail_text"] == "玩家 3：" + state["full_name"], f"{path}: actual touched player detail lost its full identity")
                require(state["focus_marker_visible"] and state["focus_marker_before_name"], f"{path}: the actual focused target obscures the roster identity")
            large = state["large_text_enabled"]
            require(state["log_font_size"] >= (17 if large else 13) and state["range_font_size"] >= (16 if large else 12) and min(state[key] for key in ("roster_name_font_size", "roster_state_font_size")) >= (20 if large else 16), f"{path}: lobby refresh shrank accessible reading fonts")
    elif name == "stats_overview":
        require("-8800" in state["score"] and state["summary"] == "-2933", f"{path}: statistics lost signed source values")
    elif name == "stats_rule":
        require(state["selected_rule"] == "yangzhou", f"{path}: rule filter lost its actual scope")


def validate_auxiliary_state(name, state, path):
    labels = state["native_labels"]
    require(bool(labels), f"{path}: no native reading evidence")
    if name.startswith("daily_"):
        for day in range(1, 8):
            for prefix in ["DailyLoginDayLabel_", "DailyLoginDayStateLabel_", "DailyLoginRewardLabel_"]:
                require(bool(labels[prefix + str(day)]["text"]), f"{path}: incomplete day {day}")
        if name == "daily_claimed":
            require(state["claim_state"] == "claimed" and state["coins_added"] == 100, f"{path}: incorrect claim credit")
            if state["toast_visible"]:
                toast, progress = state["toast_rect"], state["progress_rect"]
                require(toast[0] + toast[2] <= progress[0] - 5.99 or progress[0] + progress[2] <= toast[0] - 5.99 or toast[1] + toast[3] <= progress[1] - 5.99 or progress[1] + progress[3] <= toast[1] - 5.99, f"{path}: claim feedback covers the real daily progress")
    elif name == "loading_progress":
        require(state["progress_ratio"] == 0.43 and "同步" in labels["LoadingStatusLabel"]["text"], f"{path}: stale loading progress")
    elif name == "loading_error":
        require(state["error"] is True and "失败" in labels["LoadingStatusLabel"]["text"], f"{path}: absent recovery state")
    elif name == "exit_confirm":
        require(state["safe_focus"] is True and state["mode"] == "offline", f"{path}: unsafe exit focus")
    elif name.startswith("update_"):
        require(state["state"] == ("error" if name == "update_error" else "downloading"), f"{path}: wrong update state")
        if name == "update_notes_end":
            notes, viewport = state["notes_rect"], state["scroll_rect"]
            require(notes[1] + notes[3] <= viewport[1] + viewport[3] + 1 and notes[1] + notes[3] > viewport[1], f"{path}: final release-note line is outside the viewport")
    elif name == "diagnostic_top":
        rows = state["visible_rows"]
        require(bool(rows) and f"{rows[0]}-{rows[-1]}" in state["range_text"], f"{path}: incorrect diagnostic reading range")
    elif name == "diagnostic_end":
        require(state["copied_complete"] is True and state["scroll_value"] > 0, f"{path}: incomplete diagnostic reading")
    elif name in ["privacy_default", "privacy_consented"]:
        require(state["consent"] is (name == "privacy_consented"), f"{path}: stale consent state")
    elif name == "privacy_exported":
        require(state["exported"] is True, f"{path}: absent export")
    elif name == "privacy_clear_confirm":
        require(state["confirming"] is True, f"{path}: clear bypasses confirmation")
    elif name.startswith("replay_"):
        require(state["events"] == (0 if name == "replay_empty" else 81), f"{path}: incomplete imported timeline")
        if name != "replay_empty":
            archive_rows = state["archive_visible_rows"]
            require(bool(archive_rows) and state["archive_range_text"] == f"显示 {archive_rows[0]}-{archive_rows[-1]}/{state['archive_total']} 条", f"{path}: archive range differs from actual visible native rows")
        if name == "replay_end":
            require(state["selected_index"] == 80 and state["scroll_value"] > 0 and state["last_row_bottom"] <= state["viewport_bottom"] + 1, f"{path}: final focused event is clipped")
            rows = state["visible_rows"]
            require(bool(rows) and f"显示 {rows[0]}-{rows[-1]} /" in state["range_text"], f"{path}: replay reading range is stale after native focus scroll")


def validate_captures(batch, fingerprint, include_home=False, include_shop=False, include_guofeng_battle=False, include_guofeng_actions=False, include_guofeng_hand=False, include_guofeng_settlement=False, include_guofeng_secondary=False, include_guofeng_auxiliary=False):
    totals = {}
    groups = [("battle_reading_evidence_", len(BATTLE_NAMES)), ("reading_evidence_", 9)]
    if include_home:
        groups.append(("guofeng_home/", 4))
    if include_shop:
        groups.append(("guofeng_shop/", 4))
    if include_guofeng_battle:
        groups.append(("guofeng_battle/", 9))
    if include_guofeng_actions:
        groups.append(("guofeng_action_seats/", 10))
    if include_guofeng_hand:
        groups.append(("guofeng_hand_tray/", 8))
    if include_guofeng_settlement:
        groups.append(("guofeng_settlement/", len(GUOFENG_SETTLEMENT_NAMES)))
    if include_guofeng_secondary:
        groups.append(("guofeng_secondary/", len(GUOFENG_SECONDARY_NAMES)))
    if include_guofeng_auxiliary:
        groups.append(("guofeng_auxiliary/", 17))
    for prefix, group_count in groups:
        totals[prefix] = 0
        for width, height in [(960, 540), (1280, 720), (1920, 1080)]:
            for large in [False, True]:
                suffix = "_large_contrast" if large else ""
                folder = ROOT / "build/qa" / f"{prefix}{width}x{height}{suffix}"
                paths = sorted(folder.glob("*.json"))
                expected_count = group_count + int(prefix == "guofeng_home/" and large)
                require(len(paths) == expected_count, f"{folder}: expected {expected_count} JSON files")
                names = {path.stem for path in paths}
                require(names == {path.stem for path in folder.glob("*.png")}, f"{folder}: unpaired captures")
                if prefix == "battle_reading_evidence_":
                    require(names == BATTLE_NAMES, f"{folder}: unexpected battle capture names")
                elif prefix == "guofeng_home/":
                    require(names == HOME_NAMES | ({"settings_end"} if large else set()), f"{folder}: unexpected home capture names")
                elif prefix == "guofeng_shop/":
                    require(names == SHOP_NAMES, f"{folder}: unexpected shop capture names")
                elif prefix == "guofeng_battle/":
                    require(names == GUOFENG_BATTLE_NAMES, f"{folder}: unexpected guofeng battle capture names")
                elif prefix == "guofeng_action_seats/":
                    require(names == GUOFENG_ACTION_NAMES, f"{folder}: unexpected guofeng action capture names")
                elif prefix == "guofeng_hand_tray/":
                    require(names == GUOFENG_HAND_NAMES, f"{folder}: unexpected guofeng hand capture names")
                elif prefix == "guofeng_settlement/":
                    require(names == GUOFENG_SETTLEMENT_NAMES, f"{folder}: unexpected settlement capture names")
                elif prefix == "guofeng_secondary/":
                    require(names == GUOFENG_SECONDARY_NAMES, f"{folder}: unexpected secondary page capture names")
                elif prefix == "guofeng_auxiliary/":
                    require(names == GUOFENG_AUXILIARY_NAMES, f"{folder}: unexpected auxiliary capture names")
                else:
                    require(names == READING_NAMES, f"{folder}: unexpected reading capture names")
                for path in paths:
                    state = json.loads(path.read_text())
                    require(state["capture_batch_id"] == batch, f"{path}: stale UI batch")
                    require(state["runtime_source_diff_fingerprint"] == fingerprint, f"{path}: stale runtime source")
                    require(state["game_version"] == "1.0.180-godot", f"{path}: incorrect version")
                    require(state["viewport_size"] == [width, height], f"{path}: incorrect viewport")
                    require(
                        state["large_text_enabled"] is large and state["high_contrast_enabled"] is large,
                        f"{path}: incorrect reading profile",
                    )
                    with path.with_suffix(".png").open("rb") as capture:
                        header = capture.read(24)
                    require(
                        len(header) == 24 and header[:8] == b"\x89PNG\r\n\x1a\n"
                        and struct.unpack(">II", header[16:24]) == (width, height),
                        f"{path}: PNG dimensions disagree with metadata",
                    )
                    if prefix == "battle_reading_evidence_":
                        validate_battle_state(path.stem, state, path)
                    elif prefix == "guofeng_home/":
                        validate_home_state(path.stem, state, path)
                    elif prefix == "guofeng_shop/":
                        validate_shop_state(path.stem, state, path)
                    elif prefix == "guofeng_battle/":
                        validate_guofeng_battle_state(path.stem, state, path)
                    elif prefix == "guofeng_action_seats/":
                        validate_action_seat_state(path.stem, state, path)
                    elif prefix == "guofeng_hand_tray/":
                        validate_hand_state(path.stem, state, path)
                    elif prefix == "guofeng_settlement/":
                        validate_settlement_state(path.stem, state, path)
                    elif prefix == "guofeng_secondary/":
                        validate_secondary_state(path.stem, state, path)
                    elif prefix == "guofeng_auxiliary/":
                        validate_auxiliary_state(path.stem, state, path)
                    totals[prefix] += 1
                if prefix == "guofeng_action_seats/":
                    validate_action_seat_sequence(folder)
                print(f"PASS: {folder.name} {expected_count} current PNG/JSON pairs")
    return totals


def validate_ai_logs(report, expected_checks):
    require(report_field(report, "Run mode") == "fresh", "AI evidence must be a fresh run")
    require(
        int(report_field(report, "Executed checks")) == expected_checks
        and report_field(report, "Cached checks") == "0",
        "AI evidence contains cached or missing checks",
    )
    paths = [Path(path) for path in re.findall(r"`([^`\n]+\.log)`", report)]
    require(len(paths) == len(set(paths)) == expected_checks, "AI evidence has duplicate or missing logs")
    if expected_checks >= 46:
        require(any(path.name == "ai_play_round297.log" for path in paths), "AI evidence is missing visible-coroutine ownership coverage")
    if expected_checks >= 47:
        require(any(path.name == "ai_play_round298.log" for path in paths), "AI evidence is missing projected candidate inventory coverage")
    if expected_checks >= 48:
        require(any(path.name == "ai_play_round299.log" for path in paths), "AI evidence is missing prospective claim inventory route and scoring coverage")
    started = datetime.datetime.strptime(report_field(report, "Time"), "%Y-%m-%d %H:%M:%S %z").timestamp()
    revision = report_field(report, "Git revision")
    dirty = report_field(report, "Runtime source vs HEAD") != "clean"
    for path in paths:
        path = path if path.is_absolute() else ROOT / path
        require(path.stat().st_mtime >= started, f"{path}: log predates the fresh AI batch")
        text = path.read_text()
        require(RUNTIME_ERROR.search(text) is None, f"{path}: runtime error or resource leak")
        if path.name == "ai_play_round298.log":
            require(
                "=== ai_play_round298 check START ===" in text
                and "=== RESULT: OK ===" in text
                and re.search(r"FAIL\s*\|", text) is None,
                f"{path}: failed or incomplete projected inventory gate",
            )
            for assertion in [
                "the controlled candidate table conserves every physical tile and flower",
                "a quiet closed candidate excludes its own discarded copy from remaining waits",
                "a visible closed candidate excludes its own discarded copy from remaining waits",
                "a quiet open candidate excludes its own discarded copy from remaining waits",
                "a visible open candidate excludes its own discarded copy from remaining waits",
                "the pre-discard metric cache is explicitly warmed with a distinct inventory snapshot",
                "candidate ukeire and valued waits agree with physical unseen inventory",
                "the planned discard marks its own winning face as self-discarded",
                "candidate wait quality applies the existing self-discard penalty",
                "a fourth known copy cannot create a phantom live wait",
                "candidate projection leaves the live table and shared evaluation snapshots unchanged",
                "discard risk and meld-feed risk retain their pre-commit visibility boundary",
                "projected wait metrics do not overwrite the unprojected cache entry",
                "the production candidate list still provides legal evaluated choices",
                "every retained production candidate respects public plus original-hand copy counts",
                "the production candidate list exposes the corrected physical wait count",
                "unpruned production evaluation retains the legal planned pair discard",
                "the conserved candidate commits through the real discard boundary",
                "pre-commit candidate inventory matches independently measured post-commit inventory",
                "already-committed diagnostics do not count the same river copy twice",
                "projected and actual discard paths preserve the complete tile ledger",
                "the hidden-information swap preserves all four-copy counts",
                "candidate wait projection does not inspect concealed opponents or wall order",
            ]:
                require(f"OK  | {assertion}" in text, f"{path}: projected inventory assertion missing: {assertion}")
        if path.name == "ai_play_round299.log":
            require(
                "=== ai_play_round299 check START ===" in text
                and "=== RESULT: OK ===" in text
                and re.search(r"FAIL\s*\|", text) is None,
                f"{path}: failed or incomplete prospective claim gate",
            )
            for case_name in ["peng_dead", "chi_dead", "peng_route", "chi_score", "peng_dragon", "chi_straight", "peng_concealed_gang"]:
                require(f"=== CLAIM CASE: {case_name} ===" in text, f"{path}: prospective claim case missing: {case_name}")
            for assertion in [
                "the post-claim fixture allocates every tile and flower without impossible inventory",
                "the source discard and planned claim are legal production actions",
                "the production claim report exports its projected continuation inventory",
                "the production claim report exports its projected continuation score",
                "claim forecasting leaves the live table and shared pre-claim inputs unchanged",
                "the forecast owns the new exposed meld without changing live scoring state",
                "tiles moved into the new meld cannot create a fifth-copy continuation wait",
                "prospective scoring does not poison the live meld grouping cache",
                "the real claim commits one exposed meld with a complete physical ledger",
                "the forecasted continuation is a legal real post-claim discard",
                "predicted post-claim waits match the independently measured committed table",
                "predicted wait fan points and quality match the real exposed-hand evaluation",
                "the projected route includes the new meld exactly like the committed hand",
                "an actual open continuation cannot retain the pre-claim menzen bonus",
                "the authoritative prospective score matches every committed winning pattern",
                "the future chi supplies the missing straight sequence in actual and predicted scoring",
                "the future canonical dragon peng preserves the triplet scoring pattern",
                "an existing concealed gang retains its gang bonus while only the new peng is exposed",
                "the live-pattern fixture has a physical winning continuation",
                "forecast and execution retain all physical cards after claim and discard",
                "a claim projection rejects removal of tiles outside its new meld",
                "a claim projection rejects an incorrect consumed tile total",
                "the public prospective scorer rejects malformed melds and fifth-copy inventory",
                "invalid prospective inputs cannot mutate the live table or caller snapshots",
                "prospective quiet evaluation retains the bounded fast safety path",
                "prospective quiet evaluation preserves caller arrays and physical inventory",
                "the post-claim hidden-information swap conserves every physical copy",
                "post-claim forecasting cannot inspect hidden opponents or wall order",
            ]:
                require(f"OK  | {assertion}" in text, f"{path}: prospective claim assertion missing: {assertion}")
            for assertion in [
                "predicted post-claim waits match the independently measured committed table",
                "predicted wait fan points and quality match the real exposed-hand evaluation",
                "the projected route includes the new meld exactly like the committed hand",
                "forecast and execution retain all physical cards after claim and discard",
            ]:
                require(text.count(f"OK  | {assertion}") >= 7, f"{path}: prospective claim cases were not all checked: {assertion}")
        if expected_checks >= 46:
            require(
                f"=== QA BATCH: {report_field(report, 'QA batch')} ===" in text
                and f"=== RUNTIME SOURCE FINGERPRINT: {report_field(report, 'Runtime source diff fingerprint')} ===" in text,
                f"{path}: AI log batch or source binding mismatch",
            )
        found = re.search(r"^=== QA REVISION: (.+) ===$", text, re.MULTILINE)
        require(found is not None, f"{path}: revision marker missing")
        require(
            found.group(1) == "unbound-dirty-runtime" if dirty else found.group(1).startswith(revision),
            f"{path}: revision marker does not match the report",
        )
        if path.name.startswith("ai_play_round"):
            require("=== RESULT: OK ===" in text and "FAIL|" not in text, f"{path}: failed assertion or successful terminal result missing")
        if path.name == "ai_play_round297.log":
            for assertion in [
                "an old AI draw delay cannot draw discard or score inside a replacement round",
                "an old human-draw completion cannot unlock a live replacement coroutine",
                "a resumed hand with the same round id cannot revive its pre-menu AI coroutine",
                "a stale process-frame callback cannot consume or start the replacement queued worker",
                "a late already-dispatched callback cannot consume replacement ownership or mutate its table",
                "ordinary same-hand redraw preserves the legitimate live AI owner",
                "the legitimate visible AI loop finishes and releases its own ownership",
                "restoring an awaiting human draw queues a fresh legitimate draw worker",
                "resuming the human draw boundary returns an unlocked playable fourteen-tile hand",
                "shutdown releases all active queued and timer-owned AI resources",
            ]:
                require(f"OK  | {assertion}" in text, f"{path}: coroutine assertion missing: {assertion}")
    print(f"PASS: {expected_checks} fresh AI gate logs, no runtime error or resource-leak markers")


def validate_ui_protocol_log(report, fingerprint):
    found = re.search(
        r"^\| Real TCP framing and chat-table action ownership \| PASS \| `([^`]+)` \|$",
        report, re.MULTILINE,
    )
    require(found is not None, "UI report is missing the real TCP protocol gate")
    path = Path(found.group(1))
    path = path if path.is_absolute() else ROOT / path
    started = datetime.datetime.strptime(report_field(report, "Time"), "%Y-%m-%d %H:%M:%S %z").timestamp()
    require(path.stat().st_mtime >= started, f"{path}: protocol log predates the UI batch")
    text = path.read_text()
    batch = report_field(report, "QA batch")
    require(f"=== QA BATCH: {batch} ===" in text, f"{path}: protocol batch marker mismatch")
    require(
        f"=== RUNTIME SOURCE FINGERPRINT: {fingerprint} ===" in text,
        f"{path}: protocol source marker mismatch",
    )
    require(
        "=== RESULT: OK ===" in text and "FAIL|" not in text and RUNTIME_ERROR.search(text) is None,
        f"{path}: failed or incomplete protocol gate",
    )
    for assertion in [
        "chat ownership fixture begins with a real unacknowledged TCP discard",
        "untagged legacy replies cannot guess table ownership while chat also awaits a reply",
        "all chats reach real TCP while pending correlations stay within their declared bound",
        "buffered complete frames continue draining after the socket has no new bytes",
        "the full fifteen-hundred-frame burst completes within the unchanged per-poll processing budget",
    ]:
        require(f"OK  | {assertion}" in text, f"{path}: protocol assertion missing: {assertion}")
    print("PASS: current-batch real TCP chat ownership and buffered-frame protocol evidence")


def validate_ui_offline_input_log(report, fingerprint):
    found = re.search(
        r"^\| Offline native input and deferred-discard lifecycle \| PASS \| `([^`]+)` \|$",
        report, re.MULTILINE,
    )
    require(found is not None, "UI report is missing the offline input lifecycle gate")
    path = Path(found.group(1))
    path = path if path.is_absolute() else ROOT / path
    started = datetime.datetime.strptime(report_field(report, "Time"), "%Y-%m-%d %H:%M:%S %z").timestamp()
    require(path.stat().st_mtime >= started, f"{path}: input lifecycle log predates the UI batch")
    text = path.read_text()
    batch = report_field(report, "QA batch")
    require(f"=== QA BATCH: {batch} ===" in text, f"{path}: input lifecycle batch marker mismatch")
    require(
        f"=== RUNTIME SOURCE FINGERPRINT: {fingerprint} ===" in text,
        f"{path}: input lifecycle source marker mismatch",
    )
    require(
        "=== offline input lifecycle smoke START ===" in text
        and "=== RESULT: OK ===" in text
        and re.search(r"FAIL\s*\|", text) is None
        and RUNTIME_ERROR.search(text) is None,
        f"{path}: failed or incomplete input lifecycle gate",
    )
    for assertion in [
        "the restart fixture keeps the full tile ledger and real replay events",
        "a rapid restart and different-tile discard cannot lose its resolver or deadlock the table",
        "an already-dispatched old same-face resolver cannot adjudicate a replacement round",
        "a retained old native button signal cannot discard from the replacement hand",
        "a second-copy native click removes that exact hand serial rather than the first matching face",
        "a repeated submit while resolving cannot discard a second physical card",
        "the legitimate resolver survives a same-hand redraw and adjudicates on the real process frame",
        "a consumed resolver cannot adjudicate twice or replace a queued AI continuation",
        "real AI turns and legal passes return control to the human within the same round",
        "an old same-round same-face nonce cannot consume or adjudicate a newer human intent",
        "the newer same-round intent remains live after its stale predecessor is ignored",
        "leaving the offline page immediately detaches its pending human resolver",
        "old resolvers and native controls cannot submit into a restored identical hand and round id",
        "a preferred index pointing at a different face cannot consume either physical copy",
        "an out-of-range preferred index cannot fall back to the first matching face",
        "legacy by-value callers still commit one legal face with conserved inventory",
        "shutdown detaches every pending human process-frame resolver",
        "a dispatched human resolver cannot mutate inventory replay or AI ownership after shutdown",
        "the real danger entry preserves the selected physical copy while awaiting consent",
        "one native danger confirmation submits the selected copy without opening a different duplicate intent",
        "danger confirmation removes the selected second serial and preserves the first identical copy",
        "a repeated native danger confirmation cannot consume another physical copy",
        "an old cancel cannot dismiss a reopened same-hand same-face danger intent",
        "an old confirm cannot consent to a reopened same-hand same-face danger intent",
        "an old danger confirm cannot submit or consent inside a replacement round",
        "the current native danger cancel dismisses only its intent without discarding",
        "a current safe alternative submits its own face and retains the declined danger copy",
        "an ownership-changing identical-hand restore rebuilds retained action callbacks",
        "a retired recommendation cannot submit into an identical restored hand",
        "a newly owned recommended action still submits or opens its valid danger intent",
        "real AI discards open an authentic human claim window",
        "an old native pass cannot answer the same claim after menu and restore",
        "an already-dispatched old pass cannot consume restored claim options or append replay events",
        "a same-window redraw preserves a live native pass and its intent sequence",
        "the current native pass still answers its authentic claim exactly once",
        "a newer same-round claim has its own monotonic input sequence",
        "consumed claim controls cannot answer a newer same-round response window",
        "an owned native action at expiry still follows the automatic-pass contract",
        "real AI play opens a legal response for rejection-boundary coverage",
        "the rejection fixture begins with a live unexpired native response",
        "a rejected response leaves inventory claim options replay and intent sequence unchanged",
        "a rejected response preserves the visible native controls focus and guide state",
        "a rejected response cannot hide or disable the legitimate pass action",
        "the existing native pass remains usable after an invalid submission without a redraw",
        "the immediate-menu fixture commits one real discard before its frame adjudication",
        "the production menu flush saves the committed boundary and detaches its old resolver",
        "the production resume entry restores the exact committed discard and original round",
        "a restored resolving human discard receives a newly owned production frame resolver",
        "the old dispatched resolver cannot adjudicate the restored committed boundary",
        "the resumed human discard adjudicates once instead of remaining permanently resolving",
        "resuming adjudication never discards a second copy and preserves the complete tile ledger",
        "the bot-dealer boundary uses a complete production deal and authentic replay",
        "the production commit accepts a real uncontested bot discard",
        "the menu flush persists a committed bot resolving boundary",
        "a bot resolving save restores its original round river and owned adjudicator",
        "an identical bot resolving boundary remains valid for immediate repeated restore",
        "an old bot resolver cannot consume a newer identical restored boundary",
        "an uncontested restored bot discard schedules the pending human draw",
        "restoring seat three completes one real human draw and returns playable control",
        "bot-boundary resume preserves the complete physical ledger without a second discard",
        "the production source discard opens an authentic chi opportunity",
        "the real chi response keeps its conserved source river and hand",
        "a malformed or unoffered chi shape preserves the real response controls and inventory",
        "the native legal chi action remains available after malformed submissions",
        "the original native chi still commits its legal meld exactly once after rejection",
        "a conserved resolving save rejects unauthenticated source_seat ownership",
        "rejected source_seat restore leaves the current table and legitimate pending resolver untouched",
        "a conserved resolving save rejects unauthenticated source_tile ownership",
        "rejected source_tile restore leaves the current table and legitimate pending resolver untouched",
        "a conserved resolving save rejects unauthenticated empty_source ownership",
        "rejected empty_source restore leaves the current table and legitimate pending resolver untouched",
        "a conserved resolving save rejects unauthenticated wrong_river ownership",
        "rejected wrong_river restore leaves the current table and legitimate pending resolver untouched",
        "a conserved resolving save rejects unauthenticated valid_other_face ownership",
        "rejected valid_other_face restore leaves the current table and legitimate pending resolver untouched",
        "the validation cache is warmed by an authentic conserved save",
        "equal-revision saves with changed inventory cannot reuse a valid cached result",
        "rejecting an equal-revision corrupt save cannot clobber the live table or its owner",
        "a cached corrupt verdict cannot poison an authentic equal-revision restore",
    ]:
        require(f"OK  | {assertion}" in text, f"{path}: input lifecycle assertion missing: {assertion}")
    print("PASS: current-batch native offline input, exact-copy discard and deferred lifecycle evidence")


def main():
    parser = argparse.ArgumentParser(description="Validate current-source reading captures and optional fresh AI evidence.")
    parser.add_argument("--ui-report", type=Path, default=ROOT / "build/qa/ui_regression_verification_report.md")
    parser.add_argument("--ai-report", type=Path)
    parser.add_argument("--expected-ui-checks", type=int, default=53)
    parser.add_argument("--expected-ai-checks", type=int, default=48)
    arguments = parser.parse_args()
    require(arguments.expected_ui_checks > 0 and arguments.expected_ai_checks > 0, "expected gate counts must be positive")
    fingerprint = runtime_fingerprint()
    ui = arguments.ui_report.read_text()
    validate_report(ui, fingerprint, arguments.expected_ui_checks)
    if arguments.expected_ui_checks >= 44:
        validate_ui_protocol_log(ui, fingerprint)
    if arguments.expected_ui_checks >= 45:
        validate_ui_offline_input_log(ui, fingerprint)
    if arguments.expected_ui_checks >= 46:
        home_log = ROOT / "build/qa/logs/ui_guofeng_home.log"
        require(str(home_log) in ui, "UI report is missing the guofeng home gate")
        home_output = home_log.read_text()
        require(home_output.count("=== guofeng home UI smoke START ===") == 6 and home_output.count("=== RESULT: OK ===") == 6, "guofeng home gate must execute all six profiles")
        require(RUNTIME_ERROR.search(home_output) is None and "FAIL|" not in home_output, "guofeng home gate contains runtime or assertion errors")
    if arguments.expected_ui_checks >= 47:
        shop_log = ROOT / "build/qa/logs/ui_guofeng_shop.log"
        require(str(shop_log) in ui, "UI report is missing the guofeng shop gate")
        shop_output = shop_log.read_text()
        require(shop_output.count("=== guofeng shop UI smoke START ===") == 6 and shop_output.count("=== RESULT: OK ===") == 6, "guofeng shop gate must execute all six profiles")
        require(RUNTIME_ERROR.search(shop_output) is None and "FAIL|" not in shop_output, "guofeng shop gate contains runtime or assertion errors")
    if arguments.expected_ui_checks >= 48:
        battle_log = ROOT / "build/qa/logs/ui_guofeng_battle.log"
        require(str(battle_log) in ui, "UI report is missing the guofeng battle gate")
        battle_output = battle_log.read_text()
        require(battle_output.count("=== guofeng battle UI smoke START ===") == 6 and battle_output.count("=== RESULT: OK ===") == 6, "guofeng battle gate must execute all six profiles")
        require(RUNTIME_ERROR.search(battle_output) is None and "FAIL|" not in battle_output, "guofeng battle gate contains runtime or assertion errors")
    if arguments.expected_ui_checks >= 49:
        action_log = ROOT / "build/qa/logs/ui_guofeng_action_seats.log"
        require(str(action_log) in ui, "UI report is missing the guofeng action and seat gate")
        action_output = action_log.read_text()
        require(action_output.count("=== guofeng action seats UI smoke START ===") == 6 and action_output.count("=== RESULT: OK ===") == 6, "guofeng action and seat gate must execute all six profiles")
        require(RUNTIME_ERROR.search(action_output) is None and "FAIL|" not in action_output, "guofeng action and seat gate contains runtime or assertion errors")
    if arguments.expected_ui_checks >= 50:
        hand_log = ROOT / "build/qa/logs/ui_guofeng_hand_tray.log"
        require(str(hand_log) in ui, "UI report is missing the guofeng hand tray gate")
        hand_output = hand_log.read_text()
        require(hand_output.count("=== guofeng hand tray UI smoke START ===") == 6 and hand_output.count("=== RESULT: OK ===") == 6, "guofeng hand gate must execute all six profiles")
        require(RUNTIME_ERROR.search(hand_output) is None and "FAIL|" not in hand_output, "guofeng hand gate contains runtime or assertion errors")
    if arguments.expected_ui_checks >= 51:
        settlement_log = ROOT / "build/qa/logs/ui_guofeng_settlement.log"
        require(str(settlement_log) in ui, "UI report is missing the guofeng settlement gate")
        settlement_output = settlement_log.read_text()
        require(settlement_output.count("=== guofeng settlement UI smoke START ===") == 6 and settlement_output.count("=== RESULT: OK ===") == 6, "guofeng settlement gate must execute all six profiles")
        require(RUNTIME_ERROR.search(settlement_output) is None and "FAIL|" not in settlement_output, "guofeng settlement gate contains runtime or assertion errors")
    if arguments.expected_ui_checks >= 52:
        secondary_log = ROOT / "build/qa/logs/ui_guofeng_secondary.log"
        require(str(secondary_log) in ui, "UI report is missing the secondary pages gate")
        secondary_output = secondary_log.read_text()
        require(secondary_output.count("=== guofeng secondary pages START ===") == 6 and secondary_output.count("=== RESULT: OK ===") == 6, "secondary page gate must execute all six profiles")
        require(RUNTIME_ERROR.search(secondary_output) is None and "FAIL|" not in secondary_output, "secondary page gate contains runtime or assertion errors")
    if arguments.expected_ui_checks >= 53:
        auxiliary_log = ROOT / "build/qa/logs/ui_guofeng_auxiliary.log"
        require(str(auxiliary_log) in ui, "UI report is missing the auxiliary gate")
        auxiliary_output = auxiliary_log.read_text()
        require(auxiliary_output.count("=== guofeng auxiliary START ===") == 6 and auxiliary_output.count("=== RESULT: OK ===") == 6, "auxiliary gate must execute all six profiles")
        require(RUNTIME_ERROR.search(auxiliary_output) is None and "FAIL|" not in auxiliary_output, "auxiliary gate contains runtime or assertion errors")
    ai = arguments.ai_report.read_text() if arguments.ai_report is not None else None
    if ai is not None:
        validate_report(ai, fingerprint, arguments.expected_ai_checks)
        validate_ai_logs(ai, arguments.expected_ai_checks)
    totals = validate_captures(report_field(ui, "QA batch"), fingerprint, arguments.expected_ui_checks >= 46, arguments.expected_ui_checks >= 47, arguments.expected_ui_checks >= 48, arguments.expected_ui_checks >= 49, arguments.expected_ui_checks >= 50, arguments.expected_ui_checks >= 51, arguments.expected_ui_checks >= 52, arguments.expected_ui_checks >= 53)
    print(f"Runtime fingerprint: {fingerprint}")
    print(f"UI batch: {report_field(ui, 'QA batch')}")
    if ai is not None:
        print(f"AI batch: {report_field(ai, 'QA batch')}")
    print(f"RESULT: PASS; {totals}")


if __name__ == "__main__":
    try:
        main()
    except (ValueError, KeyError, OSError, subprocess.CalledProcessError, struct.error) as error:
        print(f"RESULT: FAIL; {error}", file=sys.stderr)
        sys.exit(1)
