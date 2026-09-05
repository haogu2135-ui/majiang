extends SceneTree

const DEFAULT_OUTPUT_DIR := "res://build/qa/pages"
const DEFAULT_VIEWPORT_SIZE := Vector2i(1280, 720)
const SCREEN_NAMES := [
	"01_menu",
	"02_menu_settings",
	"03_offline_battle",
	"04_rules",
	"05_stats",
	"06_achievements",
	"07_shop",
	"08_online_lobby",
	"09_daily_login",
	"10_loading",
	"11_exit_confirm",
	"12_toast",
	"13_round_summary",
	"14_danger_discard",
	"15_pending_claim_full",
	"16_win_detail",
	"17_hand_tutorial",
	"18_update_dialog",
	"19_reset_progress",
	"20_chat_panel",
	"21_diagnostic",
	"22_advisor",
	"23_online_lobby_connected",
	"24_online_lobby_disconnect_recovery",
	"25_replay_import_empty",
	"26_replay_import",
	"27_online_game",
	"28_online_game_pending",
	"29_online_game_chat",
	"30_online_game_disconnect",
	"31_telemetry_default",
	"32_telemetry_consented",
	"33_telemetry_revoked",
	"34_telemetry_exported",
]

class ConnectedLobbyCaptureTransport:
	extends RefCounted

	func get_status() -> int:
		return StreamPeerTCP.STATUS_CONNECTED

	func poll() -> Error:
		return OK

	func get_available_bytes() -> int:
		return 0

	func get_utf8_string(_bytes: int) -> String:
		return ""

	func put_data(_data: PackedByteArray) -> Error:
		return OK

	func disconnect_from_host() -> void:
		pass

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	OS.set_environment("YUNZHUO_UI_CAPTURE", "1")
	if DisplayServer.get_name().to_lower() == "headless":
		print("skipped page capture: screenshots require a non-headless display driver")
		quit(0)
		return

	var viewport_size = requested_viewport_size()
	DisplayServer.window_set_size(viewport_size)
	root.size = viewport_size
	root.content_scale_size = viewport_size
	await process_frame
	await process_frame

	var output_dir_res = requested_output_dir(viewport_size)
	var output_dir = ProjectSettings.globalize_path(output_dir_res)
	DirAccess.make_dir_recursive_absolute(output_dir)
	if not write_capture_metadata(output_dir_res, viewport_size):
		quit(1)
		return

	var selected_screens := selected_screen_names()
	var scene = load("res://Main.tscn").instantiate()
	apply_static_capture_mode(scene)
	root.add_child(scene)
	apply_static_capture_mode(scene)
	await settle()
	for screen_name in selected_screens:
		await capture_screen(scene, screen_name, output_dir_res)
	if scene.has_method("clear_fx_overlays"):
		scene.clear_fx_overlays()
	if scene.has_method("shutdown_runtime"):
		scene.shutdown_runtime()
	scene.queue_free()
	await process_frame
	await process_frame
	await create_timer(0.06).timeout
	await process_frame

	if selected_screens.size() == 1 and selected_screens[0] == "03_offline_battle":
		print("saved offline battle screenshot %dx%d: %s" % [viewport_size.x, viewport_size.y, output_dir])
	elif selected_screens.size() == 1 and selected_screens[0] == "08_online_lobby":
		print("saved online lobby screenshot %dx%d: %s" % [viewport_size.x, viewport_size.y, output_dir])
	else:
		print("saved page screenshots %dx%d: %s" % [viewport_size.x, viewport_size.y, output_dir])
	call_deferred("finish_capture", 0)

func finish_capture(exit_code: int) -> void:
	quit(exit_code)

func requested_viewport_size() -> Vector2i:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--size="):
			var raw_size = arg.substr("--size=".length())
			var parts = raw_size.split("x")
			if parts.size() == 2:
				var width = max(320, int(parts[0]))
				var height = max(240, int(parts[1]))
				return Vector2i(width, height)
			printerr("invalid screenshot size: %s" % raw_size)
			quit(1)
			return DEFAULT_VIEWPORT_SIZE
	return DEFAULT_VIEWPORT_SIZE

func requested_output_dir(viewport_size: Vector2i) -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output-dir="):
			return arg.substr("--output-dir=".length())
	if viewport_size == DEFAULT_VIEWPORT_SIZE:
		return DEFAULT_OUTPUT_DIR
	return "res://build/qa/pages_%dx%d" % [viewport_size.x, viewport_size.y]

