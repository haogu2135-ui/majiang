extends "res://scripts/ui_interaction_smoke_test.gd"


func reset_table_fixture(scene: Node) -> void:
	scene.mode = "offline"
	scene.settings_panel_open = false
	scene.telemetry_sheet_open = false
	scene.chat_panel_open = false
	scene.advisor_detail_open = false
	scene.table_log_archive_open = false
	scene.reset_progress_confirming = false
	scene.offline_restart_confirming = false
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.offline_turn_needs_draw = false
	scene.offline_all_bot_mode = false
	scene.offline_sim_quiet = false
	scene.offline_ai_active = true
	scene.offline_pending_claim.clear()
	scene.offline_claim_discard_bans.clear()
	scene.offline_passed_win_tiles.clear()
	scene.clear_pending_danger_discard()
	scene.hand_keyboard_selection = -1
	scene.players = []
	for seat in range(4):
		scene.players.append({"name": "P%d" % seat, "hand": [], "discards": [], "melds": [], "flowers": 0, "flower_tiles": [], "score": 25000, "bot": seat != 0})
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "5T", "6T", "7T", "E", "E", "P", "P", "S", "R"]
	scene.wall = scene.make_wall()
	scene.get_viewport().gui_release_focus()
	scene.last_game_keyboard_input_msec = 0


func prepare_danger_fixture(scene: Node, overflow_river: bool = false) -> void:
	reset_table_fixture(scene)
	if overflow_river:
		for index in range(35):
			scene.players[0]["discards"].append("%dW" % (index % 9 + 1))
	scene.ai_assist_enabled = true
	scene.render_game()
	await settle(0.06)
	if overflow_river:
		var archive := scene.find_child("DiscardRiverArchiveButton_0", true, false) as Button
		check(archive != null and archive.is_visible_in_tree(), "overflow river exposes its real pager before a danger decision")
		if archive != null:
			var latest_window := int(archive.get_meta("window_start", -1))
			await activate_button(archive, "mouse")
			await settle(0.06)
			archive = scene.find_child("DiscardRiverArchiveButton_0", true, false) as Button
			check(archive != null and int(archive.get_meta("window_start", -1)) < latest_window, "native pager reaches an earlier river page before danger confirmation")
			if archive != null:
				scene.set_meta("danger_test_archive_window", int(archive.get_meta("window_start", -1)))
	scene.current_human_advice = [
		{"tile": "S", "risk": 55.0, "feed_risk": 45.0, "risk_label": "高", "safety_label": "", "feed_text": "危险", "danger_source": {"reason": "牌路危险", "seat": 2}},
		{"tile": "1W", "risk": 4.0, "feed_risk": 2.0, "risk_label": "低", "safety_label": "安", "feed_text": "安全替代", "shanten": 1, "ukeire": 3},
	]
	scene.hand_keyboard_selection = 12
	scene.focus_hand_keyboard_control()
	scene.last_game_keyboard_input_msec = 0
	await send_key(KEY_ENTER, 0)
	await settle(0.06)
	check(scene.has_pending_danger_discard() and scene.players[0]["hand"].has("S"), "hand-focused Enter opens danger confirmation without discarding")
	var pending_tile := scene.find_child("HandTile_12_S", true, false) as Control
	check(pending_tile != null and pending_tile.tooltip_text.contains("风险高") and pending_tile.tooltip_text.contains("当前待确认"), "rendered danger tile exposes risk and confirmation together (tooltip=%s)" % (pending_tile.tooltip_text if pending_tile != null else "missing"))