func write_capture_metadata(output_dir_res: String, viewport_size: Vector2i) -> bool:
	var metadata := {
		"capture_revision": OS.get_environment("YUNZHUO_CAPTURE_REVISION"),
		"capture_batch_id": OS.get_environment("YUNZHUO_CAPTURE_BATCH_ID"),
		"worktree_state": OS.get_environment("YUNZHUO_CAPTURE_WORKTREE_STATE"),
		"runtime_source_state": OS.get_environment("YUNZHUO_CAPTURE_RUNTIME_SOURCE_STATE"),
		"worktree_diff_fingerprint": OS.get_environment("YUNZHUO_CAPTURE_WORKTREE_DIFF_FINGERPRINT"),
		"runtime_source_diff_fingerprint": OS.get_environment("YUNZHUO_CAPTURE_RUNTIME_SOURCE_DIFF_FINGERPRINT"),
		"capture_size": "%dx%d" % [viewport_size.x, viewport_size.y],
		"meld_fixture_contract": {
			"seed": "seed_preview_discards",
			"horizontal_seats": [0, 2],
			"vertical_seats": [1, 3],
			"meld_group_count_variants": {
				"seed_preview_discards": [4, 3, 3, 4],
				"seed_preview_capacity_battle": [4, 4, 4, 4],
			},
			"compact_horizontal_tile_width_min": 18,
			"orientation_rule": "top/bottom horizontal; left/right vertical; faces point to table center",
		},
		"interactive_state_contract": {
			"11_exit_confirm": {"required_nodes": ["ExitConfirmDialog", "ExitConfirmContinueButton", "ExitConfirmLeaveButton"], "default_focus": "ExitConfirmContinueButton", "state_text": "确认退出"},
			"12_toast": {"required_nodes": ["ToastContainer", "Toast"], "default_focus": "", "state_text": "成就解锁：初入牌桌"},
			"17_hand_tutorial": {"required_nodes": ["HandTrayTutorialHint", "HandTrayTutorialTargetTile"], "default_focus": "", "state_text": "点击一张手牌，将它打入牌河"},
			"18_update_dialog": {"required_nodes": ["UpdatePrimaryButton", "UpdateSecondaryButton"], "default_focus": "UpdateSecondaryButton", "state_text": "发现新版本 v1.0.181"},
			"19_reset_progress": {"required_nodes": ["SettingsPanel", "SettingsCloseButton", "ResetProgressConfirmArt"], "default_focus": "SettingsCloseButton", "state_text": "再次点击确认清空本地进度"},
			"20_chat_panel": {"required_nodes": ["ChatPanel", "ChatPanelCloseButton", "ChatInput", "ChatSendButton"], "default_focus": "ChatInput", "state_text": "房间消息"},
			"22_advisor": {"required_nodes": ["AdvisorPanel", "AdvisorDetailButton"], "default_focus": "AdvisorDetailButton", "state_text": "牌势"},
			"23_online_lobby_connected": {"fixture_seed": "seed_preview_online_lobby_connected", "required_nodes": ["OnlineLobbyLowFrequencyPagePlate", "OnlineLobbyHostEdit", "OnlineLobbyRoomEdit", "OnlineLobbyConnectButton", "OnlineLobbyPrimaryStartButton", "OnlineLobbyStatusLabel"], "default_focus": "OnlineLobbyConnectButton", "state_text": "房间同步完成"},
			"24_online_lobby_disconnect_recovery": {"fixture_seed": "seed_preview_online_lobby_disconnect_recovery", "required_nodes": ["OnlineLobbyLowFrequencyPagePlate", "OnlineLobbyHostEdit", "OnlineLobbyRoomEdit", "OnlineLobbyConnectButton", "OnlineLobbyStatusLabel"], "default_focus": "OnlineLobbyConnectButton", "state_text": "连接已断开"},
			"25_replay_import_empty": {"fixture_seed": "show_replay_import_screen", "required_nodes": ["ReplayImportPanel", "ReplayImportCodeInput", "ReplayImportButton", "ReplayImportTimeline", "ReplayImportTimelineScroll"], "default_focus": "ReplayImportCodeInput", "state_text": "等待导入"},
			"26_replay_import": {"fixture_seed": "seed_preview_replay_import", "required_nodes": ["ReplayImportPanel", "ReplayImportCodeInput", "ReplayImportButton", "ReplayImportTimeline", "ReplayImportTimelineScroll", "ReplayArchivePane", "ReplayArchiveScroll", "ReplayImportEventList"], "default_focus": "ReplayImportCodeInput", "state_text": "校验通过"},
			"27_online_game": {"fixture_seed": "seed_preview_online_game:awaitDiscard", "required_nodes": ["TopHudStatus", "TopHudWallText", "HandTray", "ActionButtonDock"], "default_focus": "HandTile_", "state_text": "轮到你出牌"},
			"28_online_game_pending": {"fixture_seed": "seed_preview_online_game:pendingClaim", "required_nodes": ["TopHudStatus", "PendingClaimIllustration", "PendingClaimResponseGrid", "ActionButtonDock"], "default_focus": "PendingClaimPrimaryButton", "state_text": "等待响应"},
			"29_online_game_chat": {"fixture_seed": "seed_preview_online_game:awaitDiscard+seed_preview_online_game_chat", "required_nodes": ["TopHudStatus", "HandTray", "ActionButtonDock", "ChatPanel", "ChatPanelCloseButton", "ChatInput", "ChatSendButton"], "default_focus": "ChatInput", "state_text": "房间消息"},
		"30_online_game_disconnect": {"fixture_seed": "seed_preview_online_game:awaitDiscard+seed_preview_online_game_disconnect", "required_nodes": ["TopHudStatus", "HandTray", "ActionButtonDock", "OnlineReconnectGameButton"], "default_focus": "OnlineReconnectGameButton", "state_text": "连接已断开"},
			"31_telemetry_default": {"fixture_seed": "seed_preview_telemetry:default", "required_nodes": ["TelemetryDataSheet", "TelemetryDataSheetCard", "TelemetryConsentButton", "TelemetryExportButton", "TelemetryClearButton", "TelemetryDataSheetCloseButton", "TelemetryDataStatus", "TelemetryExportStatus"], "default_focus": "TelemetryConsentButton", "state_text": "未同意 · 默认不记录"},
			"32_telemetry_consented": {"fixture_seed": "seed_preview_telemetry:consented", "required_nodes": ["TelemetryDataSheet", "TelemetryDataSheetCard", "TelemetryConsentButton", "TelemetryExportButton", "TelemetryClearButton", "TelemetryDataSheetCloseButton", "TelemetryDataStatus", "TelemetryExportStatus"], "default_focus": "TelemetryConsentButton", "state_text": "已同意 · 本地队列"},
			"33_telemetry_revoked": {"fixture_seed": "seed_preview_telemetry:revoked", "required_nodes": ["TelemetryDataSheet", "TelemetryDataSheetCard", "TelemetryConsentButton", "TelemetryExportButton", "TelemetryClearButton", "TelemetryDataSheetCloseButton", "TelemetryDataStatus", "TelemetryExportStatus"], "default_focus": "TelemetryConsentButton", "state_text": "已关闭 · 不记录"},
			"34_telemetry_exported": {"fixture_seed": "seed_preview_telemetry:exported", "required_nodes": ["TelemetryDataSheet", "TelemetryDataSheetCard", "TelemetryConsentButton", "TelemetryExportButton", "TelemetryClearButton", "TelemetryDataSheetCloseButton", "TelemetryDataStatus", "TelemetryExportStatus"], "default_focus": "TelemetryExportButton", "state_text": "匿名诊断数据已复制"},
		},
		"capture_time_utc": Time.get_datetime_string_from_system(true),
	}
	var metadata_path := ProjectSettings.globalize_path("%s/capture_metadata.json" % output_dir_res)
	var file := FileAccess.open(metadata_path, FileAccess.WRITE)
	if file == null:
		printerr("failed to write capture metadata: %s" % metadata_path)
		return false
	file.store_string(JSON.stringify(metadata) + "\n")
	return true

func selected_screen_names() -> Array:
	var args := OS.get_cmdline_user_args()
	for arg in args:
		if arg.begins_with("--screen="):
			return [arg.substr("--screen=".length())]
		if arg.begins_with("--screens="):
			var selected: Array = []
			for raw_name in arg.substr("--screens=".length()).split(",", false):
				var screen_name = str(raw_name).strip_edges()
				if not SCREEN_NAMES.has(screen_name):
					printerr("unknown screenshot screen: %s" % screen_name)
					quit(1)
					return []
				selected.append(screen_name)
			if selected.is_empty():
				printerr("--screens requires at least one screen name")
				quit(1)
			return selected
	if args.has("--offline-battle-only"):
		return ["03_offline_battle"]
	if args.has("--online-lobby-only"):
		return ["08_online_lobby"]
	return SCREEN_NAMES.duplicate()

func capture_screen(scene: Node, screen_name: String, output_dir_res: String) -> void:
	apply_static_capture_mode(scene)
	reset_update_fixture_state(scene, screen_name)
	build_screen(scene, screen_name)
	apply_static_capture_mode(scene)
	if not validate_update_fixture(scene, screen_name):
		printerr("update dialog fixture contract failed for %s" % screen_name)
		quit(1)
		return
	if screen_name == "22_advisor" and not validate_advisor_fixture(scene):
		printerr("advisor fixture contract failed for %s" % screen_name)
		quit(1)
		return
	if screen_name == "17_hand_tutorial" and not validate_hand_tutorial_fixture(scene):
		printerr("hand tutorial fixture contract failed for %s" % screen_name)
		quit(1)
		return
	if screen_name == "19_reset_progress" and not validate_reset_progress_fixture(scene):
		printerr("reset progress fixture contract failed for %s" % screen_name)
		quit(1)
		return
	if ["03_offline_battle", "13_round_summary", "14_danger_discard", "15_pending_claim_full", "16_win_detail"].has(screen_name):
		if not validate_preview_meld_fixture(scene):
			printerr("capture fixture contract failed for %s" % screen_name)
			quit(1)
			return
	if ["27_online_game", "28_online_game_pending", "29_online_game_chat", "30_online_game_disconnect"].has(screen_name):
		if not validate_online_game_fixture(scene, screen_name):
			printerr("online game fixture contract failed for %s" % screen_name)
			quit(1)
			return
	if ["31_telemetry_default", "32_telemetry_consented", "33_telemetry_revoked", "34_telemetry_exported"].has(screen_name):
		if not validate_telemetry_fixture(scene, screen_name):
			printerr("telemetry fixture contract failed for %s" % screen_name)
			quit(1)
			return
	if scene.has_method("clear_fx_overlays"):
		scene.clear_fx_overlays()
	await settle()
	_force_capture_visible_screens(scene)
	if screen_name == "13_round_summary" or screen_name == "16_win_detail":
		stabilize_capture_round_summary(scene)

	var viewport_texture = root.get_texture()
	if viewport_texture == null:
		printerr("failed to save %s: viewport texture is unavailable" % screen_name)
		quit(1)
		return

	var image = viewport_texture.get_image()
	if image == null:
		printerr("failed to save %s: viewport image is unavailable" % screen_name)
		quit(1)
		return

	var output_path = ProjectSettings.globalize_path("%s/%s.png" % [output_dir_res, screen_name])
	var err = image.save_png(output_path)
	if err != OK:
		printerr("failed to save %s: %s" % [screen_name, error_string(err)])
		quit(1)
		return
	print("saved %s: %s" % [screen_name, output_path])
	if scene.has_method("clear_fx_overlays"):
		scene.clear_fx_overlays()
	if scene.has_method("shutdown_runtime_tweens"):
		scene.shutdown_runtime_tweens()
	await process_frame
	await process_frame

func reset_update_fixture_state(scene: Node, screen_name: String) -> void:
	if scene == null or screen_name == "18_update_dialog":
		return
	# The update overlay is modal runtime state. Screenshot pages are isolated
	# fixtures, so a prior update page must not leak into the next capture.
	scene.update_state = "idle"
	scene.update_message = ""
	if scene.has_method("refresh_update_dialog"):
		scene.refresh_update_dialog()

func validate_update_fixture(scene: Node, screen_name: String) -> bool:
	var overlay = scene.find_child("UpdateDialogOverlay", true, false) if scene != null else null
	var expected := screen_name == "18_update_dialog"
	if expected:
		return overlay != null and str(scene.update_state) != "idle"
	return overlay == null and str(scene.update_state) == "idle"

func validate_preview_meld_fixture(scene: Node) -> bool:
	var fixture = scene.get_meta("ui_capture_meld_fixture", {})
	if typeof(fixture) != TYPE_DICTIONARY:
		printerr("meld fixture metadata is missing or not a Dictionary")
		return false
	if fixture.get("horizontal_seats", []) != [0, 2] or fixture.get("vertical_seats", []) != [1, 3]:
		printerr("meld fixture seat contract mismatch: %s" % fixture)
		return false
	var expected_counts: Array = fixture.get("meld_group_counts", [])
	if expected_counts.is_empty() or scene.players.size() != 4:
		printerr("meld fixture count contract mismatch: counts=%s players=%d" % [expected_counts, scene.players.size()])
		return false
	for seat in range(4):
		var player: Dictionary = scene.players[seat]
		var melds: Array = player.get("melds", [])
		if melds.size() != int(expected_counts[seat]):
			printerr("meld fixture group count mismatch at seat %d: got=%d expected=%d player=%s" % [seat, melds.size(), int(expected_counts[seat]), player])
			return false
		var expected_vertical := seat == 1 or seat == 3
		if bool(scene.seat_meld_is_vertical(seat)) != expected_vertical:
			printerr("meld fixture orientation mismatch at seat %d: got=%s expected=%s" % [seat, scene.seat_meld_is_vertical(seat), expected_vertical])
			return false
	return true