func run() -> void:
	print("=== ui input safety smoke START ===")
	if DisplayServer.get_name().to_lower() == "headless":
		quit(1)
		return
	OS.set_environment("YUNZHUO_UI_CAPTURE", "1")
	var viewport_size := Vector2i(960, 540)
	var arguments := OS.get_cmdline_user_args()
	if not arguments.is_empty():
		var dimensions := arguments[0].split("x")
		if dimensions.size() == 2:
			viewport_size = Vector2i(int(dimensions[0]), int(dimensions[1]))
	DisplayServer.window_set_size(viewport_size)
	root.size = viewport_size
	root.content_scale_size = viewport_size
	var scene = load("res://Main.tscn").instantiate()
	scene.music_enabled = false
	scene.sfx_enabled = false
	scene.tts_enabled = false
	scene.voice_enabled = false
	scene.fx_enabled = false
	root.add_child(scene)
	await settle(0.10)
	var snapshot := capture_smoke_state(scene)

	for key in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
		await prepare_danger_fixture(scene)
		var original_hand: Array = scene.players[0]["hand"].duplicate()
		var cancel_button := scene.find_child("DangerDiscardCancelButton", true, false) as Button
		check(cancel_button != null, "danger cancel exposes a native focus target")
		if cancel_button != null:
			cancel_button.grab_focus()
			scene.last_game_keyboard_input_msec = 0
			await send_key(key, 0)
			await settle(0.06)
			check(not scene.has_pending_danger_discard() and scene.players[0]["hand"] == original_hand, "focused danger cancel preserves the hand for key %d" % key)

	await prepare_danger_fixture(scene, true)
	var hidden_archive := scene.find_child("DiscardRiverArchiveButton_0", true, false) as Button
	check(hidden_archive != null and not hidden_archive.is_visible_in_tree() and hidden_archive.focus_mode == Control.FOCUS_NONE, "danger confirmation hides the existing river pager from view and focus")
	var danger_cancel := scene.find_child("DangerDiscardCancelButton", true, false) as Button
	await activate_button(danger_cancel, "mouse")
	await settle(0.06)
	var restored_archive := scene.find_child("DiscardRiverArchiveButton_0", true, false) as Button
	check(not scene.has_pending_danger_discard() and restored_archive != null and restored_archive.is_visible_in_tree() and restored_archive.focus_mode == Control.FOCUS_ALL and int(restored_archive.get_meta("window_start", -1)) == int(scene.get_meta("danger_test_archive_window", -2)), "cancel restores the same readable river page and its native pager")

	await prepare_danger_fixture(scene)
	var alternative_button := scene.find_child("DangerDiscardAlternativeButton_0", true, false) as Button
	check(alternative_button != null, "danger alternatives expose a native focus target")
	if alternative_button != null:
		alternative_button.grab_focus()
		scene.last_game_keyboard_input_msec = Time.get_ticks_msec()
		await send_key(KEY_ENTER, 0)
		await settle(0.06)
		check(scene.players[0]["hand"].has("S") and not scene.players[0]["hand"].has("1W") and scene.players[0]["hand"].size() == 13, "focused alternative bypasses hand throttling and commits only its own tile")

	await prepare_danger_fixture(scene)
	var confirm_button := scene.find_child("DangerDiscardConfirmButton", true, false) as Button
	check(confirm_button != null, "danger confirm exposes a native focus target")
	if confirm_button != null:
		confirm_button.grab_focus()
		scene.last_game_keyboard_input_msec = 0
		await send_key(KEY_SPACE, 0)
		await settle(0.06)
		check(not scene.players[0]["hand"].has("S") and scene.players[0]["hand"].size() == 13, "focused confirm commits exactly the original dangerous tile")

	reset_table_fixture(scene)
	set_offline_pending_claim_fixture(scene, "peng")
	scene.offline_pending_claim["deadline_msec"] = Time.get_ticks_msec() + 60000
	await settle(0.06)
	var peng_button := first_button_with_text_prefix(scene.action_bar, "碰")
	check(peng_button != null, "pending claim exposes its peng focus target")
	if peng_button != null:
		peng_button.grab_focus()
		scene.last_game_keyboard_input_msec = 0
		await send_key(KEY_SPACE, 0)
		await settle(0.06)
		check(scene.players[0]["melds"].has(["3W", "3W", "3W"]), "Space on the focused peng button claims instead of passing")

	reset_table_fixture(scene)
	set_offline_pending_claim_fixture(scene, "peng")
	await settle(0.06)
	scene.offline_pending_claim["deadline_msec"] = Time.get_ticks_msec() + 60000
	var pending_claim: Dictionary = scene.offline_pending_claim.duplicate(true)
	scene.toggle_settings_panel()
	await settle(0.06)
	await send_key(KEY_ESCAPE, 0)
	await settle(0.06)
	check(not scene.settings_panel_open and scene.offline_pending_claim == pending_claim, "Esc closes settings without passing the offline pending claim")
	scene.toggle_settings_panel()
	await settle(0.06)
	scene.show_telemetry_data_sheet()
	await settle(0.06)
	await send_key(KEY_ESCAPE, 0)
	await settle(0.06)
	check(not scene.telemetry_sheet_open and scene.settings_panel_open and scene.offline_pending_claim == pending_claim, "Esc closes nested privacy before settings or the pending claim")
	scene.request_reset_progress_from_settings()
	await send_key(KEY_ESCAPE, 0)
	await settle(0.06)
	check(not scene.reset_progress_confirming and scene.settings_panel_open and scene.offline_pending_claim == pending_claim, "Esc disarms settings reset before closing settings or passing")
	scene.close_settings_panel()
	await settle(0.06)
	check(scene.pending_claim_remaining_seconds() > 0, "uncovered claim fixture has not timed out during modal rendering")
	await send_key(KEY_ESCAPE, 0)
	await settle(0.06)
	check(scene.offline_pending_claim.is_empty(), "uncovered pending claim still owns Esc as pass")

	await prepare_danger_fixture(scene)
	scene.toggle_settings_panel()
	await settle(0.06)
	await send_key(KEY_ESCAPE, 0)
	await settle(0.06)
	check(not scene.settings_panel_open and scene.has_pending_danger_discard(), "Esc closes settings without canceling the covered danger confirmation")
	await send_key(KEY_ESCAPE, 0)
	await settle(0.06)
	check(not scene.has_pending_danger_discard() and scene.players[0]["hand"].has("S"), "uncovered danger confirmation still owns Esc as cancel")

	reset_table_fixture(scene)
	var transport := ConnectedLobbyTransport.new()
	scene.tcp = transport
	scene.mode = "online_game"
	scene.online_room = connected_room_fixture()
	scene.online_game = online_pending_game_fixture()
	scene.online_waiting_for_server = false
	scene.online_last_sent_payload.clear()
	scene.render_game()
	await settle(0.06)
	for overlay in ["settings", "chat"]:
		if overlay == "settings":
			scene.toggle_settings_panel()
		else:
			scene.show_chat_panel()
		await settle(0.06)
		var writes_before := transport.writes.size()
		var online_pending: Dictionary = scene.online_game.get("pending", {}).duplicate(true)
		await send_key(KEY_ESCAPE, 0)
		await settle(0.06)
		check(not scene.settings_panel_open and not scene.chat_panel_open and not scene.online_waiting_for_server and transport.writes.size() == writes_before and scene.online_game.get("pending", {}) == online_pending, "Esc closes online %s without sending a background pass" % overlay)

	var tooltip_report := {"safety_label": "", "risk_label": "高"}
	for badge in ["荐", "确认", "摸"]:
		check(scene.hand_tile_interaction_tooltip("S", tooltip_report, badge).contains("风险高"), "empty safety label retains risk in the %s hand tooltip" % badge)
	check(scene.hand_tile_interaction_tooltip("S", {"risk_label": "高"}).contains("风险高"), "missing safety label falls back to risk")
	check(scene.hand_tile_report_risk_text({"safety_label": "  ", "risk_label": "高"}) == "高", "visual and tooltip risk binding also rejects whitespace-only safety")
	check(scene.hand_tile_interaction_tooltip("S", {"safety_label": "现", "risk_label": "高"}).contains("风险现"), "nonempty safety label keeps its existing semantics")

	scene.show_menu(true)
	await settle(0.06)
	scene.offline_progress_dirty = false
	scene.game_stats["games_played"] = 10
	scene.game_stats["games_won"] = 7
	scene.save_game_stats()
	var stats_file := FileAccess.get_file_as_bytes(scene.STATS_PATH)
	var stats: Dictionary = scene.game_stats.duplicate(true)
	var progress := ConfigFile.new()
	progress.set_value("qa", "marker", "retained")
	check(progress.save(scene.PROGRESS_PATH) == OK, "reset fixture creates a disposable continuation save")
	scene.toggle_settings_panel()
	await settle(0.06)
	var reset_status := scene.find_child("SettingRowStatus_本地进度", true, false) as Label
	var reset_button := scene.find_child("SettingRowButton_本地进度", true, false) as Button
	check(reset_status != null and reset_button != null and reset_status.tooltip_text.contains("续局") and reset_status.tooltip_text.contains("保留战绩") and reset_button.tooltip_text.contains("保留战绩"), "reset copy explicitly limits deletion to continuation saves and preserves statistics")
	check(reset_button != null and reset_button.get_meta("destructive_scope", "") == "离线续局存档", "reset accessibility metadata declares the same deletion scope as its copy")
	scene.request_reset_progress_from_settings()
	check(FileAccess.file_exists(scene.PROGRESS_PATH), "first reset click never deletes the continuation save")
	var armed_reset_button := scene.find_child("SettingRowButton_本地进度", true, false) as Button
	check(armed_reset_button != null and armed_reset_button.tooltip_text.contains("5秒") and armed_reset_button.tooltip_text.contains("保留战绩"), "armed reset retains its confirmation deadline in the button tooltip")
	await send_key(KEY_ESCAPE, 0)
	await settle(0.06)
	check(not scene.reset_progress_confirming and scene.settings_panel_open and FileAccess.file_exists(scene.PROGRESS_PATH), "Esc cancels only the armed reset and leaves the save")
	scene.request_reset_progress_from_settings()
	scene.close_settings_panel()
	check(FileAccess.file_exists(scene.PROGRESS_PATH) and not scene.reset_progress_confirming, "closing settings cancels the reset without deleting files")
	scene.toggle_settings_panel()
	scene.request_reset_progress_from_settings()
	scene.reset_progress_confirm_deadline_msec = Time.get_ticks_msec() - 1
	scene.request_reset_progress_from_settings()
	check(scene.reset_progress_confirming and FileAccess.file_exists(scene.PROGRESS_PATH) and scene.reset_progress_confirm_deadline_msec > Time.get_ticks_msec(), "an expired confirmation cannot delete before the deadline poll runs")
	scene.reset_progress_confirm_deadline_msec = Time.get_ticks_msec() - 1
	scene._process(0.0)
	check(not scene.reset_progress_confirming and FileAccess.file_exists(scene.PROGRESS_PATH), "reset expiry leaves the continuation save intact")
	scene.request_reset_progress_from_settings()
	scene.request_reset_progress_from_settings()
	check(not FileAccess.file_exists(scene.PROGRESS_PATH), "second reset click removes only the continuation save")
	check(scene.game_stats == stats and FileAccess.get_file_as_bytes(scene.STATS_PATH) == stats_file, "reset preserves both in-memory and persisted statistics")

	if scene.has_method("shutdown_runtime"):
		scene.shutdown_runtime()
	restore_smoke_state(scene, snapshot)
	scene.queue_free()
	await process_frame
	print("=== RESULT: %s ===" % ("FAIL" if failed else "OK"))
	quit(1 if failed else 0)