func validate_online_game_fixture(scene: Node, screen_name: String) -> bool:
	if scene.mode != "online_game" or scene.online_game.is_empty():
		return false
	var required_phase := "pendingClaim" if screen_name == "28_online_game_pending" else "awaitDiscard"
	if str(scene.online_game.get("phase", "")) != required_phase:
		return false
	if screen_name == "29_online_game_chat" and scene.find_child("ChatPanel", true, false) == null:
		return false
	if screen_name == "30_online_game_disconnect" and scene.online_feedback.find("断开") < 0:
		return false
	if screen_name == "30_online_game_disconnect" and scene.find_child("OnlineReconnectGameButton", true, false) == null:
		return false
	return scene.find_child("TopHudStatus", true, false) != null and scene.find_child("HandTray", true, false) != null and scene.find_child("ActionButtonDock", true, false) != null

func validate_advisor_fixture(scene: Node) -> bool:
	var panels := scene.find_children("AdvisorPanel", "Control", true, false)
	if panels.size() != 1:
		printerr("advisor panel count mismatch: got=%d expected=1" % panels.size())
		return false
	for heading in ["荐", "势", "守"]:
		var cards := scene.find_children("AdvisorInfoCard_%s" % heading, "Control", true, false)
		if cards.size() != 1:
			printerr("advisor card count mismatch for %s: got=%d expected=1" % [heading, cards.size()])
			return false
	return true

func validate_hand_tutorial_fixture(scene: Node) -> bool:
	var hint := scene.find_child("HandTrayTutorialHint", true, false) as Control
	var target := scene.find_child("HandTrayTutorialTargetTile", true, false) as Control
	var hand := scene.find_child("HandTrayTiles", true, false) as Control
	return hint != null and target != null and hand != null and scene.show_hand_hint and scene.tutorial_step == scene.TUTORIAL_STEP_DISCARD and scene.can_self_discard() and scene.players.size() > 0 and scene.players[0].get("hand", []).size() == 14

func validate_reset_progress_fixture(scene: Node) -> bool:
	var row_status := scene.find_child("SettingRowStatus_本地进度", true, false) as Label
	var reset_button := scene.find_child("SettingRowButton_本地进度", true, false) as Button
	var confirm_art := scene.find_child("ResetProgressConfirmArt", true, false)
	var valid: bool = scene.reset_progress_confirming and row_status != null and row_status.tooltip_text.contains("再次点击确认") and (row_status.text == "再次确认" or row_status.text.contains("再次点击确认")) and reset_button != null and reset_button.text == "确认清空" and reset_button.tooltip_text.contains("确认清空") and confirm_art != null
	return valid

func validate_telemetry_fixture(scene: Node, screen_name: String) -> bool:
	if not scene.settings_panel_open or not scene.telemetry_sheet_open:
		return false
	var status := scene.find_child("TelemetryDataStatus", true, false) as Label
	var consent := scene.find_child("TelemetryConsentButton", true, false) as Button
	if status == null or consent == null:
		return false
	if screen_name == "31_telemetry_default":
		return status.text == "未同意 · 默认不记录" and consent.text == "同意记录"
	if screen_name == "33_telemetry_revoked":
		return status.text == "已关闭 · 不记录" and consent.text == "同意记录"
	return status.text.begins_with("已同意 · 本地队列") and consent.text == "关闭记录"


func apply_static_capture_mode(scene: Node) -> void:
	scene.set("fx_enabled", false)
	scene.set("music_enabled", false)
	scene.set("sfx_enabled", false)
	scene.set("tts_enabled", false)
	scene.set("voice_enabled", false)

func build_screen(scene: Node, screen_name: String) -> void:
	match screen_name:
		"01_menu":
			scene.show_menu(true)
		"02_menu_settings":
			scene.show_menu(true)
			scene.settings_panel_open = true
			scene.refresh_current_screen()
		"03_offline_battle":
			scene.settings_panel_open = false
			scene.start_offline(true)
			seed_preview_capacity_battle(scene)
			scene.render_game()
			scene.clear_fx_overlays()
		"04_rules":
			scene._show_rules_screen_impl()
		"05_stats":
			scene._show_stats_screen_impl()
		"06_achievements":
			scene._show_achievements_screen_impl()
		"07_shop":
			scene._show_shop_screen_impl()
		"08_online_lobby":
			seed_preview_online_lobby(scene)
			scene._show_online_lobby_impl()
		"09_daily_login":
			scene.show_menu(true)
			scene.clear_fx_overlays()
			scene.show_daily_login_panel({
				"show_reward": true,
				"consecutive_days": 5,
			})
		"10_loading":
			scene.show_loading_screen()
		"11_exit_confirm":
			scene.settings_panel_open = false
			scene.start_offline(true)
			seed_preview_discards(scene)
			scene.render_game()
			scene.clear_fx_overlays()
			scene.show_exit_confirm()
			# Capture mode: force fully-visible static dialog (skip entrance fade).
			if scene.exit_confirm_panel != null and is_instance_valid(scene.exit_confirm_panel):
				scene.exit_confirm_panel.modulate = Color(1, 1, 1, 1)
				var dialog = scene.exit_confirm_panel.find_child("ExitConfirmDialog", true, false)
				if dialog != null:
					dialog.scale = Vector2(1, 1)
					if dialog is Control:
						dialog.modulate = Color(1, 1, 1, 1)
		"12_toast":
			scene.show_menu(true)
			scene.clear_fx_overlays()
			# Long duration so capture settle still sees full opacity toast.
			scene.show_toast("成就解锁：初入牌桌", 8000)
			# Freeze toast static for screenshot (kill entrance/exit tweens).
			if scene.toast_tween != null and is_instance_valid(scene.toast_tween):
				scene.toast_tween.kill()
				scene.toast_tween = null
			if scene.toast_current != null and is_instance_valid(scene.toast_current):
				scene.toast_current.modulate = Color(1, 1, 1, 1)
				scene.toast_current.offset_top = 0.0
				scene.toast_current.scale = Vector2(1, 1)
			if scene.toast_container != null and is_instance_valid(scene.toast_container):
				scene.toast_container.visible = true
		"13_round_summary":
			scene.settings_panel_open = false
			scene.start_offline(true)
			seed_preview_discards(scene)
			seed_preview_round_summary(scene)
			scene.render_game()
			scene.clear_fx_overlays()
		"14_danger_discard":
			scene.settings_panel_open = false
			scene.start_offline(true)
			seed_preview_discards(scene)
			seed_preview_danger_discard(scene)
			scene.render_game()
			scene.clear_fx_overlays()
		"15_pending_claim_full":
			scene.settings_panel_open = false
			scene.start_offline(true)
			seed_preview_discards(scene)
			seed_preview_pending_claim_full(scene)
			scene.render_game()
			scene.clear_fx_overlays()
		"16_win_detail":
			scene.settings_panel_open = false
			scene.start_offline(true)
			seed_preview_discards(scene)
			seed_preview_win_detail(scene)
			scene.render_game()
			scene.clear_fx_overlays()
		"23_online_lobby_connected":
			seed_preview_online_lobby_connected(scene)
			scene._show_online_lobby_impl()
		"24_online_lobby_disconnect_recovery":
			seed_preview_online_lobby_disconnect_recovery(scene)
			scene._show_online_lobby_impl()
		"25_replay_import_empty":
			scene.show_replay_import_screen(true)
		"26_replay_import":
			seed_preview_replay_import(scene)
		"27_online_game":
			seed_preview_online_game(scene, "awaitDiscard")
		"28_online_game_pending":
			seed_preview_online_game(scene, "pendingClaim")
		"29_online_game_chat":
			seed_preview_online_game(scene, "awaitDiscard")
			seed_preview_online_game_chat(scene)
		"30_online_game_disconnect":
			seed_preview_online_game(scene, "awaitDiscard")
			seed_preview_online_game_disconnect(scene)
		"31_telemetry_default":
			seed_preview_telemetry(scene, "default")
		"32_telemetry_consented":
			seed_preview_telemetry(scene, "consented")
		"33_telemetry_revoked":
			seed_preview_telemetry(scene, "revoked")
		"34_telemetry_exported":
			seed_preview_telemetry(scene, "exported")
		"17_hand_tutorial":
			scene.settings_panel_open = false
			scene.start_offline(true)
			seed_preview_discards(scene)
			seed_preview_hand_tutorial(scene)
			scene.render_game()
			scene.clear_fx_overlays()
		"18_update_dialog":
			scene.show_menu(true)
			scene.clear_fx_overlays()
			seed_preview_update_dialog(scene)
		"19_reset_progress":
			scene.show_menu(true)
			scene.settings_panel_open = true
			scene.refresh_current_screen()
			# Exercise the same confirmation path as a user click so the row
			# status, button label, and toast all describe the armed state.
			scene.request_reset_progress_from_settings()
			# Force fully-visible static settings overlay under capture.
			var settings_panel = scene.find_child("SettingsPanel", true, false)
			if settings_panel is Control:
				(settings_panel as Control).modulate = Color(1, 1, 1, 1)
		"20_chat_panel":
			scene.settings_panel_open = false
			scene.start_offline(true)
			seed_preview_discards(scene)
			scene.render_game()
			scene.clear_fx_overlays()
			seed_preview_chat_panel(scene)
		"21_diagnostic":
			scene.show_menu(true)
			scene.clear_fx_overlays()
			scene.show_diagnostic_dialog(diagnostic_capture_lines(scene))
			# Capture mode: force fully-visible static dialog (skip entrance fade).
			var diag_panel = scene.find_child("DiagnosticDialogPanel", true, false)
			if diag_panel is Control:
				(diag_panel as Control).modulate = Color(1, 1, 1, 1)
			var diag_bg = scene.find_child("DiagnosticDismissOverlay", true, false)
			if diag_bg is Control:
				(diag_bg as Control).modulate = Color(1, 1, 1, 1)
		"22_advisor":
			scene.settings_panel_open = false
			scene.ai_assist_enabled = true
			scene.start_offline(true)
			seed_preview_discards(scene)
			scene.render_game()
			scene.clear_fx_overlays()
			# render_game() normally creates the advisor through its refresh path. Only
			# backfill it for a fixture that did not expose the panel.
			if scene.has_method("draw_advisor_panel") and scene.find_child("AdvisorPanel", true, false) == null:
				scene.draw_advisor_panel(scene.root_layer, true)
		"23_score_strip":
			# Online HUD shows ScoreStrip; offline intentionally omits it.
			scene.settings_panel_open = false
			scene.start_offline(true)
			seed_preview_discards(scene)
			scene.mode = "online"
			for seat in range(4):
				scene.players[seat]["score"] = 22000 + seat * 1100
			scene.players[0]["score"] = 28500
			scene.players[0]["name"] = "你"
			scene.render_game()
			scene.clear_fx_overlays()
		_:
			push_error("unknown screenshot screen: %s" % screen_name)


func diagnostic_capture_lines(scene: Node = null) -> Array[String]:
	var version := "1.0.180-godot"
	if scene != null and scene.has_method("app_version"):
		version = str(scene.call("app_version"))
	return [
		"【音频系统诊断 %s】" % version,
		"",
		"1. 用户激活: 是",
		"2. 设备: 小米手机 (MIUI)",
		"",
		"⚠️ 当前音频说明",
		"BGM已从WAV改为MP3格式",
		"因为您能听到TTS语音提示",
		"说明音频系统正常",
		"只是WAV格式不兼容",
		"",
		"【请回答】",
		"1. 能听到背景音乐了吗？",
		"2. 刚才的440Hz测试音听到了吗？",
		"",
		"3. BGM播放器: 正常",
		"4. BGM音频流: 已加载",
		"5. BGM正在播放: 是",
		"6. BGM音量: -8.0dB (0dB=最大)",
		"7. 音频总线: Master",
		"8. Master总线音量: 0.0dB",
		"9. Master总线静音: 否",
		"10. 音频格式: AudioStreamMP3",
		"",
		"✓ BGM播放成功",
		"",
		"小米手机听不到声音？",
		"请检查以下MIUI设置:",
		"",
		"1. 断开蓝牙设备",
		"2. 按音量+键调整【媒体音量】",
		"3. 关闭【游戏加速】",
		"4. 关闭【省电模式】",
		"5. 设置→应用管理→本应用",
		"   →省电策略→无限制",
		"6. 尝试重启手机",
		"",
		"点击任意位置关闭",
	]


func _force_capture_visible_screens(target: Node) -> void:
	if target == null:
		return
	for node_name in [
		"ShopCabinetFrontPanel",
		"OnlineLobbyFormPanel",
		"OnlineLobbyLogPanel",
	]:
		var node = target.find_child(node_name, true, false)
		if node is CanvasItem:
			(node as CanvasItem).modulate = Color(1, 1, 1, 1)

func stabilize_capture_round_summary(target: Node) -> void:
	if target == null:
		return
	var panel := target.find_child("RoundSummaryPanel", true, false) as Control
	if panel == null:
		return
	panel.visible = true
	panel.z_index = 30
	panel.modulate = Color(1, 1, 1, 1)
	panel.scale = Vector2.ONE
	panel.offset_left = 0.0
	panel.offset_top = 0.0
	panel.offset_right = 0.0
	panel.offset_bottom = 0.0


func settle() -> void:
	await process_frame
	await process_frame
	# Entrance staggers (shop/rules/stats/online) can last ~0.4-0.5s under xvfb (DisplayServer=x11).
	await create_timer(0.75).timeout
	await process_frame
	await process_frame

func seed_preview_discards(scene: Node) -> void:
	scene.set_meta("ui_capture_meld_fixture", {
		"seed": "seed_preview_discards",
		"horizontal_seats": [0, 2],
		"vertical_seats": [1, 3],
		"meld_group_counts": [4, 3, 3, 4],
		"compact_horizontal_tile_width_min": 18,
		"orientation_rule": "top/bottom horizontal; left/right vertical; faces point to table center",
	})
	var preview_discards := [
		["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "S", "N", "1T", "2T", "3T", "4T"],
		["1T", "2T", "3T", "4T", "5T", "6T", "7T", "8T", "9T", "E", "S", "W", "1B", "2B", "3B", "4B"],
		["1B", "2B", "3B", "4B", "5B", "6B", "7B", "8B", "9B", "E", "S", "N", "1W", "2W", "3W", "4W"],
		["Z", "F", "P", "R", "N", "E", "S", "W", "1T", "2T", "3T", "4T", "5T", "6T", "7T", "8T"],
	]
	# r411: denser multi-meld fixture to prove adaptive lane packing (2–4 groups).
	var preview_melds := [
		[["5T", "5T", "5T"], ["2W", "3W", "4W"], ["7B", "7B", "7B"], ["E", "E", "E", "E"]],
		[["2W", "2W", "2W"], ["3T", "4T", "5T"], ["9B", "9B", "9B"]],
		[["1B", "1B", "1B", "1B"], ["4W", "5W", "6W"], ["S", "S", "S"]],
		[["E", "E", "E"], ["1T", "2T", "3T"], ["P", "P", "P"], ["6B", "7B", "8B"]],
	]
	for seat in range(preview_discards.size()):
		scene.players[seat]["discards"] = preview_discards[seat].duplicate()
		scene.players[seat]["melds"] = preview_melds[seat].duplicate(true)
		scene.players[seat]["flowers"] = 2 if seat % 2 == 0 else 1
		scene.players[seat]["score"] = 24000 + seat * 800
		if seat != 0:
			# 13 - 3*open_sets (+1 if gang replaced) approx for visual consistency.
			var open_sets: int = scene.players[seat]["melds"].size()
			scene.players[seat]["hand_count"] = maxi(1, 13 - open_sets * 3)
	scene.last_discard = "S"
	scene.last_discard_seat = 3
	scene.current_seat = 0
	scene.offline_phase = "await_discard"
	scene.table_logs.clear()
	scene.add_log("预览：弃牌区与副露使用真实牌面贴图。")


func seed_preview_capacity_battle(scene: Node) -> void:
	seed_preview_discards(scene)
	scene.offline_phase = "await_discard"
	scene.offline_pending_claim.clear()
	scene.current_seat = 0
	scene.offline_turn_needs_draw = false
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "5T", "9T", "E", "R"]
	scene.offline_last_draw = {"seat": 0, "tile": "R", "source": "normal", "announce": false, "serial": 902}
	scene.offline_self_draw_ready = {"seat": 0, "tile": "R", "serial": 902}
	var river_codes := ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "3T", "4T", "5T", "6T", "7T", "8T", "9T", "1B", "2B", "3B", "4B", "5B", "6B", "7B", "8B", "9B", "E", "S", "W", "N", "Z", "F", "P", "R"]
	var meld_sets := [
		["1W", "1W", "1W"],
		["2T", "3T", "4T"],
		["5B", "5B", "5B"],
		["R", "R", "R", "R"],
	]
	var flower_tiles := ["H1", "H2", "H3", "H4", "H5", "H6", "H7", "H8"]
	for seat in range(4):
		scene.players[seat]["discards"] = river_codes.duplicate()
		scene.players[seat]["melds"] = meld_sets.duplicate(true)
		scene.players[seat]["flowers"] = flower_tiles.size()
		scene.players[seat]["flower_tiles"] = flower_tiles.duplicate()
	scene.last_discard = "R"
	scene.last_discard_seat = 3
	scene.table_logs.clear()
	for i in range(scene.ONLINE_LOG_HISTORY_LIMIT):
		scene.table_logs.append("第%02d巡：四家牌河、副露与花牌状态已同步" % (i + 1))
	scene.set_meta("ui_capture_meld_fixture", {
		"seed": "seed_preview_capacity_battle",
		"horizontal_seats": [0, 2],
		"vertical_seats": [1, 3],
		"meld_group_counts": [4, 4, 4, 4],
		"compact_horizontal_tile_width_min": 18,
		"orientation_rule": "top/bottom horizontal; left/right vertical; faces point to table center",
	})


func seed_preview_pending_claim(scene: Node) -> void:
	scene.offline_phase = "pending_claim"
	scene.players[0]["hand"] = ["1W", "2W", "3W", "3W", "4W", "5W", "5T", "6T", "7T", "E", "E", "P", "P"]
	scene.offline_pending_claim = {
		"from_seat": 3,
		"tile": "3W",
		"options": ["chi", "peng"],
		"chi_choices": scene.get_chi_choices(scene.players[0]["hand"], "3W"),
	}
	scene.offline_last_draw = {
		"seat": 3,
		"tile": "S",
		"source": "normal",
		"wall_empty": false,
		"announce": true,
		"serial": 777,
	}
	scene.add_log("预览：响应插画展示吃碰选择。")

func seed_preview_online_lobby(scene: Node) -> void:
	scene.selected_room = ""
	scene.online_room = {}
	scene.online_feedback = ""
	scene.online_waiting_for_server = false

func seed_preview_online_lobby_connected(scene: Node) -> void:
	scene.tcp = ConnectedLobbyCaptureTransport.new()
	scene.tcp_status = StreamPeerTCP.STATUS_CONNECTED
	scene.selected_room = "ROOM7"
	scene.online_room = {
		"code": "ROOM7",
		"players": [
			{"seat": 0, "name": "甲", "ready": true},
			{"seat": 1, "name": "乙", "ready": true},
			{"seat": 2, "name": "丙", "ready": false},
		],
		"logs": [
			"甲加入房间",
			"乙准备就绪",
			"丙加入房间",
			"房间同步完成，等待房主开始",
		],
	}
	scene.online_feedback = "房间同步完成，等待房主开始。"
	scene.online_waiting_for_server = false

func seed_preview_online_lobby_disconnect_recovery(scene: Node) -> void:
	scene.tcp = StreamPeerTCP.new()
	scene.tcp_status = StreamPeerTCP.STATUS_NONE
	scene.tcp_buffer.clear()
	scene.sent_hello = false
	scene.online_player_name = "协议测试者"
	scene.selected_room = "ROOM7"
	scene.online_room = {}
	scene.online_game = {}
	scene.online_feedback = "连接已断开，请重新连接。"
	scene.online_waiting_for_server = false

func seed_preview_round_summary(scene: Node) -> void:
	scene.offline_phase = "ended"
	scene.offline_hand_number = 1
	scene.offline_last_winner = 0
	scene.offline_dealer_repeat = false
	scene.dealer_seat = 0
	scene.round_summary = "东家自摸九万，8番高番 16分。清一色、碰碰胡、门清、一条龙、杠上开花、海底捞月、自摸、花牌加番。庄家下庄。包三搭：南家包赔东家。全场结束。"
	scene.last_win_score = {
		"winner": 0,
		"fan": 8,
		"points": 16,
		"reasons": ["清一色", "碰碰胡", "门清", "一条龙", "杠上开花", "海底捞月", "自摸", "花牌加番"],
		"win_tile": "9W",
		"self_draw": true,
		"limit_name": "高番",
	}
	for seat in range(4):
		scene.players[seat]["score"] = 24000 + (3 - seat) * 1200
		scene.players[seat]["flowers"] = 2 if seat % 2 == 0 else 1
	scene.players[0]["score"] = 27600
	scene.offline_package_liability = {0: 1}
	scene.add_log("预览：本局结算面板。")

func seed_preview_danger_discard(scene: Node) -> void:
	scene.ai_assist_enabled = true
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "5T", "6T", "7T", "E", "E", "P", "P", "S"]
	scene.pending_danger_discard_index = 12
	scene.pending_danger_discard_tile = "S"
	scene.pending_danger_discard_report = {
		"tile": "S",
		"risk": 52.0,
		"feed_risk": 48.0,
		"risk_label": "高",
		"safety_label": "",
		"feed_text": "对家听口偏高",
		"danger_source": {"reason": "牌路危险", "seat": 2},
	}
	scene.add_log("预览：高危弃牌二次确认。")

func seed_preview_pending_claim_full(scene: Node) -> void:
	scene.offline_phase = "pending_claim"
	scene.players[0]["hand"] = ["1W", "2W", "3W", "3W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E"]
	scene.offline_pending_claim = {
		"from_seat": 3,
		"tile": "3W",
		"options": ["hu", "gang", "peng", "chi"],
		"chi_choices": [
			{"meld": ["1W", "2W", "3W"]},
			{"meld": ["2W", "3W", "4W"]},
			{"meld": ["3W", "4W", "5W"]},
		],
	}
	scene.offline_last_draw = {
		"seat": 3,
		"tile": "S",
		"source": "normal",
		"wall_empty": false,
		"announce": true,
		"serial": 778,
	}
	scene.add_log("预览：完整吃碰杠胡响应条。")

func seed_preview_win_detail(scene: Node) -> void:
	scene.offline_phase = "ended"
	scene.offline_hand_number = 1
	scene.offline_last_winner = 0
	scene.offline_dealer_repeat = false
	scene.dealer_seat = 1
	scene.round_summary = "你自摸九万，8番高番 16分。清一色、碰碰胡、门清、一条龙、杠上开花、海底捞月、自摸、花牌加番。庄家下庄。包三搭：青竹道人包赔你。全场结束。"
	scene.last_win_score = {
		"winner": 0,
		"fan": 8,
		"points": 16,
		"reasons": ["清一色", "碰碰胡", "门清", "一条龙", "杠上开花", "海底捞月", "自摸", "花牌加番"],
		"win_tile": "9W",
		"self_draw": true,
		"limit_name": "高番",
	}
	for seat in range(4):
		scene.players[seat]["score"] = 22000 + seat * 900
		scene.players[seat]["flowers"] = 1 + (seat % 2)
	scene.players[0]["score"] = 31200
	scene.players[0]["name"] = "你"
	scene.offline_package_liability = {0: 1}
	scene.add_log("预览：胡牌详情结算。")

func seed_preview_hand_tutorial(scene: Node) -> void:
	scene.ai_assist_enabled = false
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.tutorial_step = scene.TUTORIAL_STEP_DISCARD
	scene.show_hand_hint = true
	scene.offline_turn_needs_draw = false
	scene.offline_last_draw = {"seat": 0, "tile": "S", "source": "normal", "announce": false, "serial": 913}
	scene.offline_self_draw_ready = {"seat": 0, "tile": "S", "serial": 913}
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E", "S", "S", "S"]
	scene.offline_pending_claim.clear()
	scene.clear_pending_danger_discard()
	scene.add_log("预览：新手出牌提示。")

func seed_preview_update_dialog(scene: Node) -> void:
	scene.update_state = "ready"
	scene.update_remote_version = "1.0.181"
	scene.update_message = "发现新版本 v1.0.181，校验通过，可安装。"
	scene.update_downloaded_bytes = 10485760
	scene.update_total_bytes = 10485760
	scene.update_release_notes = "修复对局可读性；优化设置与更新弹窗奶油字色。"
	if scene.has_method("ensure_update_dialog"):
		scene.ensure_update_dialog()
	if scene.has_method("refresh_update_dialog"):
		scene.refresh_update_dialog()
	if scene.update_dialog != null and is_instance_valid(scene.update_dialog):
		scene.update_dialog.modulate = Color(1, 1, 1, 1)
		var panel = scene.update_dialog.get_child(1) if scene.update_dialog.get_child_count() > 1 else null
		if panel is Control:
			(panel as Control).scale = Vector2(1, 1)
			(panel as Control).modulate = Color(1, 1, 1, 1)

func seed_preview_chat_panel(scene: Node) -> void:
	scene.chat_messages = [
		"甲: 这局稳了",
		"乙: 小心三筒",
		"你: 收到，注意防守",
		"丙: 准备杠上开花",
	]
	if scene.has_method("show_chat_panel"):
		scene.show_chat_panel()

func seed_preview_replay_import(scene: Node) -> void:
	scene.show_replay_import_screen(true)
	scene.active_round_id = "CAPTURE-REPLAY-LONG"
	scene.round_event_history.clear()
	scene.round_event_sequence = 0
	scene.record_round_event("round_start", {"dealer": 0})
	for event_index in range(scene.ROUND_EVENT_HISTORY_LIMIT - 2):
		var kind := "draw"
		var fields := {"seat": event_index % 4}
		if event_index % 7 == 1:
			kind = "discard"
			fields = {"seat": event_index % 4, "tile": "3W"}
		elif event_index % 11 == 3:
			kind = "claim"
			fields = {"seat": event_index % 4, "claim": "peng"}
		scene.record_round_event(kind, fields)
	scene.record_round_event("win", {"seat": 0, "points": 16})
	var input := scene.find_child("ReplayImportCodeInput", true, false) as LineEdit
	if input != null:
		scene.set_replay_import_input_text(scene.round_replay_share_code())
		scene.import_replay_from_input()

func seed_preview_online_game(scene: Node, phase: String) -> void:
	scene.mode = "online_game"
	scene.online_feedback = ""
	scene.online_waiting_for_server = false
	scene.online_retry_available = false
	scene.current_seat = 0
	scene.online_game = {
		"roomCode": "CAPTURE7",
		"phase": phase,
		"youSeat": 0,
		"currentSeat": 0,
		"wallCount": 55,
		"wallTotal": 108,
		"ruleVariant": "sichuan",
		"hand": ["1W", "2W", "3W", "3W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E", "R"],
		"lastDiscard": "3W",
		"lastDiscardSeat": 3,
		"players": [
			{"seat": 0, "name": "你", "handCount": 14, "flowerCount": 0, "score": 26400, "discards": ["1W", "2W"], "melds": []},
			{"seat": 1, "name": "东风夜放", "handCount": 13, "flowerCount": 1, "score": 23800, "discards": ["1T", "2T", "3T"], "melds": [["5T", "5T", "5T"]]},
			{"seat": 2, "name": "南山客", "handCount": 13, "flowerCount": 0, "score": 27200, "discards": ["1B", "2B", "3B"], "melds": [["2W", "3W", "4W"]]},
			{"seat": 3, "name": "北海若", "handCount": 13, "flowerCount": 0, "score": 22600, "discards": ["Z", "F", "P"], "melds": []},
		],
	}
	if phase == "pendingClaim":
		scene.online_game["pending"] = {
			"tile": "3W",
			"fromSeat": 3,
			"options": ["hu", "gang", "peng", "chi"],
			"chi_choices": [
				{"meld": ["1W", "2W", "3W"]},
				{"meld": ["2W", "3W", "4W"]},
				{"meld": ["3W", "4W", "5W"]},
			],
		}
	scene.table_logs.clear()
	scene.table_logs.append("北海若打出三万，等待响应")
	scene.table_logs.append("在线房间 CAPTURE7 已同步")
	scene.render_game()
	scene.clear_fx_overlays()

func seed_preview_online_game_chat(scene: Node) -> void:
	scene.chat_messages = ["甲: 这局稳了", "乙: 注意三万", "你: 收到，准备响应", "丙: 等服务器同步"]
	scene.show_chat_panel()

func seed_preview_online_game_disconnect(scene: Node) -> void:
	scene.online_feedback = "连接已断开，请重新连接。"
	scene.online_waiting_for_server = false
	scene.online_retry_available = true
	scene.render_game()
	scene.clear_fx_overlays()


func seed_preview_telemetry(scene: Node, state: String) -> void:
	if scene.has_method("dismiss_active_toast"):
		scene.dismiss_active_toast()
	scene.settings_panel_open = false
	scene.telemetry_sheet_open = false
	scene.telemetry_outbox = []
	scene.telemetry_event_sequence = 0
	scene.telemetry_export_status = "未导出"
	scene.telemetry_consent = state == "consented" or state == "exported"
	scene.telemetry_consent_decided = state != "default"
	if scene.telemetry_consent:
		scene.telemetry_outbox = [{
			"schema": scene.TELEMETRY_SCHEMA_VERSION,
			"event_id": 1,
			"name": "round_started",
			"occurred_at": 1,
			"payload": {"rule_variant": "yangzhou", "difficulty": "标准", "hand_number": 1},
		}]
		scene.telemetry_event_sequence = 1
	scene.show_menu(true)
	scene.settings_panel_open = true
	scene.refresh_current_screen()
	scene.show_telemetry_data_sheet()
	if state == "exported":
		scene.export_telemetry_data()
