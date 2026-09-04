extends SceneTree
## Runtime interaction coverage for hover, press, focus, and connected lobby UI.

class ConnectedLobbyTransport:
	extends RefCounted
	var writes: Array[String] = []

	func get_status() -> int:
		return StreamPeerTCP.STATUS_CONNECTED

	func poll() -> Error:
		return OK

	func get_available_bytes() -> int:
		return 0

	func get_utf8_string(_bytes: int) -> String:
		return ""

	func put_data(data: PackedByteArray) -> Error:
		writes.append(data.get_string_from_utf8().strip_edges())
		return OK

	func disconnect_from_host() -> void:
		pass


var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(cond: bool, msg: String) -> void:
	if cond:
		print("  OK  | %s" % msg)
	else:
		print("  FAIL| %s" % msg)
		failed = true


func settle(seconds: float = 0.0) -> void:
	await process_frame
	await process_frame
	if seconds > 0.0:
		await create_timer(seconds).timeout
		await process_frame


func first_button_with_text(scope: Node, text: String) -> Button:
	if scope == null:
		return null
	for candidate in scope.find_children("*", "Button", true, false):
		var button := candidate as Button
		if button != null and button.text == text:
			return button
	return null


func first_button_with_text_prefix(scope: Node, prefix: String) -> Button:
	for candidate in scope.find_children("*", "Button", true, false):
		var button := candidate as Button
		if button != null and button.text.begins_with(prefix):
			return button
	return null


func first_button_in(scope: Node) -> Button:
	if scope == null:
		return null
	for candidate in scope.find_children("*", "Button", true, false):
		var button := candidate as Button
		if button != null:
			return button
	return null


func buttons_in(scope: Node) -> Array[Button]:
	var buttons: Array[Button] = []
	if scope == null:
		return buttons
	for candidate in scope.find_children("*", "Button", true, false):
		var button := candidate as Button
		if button != null:
			buttons.append(button)
	return buttons


func valid_replay_events(scene: Node, round_id: String) -> Array:
	var events: Array = []
	var previous_digest := ""
	var definitions := [
		["round_start", {"dealer": 0}],
		["draw", {"seat": 0}],
		["discard", {"seat": 0, "tile": "3W"}],
		["claim", {"seat": 1, "claim": "peng"}],
	]
	var sequence := 1
	for definition in definitions:
		var event: Dictionary = (definition[1] as Dictionary).duplicate(true)
		event["round_id"] = round_id
		event["sequence"] = sequence
		event["type"] = str(definition[0])
		event["prev_digest"] = previous_digest
		event["digest"] = scene.replay_event_digest(event)
		events.append(event)
		previous_digest = str(event["digest"])
		sequence += 1
	return events


func set_offline_pending_claim_fixture(scene: Node, claim: String) -> void:
	var hands := {
		"chi": ["1W", "2W", "4W", "5W", "6W", "7B", "8B", "9B", "E", "E", "E", "1T", "1T"],
		"peng": ["1W", "2W", "4W", "5W", "6W", "7B", "8B", "9B", "E", "E", "E", "3W", "3W"],
		"gang": ["1W", "2W", "4W", "5W", "6W", "7B", "8B", "9B", "E", "E", "E", "3W", "3W", "3W"],
		"hu": ["1W", "2W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E", "E", "1T", "1T"],
	}
	var hand: Array = (hands.get(claim, hands["peng"]) as Array).duplicate()
	var chi_choices: Array = scene.get_chi_choices(hand, "3W") if claim == "chi" else []
	scene.mode = "offline"
	scene.ai_assist_enabled = false
	scene.current_seat = 0
	scene.offline_phase = "pending_claim"
	scene.offline_turn_needs_draw = false
	scene.offline_pending_claim = {
		"from_seat": 3,
		"tile": "3W",
		"options": [claim],
		"chi_choices": chi_choices,
		"deadline_msec": Time.get_ticks_msec() + 10000,
	}
	scene.players[0]["bot"] = false
	scene.players[0]["hand"] = hand
	scene.players[0]["melds"] = []
	scene.players[3]["discards"] = ["3W"]
	scene.last_discard = "3W"
	scene.last_discard_seat = 3
	scene.render_game()


func has_label_text(scope: Node, expected: String) -> bool:
	if scope == null:
		return false
	for candidate in scope.find_children("*", "Label", true, false):
		var label := candidate as Label
		if label != null and label.text == expected:
			return true
	return false


func label_text_width(label: Label, text: String) -> float:
	if label == null:
		return 0.0
	var font := label.get_theme_font("font")
	if font == null:
		return 0.0
	return font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, label.get_theme_font_size("font_size")).x


func node_is_descendant_of(node: Node, ancestor: Node) -> bool:
	var cursor := node
	while cursor != null:
		if cursor == ancestor:
			return true
		cursor = cursor.get_parent()
	return false


func move_pointer(position: Vector2, settle_seconds: float = 0.42) -> void:
	Input.warp_mouse(position)
	var motion := InputEventMouseMotion.new()
	motion.position = position
	motion.global_position = position
	Input.parse_input_event(motion)
	await settle(settle_seconds)


func send_left_button(position: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.position = position
	event.global_position = position
	event.button_index = MOUSE_BUTTON_LEFT
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
	event.pressed = pressed
	Input.parse_input_event(event)
	await process_frame


func send_screen_touch(position: Vector2, pressed: bool, index: int = 0) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = position
	event.pressed = pressed
	Input.parse_input_event(event)
	await process_frame


func send_screen_drag(from: Vector2, to: Vector2, index: int = 0) -> void:
	var event := InputEventScreenDrag.new()
	event.index = index
	event.position = to
	event.relative = to - from
	event.screen_relative = to - from
	Input.parse_input_event(event)
	await process_frame


func send_wheel_down(position: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.position = position
	event.global_position = position
	event.button_index = MOUSE_BUTTON_WHEEL_DOWN
	event.factor = 1.0
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	var release_event := InputEventMouseButton.new()
	release_event.position = position
	release_event.global_position = position
	release_event.button_index = MOUSE_BUTTON_WHEEL_DOWN
	release_event.factor = 1.0
	release_event.pressed = false
	Input.parse_input_event(release_event)
	await process_frame


func send_key(keycode: Key, unicode_value: int) -> void:
	var pressed_event := InputEventKey.new()
	pressed_event.keycode = keycode
	pressed_event.unicode = unicode_value
	pressed_event.pressed = true
	Input.parse_input_event(pressed_event)
	await process_frame
	var released_event := InputEventKey.new()
	released_event.keycode = keycode
	released_event.unicode = unicode_value
	released_event.pressed = false
	Input.parse_input_event(released_event)
	await process_frame


func activate_button(button: Button, modality: String = "mouse") -> void:
	if button == null or not is_instance_valid(button) or button.disabled or not button.visible:
		return
	var center := button.get_global_rect().get_center()
	match modality:
		"touch":
			await send_screen_touch(center, true)
			await send_screen_touch(center, false)
		"key":
			button.grab_focus()
			await process_frame
			await send_key(KEY_ENTER, 0)
		_:
			await send_left_button(center, true)
			await send_left_button(center, false)
	await settle(0.04)


func duplicate_smoke_value(value):
	if typeof(value) == TYPE_DICTIONARY:
		return (value as Dictionary).duplicate(true)
	if typeof(value) == TYPE_ARRAY:
		return (value as Array).duplicate(true)
	return value


func capture_smoke_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"exists": false, "data": PackedByteArray()}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"exists": false, "data": PackedByteArray()}
	return {"exists": true, "data": file.get_buffer(file.get_length())}


func capture_smoke_update_files() -> Dictionary:
	var files: Dictionary = {}
	var directory := DirAccess.open("user://updates")
	if directory == null:
		return files
	directory.list_dir_begin()
	while true:
		var entry := directory.get_next()
		if entry == "":
			break
		if directory.current_is_dir() or entry == "." or entry == "..":
			continue
		var path := "user://updates/%s" % entry
		files[path] = capture_smoke_file(path)
	directory.list_dir_end()
	return files


func capture_smoke_state(scene: Node) -> Dictionary:
	var field_names := [
		"mode", "currency", "inventory", "game_stats", "achievements", "round_history", "replay_archive",
		"replay_search_query", "replay_archive_generation", "replay_search_cache_generation", "replay_search_cache_query", "replay_search_cache_results",
		"round_event_history", "replay_import_payload", "round_event_sequence", "active_round_id", "last_match_summary", "applied_result_transactions",
		"settings_panel_open", "settings_focus_restore_name", "menu_focus_restore_name", "shop_scroll_restore_value", "shop_focus_restore_name", "reset_progress_confirming",
		"update_state", "update_request_mode", "update_message", "update_download_url", "update_remote_version", "update_release_notes", "update_remote_sha256", "update_remote_size", "update_file_path", "update_downloaded_bytes", "update_total_bytes", "next_update_progress_msec",
		"telemetry_consent", "telemetry_consent_decided", "telemetry_outbox", "telemetry_event_sequence", "telemetry_save_pending", "telemetry_save_due_msec",
		"telemetry_upload_status", "telemetry_export_status", "telemetry_sheet_open", "telemetry_clear_confirming",
		"last_login_date", "consecutive_login_days", "login_reward_claimed_date", "season_data", "daily_tasks", "task_progress", "task_claimed", "last_task_reset_date",
		"daily_login_view_state", "tutorial_step", "tutorial_checkpoint_round_id", "tutorial_checkpoint_phase", "tutorial_checkpoint_reason", "tutorial_last_saved_unix", "show_hand_hint", "interactive_guide_active", "interactive_guide_type", "interactive_guide_target_index",
		"music_enabled", "sfx_enabled", "tts_enabled", "voice_enabled", "fast_mode_enabled", "large_text_enabled", "high_contrast_enabled", "reduce_motion_enabled", "ai_difficulty", "fx_enabled", "graphics_quality", "ai_assist_enabled", "current_bgm_index", "rule_variant",
		"players", "wall", "current_seat", "dealer_seat", "offline_hand_number", "offline_last_winner", "offline_dealer_repeat", "last_discard", "last_discard_seat", "table_logs", "offline_phase", "offline_turn_needs_draw", "offline_pending_claim", "offline_pending_claim_deadline_msec", "offline_claim_counts", "offline_package_liability", "offline_passed_win_tiles", "offline_claim_discard_bans", "offline_concealed_gang_tiles", "offline_last_draw", "offline_self_draw_ready", "offline_ai_active", "offline_ai_run_queued", "offline_all_bot_mode", "offline_sim_quiet", "offline_match_briefing_shown", "offline_skip_ai_profile_reshuffle", "offline_active_rule_variant", "round_summary", "round_result_kind", "last_score_deltas", "last_win_score", "current_human_advice", "current_seat_threat_reports", "advisor_detail_open", "table_log_archive_open", "table_log_chat_restore_pending", "table_log_chat_draft", "pending_danger_discard_index", "pending_danger_discard_tile", "pending_danger_discard_report", "hand_keyboard_selection",
		"selected_room", "online_connection_host", "online_player_name", "online_room", "online_game", "online_log_seen_count", "online_feedback", "online_waiting_for_server", "online_last_sent_action", "online_last_sent_type", "online_last_sent_msec", "online_last_sent_payload", "online_slow_notice_shown", "online_retry_available", "online_action_sequence", "online_session_id", "online_room_revision", "online_game_revision", "online_resume_context", "online_resume_pending", "online_resume_join_sent", "online_seen_message_ids", "online_seen_voice_sequences", "online_last_chat_sent_msec", "online_last_receive_msec", "online_last_heartbeat_msec", "online_reconnect_attempts", "online_next_reconnect_msec", "online_last_malformed_notice_msec", "online_messages_received", "online_messages_rejected", "online_last_snapshot_fingerprint", "online_last_room_snapshot_fingerprint", "online_players_by_seat", "online_player_index_token", "online_announced_discard_key", "online_pending_local_discard_identity", "sent_hello", "chat_messages", "chat_panel_open", "table_log_chat_restore_pending", "table_log_chat_draft", "safe_area_test_margins_override"
	]
	var fields: Dictionary = {}
	for field_name in field_names:
		fields[field_name] = duplicate_smoke_value(scene.get(field_name))
	var paths := [
		str(scene.SETTINGS_PATH), str(scene.PROGRESS_PATH), str(scene.STATS_PATH), str(scene.HISTORY_PATH), str(scene.REPLAY_ARCHIVE_PATH),
		str(scene.TUTORIAL_PATH), str(scene.ACHIEVEMENTS_PATH), str(scene.LOGIN_PATH), str(scene.TELEMETRY_PATH), str(scene.INVENTORY_PATH), str(scene.CURRENCY_PATH),
		str(scene.SEASON_PATH), str(scene.TASKS_PATH), str(scene.UPDATE_FILE_PATH)
	]
	var files: Dictionary = {}
	for path in paths:
		files[path] = capture_smoke_file(path)
	return {"fields": fields, "files": files, "update_files": capture_smoke_update_files(), "tcp": scene.get("tcp")}


func restore_smoke_state(scene: Node, snapshot: Dictionary) -> void:
	var current_tcp = scene.get("tcp")
	var saved_tcp = snapshot.get("tcp", null)
	if current_tcp != null and current_tcp != saved_tcp and current_tcp.has_method("disconnect_from_host"):
		current_tcp.disconnect_from_host()
	for field_name in (snapshot.get("fields", {}) as Dictionary).keys():
		scene.set(str(field_name), duplicate_smoke_value((snapshot["fields"] as Dictionary)[field_name]))
	if saved_tcp != null:
		scene.set("tcp", saved_tcp)
	for path in (snapshot.get("files", {}) as Dictionary).keys():
		var file_snapshot: Dictionary = (snapshot["files"] as Dictionary)[path]
		if bool(file_snapshot.get("exists", false)):
			var file := FileAccess.open(str(path), FileAccess.WRITE)
			if file != null:
				file.store_buffer(file_snapshot.get("data", PackedByteArray()))
		elif FileAccess.file_exists(str(path)):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(str(path)))
	var saved_update_files: Dictionary = snapshot.get("update_files", {})
	var current_update_files := capture_smoke_update_files()
	for path in current_update_files.keys():
		if not saved_update_files.has(path) and FileAccess.file_exists(str(path)):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(str(path)))
	for path in saved_update_files.keys():
		var update_snapshot: Dictionary = saved_update_files[path]
		if bool(update_snapshot.get("exists", false)):
			var update_file := FileAccess.open(str(path), FileAccess.WRITE)
			if update_file != null:
				update_file.store_buffer(update_snapshot.get("data", PackedByteArray()))


func connected_room_fixture() -> Dictionary:
	return {
		"code": "ROOM7",
		"canStart": false,
		"players": [
			{"seat": 0, "name": "甲", "ready": true},
			{"seat": 1, "name": "乙", "ready": true},
			{"seat": 2, "name": "丙", "ready": false},
		],
		"logs": ["甲加入房间", "乙准备就绪", "丙加入房间", "房间同步完成"],
	}


func online_pending_game_fixture() -> Dictionary:
	return {
		"roomCode": "QA7",
		"phase": "pendingClaim",
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
			{"seat": 1, "name": "东风夜放", "handCount": 13, "flowerCount": 1, "score": 23800, "discards": ["1T", "2T"], "melds": []},
			{"seat": 2, "name": "南山客", "handCount": 13, "flowerCount": 0, "score": 27200, "discards": ["1B", "2B"], "melds": []},
			{"seat": 3, "name": "北海若", "handCount": 13, "flowerCount": 0, "score": 22600, "discards": ["Z", "F", "P", "3W"], "melds": []},
		],
		"pending": {
			"tile": "3W",
			"fromSeat": 3,
			"options": ["hu", "gang", "peng", "chi"],
			"chi_choices": [{"meld": ["1W", "2W", "3W"]}],
		},
	}


func run_optimization_contract_checks(scene: Node) -> void:
	print("--- optimization contracts: cache, transport, and state guards ---")
	var profile: Dictionary = scene.rule_profile(scene.RULE_VARIANT_SICHUAN)
	var tile_codes: Array = scene.rule_tile_codes(scene.RULE_VARIANT_SICHUAN)
	var flower_codes: Array = scene.rule_flower_codes(scene.RULE_VARIANT_SICHUAN)
	check(profile.get("include_honors", true) == false and tile_codes.size() == 27 and flower_codes.is_empty(), "rule profile and derived tile lists preserve the Sichuan deck")
	check(scene.rule_profile_cache.has(scene.RULE_VARIANT_SICHUAN) and scene.rule_tile_codes_cache.has(scene.RULE_VARIANT_SICHUAN) and scene.rule_flower_codes_cache.has(scene.RULE_VARIANT_SICHUAN), "rule metadata caches are populated after the first lookup")
	check(scene.normalize_tile_code(" m1 ") == "1W" and scene.normalize_tile_code("white") == "P" and scene.normalize_tile_code("north") == "R", "tile normalization canonicalizes legacy aliases")
	check(scene.is_number_tile("m1") and scene.is_honor_tile("white") and scene.is_terminal_or_honor("m1") and scene.is_simple_number_tile("m2"), "tile classification accepts normalized aliases and caches misses")
	check(scene.is_tile_enabled_for_rule("m1", scene.RULE_VARIANT_SICHUAN) and not scene.is_tile_enabled_for_rule("E", scene.RULE_VARIANT_SICHUAN), "rule membership cache follows the active tile profile")
	var valid_game := online_pending_game_fixture()
	valid_game["ruleVariant"] = "yangzhou"
	valid_game["wallTotal"] = 144
	check(scene.online_game_snapshot_validation_error(valid_game) == "", "complete online snapshot passes cross-field validation")
	var overfull_game := {"ruleVariant": "yangzhou", "youSeat": 0, "currentSeat": 0, "wallCount": 120, "wallTotal": 144, "phase": "awaitDiscard", "hand": ["1W", "1W", "1W", "1W", "1W"]}
	check(scene.online_game_snapshot_validation_error(overfull_game).contains("四张"), "online snapshot rejects more than four copies of one tile")
	var wrong_wall_game := overfull_game.duplicate(true)
	wrong_wall_game["hand"] = ["1W"]
	wrong_wall_game["wallCount"] = 100
	wrong_wall_game["wallTotal"] = 108
	check(scene.online_game_snapshot_validation_error(wrong_wall_game).contains("规则数量"), "online snapshot rejects a wall size that disagrees with the rule profile")
	scene.online_session_id = 42
	check(scene.online_message_session_matches({"sessionId": 42}) and not scene.online_message_session_matches({"sessionId": 41}) and scene.online_message_session_matches({}), "stale online messages are isolated by connection session")
	check(scene.online_frame_line_is_safe(PackedByteArray([123, 125])) and not scene.online_frame_line_is_safe(PackedByteArray([0, 123])), "TCP frames reject embedded NUL bytes before JSON parsing")
	check(scene.online_reconnect_delay_msec(1) == scene.ONLINE_RECONNECT_BASE_DELAY_MSEC and scene.online_reconnect_delay_msec(99) == scene.ONLINE_RECONNECT_MAX_DELAY_MSEC, "reconnect delay uses bounded exponential backoff")
	scene.telemetry_save_pending = false
	scene.schedule_telemetry_save()
	check(scene.telemetry_save_pending and scene.telemetry_save_due_msec > Time.get_ticks_msec(), "telemetry writes are coalesced behind a short deferred save")
	var saved_archive: Array = scene.replay_archive.duplicate(true)
	scene.replay_archive = [{"summary": "contract probe", "rule_variant": "yangzhou", "result_kind": "win", "saved_at": 1, "replay_digest": "ABC"}]
	scene.replay_archive_generation += 1
	var first_search: Array = scene.replay_archive_entries("contract")
	var second_search: Array = scene.replay_archive_entries("contract")
	check(first_search.size() == 1 and second_search.size() == 1 and scene.replay_search_cache_generation == scene.replay_archive_generation, "replay search reuses a generation-keyed result cache")
	scene.replay_archive = saved_archive
	scene.replay_archive_generation += 1
	scene.replay_search_cache_generation = -1
	scene.online_game = {"players": [{"seat": 2, "name": "缓存测试", "handCount": 13, "flowerCount": 0, "score": 25000, "discards": [], "melds": []}]}
	scene.online_players_by_seat.clear()
	check(scene.online_player_for_seat(2).get("name", "") == "缓存测试" and scene.online_players_by_seat.has(2), "online seat lookup builds a reusable player index")


func diagnostic_interaction_lines() -> Array[String]:
	return [
		"【音频系统诊断 1.0.180-godot】", "",
		"1. 用户激活: 是", "2. 设备: 小米手机 (MIUI)", "",
		"⚠️ 当前音频说明", "BGM已从WAV改为MP3格式", "因为您能听到TTS语音提示",
		"说明音频系统正常", "只是WAV格式不兼容", "", "【请回答】",
		"1. 能听到背景音乐了吗？", "2. 刚才的440Hz测试音听到了吗？", "",
		"3. BGM播放器: 正常", "4. BGM音频流: 已加载", "5. BGM正在播放: 是",
		"6. BGM音量: -8.0dB (0dB=最大)", "7. 音频总线: Master",
		"8. Master总线音量: 0.0dB", "9. Master总线静音: 否",
		"10. 音频格式: AudioStreamMP3", "", "✓ BGM播放成功", "",
		"小米手机听不到声音？", "请检查以下MIUI设置:", "",
		"1. 断开蓝牙设备", "2. 按音量+键调整【媒体音量】", "3. 关闭【游戏加速】",
		"4. 关闭【省电模式】", "5. 设置→应用管理→本应用", "   →省电策略→无限制",
		"6. 尝试重启手机", "", "点击任意位置关闭",
	]


func run() -> void:
	print("=== ui interaction smoke START ===")
	if DisplayServer.get_name().to_lower() == "headless":
		printerr("UI interaction smoke requires a non-headless display driver")
		quit(1)
		return
	# Preserve visual tweens while disabling desktop audio/TTS backends that are
	# unrelated to pointer and focus coverage in the virtual display.
	OS.set_environment("YUNZHUO_UI_CAPTURE", "1")

	var viewport_size := Vector2i(960, 540)
	DisplayServer.window_set_size(viewport_size)
	root.size = viewport_size
	root.content_scale_size = viewport_size
	await settle()

	var scene = load("res://Main.tscn").instantiate()
	scene.music_enabled = false
	scene.sfx_enabled = false
	scene.tts_enabled = false
	scene.voice_enabled = false
	root.add_child(scene)
	await settle(0.10)
	run_optimization_contract_checks(scene)
	scene._show_online_lobby_impl()
	await settle(0.65)
	var initial_name_edit := scene.online_name_edit as LineEdit
	check(initial_name_edit != null and initial_name_edit.has_focus(), "lobby assigns default keyboard focus to its nickname editor")
	if initial_name_edit != null:
		initial_name_edit.release_focus()
		await process_frame

	print("--- A) pointer hover and press drive the real lobby button ---")
	var connect_button := first_button_with_text(scene, "连接")
	check(connect_button != null and not connect_button.disabled, "disconnected lobby exposes the active connection action")
	if connect_button != null:
		var hover_probe := {"entered": false, "exited": false}
		var button_down_probe := {"down": 0}
		connect_button.button_down.connect(func() -> void:
			button_down_probe["down"] = int(button_down_probe.get("down", 0)) + 1
		)
		connect_button.mouse_entered.connect(func() -> void:
			hover_probe["entered"] = true
		)
		connect_button.mouse_exited.connect(func() -> void:
			hover_probe["exited"] = true
		)
		await move_pointer(Vector2(4.0, 4.0))
		var rest_scale := connect_button.scale
		check(not connect_button.is_hovered() and rest_scale.distance_to(Vector2.ONE) <= 0.015, "mouse exit reaches the stable resting transform")
		await move_pointer(connect_button.get_global_rect().get_center())
		check(connect_button.is_hovered() and bool(hover_probe.get("entered", false)), "mouse motion enters the hit target and emits the native hover signal")
		await send_left_button(connect_button.get_global_rect().get_center(), true)
		check(int(button_down_probe.get("down", 0)) == 1, "left-button down reaches the native button-down signal")
		check(connect_button.find_child("LobbyActionPressFeedback_连接", true, false) != null, "button-down signal produces authored press feedback")
		await send_left_button(connect_button.get_global_rect().get_center(), false)
		check(not connect_button.button_pressed, "left-button release clears the native pressed state")
		await move_pointer(Vector2(4.0, 4.0))
		check(not connect_button.is_hovered() and bool(hover_probe.get("exited", false)), "mouse exit clears hover and emits the native exit signal")
		# A successful connection intentionally disables the connect action. Use a
		# connected fixture for the independent touch activation path instead of
		# testing a button whose state changes as part of its own callback.
		var touch_transport := ConnectedLobbyTransport.new()
		scene.tcp = touch_transport
		scene.tcp_status = StreamPeerTCP.STATUS_CONNECTED
		scene.online_room = connected_room_fixture()
		scene.online_waiting_for_server = false
		scene.refresh_online_lobby_state()
		await settle()
		var touch_button := first_button_with_text(scene, "创建")
		check(touch_button != null and not touch_button.disabled, "connected lobby exposes a touch-testable create action")
		var touch_probe := {"pressed": false}
		var touch_down_probe := {"down": 0}
		if touch_button != null:
			touch_button.button_down.connect(func() -> void:
				touch_down_probe["down"] = int(touch_down_probe.get("down", 0)) + 1
			)
			touch_button.pressed.connect(func() -> void:
				touch_probe["pressed"] = true
			)
		if scene.tcp != null:
			scene.tcp.disconnect_from_host()
		if touch_button != null:
			await send_screen_touch(touch_button.get_global_rect().get_center(), true)
			check(int(touch_down_probe.get("down", 0)) == 1, "screen-touch down reaches the native button-down signal")
			await send_screen_touch(touch_button.get_global_rect().get_center(), false)
			check(bool(touch_probe.get("pressed", false)) and not touch_button.button_pressed, "screen-touch release activates the real lobby button")
		scene.tcp = StreamPeerTCP.new()
		scene.tcp_status = StreamPeerTCP.STATUS_NONE
		scene.online_room.clear()
		scene.online_waiting_for_server = false
		scene.online_feedback = ""
		scene.refresh_online_lobby_state()
		await settle()
	var disconnected_start = scene.find_child("OnlineLobbyPrimaryStartButton", true, false) as Button
	check(disconnected_start != null and disconnected_start.disabled, "disconnected lobby exposes a visibly disabled start action")
	if disconnected_start != null:
		var disabled_start_probe := {"pressed": 0}
		disconnected_start.pressed.connect(func() -> void:
			disabled_start_probe["pressed"] = int(disabled_start_probe.get("pressed", 0)) + 1
		)
		var disabled_start_center := disconnected_start.get_global_rect().get_center()
		await send_left_button(disabled_start_center, true)
		await send_left_button(disabled_start_center, false)
		await send_screen_touch(disabled_start_center, true)
		await send_screen_touch(disabled_start_center, false)
		check(int(disabled_start_probe.get("pressed", 0)) == 0 and disconnected_start.disabled, "disabled start ignores desktop and single-finger activation")

	print("--- B) keyboard focus and editing drive the real line edit ---")
	var name_edit := scene.online_name_edit as LineEdit
	check(name_edit != null, "lobby exposes its nickname editor")
	if name_edit != null:
		await send_screen_touch(name_edit.get_global_rect().get_center(), true)
		await send_screen_touch(name_edit.get_global_rect().get_center(), false)
		check(name_edit.has_focus(), "screen touch enters the native line-edit focus state")
		check(name_edit.find_child("LineEditInputFeedback_name", true, false) != null, "focus-entered signal produces authored input feedback")
		name_edit.caret_column = name_edit.text.length()
		await send_key(KEY_1, "1".unicode_at(0))
		check(name_edit.text.ends_with("1"), "focused line edit accepts a dispatched keyboard character")
		var committed_feedback := false
		for candidate in name_edit.find_children("LineEditInputFeedbackGlyph_name", "Label", true, false):
			var changed_glyph := candidate as Label
			if changed_glyph != null and changed_glyph.text == "定":
				committed_feedback = true
				break
		check(committed_feedback, "text editing replaces focus feedback with the committed-value state")
		name_edit.release_focus()
		await process_frame
		check(not name_edit.has_focus(), "release_focus exits the native line-edit focus state")
		name_edit.text = "名".repeat(scene.ONLINE_NAME_MAX_LENGTH + 4)
		check(name_edit.text.length() == scene.ONLINE_NAME_MAX_LENGTH, "nickname editor enforces its native max-length boundary")
	var host_edit := scene.online_host_edit as LineEdit
	var room_edit := scene.online_room_edit as LineEdit
	check(host_edit != null and host_edit.max_length == scene.ONLINE_HOST_MAX_LENGTH and host_edit.virtual_keyboard_type == LineEdit.KEYBOARD_TYPE_URL, "host editor exposes bounded URL-keyboard input")
	if room_edit != null:
		room_edit.text = "R".repeat(scene.ONLINE_ROOM_CODE_MAX_LENGTH + 5)
		check(room_edit.text.length() == scene.ONLINE_ROOM_CODE_MAX_LENGTH, "room editor enforces its native max-length boundary")
	scene.online_connection_host = "qa.lobby.internal"
	scene.refresh_online_lobby_state()
	var endpoint_label = scene.find_child("OnlineLobbyServerEndpointLabel", true, false) as Label
	check(endpoint_label != null and endpoint_label.text == "qa.lobby.internal:%d" % scene.DEFAULT_PORT, "endpoint badge follows the actual connection target")

	print("--- C) connected transport state renders a usable room lobby ---")
	var transport := ConnectedLobbyTransport.new()
	scene.tcp = transport
	scene.tcp_status = StreamPeerTCP.STATUS_CONNECTED
	scene.selected_room = "ROOM7"
	scene.online_room = connected_room_fixture()
	scene.online_feedback = "房间同步完成，等待房主开始。"
	scene.online_waiting_for_server = false
	scene._show_online_lobby_impl()
	await settle(0.20)
	check(scene.lobby_connection_state_text() == "已连接", "connected fixture uses the production transport-status contract")
	var connection_label = scene.find_child("OnlineLobbyConnectionStateLabel", true, false) as Label
	var start_button = scene.find_child("OnlineLobbyPrimaryStartButton", true, false) as Button
	var return_button = scene.find_child("OnlineLobbySecondaryReturnButton", true, false) as Button
	var room_art = scene.find_child("OnlineLobbyRoomArt", true, false) as Control
	var roster = scene.find_child("OnlineLobbyRosterPanel", true, false) as Control
	var log_list = scene.find_child("OnlineLobbyLogListPanel", true, false) as Control
	var offline_state = scene.find_child("OnlineLobbyRoomOfflineState", true, false) as Control
	check(connection_label != null and connection_label.text == "已连接", "connection badge reports the connected state")
	check(start_button != null and start_button.disabled and start_button.text == "等待开局" and start_button.tooltip_text.contains("开局"), "connected lobby gates the primary start action until the server grants permission")
	check(start_button != null and return_button != null and start_button.size.x > return_button.size.x + 36.0 and return_button.modulate.a <= 0.85, "connected lobby gives start a unique primary hierarchy")
	check(room_art != null and room_art.visible and roster != null and roster.visible and log_list != null and log_list.visible, "connected lobby reveals room summary, roster, and logs")
	check(offline_state != null and not offline_state.visible, "connected lobby hides the disconnected empty state")
	var room_badge = scene.find_child("OnlineLobbyRoomBadge", true, false) as Control
	var room_badge_label = room_badge.get_child(room_badge.get_child_count() - 1) as Label if room_badge != null and room_badge.get_child_count() > 0 else null
	check(room_badge_label != null and room_badge_label.text == "房间号 ROOM7", "connected lobby displays the active room code")
	if room_badge != null and room_badge_label != null:
		var room_badge_rect := room_badge.get_global_rect()
		var room_badge_label_rect := room_badge_label.get_global_rect()
		check(room_badge_rect.size.x >= 128.0 and room_badge_rect.end.x <= viewport_size.x + 1.0, "compact connected lobby reserves a readable room-code badge lane")
		var room_code_text_width := label_text_width(room_badge_label, room_badge_label.text)
		check(room_code_text_width <= room_badge_label_rect.size.x + 1.0, "compact connected lobby renders the complete short room code without label overrun (text=%.1f lane=%.1f badge=%.1f)" % [room_code_text_width, room_badge_label_rect.size.x, room_badge_rect.size.x])
	var occupancy = scene.find_child("OnlineLobbyRoomSummaryOccupancyLabel", true, false) as Label
	var ready = scene.find_child("OnlineLobbyRoomSummaryReadyLabel", true, false) as Label
	check(occupancy != null and occupancy.text == "入席 3/4" and ready != null and ready.text == "已备 2", "connected summary reflects player and ready counts")
	var roster_name = scene.find_child("OnlineLobbyRosterName_2", true, false) as Label
	var logs = scene.find_child("OnlineLobbyLogListText", true, false) as RichTextLabel
	check(roster_name != null and roster_name.text == "丙", "connected roster renders server-provided seat identity")
	check(logs != null and logs.text.contains("甲加入房间") and logs.text.contains("房间同步完成"), "connected log panel renders the complete room event stream")
	check(logs != null and logs.fit_content and not logs.scroll_active, "connected log text delegates overflow to the native scroll container")
	scene.online_room["canStart"] = true
	scene.refresh_online_lobby_state()
	await settle(0.05)
	check(start_button != null and not start_button.disabled and start_button.text == "开始游戏", "connected lobby enables the primary start action after the server grants permission")
	scene.online_room["canStart"] = false
	scene.refresh_online_lobby_state()

	print("--- D) bounded actions and live room messages update the same page ---")
	transport.writes.clear()
	scene.online_name_edit.text = "  测试玩家  "
	scene.online_room_edit.text = "   "
	scene.join_online_room()
	check(transport.writes.is_empty(), "blank normalized room code does not emit a join action")
	scene.online_room_edit.text = "  QA-ROOM  "
	scene.create_online_room()
	scene.join_online_room()
	check(transport.writes.size() == 2, "valid create and join actions reach the connected transport")
	if transport.writes.size() == 2:
		var create_payload = JSON.parse_string(transport.writes[0])
		var join_payload = JSON.parse_string(transport.writes[1])
		check(typeof(create_payload) == TYPE_DICTIONARY and create_payload.get("name", "") == "测试玩家", "create action sends the normalized nickname")
		check(typeof(join_payload) == TYPE_DICTIONARY and join_payload.get("roomCode", "") == "QA-ROOM" and join_payload.get("name", "") == "测试玩家", "join action sends normalized room and nickname fields")

	var room_art_id := room_art.get_instance_id() if room_art != null else 0
	var live_logs: Array[String] = []
	for i in range(scene.ONLINE_LOG_HISTORY_LIMIT):
		live_logs.append("实时日志%02d" % (i + 1))
	var updated_room := {
		"type": "roomState",
		"room": {
			"room_code": "LIVE180",
			"players": [
				{"seat": 3, "nickname": "丁", "isReady": true},
				{"seat": 0, "nickname": "甲新", "ready": true},
				{"seat": 2, "nickname": "丙新", "ready": false},
				{"seat": 1, "nickname": "乙新", "ready": true},
			],
			"logs": live_logs,
		},
	}
	scene.handle_online_message(JSON.stringify(updated_room))
	await settle(0.05)
	var refreshed_room_art = scene.find_child("OnlineLobbyRoomArt", true, false) as Control
	check(refreshed_room_art != null and refreshed_room_art.get_instance_id() == room_art_id, "roomState refreshes the existing lobby page without reconstruction")
	occupancy = scene.find_child("OnlineLobbyRoomSummaryOccupancyLabel", true, false) as Label
	ready = scene.find_child("OnlineLobbyRoomSummaryReadyLabel", true, false) as Label
	check(occupancy != null and occupancy.text == "入席 4/4" and ready != null and ready.text == "已备 3", "live roomState refreshes occupancy and ready summaries")
	var live_names: Array[String] = []
	for slot in range(4):
		var live_name = scene.find_child("OnlineLobbyRosterName_%d" % slot, true, false) as Label
		var live_seat = scene.find_child("OnlineLobbyPlayerSeat_%d" % slot, true, false) as CanvasItem
		if live_name != null:
			live_names.append(live_name.text)
		check(live_seat != null and live_seat.modulate.a >= 0.99, "live roomState activates seat %d" % slot)
	check(live_names == ["甲新", "乙新", "丙新", "丁"], "live roster follows explicit seats and nickname aliases")
	logs = scene.find_child("OnlineLobbyLogListText", true, false) as RichTextLabel
	var log_count_label = scene.find_child("OnlineLobbyLogCountLabel", true, false) as Label
	check(logs != null and logs.text.contains("实时日志01") and logs.text.contains("实时日志14"), "all fourteen retained room logs remain accessible")
	check(log_count_label != null and log_count_label.text == "14条", "live log count stays synchronized with retained history")
	var log_scroll = scene.find_child("OnlineLobbyLogScroll", true, false) as ScrollContainer
	var review_scroll := 0
	if log_scroll != null:
		log_scroll.scroll_vertical = 0
		await process_frame
		var drag_start := log_scroll.get_global_rect().get_center() + Vector2(0.0, 28.0)
		var drag_capture := drag_start - Vector2(0.0, 12.0)
		var drag_middle := drag_start - Vector2(0.0, 48.0)
		var drag_end := drag_start - Vector2(0.0, 84.0)
		await send_screen_touch(drag_start, true)
		await send_screen_drag(drag_start, drag_capture)
		await send_screen_drag(drag_capture, drag_middle)
		await send_screen_drag(drag_middle, drag_end)
		await send_screen_touch(drag_end, false)
		await settle(0.05)
		var log_bar := log_scroll.get_v_scroll_bar()
		check(log_bar.max_value > log_bar.page, "fourteen room logs create a native vertical scroll range")
		if DisplayServer.is_touchscreen_available():
			check(log_scroll.scroll_vertical > 0, "screen drag scrolls the native room log history")
		else:
			check(log_scroll.scroll_vertical == 0, "Xvfb exposes no touchscreen device; drag validation remains a real-device gate")
			await send_wheel_down(log_scroll.get_global_rect().get_center())
			check(log_scroll.scroll_vertical > 0, "desktop wheel scrolls the same native room log history")
		review_scroll = log_scroll.scroll_vertical
	scene.handle_online_message(JSON.stringify({"type": "log", "text": "实时日志15"}))
	await settle(0.05)
	check((scene.online_room.get("logs", []) as Array).size() == scene.ONLINE_LOG_HISTORY_LIMIT, "appended logs stay within the fourteen-entry history limit")
	check(logs != null and not logs.text.contains("实时日志01") and logs.text.contains("实时日志15") and log_count_label != null and log_count_label.text == "14条", "log append evicts the oldest line and refreshes text and count")
	if log_scroll != null:
		check(log_scroll.scroll_vertical == review_scroll, "new logs preserve the scroll offset while the user reviews history")
		var before_follow_bar := log_scroll.get_v_scroll_bar()
		log_scroll.scroll_vertical = int(round(maxf(0.0, before_follow_bar.max_value - before_follow_bar.page)))
		await process_frame
		scene.handle_online_message(JSON.stringify({"type": "log", "text": "末尾跟随" + "长".repeat(80)}))
		await settle(0.05)
		var after_follow_bar := log_scroll.get_v_scroll_bar()
		var after_follow_max := int(round(maxf(0.0, after_follow_bar.max_value - after_follow_bar.page)))
		check(log_scroll.scroll_vertical >= after_follow_max - 1 and after_follow_max > review_scroll, "new logs remain visible when the user was already at the bottom (value=%d max=%d)" % [log_scroll.scroll_vertical, after_follow_max])

	print("--- E) touch reveals full clipped room and roster identities ---")
	var long_name := "名".repeat(scene.ONLINE_NAME_MAX_LENGTH)
	var long_room := "R".repeat(scene.ONLINE_ROOM_CODE_MAX_LENGTH)
	scene.handle_online_message(JSON.stringify({
		"type": "roomState",
		"room": {
			"roomCode": long_room,
			"players": [{"seat": 0, "name": long_name, "ready": true}],
			"logs": scene.online_room.get("logs", []),
		},
	}))
	await settle(0.05)
	var long_name_label = scene.find_child("OnlineLobbyRosterName_0", true, false) as Label
	var long_room_label = scene.find_child("OnlineLobbyRoomBadgeLabel", true, false) as Label
	var room_view_icon = scene.find_child("OnlineLobbyRoomBadgeViewIcon", true, false) as TextureRect
	check(long_name_label != null and long_name_label.tooltip_text == long_name and long_room_label != null and long_room_label.text == scene.online_room_badge_display_text(long_room) and long_room_label.text != long_room and long_room_label.tooltip_text == "房间号 " + long_room and room_view_icon != null and room_view_icon.texture != null, "long room badge shows a stable short identifier with a visible view icon while retaining the complete source value")
	var roster_row = scene.find_child("OnlineLobbyRosterRow_0", true, false) as Control
	if roster_row != null:
		var roster_touch_target := scene.find_child("OnlineLobbyRosterTouchTarget_0", true, false) as Button
		var roster_touch_probe := {"down": 0, "pressed": 0}
		if roster_touch_target != null:
			roster_touch_target.button_down.connect(func() -> void:
				roster_touch_probe["down"] = int(roster_touch_probe.get("down", 0)) + 1
			)
			roster_touch_target.pressed.connect(func() -> void:
				roster_touch_probe["pressed"] = int(roster_touch_probe.get("pressed", 0)) + 1
			)
		check(roster_touch_target != null and not roster_touch_target.disabled, "active roster row exposes a native detail touch target")
		var roster_center := roster_touch_target.get_global_rect().get_center() if roster_touch_target != null else roster_row.get_global_rect().get_center()
		await send_screen_touch(roster_center, true)
		check(int(roster_touch_probe.get("down", 0)) == 1, "screen touch reaches the active roster detail target")
		await send_screen_touch(roster_center, false)
		await settle(0.05)
		check(int(roster_touch_probe.get("pressed", 0)) == 1, "screen-touch release activates the roster detail target")
		check(scene.toast_current != null and has_label_text(scene.toast_current, "玩家 1：%s" % long_name), "single-finger roster press reveals the complete nickname")
	var room_badge_touch = scene.find_child("OnlineLobbyRoomBadge", true, false) as Control
	if room_badge_touch != null:
		var room_touch_target := scene.find_child("OnlineLobbyRoomBadgeTouchTarget", true, false) as Button
		var room_touch_probe := {"down": 0, "pressed": 0}
		if room_touch_target != null:
			room_touch_target.button_down.connect(func() -> void:
				room_touch_probe["down"] = int(room_touch_probe.get("down", 0)) + 1
			)
			room_touch_target.pressed.connect(func() -> void:
				room_touch_probe["pressed"] = int(room_touch_probe.get("pressed", 0)) + 1
			)
		check(room_touch_target != null and not room_touch_target.disabled, "room badge exposes a native detail touch target")
		var room_center := room_touch_target.get_global_rect().get_center() if room_touch_target != null else room_badge_touch.get_global_rect().get_center()
		await send_screen_touch(room_center, true)
		check(int(room_touch_probe.get("down", 0)) == 1, "screen touch reaches the room detail target")
		await send_screen_touch(room_center, false)
		await settle(0.05)
		check(int(room_touch_probe.get("pressed", 0)) == 1, "screen-touch release activates the room detail target")
		check(scene.toast_current != null and has_label_text(scene.toast_current, "房间号：%s" % long_room), "single-finger room-badge press reveals the complete room code")

	print("--- F) diagnostic report scroll and modal dismiss paths ---")
	var diagnostic_lines := diagnostic_interaction_lines()
	scene.show_diagnostic_dialog(diagnostic_lines)
	await settle(0.10)
	var diagnostic_scroll = scene.find_child("DiagnosticContentScroll", true, false) as ScrollContainer
	var diagnostic_close = scene.find_child("DiagnosticCloseButton", true, false) as Button
	var diagnostic_status = scene.find_child("DiagnosticContentStatusLabel", true, false) as Label
	check(diagnostic_scroll != null and diagnostic_close != null and diagnostic_status != null and diagnostic_status.visible, "diagnostic exposes its native scroll, visible range status, and explicit close action")
	if diagnostic_scroll != null:
		var diagnostic_bar := diagnostic_scroll.get_v_scroll_bar()
		check(diagnostic_bar.max_value > diagnostic_bar.page, "full diagnostic report creates a native vertical range")
		diagnostic_scroll.scroll_vertical = 0
		await send_wheel_down(diagnostic_scroll.get_global_rect().get_center())
		check(diagnostic_scroll.scroll_vertical > 0, "desktop wheel scrolls the full diagnostic report")
		if diagnostic_status != null:
			scene.sync_diagnostic_scroll_status(diagnostic_scroll, diagnostic_status, diagnostic_lines.size())
			check(diagnostic_status.text.contains("可继续滚动") or diagnostic_status.text.contains("已到末尾"), "diagnostic range status follows the active scroll position")
	if diagnostic_close != null:
		check(diagnostic_close.focus_mode == Control.FOCUS_ALL and diagnostic_close.has_focus(), "diagnostic close action receives modal keyboard focus")
	var diagnostic_copy_mouse := scene.find_child("DiagnosticCopyButton", true, false) as Button
	var diagnostic_report_text := "\n".join(diagnostic_lines)
	check(diagnostic_copy_mouse != null and not diagnostic_copy_mouse.disabled, "diagnostic exposes an active copy-report button")
	if diagnostic_copy_mouse != null:
		var diagnostic_mouse_pressed := {"value": false}
		var diagnostic_mouse_gui_input := {"value": false}
		diagnostic_copy_mouse.button_down.connect(func() -> void:
			diagnostic_mouse_pressed["value"] = true
		)
		diagnostic_copy_mouse.gui_input.connect(func(event: InputEvent) -> void:
			if event is InputEventMouseButton:
				diagnostic_mouse_gui_input["value"] = true
		)
		var diagnostic_copy_mouse_center := diagnostic_copy_mouse.get_global_rect().get_center()
		await move_pointer(diagnostic_copy_mouse_center)
		DisplayServer.clipboard_set("")
		await send_left_button(diagnostic_copy_mouse_center, true)
		await send_left_button(diagnostic_copy_mouse_center, false)
		await settle(0.04)
		check(bool(diagnostic_mouse_gui_input.get("value", false)), "mouse copy reaches the button gui input")
		check(bool(diagnostic_mouse_pressed.get("value", false)), "mouse copy reaches the native button-down signal")
		check(DisplayServer.clipboard_get() == diagnostic_report_text, "mouse copy writes the complete diagnostic report")
		check(scene.find_child("DiagnosticDialogPanel", true, false) != null and scene.toast_current != null and has_label_text(scene.toast_current, "诊断报告已复制"), "mouse copy keeps the dialog open and shows feedback")
	scene.show_diagnostic_dialog(diagnostic_lines)
	await settle(0.05)
	var diagnostic_copy_touch := scene.find_child("DiagnosticCopyButton", true, false) as Button
	if diagnostic_copy_touch != null:
		await send_screen_touch(diagnostic_copy_touch.get_global_rect().get_center(), true)
		await send_screen_touch(diagnostic_copy_touch.get_global_rect().get_center(), false)
		await settle(0.04)
	check(DisplayServer.clipboard_get() == diagnostic_report_text and scene.find_child("DiagnosticDialogPanel", true, false) != null and scene.toast_current != null and has_label_text(scene.toast_current, "诊断报告已复制"), "single-finger copy writes the same complete diagnostic report without dismissing the dialog")
	scene.show_diagnostic_dialog(diagnostic_lines)
	await settle(0.05)
	var diagnostic_copy_keyboard := scene.find_child("DiagnosticCopyButton", true, false) as Button
	if diagnostic_copy_keyboard != null:
		diagnostic_copy_keyboard.grab_focus()
		await send_key(KEY_ENTER, 0)
		await settle(0.04)
	check(DisplayServer.clipboard_get() == diagnostic_report_text and scene.find_child("DiagnosticDialogPanel", true, false) != null and scene.toast_current != null and has_label_text(scene.toast_current, "诊断报告已复制"), "keyboard copy writes the same complete diagnostic report without dismissing the dialog")
	diagnostic_close = scene.find_child("DiagnosticCloseButton", true, false) as Button
	if diagnostic_close != null:
		check(diagnostic_close.focus_mode == Control.FOCUS_ALL and scene.find_child("DiagnosticDialogPanel", true, false) != null, "diagnostic close action remains available after copy")
	await send_key(KEY_ESCAPE, 0)
	await settle(0.10)
	check(scene.find_child("DiagnosticDialogPanel", true, false) == null and scene.find_child("OnlineLobbyFormPanel", true, false) != null, "ui_cancel closes the diagnostic and restores the source page")

	scene.show_diagnostic_dialog(diagnostic_lines)
	await settle(0.05)
	diagnostic_close = scene.find_child("DiagnosticCloseButton", true, false) as Button
	if diagnostic_close != null:
		await send_key(KEY_ENTER, 0)
		await settle(0.10)
	check(scene.find_child("DiagnosticDialogPanel", true, false) == null, "focused explicit close button dismisses the diagnostic")

	scene.show_diagnostic_dialog(diagnostic_lines)
	await settle(0.05)
	var dismiss_overlay = scene.find_child("DiagnosticDismissOverlay", true, false) as Control
	if dismiss_overlay != null:
		var mouse_dismiss_position := dismiss_overlay.get_global_rect().position + Vector2(8.0, 8.0)
		await send_left_button(mouse_dismiss_position, true)
		await send_left_button(mouse_dismiss_position, false)
		await settle(0.10)
	check(scene.find_child("DiagnosticDialogPanel", true, false) == null, "desktop backdrop click dismisses the diagnostic")

	scene.show_diagnostic_dialog(diagnostic_lines)
	await settle(0.05)
	dismiss_overlay = scene.find_child("DiagnosticDismissOverlay", true, false) as Control
	if dismiss_overlay != null:
		var touch_dismiss_position := dismiss_overlay.get_global_rect().position + Vector2(8.0, 8.0)
		await send_screen_touch(touch_dismiss_position, true)
		await send_screen_touch(touch_dismiss_position, false)
		await settle(0.10)
	check(scene.find_child("DiagnosticDialogPanel", true, false) == null, "single-finger backdrop press dismisses the diagnostic")

	print("--- G) exit confirmation owns focus and blocks input penetration ---")
	scene.show_menu(true)
	await settle(0.05)
	var menu_settings = scene.find_child("MenuSettingsButton", true, false) as Button
	check(menu_settings != null, "menu exposes a focus-restore source control")
	var menu_settings_probe := {"pressed": 0}
	if menu_settings != null:
		menu_settings.focus_mode = Control.FOCUS_ALL
		menu_settings.pressed.connect(func() -> void:
			menu_settings_probe["pressed"] = int(menu_settings_probe.get("pressed", 0)) + 1
		)
		menu_settings.grab_focus()
		scene.show_exit_confirm()
		await settle(0.05)
		var exit_overlay = scene.exit_confirm_panel as Control
		var continue_button := first_button_with_text(exit_overlay, "继续游戏")
		var leave_button := first_button_with_text(exit_overlay, "退出游戏")
		var exit_focus_owner := scene.get_viewport().gui_get_focus_owner() as Control
		check(exit_overlay != null and continue_button != null and leave_button != null, "exit confirmation exposes both explicit decisions")
		check(continue_button != null and continue_button.focus_mode == Control.FOCUS_ALL and continue_button.has_focus() and node_is_descendant_of(exit_focus_owner, exit_overlay), "exit confirmation moves keyboard focus inside the modal")
		var covered_settings_center := menu_settings.get_global_rect().get_center()
		await send_left_button(covered_settings_center, true)
		await send_left_button(covered_settings_center, false)
		await send_screen_touch(covered_settings_center, true)
		await send_screen_touch(covered_settings_center, false)
		check(int(menu_settings_probe.get("pressed", 0)) == 0 and scene.exit_confirm_panel != null, "exit modal blocks desktop and touch input from reaching the menu")
		await send_key(KEY_ESCAPE, 0)
		await settle(0.20)
		check(scene.exit_confirm_panel == null and scene.find_child("ExitConfirmDialog", true, false) == null and menu_settings.has_focus(), "ui_cancel closes exit confirmation and restores prior focus")

		scene.show_exit_confirm()
		await settle(0.05)
		continue_button = first_button_with_text(scene.exit_confirm_panel, "继续游戏")
		await send_key(KEY_ENTER, 0)
		await settle(0.20)
		check(scene.exit_confirm_panel == null, "Enter activates the safe default exit-confirmation action")

		scene.show_exit_confirm()
		await settle(0.05)
		continue_button = first_button_with_text(scene.exit_confirm_panel, "继续游戏")
		if continue_button != null:
			var continue_center := continue_button.get_global_rect().get_center()
			await send_screen_touch(continue_center, true)
			await send_screen_touch(continue_center, false)
			await settle(0.20)
		check(scene.exit_confirm_panel == null, "single-finger safe-default activation closes exit confirmation")

	print("--- H) settings modal owns focus and blocks every background input path ---")
	scene.show_menu(true)
	await settle(0.05)
	scene.settings_panel_open = true
	scene.refresh_current_screen()
	await settle(0.05)
	var settings_overlay = scene.find_child("SettingsOverlay", true, false) as Control
	var settings_close = scene.find_child("SettingsCloseButton", true, false) as Button
	var settings_underlay = scene.find_child("MenuSettingsButton", true, false) as Button
	var settings_underlay_probe := {"pressed": 0}
	if settings_underlay != null:
		settings_underlay.pressed.connect(func() -> void:
			settings_underlay_probe["pressed"] = int(settings_underlay_probe.get("pressed", 0)) + 1
		)
	var settings_focus_owner := scene.get_viewport().gui_get_focus_owner() as Control
	check(settings_overlay != null and settings_close != null and settings_underlay != null, "settings exposes its modal close action above the menu")
	check(settings_close != null and settings_close.has_focus() and node_is_descendant_of(settings_focus_owner, settings_overlay), "settings moves keyboard focus to its safe close action")
	await send_key(KEY_TAB, 0)
	settings_focus_owner = scene.get_viewport().gui_get_focus_owner() as Control
	check(settings_focus_owner != null and node_is_descendant_of(settings_focus_owner, settings_overlay) and settings_focus_owner != settings_close, "settings advances sequential keyboard focus to another modal control")
	if settings_underlay != null:
		var covered_settings_position := settings_underlay.get_global_rect().get_center()
		await send_left_button(covered_settings_position, true)
		await send_left_button(covered_settings_position, false)
		await send_screen_touch(covered_settings_position, true)
		await send_screen_touch(covered_settings_position, false)
	check(int(settings_underlay_probe.get("pressed", 0)) == 0 and scene.settings_panel_open, "settings blocks desktop and touch input from reaching the menu")
	settings_close.grab_focus()
	await send_key(KEY_ENTER, 0)
	await settle(0.10)
	var restored_settings = scene.find_child("MenuSettingsButton", true, false) as Button
	check(not scene.settings_panel_open and scene.find_child("SettingsOverlay", true, false) == null and restored_settings != null and restored_settings.has_focus(), "Enter closes settings and restores menu focus")

	scene.settings_panel_open = true
	scene.refresh_current_screen()
	await settle(0.05)
	await send_key(KEY_ESCAPE, 0)
	await settle(0.10)
	restored_settings = scene.find_child("MenuSettingsButton", true, false) as Button
	check(not scene.settings_panel_open and scene.find_child("SettingsOverlay", true, false) == null and restored_settings != null and restored_settings.has_focus(), "ui_cancel closes settings and restores menu focus")
	menu_settings = restored_settings
	menu_settings_probe = {"pressed": 0}
	if menu_settings != null:
		menu_settings.pressed.connect(func() -> void:
			menu_settings_probe["pressed"] = int(menu_settings_probe.get("pressed", 0)) + 1
		)

	print("--- I) update modal owns focus and keeps the underlying menu inert ---")
	if menu_settings != null:
		menu_settings.grab_focus()
	scene.update_state = "checking"
	scene.update_message = "正在检查更新。"
	scene.ensure_update_dialog()
	await settle(0.05)
	var blocked_primary = scene.find_child("UpdatePrimaryButton", true, false) as Button
	var blocked_primary_probe := {"pressed": 0}
	check(blocked_primary != null and blocked_primary.visible and blocked_primary.disabled and blocked_primary.text == "检查中", "active update work exposes a visible disabled primary action")
	if blocked_primary != null:
		blocked_primary.pressed.connect(func() -> void:
			blocked_primary_probe["pressed"] = int(blocked_primary_probe.get("pressed", 0)) + 1
		)
		var blocked_primary_center := blocked_primary.get_global_rect().get_center()
		await send_left_button(blocked_primary_center, true)
		await send_left_button(blocked_primary_center, false)
		await send_screen_touch(blocked_primary_center, true)
		await send_screen_touch(blocked_primary_center, false)
	scene.get_viewport().gui_release_focus()
	await send_key(KEY_ENTER, 0)
	check(int(blocked_primary_probe.get("pressed", 0)) == 0 and scene.update_state == "checking", "disabled update primary ignores desktop touch and unfocused keyboard activation")
	scene.update_state = "idle"
	scene.refresh_update_dialog()
	await settle(0.10)
	if menu_settings != null:
		menu_settings.grab_focus()
	scene.update_state = "error"
	scene.update_message = "更新服务器暂时不可用，请稍后重试。"
	scene.ensure_update_dialog()
	await settle(0.05)
	var update_overlay = scene.find_child("UpdateDialogOverlay", true, false) as Control
	var update_secondary = scene.find_child("UpdateSecondaryButton", true, false) as Button
	var update_focus_owner := scene.get_viewport().gui_get_focus_owner() as Control
	check(update_overlay != null and update_secondary != null, "update flow exposes a named modal and secondary exit action")
	check(update_secondary != null and update_secondary.focus_mode == Control.FOCUS_ALL and update_secondary.has_focus() and node_is_descendant_of(update_focus_owner, update_overlay), "update modal moves keyboard focus to its safe action")
	if menu_settings != null:
		var update_probe_before := int(menu_settings_probe.get("pressed", 0))
		var covered_menu_center := menu_settings.get_global_rect().get_center()
		await send_left_button(covered_menu_center, true)
		await send_left_button(covered_menu_center, false)
		await send_screen_touch(covered_menu_center, true)
		await send_screen_touch(covered_menu_center, false)
		check(int(menu_settings_probe.get("pressed", 0)) == update_probe_before and scene.find_child("UpdateDialogOverlay", true, false) != null, "update modal blocks desktop and touch input penetration")
	await send_key(KEY_ESCAPE, 0)
	await settle(0.10)
	check(scene.update_state == "idle" and scene.find_child("UpdateDialogOverlay", true, false) == null and (menu_settings == null or menu_settings.has_focus()), "ui_cancel closes a non-active update modal and restores prior focus")

	scene.update_state = "error"
	scene.update_message = "更新服务器暂时不可用，请稍后重试。"
	scene.ensure_update_dialog()
	await settle(0.05)
	await send_key(KEY_ENTER, 0)
	await settle(0.10)
	check(scene.update_state == "idle" and scene.find_child("UpdateDialogOverlay", true, false) == null, "Enter activates the focused update close action")

	print("--- J) disabled daily claim and page exit routes remain deterministic ---")
	scene.show_daily_login_panel({"consecutive_days": 5, "claimed_today": true, "show_reward": true})
	await settle(0.05)
	var claim_button = scene.find_child("DailyLoginClaimButton", true, false) as Button
	var claim_probe := {"pressed": 0}
	check(claim_button != null and claim_button.disabled, "already-claimed daily reward exposes a disabled claim action")
	if claim_button != null:
		claim_button.pressed.connect(func() -> void:
			claim_probe["pressed"] = int(claim_probe.get("pressed", 0)) + 1
		)
		var coins_before := int(scene.currency.get("coins", 0))
		var claim_center := claim_button.get_global_rect().get_center()
		await send_left_button(claim_center, true)
		await send_left_button(claim_center, false)
		await send_screen_touch(claim_center, true)
		await send_screen_touch(claim_center, false)
		check(int(claim_probe.get("pressed", 0)) == 0 and int(scene.currency.get("coins", 0)) == coins_before, "disabled daily claim ignores desktop and touch activation without duplicate reward")
	await send_key(KEY_ESCAPE, 0)
	await settle(0.10)
	check(scene.mode == "menu" and scene.find_child("MenuSettingsButton", true, false) != null, "ui_cancel returns from daily login to the menu")

	scene._show_rules_screen_impl()
	await settle(0.05)
	var rules_scroll := scene.find_child("RulesContentScroll", true, false) as ScrollContainer
	var rules_scrollbar := scene.find_child("RulesContentScrollBar", true, false) as VScrollBar
	check(rules_scroll != null and rules_scrollbar != null and rules_scroll.focus_mode == Control.FOCUS_ALL and rules_scroll.has_meta("ui_scroll_view"), "rules exposes a keyboard-focusable native scroll view")
	if rules_scroll != null and rules_scrollbar != null:
		check(rules_scrollbar.max_value > rules_scrollbar.page, "rules content creates a native vertical range for keyboard scrolling")
		if rules_scrollbar.max_value > rules_scrollbar.page:
			rules_scroll.scroll_vertical = 0
			rules_scrollbar.value = 0.0
			rules_scroll.grab_focus()
			check(rules_scroll.has_focus(), "rules scroll accepts keyboard focus before paging")
			await send_key(KEY_PAGEDOWN, 0)
			var rules_page_value := float(rules_scrollbar.value)
			check(rules_page_value > 0.0, "PageDown moves the rules scroll value")
			await send_key(KEY_END, 0)
			var rules_end_value := float(rules_scrollbar.value)
			var rules_scroll_range := rules_scrollbar.max_value - rules_scrollbar.page
			check(rules_end_value >= rules_scroll_range - 1.0, "End moves the rules scroll to its bottom boundary")
			await send_key(KEY_HOME, 0)
			check(rules_scrollbar.value <= 1.0, "Home returns the rules scroll to its top boundary")
			await send_key(KEY_PAGEDOWN, 0)
			var rules_before_page_up := float(rules_scrollbar.value)
			await send_key(KEY_PAGEUP, 0)
			check(rules_scrollbar.value < rules_before_page_up, "PageUp reverses the rules scroll direction")
	await send_key(KEY_ESCAPE, 0)
	await settle(0.10)
	check(scene.mode == "menu" and scene.find_child("MenuSettingsButton", true, false) != null, "ui_cancel returns from the rules to the menu")

	scene._show_shop_screen_impl()
	await settle(0.05)
	var shop_scroll := scene.find_child("ShopItemsScroll", true, false) as ScrollContainer
	var shop_scrollbar := scene.find_child("ShopItemsScrollBar", true, false) as VScrollBar
	var shop_scroll_hit_target := scene.find_child("ShopItemsScrollHitTarget", true, false) as Control
	var shop_content := scene.find_child("ShopItemsContent", true, false) as Control
	check(shop_scroll != null and shop_scrollbar != null and shop_scroll_hit_target != null, "shop exposes a drag-capable custom scrollbar target")
	if shop_scroll != null and shop_scrollbar != null and shop_scroll_hit_target != null:
		# The production four-item fixture fits at 960x540. Add an inert overflow
		# probe here so the input path is exercised without changing the product
		# catalog or forcing a scroll range in the compact layout.
		if shop_scrollbar.max_value <= shop_scrollbar.page and shop_content != null:
			var overflow_probe := Control.new()
			overflow_probe.name = "InteractionSmokeShopOverflowProbe"
			overflow_probe.custom_minimum_size = Vector2(0.0, shop_scroll.size.y + 240.0)
			shop_content.add_child(overflow_probe)
			await settle(0.05)
		check(shop_scrollbar.max_value > shop_scrollbar.page, "shop overflow fixture creates a native vertical range for scrollbar interaction")
	if shop_scroll != null and shop_scrollbar != null and shop_scrollbar.max_value > shop_scrollbar.page:
		check(shop_scroll.focus_mode == Control.FOCUS_ALL and shop_scroll.has_meta("ui_scroll_view"), "shop scroll accepts keyboard focus for the item list")
		shop_scroll.scroll_vertical = 0
		shop_scrollbar.value = 0.0
		shop_scroll.grab_focus()
		check(shop_scroll.has_focus(), "shop scroll receives keyboard focus before paging")
		await send_key(KEY_PAGEDOWN, 0)
		var shop_page_value := float(shop_scrollbar.value)
		check(shop_page_value > 0.0, "PageDown moves the shop scroll value")
		await send_key(KEY_END, 0)
		var shop_end_value := float(shop_scrollbar.value)
		var shop_scroll_range := shop_scrollbar.max_value - shop_scrollbar.page
		check(shop_end_value >= shop_scroll_range - 1.0, "End moves the shop scroll to its bottom boundary")
		await send_key(KEY_HOME, 0)
		check(shop_scrollbar.value <= 1.0, "Home returns the shop scroll to its top boundary")
		await send_key(KEY_PAGEDOWN, 0)
		var shop_before_page_up := float(shop_scrollbar.value)
		await send_key(KEY_PAGEUP, 0)
		check(shop_scrollbar.value < shop_before_page_up, "PageUp reverses the shop scroll direction")
	if shop_scrollbar != null and shop_scroll_hit_target != null and shop_scrollbar.max_value > shop_scrollbar.page:
		var shop_scroll_range: float = shop_scrollbar.max_value - shop_scrollbar.page
		var shop_target_rect: Rect2 = shop_scroll_hit_target.get_global_rect()
		var shop_track_bottom: Vector2 = shop_target_rect.position + Vector2(shop_target_rect.size.x * 0.5, shop_target_rect.size.y * 0.90)
		await send_left_button(shop_track_bottom, true)
		await send_left_button(shop_track_bottom, false)
		check(shop_scrollbar.value >= shop_scroll_range * 0.70, "clicking the shop scrollbar track moves the native scroll value")
		var shop_value_before_drag: float = float(shop_scrollbar.value)
		var shop_track_top: Vector2 = shop_target_rect.position + Vector2(shop_target_rect.size.x * 0.5, shop_target_rect.size.y * 0.12)
		await send_screen_touch(shop_track_top, true)
		await send_screen_drag(shop_track_top, shop_target_rect.position + Vector2(shop_target_rect.size.x * 0.5, shop_target_rect.size.y * 0.30))
		await send_screen_touch(shop_target_rect.position + Vector2(shop_target_rect.size.x * 0.5, shop_target_rect.size.y * 0.30), false)
		check(shop_scrollbar.value < shop_value_before_drag, "dragging the shop scrollbar thumb updates the native scroll value")
	await send_key(KEY_ESCAPE, 0)
	await settle(0.10)
	check(scene.mode == "menu" and scene.find_child("MenuSettingsButton", true, false) != null, "ui_cancel returns from the shop to the menu")

	print("--- K) table Esc routes active response and network-wait states ---")
	var game_transport := ConnectedLobbyTransport.new()
	scene.tcp = game_transport
	scene.mode = "online_game"
	scene.online_game = online_pending_game_fixture()
	scene.online_feedback = ""
	scene.online_waiting_for_server = false
	scene.online_retry_available = false
	scene.online_last_sent_payload.clear()
	scene.online_last_sent_action = ""
	scene.online_last_sent_type = ""
	scene.render_game()
	await settle(0.10)
	check(scene.find_child("PendingClaimResponseGrid", true, false) != null and scene.exit_confirm_panel == null, "online table fixture exposes the response lane before Esc routing")
	await send_key(KEY_ESCAPE, 0)
	await settle(0.10)
	check(game_transport.writes.size() == 1 and game_transport.writes[0].contains("\"claim\":\"pass\"") and scene.online_waiting_for_server and scene.exit_confirm_panel == null, "Esc submits the implicit online pass instead of opening exit confirmation")
	await send_key(KEY_ESCAPE, 0)
	await settle(0.10)
	check(not scene.online_waiting_for_server and scene.online_retry_available == false and scene.exit_confirm_panel == null and scene.mode == "online_game", "a second Esc cancels the online wait and keeps the table open")

	print("--- L) achievements use real wheel, touch, keyboard, and return focus ---")
	scene.show_menu(true)
	await settle(0.10)
	var achievements_entry := scene.find_child("MenuQuickAchievementsButton", true, false) as Button
	check(achievements_entry != null and not achievements_entry.disabled, "menu exposes the real achievements quick-entry button")
	if achievements_entry != null:
		var achievements_entry_center := achievements_entry.get_global_rect().get_center()
		await send_screen_touch(achievements_entry_center, true)
		await send_screen_touch(achievements_entry_center, false)
	await settle(0.65)
	var achievements_interaction_scroll := scene.find_child("AchievementsScroll", true, false) as ScrollContainer
	var achievements_interaction_bar := scene.find_child("AchievementsScrollBar", true, false) as VScrollBar
	var achievements_interaction_status := scene.find_child("AchievementsBrowseStatusLabel", true, false) as Label
	var achievements_interaction_hit_target := scene.find_child("AchievementsScrollHitTarget", true, false) as Control
	check(scene.mode == "achievements" and achievements_interaction_scroll != null and achievements_interaction_bar != null and achievements_interaction_status != null, "achievements opens through the menu entry with a native scroll view and range status")
	if achievements_interaction_scroll != null and achievements_interaction_bar != null and achievements_interaction_status != null:
		var achievements_interaction_range := maxf(0.0, achievements_interaction_bar.max_value - achievements_interaction_bar.page)
		check(achievements_interaction_range > 1.0, "achievements catalogue has reachable content beyond the first viewport")
		achievements_interaction_scroll.scroll_vertical = 0
		await send_wheel_down(achievements_interaction_scroll.get_global_rect().get_center())
		await send_wheel_down(achievements_interaction_scroll.get_global_rect().get_center())
		check(achievements_interaction_scroll.scroll_vertical > 0 and achievements_interaction_status.text.contains("浏览") and achievements_interaction_status.text.contains("余"), "mouse wheel advances the real achievements list and range status")
		var achievements_drag_start := achievements_interaction_scroll.get_global_rect().get_center() + Vector2(0.0, 24.0)
		var achievements_drag_end := achievements_drag_start - Vector2(0.0, 112.0)
		achievements_interaction_scroll.scroll_vertical = 0
		await send_screen_touch(achievements_drag_start, true)
		await send_screen_drag(achievements_drag_start, achievements_drag_end)
		await send_screen_touch(achievements_drag_end, false)
		await settle(0.05)
		if DisplayServer.is_touchscreen_available():
			check(achievements_interaction_scroll.scroll_vertical > 0, "single-finger drag advances the achievements list on a touchscreen")
		else:
			check(achievements_interaction_hit_target != null and achievements_interaction_hit_target.mouse_filter == Control.MOUSE_FILTER_STOP, "achievements keeps a native drag hit target for touchscreen verification")
		achievements_interaction_scroll.scroll_vertical = 0
		achievements_interaction_scroll.grab_focus()
		check(achievements_interaction_scroll.has_focus(), "achievements scroll receives keyboard focus before paging")
		await send_key(KEY_PAGEDOWN, 0)
		var achievements_page_value := float(achievements_interaction_bar.value)
		check(achievements_page_value > 0.0, "PageDown advances the achievements catalogue")
		await send_key(KEY_END, 0)
		var achievements_end_value := float(achievements_interaction_bar.value)
		check(achievements_end_value >= achievements_interaction_range - 1.0 and achievements_interaction_status.text.contains("余 0") and achievements_interaction_status.text.contains("已全部看完"), "End reaches the catalogue tail and reports all achievements viewed")
	await send_key(KEY_ESCAPE, 0)
	await settle(0.20)
	var restored_achievements_entry := scene.find_child("MenuQuickAchievementsButton", true, false) as Button
	check(scene.mode == "menu" and restored_achievements_entry != null and restored_achievements_entry.has_focus(), "returning from achievements restores focus to its source entry")

	print("--- M) rule chapters activate through mouse and touch and keep active state ---")
	var rules_interaction_entry := scene.find_child("MenuQuickRulesButton", true, false) as Button
	check(rules_interaction_entry != null and not rules_interaction_entry.disabled, "menu exposes the real rules quick-entry button")
	if rules_interaction_entry != null:
		var rules_interaction_entry_center := rules_interaction_entry.get_global_rect().get_center()
		await send_left_button(rules_interaction_entry_center, true)
		await send_left_button(rules_interaction_entry_center, false)
	await settle(0.65)
	var rules_interaction_scroll := scene.find_child("RulesContentScroll", true, false) as ScrollContainer
	var rules_interaction_bar := scene.find_child("RulesContentScrollBar", true, false) as VScrollBar
	var rules_interaction_status := scene.find_child("RulesReadingStatus", true, false) as Label
	check(scene.mode == "rules" and rules_interaction_scroll != null and rules_interaction_bar != null and rules_interaction_status != null, "rules opens through the menu entry with chapter status")
	if rules_interaction_scroll != null and rules_interaction_bar != null and rules_interaction_status != null:
		var rules_interaction_targets := [0, 2, 4, 5]
		for rules_interaction_index in range(rules_interaction_targets.size()):
			var rules_target_section := int(rules_interaction_targets[rules_interaction_index])
			var rules_target_button := scene.find_child("RulesGuideStepButton_%d" % rules_interaction_index, true, false) as Button
			check(rules_target_button != null and not rules_target_button.disabled, "rules exposes chapter target %d as a native button" % (rules_interaction_index + 1))
			if rules_target_button == null:
				continue
			var rules_target_center := rules_target_button.get_global_rect().get_center()
			if rules_interaction_index % 2 == 0:
				await send_left_button(rules_target_center, true)
				await send_left_button(rules_target_center, false)
			else:
				await send_screen_touch(rules_target_center, true)
				await send_screen_touch(rules_target_center, false)
			await settle(0.04)
			var rules_target_value := float(rules_interaction_bar.value)
			var rules_target_top := 0.0
			for rules_anchor in scene.rules_section_anchors(rules_interaction_scroll):
				if int(rules_anchor.get("index", -1)) == rules_target_section:
					rules_target_top = float(rules_anchor.get("top", 0.0))
					break
			var rules_target_expected := clampf(rules_target_top, 0.0, maxf(0.0, rules_interaction_bar.max_value - rules_interaction_bar.page))
			check(absf(rules_target_value - rules_target_expected) <= 1.5 and rules_interaction_status.text == "阅读 %d/6" % (rules_target_section + 1), "chapter button %d reaches section %d and updates reading status" % [rules_interaction_index, rules_target_section + 1])
			var rules_step := scene.find_child("RulesGuideStep_%d" % rules_interaction_index, true, false) as Control
			check(rules_step != null and bool(rules_step.get_meta("active", false)), "chapter button %d marks its guide step active" % (rules_interaction_index + 1))
	await send_key(KEY_ESCAPE, 0)
	await settle(0.20)
	var restored_rules_entry := scene.find_child("MenuQuickRulesButton", true, false) as Button
	check(scene.mode == "menu" and restored_rules_entry != null and restored_rules_entry.has_focus(), "returning from rules restores focus to its source entry")

	print("--- N) table actions use real hand, danger, and claim controls ---")
	scene.start_offline(true)
	await settle(0.10)
	scene.mode = "offline"
	scene.ai_assist_enabled = false
	scene.interactive_guide_active = false
	scene.interactive_guide_type = ""
	scene.offline_active_rule_variant = "yangzhou"
	scene.current_seat = 0
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_pending_claim.clear()
	scene.clear_pending_danger_discard()
	scene.players[0]["bot"] = false
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E", "S", "S", "S"]
	scene.render_game()
	await settle(0.08)
	var normal_discard_tile := scene.find_child("HandTile_00_1W", true, false) as Control
	var normal_discard_button := first_button_in(normal_discard_tile)
	var normal_hand_size := (scene.players[0]["hand"] as Array).size()
	check(normal_discard_tile != null and normal_discard_button != null and not normal_discard_button.disabled, "a legal hand tile exposes a native discard hit target")
	if normal_discard_button != null:
		var normal_discard_center := normal_discard_button.get_global_rect().get_center()
		await send_left_button(normal_discard_center, true)
		await send_left_button(normal_discard_center, false)
		await settle(0.04)
	check((scene.players[0]["hand"] as Array).size() == normal_hand_size - 1 and not (scene.players[0]["hand"] as Array).has("1W"), "mouse activation removes only the selected hand tile")

	var danger_report := {
		"tile": "S",
		"risk": 52.0,
		"feed_risk": 48.0,
		"risk_label": "高",
		"safety_label": "",
		"feed_text": "对家听口偏高",
		"danger_source": {"reason": "牌路危险", "seat": 2},
	}
	scene.ai_assist_enabled = true
	scene.current_seat = 0
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_pending_claim.clear()
	scene.clear_pending_danger_discard()
	scene.current_human_advice = [danger_report]
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "5T", "6T", "7T", "E", "E", "P", "P", "S"]
	scene.render_game()
	await settle(0.08)
	# render_game() may finish an asynchronous AI refresh after the fixture is
	# rendered. Re-apply the deterministic advice once that refresh has settled.
	scene.current_human_advice = [danger_report]
	var danger_tile_node := scene.find_child("HandTile_12_S", true, false) as Control
	var danger_tile_button := first_button_in(danger_tile_node)
	var danger_hand_size := (scene.players[0]["hand"] as Array).size()
	check(danger_tile_button != null and not danger_tile_button.disabled, "high-risk hand tile remains a real input target before confirmation")
	if danger_tile_button != null:
		var danger_tile_center := danger_tile_button.get_global_rect().get_center()
		await send_left_button(danger_tile_center, true)
		await send_left_button(danger_tile_center, false)
		await settle(0.04)
	check(scene.has_pending_danger_discard() and (scene.players[0]["hand"] as Array).size() == danger_hand_size and scene.find_child("DangerDiscardConfirmButton", true, false) != null, "touching a dangerous discard opens confirmation without changing the hand")
	var danger_cancel_button := first_button_with_text(scene, "取消")
	if danger_cancel_button != null:
		var danger_cancel_center := danger_cancel_button.get_global_rect().get_center()
		await send_screen_touch(danger_cancel_center, true)
		await send_screen_touch(danger_cancel_center, false)
		await settle(0.04)
	check(not scene.has_pending_danger_discard() and (scene.players[0]["hand"] as Array).size() == danger_hand_size, "touch activation of danger cancel preserves the hand and clears confirmation")
	scene.offline_phase = "await_discard"
	scene.clear_pending_danger_discard()
	scene.current_human_advice = [danger_report]
	scene.render_game()
	await settle(0.05)
	scene.current_human_advice = [danger_report]
	danger_tile_node = scene.find_child("HandTile_12_S", true, false) as Control
	danger_tile_button = first_button_in(danger_tile_node)
	if danger_tile_button != null:
		var danger_repeat_center := danger_tile_button.get_global_rect().get_center()
		await send_left_button(danger_repeat_center, true)
		await send_left_button(danger_repeat_center, false)
		await settle(0.04)
	var danger_confirm_button := scene.find_child("DangerDiscardConfirmButton", true, false) as Button
	check(danger_confirm_button != null, "danger flow exposes the explicit confirmation action")
	if danger_confirm_button != null:
		var danger_confirm_center := danger_confirm_button.get_global_rect().get_center()
		await send_left_button(danger_confirm_center, true)
		await send_left_button(danger_confirm_center, false)
		await settle(0.04)
	check(not scene.has_pending_danger_discard() and not (scene.players[0]["hand"] as Array).has("S") and str(scene.last_discard) == "S", "mouse confirmation commits exactly one dangerous discard")

	var claim_interaction_names := ["chi", "peng", "gang", "hu"]
	for claim_interaction_index in range(claim_interaction_names.size()):
		var claim_interaction_name := str(claim_interaction_names[claim_interaction_index])
		set_offline_pending_claim_fixture(scene, claim_interaction_name)
		await settle(0.05)
		var claim_interaction_grid := scene.find_child("PendingClaimResponseGrid", true, false) as Control
		var claim_interaction_button := first_button_with_text_prefix(claim_interaction_grid, "吃") if claim_interaction_name == "chi" else first_button_with_text(claim_interaction_grid, scene.claim_label(claim_interaction_name))
		check(claim_interaction_button != null and not claim_interaction_button.disabled, "pending claim exposes a real %s response button" % claim_interaction_name)
		if claim_interaction_button != null:
			var claim_interaction_center := claim_interaction_button.get_global_rect().get_center()
			if claim_interaction_index % 2 == 0:
				await send_left_button(claim_interaction_center, true)
				await send_left_button(claim_interaction_center, false)
			else:
				await send_screen_touch(claim_interaction_center, true)
				await send_screen_touch(claim_interaction_center, false)
			await settle(0.05)
		if claim_interaction_name == "hu":
			check(scene.offline_phase == "ended" and scene.offline_pending_claim.is_empty(), "胡 response commits the pending win through the real action button")
		else:
			check(scene.offline_pending_claim.is_empty() and (scene.players[0]["melds"] as Array).size() == 1, "%s response commits one real meld and closes the response window" % claim_interaction_name)

	print("--- O) chat input handles empty, bounded, mouse, touch, and Enter sends ---")
	var chat_interaction_transport := ConnectedLobbyTransport.new()
	scene.tcp = chat_interaction_transport
	scene.tcp_status = StreamPeerTCP.STATUS_CONNECTED
	scene.mode = "online_lobby"
	scene.online_room = connected_room_fixture()
	scene.online_feedback = ""
	scene.online_waiting_for_server = false
	scene.online_last_chat_sent_msec = 0
	scene.chat_messages = ["甲: 初始消息"]
	scene.chat_panel_open = false
	scene._show_online_lobby_impl()
	await settle(0.12)
	scene.show_chat_panel()
	await settle(0.08)
	var chat_interaction_input := scene.find_child("ChatInput", true, false) as LineEdit
	var chat_interaction_send := scene.find_child("ChatSendButton", true, false) as Button
	var chat_interaction_text := scene.find_child("ChatPanelMessageText", true, false) as Label
	var chat_initial_count: int = scene.chat_messages.size()
	check(chat_interaction_input != null and chat_interaction_send != null and chat_interaction_input.has_focus(), "chat panel opens with its real input focused")
	if chat_interaction_input != null:
		chat_interaction_input.grab_focus()
		chat_interaction_input.text = ""
		chat_interaction_transport.writes.clear()
		scene.online_last_chat_sent_msec = 0
		await send_key(KEY_ENTER, 0)
		check(chat_interaction_transport.writes.is_empty() and scene.chat_messages.size() == chat_initial_count and chat_interaction_input.text == "", "empty chat submission is rejected without appending a message")
		chat_interaction_input.text = "鼠标消息"
		scene.online_last_chat_sent_msec = 0
		var chat_mouse_send_center := chat_interaction_send.get_global_rect().get_center()
		await send_left_button(chat_mouse_send_center, true)
		await send_left_button(chat_mouse_send_center, false)
		await settle(0.04)
		check(chat_interaction_transport.writes.size() == 1 and chat_interaction_transport.writes[0].contains("鼠标消息") and scene.chat_messages.back() == "你: 鼠标消息" and scene.find_child("ChatInput", true, false) is LineEdit and (scene.find_child("ChatInput", true, false) as LineEdit).text == "", "mouse send appends once, writes the transport message, and clears the input")
		chat_interaction_input = scene.find_child("ChatInput", true, false) as LineEdit
		chat_interaction_send = scene.find_child("ChatSendButton", true, false) as Button
		chat_interaction_input.text = "触控消息"
		scene.online_waiting_for_server = false
		scene.online_last_chat_sent_msec = 0
		var chat_touch_send_center := chat_interaction_send.get_global_rect().get_center()
		await send_screen_touch(chat_touch_send_center, true)
		await send_screen_touch(chat_touch_send_center, false)
		await settle(0.04)
		check(chat_interaction_transport.writes.size() == 2 and scene.chat_messages.back() == "你: 触控消息", "single-finger send appends the next chat message")
		chat_interaction_input = scene.find_child("ChatInput", true, false) as LineEdit
		chat_interaction_input.text = "回车消息"
		chat_interaction_input.grab_focus()
		scene.online_waiting_for_server = false
		scene.online_last_chat_sent_msec = 0
		await send_key(KEY_ENTER, 0)
		await settle(0.04)
		check(chat_interaction_transport.writes.size() == 3 and scene.chat_messages.back() == "你: 回车消息", "Enter sends the focused chat input through the same production path")
		chat_interaction_input = scene.find_child("ChatInput", true, false) as LineEdit
		chat_interaction_input.text = "长".repeat(scene.CHAT_MESSAGE_MAX_LENGTH + 20)
		check(chat_interaction_input.text.length() == scene.CHAT_MESSAGE_MAX_LENGTH, "chat input enforces the native message length boundary")
		if chat_interaction_text != null:
			check(chat_interaction_text.tooltip_text.contains("初始消息") and chat_interaction_text.tooltip_text.contains("鼠标消息") and chat_interaction_text.tooltip_text.contains("回车消息"), "chat panel retains the complete appended message history in its tooltip")
	scene.close_chat_panel()
	await settle(0.05)

	print("--- P) replay archive actions are real, reversible, and confirmed ---")
	var replay_archive_saved_fixture: Array = scene.replay_archive.duplicate(true)
	var replay_archive_first_events := valid_replay_events(scene, "UI-SMOKE-ARCHIVE-A")
	var replay_archive_second_events := valid_replay_events(scene, "UI-SMOKE-ARCHIVE-B")
	var replay_archive_fixture_entries: Array = []
	for replay_fixture_data in [["UI-SMOKE-ARCHIVE-A", replay_archive_first_events, "win", "交互归档甲", 180], ["UI-SMOKE-ARCHIVE-B", replay_archive_second_events, "wall_draw", "交互归档乙", 181]]:
		var replay_fixture_events: Array = replay_fixture_data[1] as Array
		var replay_fixture_entry := {
			"round_id": str(replay_fixture_data[0]),
			"rule_variant": "yangzhou",
			"result_kind": str(replay_fixture_data[2]),
			"summary": str(replay_fixture_data[3]),
			"seed": int(replay_fixture_data[4]),
			"events": replay_fixture_events,
			"replay_digest": scene.round_replay_digest(replay_fixture_events),
			"saved_at": int(replay_fixture_data[4]),
			"archived_at": int(replay_fixture_data[4]),
			"favorite": false,
			"source": "local",
		}
		replay_archive_fixture_entries.append(scene.normalize_replay_archive_entry(replay_fixture_entry))
	scene.replay_archive = replay_archive_fixture_entries
	scene.replay_search_query = ""
	scene.replay_delete_confirming = false
	scene.replay_delete_target_id = ""
	scene.show_replay_import_screen(true)
	await settle(0.10)
	var replay_archive_rows := scene.find_child("ReplayArchiveList", true, false) as Control
	var replay_archive_entry_a := replay_archive_fixture_entries[0] as Dictionary
	var replay_archive_id_a := str(replay_archive_entry_a.get("archive_id", ""))
	var replay_archive_node_key := replay_archive_id_a.left(12).replace(":", "_")
	var replay_archive_button_key := replay_archive_id_a.left(8).replace(":", "_")
	var replay_archive_row_a := scene.find_child("ReplayArchiveRow_%s" % replay_archive_node_key, true, false) as Control
	var replay_archive_buttons := buttons_in(replay_archive_row_a)
	var replay_archive_favorite := replay_archive_row_a.find_child("ReplayArchiveFavoriteButton_%s" % replay_archive_button_key, true, false) as Button if replay_archive_row_a != null else null
	var replay_archive_open := replay_archive_row_a.find_child("ReplayArchiveOpenButton_%s" % replay_archive_button_key, true, false) as Button if replay_archive_row_a != null else null
	var replay_archive_copy := replay_archive_row_a.find_child("ReplayArchiveCopyButton_%s" % replay_archive_button_key, true, false) as Button if replay_archive_row_a != null else null
	var replay_archive_delete := replay_archive_row_a.find_child("ReplayArchiveDeleteButton_%s" % replay_archive_button_key, true, false) as Button if replay_archive_row_a != null else null
	check(replay_archive_rows != null and replay_archive_row_a != null and replay_archive_buttons.size() == 4 and replay_archive_favorite != null and replay_archive_open != null and replay_archive_copy != null and replay_archive_delete != null, "replay archive renders four real action targets for the fixture row (entries=%d id=%s rows=%s)" % [scene.replay_archive.size(), replay_archive_id_a, replay_archive_rows != null])
	var replay_archive_scroll := scene.find_child("ReplayArchiveScroll", true, false) as ScrollContainer
	if replay_archive_scroll != null:
		var replay_archive_scrollbar := replay_archive_scroll.get_v_scroll_bar()
		if replay_archive_scrollbar != null and replay_archive_scrollbar.max_value > replay_archive_scrollbar.page:
			replay_archive_scroll.scroll_vertical = int(ceil(replay_archive_scrollbar.max_value))
			await settle(0.04)
	check(replay_archive_scroll != null and replay_archive_favorite != null and replay_archive_scroll.get_global_rect().encloses(replay_archive_favorite.get_global_rect()), "archive scroll reveals the target action lane before action testing")
	if replay_archive_favorite != null:
		var replay_archive_favorite_probe := {"gui": 0, "down": 0}
		replay_archive_favorite.gui_input.connect(func(event: InputEvent) -> void:
			if event is InputEventMouseButton or event is InputEventScreenTouch:
				replay_archive_favorite_probe["gui"] = int(replay_archive_favorite_probe.get("gui", 0)) + 1
		)
		replay_archive_favorite.button_down.connect(func() -> void:
			replay_archive_favorite_probe["down"] = int(replay_archive_favorite_probe.get("down", 0)) + 1
		)
		var replay_archive_favorite_mouse_center := replay_archive_favorite.get_global_rect().get_center()
		await move_pointer(replay_archive_favorite_mouse_center, 0.04)
		await send_left_button(replay_archive_favorite_mouse_center, true)
		await send_left_button(replay_archive_favorite_mouse_center, false)
		await settle(0.04)
		check(bool(scene.replay_archive_entry(replay_archive_id_a).get("favorite", false)), "mouse activation adds the archive to favorites")
		replay_archive_row_a = scene.find_child("ReplayArchiveRow_%s" % replay_archive_node_key, true, false) as Control
		replay_archive_buttons = buttons_in(replay_archive_row_a)
		replay_archive_favorite = replay_archive_row_a.find_child("ReplayArchiveFavoriteButton_%s" % replay_archive_button_key, true, false) as Button if replay_archive_row_a != null else null
		replay_archive_open = replay_archive_row_a.find_child("ReplayArchiveOpenButton_%s" % replay_archive_button_key, true, false) as Button if replay_archive_row_a != null else null
		replay_archive_copy = replay_archive_row_a.find_child("ReplayArchiveCopyButton_%s" % replay_archive_button_key, true, false) as Button if replay_archive_row_a != null else null
		replay_archive_delete = replay_archive_row_a.find_child("ReplayArchiveDeleteButton_%s" % replay_archive_button_key, true, false) as Button if replay_archive_row_a != null else null
		check(replay_archive_row_a != null and replay_archive_buttons.size() == 4 and replay_archive_favorite != null and replay_archive_open != null and replay_archive_copy != null and replay_archive_delete != null, "archive refresh preserves all four action targets")
		if replay_archive_scroll != null:
			var replay_archive_scrollbar_after_favorite := replay_archive_scroll.get_v_scroll_bar()
			if replay_archive_scrollbar_after_favorite != null and replay_archive_scrollbar_after_favorite.max_value > replay_archive_scrollbar_after_favorite.page:
				replay_archive_scroll.scroll_vertical = int(ceil(replay_archive_scrollbar_after_favorite.max_value))
				await settle(0.04)
		if replay_archive_favorite != null:
			var replay_archive_favorite_touch_center := replay_archive_favorite.get_global_rect().get_center()
			await send_screen_touch(replay_archive_favorite_touch_center, true)
			await send_screen_touch(replay_archive_favorite_touch_center, false)
			await settle(0.04)
		check(not bool(scene.replay_archive_entry(replay_archive_id_a).get("favorite", false)), "single-finger activation reverses the archive favorite state")
		replay_archive_row_a = scene.find_child("ReplayArchiveRow_%s" % replay_archive_node_key, true, false) as Control
		replay_archive_buttons = buttons_in(replay_archive_row_a)
		replay_archive_favorite = replay_archive_row_a.find_child("ReplayArchiveFavoriteButton_%s" % replay_archive_button_key, true, false) as Button if replay_archive_row_a != null else null
		replay_archive_open = replay_archive_row_a.find_child("ReplayArchiveOpenButton_%s" % replay_archive_button_key, true, false) as Button if replay_archive_row_a != null else null
		replay_archive_copy = replay_archive_row_a.find_child("ReplayArchiveCopyButton_%s" % replay_archive_button_key, true, false) as Button if replay_archive_row_a != null else null
		replay_archive_delete = replay_archive_row_a.find_child("ReplayArchiveDeleteButton_%s" % replay_archive_button_key, true, false) as Button if replay_archive_row_a != null else null
		check(replay_archive_row_a != null and replay_archive_buttons.size() == 4 and replay_archive_favorite != null and replay_archive_open != null and replay_archive_copy != null and replay_archive_delete != null, "touch refresh preserves all four archive action targets")
		if replay_archive_scroll != null:
			var replay_archive_scrollbar_after_touch := replay_archive_scroll.get_v_scroll_bar()
			if replay_archive_scrollbar_after_touch != null and replay_archive_scrollbar_after_touch.max_value > replay_archive_scrollbar_after_touch.page:
				replay_archive_scroll.scroll_vertical = int(ceil(replay_archive_scrollbar_after_touch.max_value))
				await settle(0.04)
	if replay_archive_open != null:
		var replay_archive_open_probe := {"gui": 0, "down": 0}
		replay_archive_open.gui_input.connect(func(event: InputEvent) -> void:
			if event is InputEventScreenTouch:
				replay_archive_open_probe["gui"] = int(replay_archive_open_probe.get("gui", 0)) + 1
		)
		replay_archive_open.button_down.connect(func() -> void:
			replay_archive_open_probe["down"] = int(replay_archive_open_probe.get("down", 0)) + 1
		)
		await send_screen_touch(replay_archive_open.get_global_rect().get_center(), true)
		await send_screen_touch(replay_archive_open.get_global_rect().get_center(), false)
		await settle(0.04)
		var replay_archive_open_input := scene.find_child("ReplayImportCodeInput", true, false) as LineEdit
		var replay_archive_open_status := scene.find_child("ReplayImportStatus", true, false) as Label
		check(replay_archive_open_input != null and replay_archive_open_input.text == scene.replay_archive_share_code(replay_archive_id_a) and replay_archive_open_status != null and replay_archive_open_status.text.contains("归档已打开") and scene.replay_import_payload.size() > 0, "single-finger archive view loads and verifies the selected replay")
	if replay_archive_copy != null:
		replay_archive_copy.grab_focus()
		await send_key(KEY_ENTER, 0)
		await settle(0.04)
		check(DisplayServer.clipboard_get() == scene.replay_archive_share_code(replay_archive_id_a) and scene.toast_current != null and has_label_text(scene.toast_current, "已复制归档回放码"), "keyboard activation copies the complete archive replay code and shows feedback")
	var replay_archive_count_before_delete: int = scene.replay_archive.size()
	if replay_archive_delete != null:
		var replay_archive_delete_mouse_center := replay_archive_delete.get_global_rect().get_center()
		await move_pointer(replay_archive_delete_mouse_center, 0.04)
		await send_left_button(replay_archive_delete_mouse_center, true)
		await send_left_button(replay_archive_delete_mouse_center, false)
		await settle(0.04)
		check(scene.replay_archive.size() == replay_archive_count_before_delete and scene.replay_delete_confirming and scene.replay_delete_target_id == replay_archive_id_a, "first archive delete activation only arms the confirmation")
		replay_archive_row_a = scene.find_child("ReplayArchiveRow_%s" % replay_archive_node_key, true, false) as Control
		replay_archive_buttons = buttons_in(replay_archive_row_a)
		replay_archive_delete = replay_archive_row_a.find_child("ReplayArchiveDeleteButton_%s" % replay_archive_button_key, true, false) as Button if replay_archive_row_a != null else null
		check(replay_archive_row_a != null and replay_archive_buttons.size() == 4 and replay_archive_delete != null, "delete confirmation refresh preserves the target action")
		if replay_archive_scroll != null:
			var replay_archive_scrollbar_after_delete := replay_archive_scroll.get_v_scroll_bar()
			if replay_archive_scrollbar_after_delete != null and replay_archive_scrollbar_after_delete.max_value > replay_archive_scrollbar_after_delete.page:
				replay_archive_scroll.scroll_vertical = int(ceil(replay_archive_scrollbar_after_delete.max_value))
				await settle(0.04)
		if replay_archive_delete != null:
			var replay_archive_delete_touch_center := replay_archive_delete.get_global_rect().get_center()
			await send_screen_touch(replay_archive_delete_touch_center, true)
			await send_screen_touch(replay_archive_delete_touch_center, false)
			await settle(0.04)
		check(scene.replay_archive.size() == replay_archive_count_before_delete - 1 and scene.replay_archive_entry(replay_archive_id_a).is_empty() and not scene.replay_delete_confirming, "second single-finger delete activation removes only the confirmed archive")
	scene.replay_archive = replay_archive_saved_fixture
	scene.replay_delete_confirming = false
	scene.replay_delete_target_id = ""
	scene.save_replay_archive()

	print("--- Q) menu cards, quick entries, and settings use real input with focus recovery ---")
	scene.show_menu(true)
	await settle(0.10)
	var menu_interaction_card_names := ["MenuPrimaryOfflineCard", "MenuPrimaryOnlineCard", "MenuPrimaryShopCard"]
	for menu_interaction_index in range(menu_interaction_card_names.size()):
		var menu_interaction_card := scene.find_child(str(menu_interaction_card_names[menu_interaction_index]), true, false) as Button
		check(menu_interaction_card != null and not menu_interaction_card.disabled, "menu exposes primary card %d as a native button" % (menu_interaction_index + 1))
		if menu_interaction_card == null:
			continue
		var menu_interaction_card_center := menu_interaction_card.get_global_rect().get_center()
		if menu_interaction_index == 1:
			await send_screen_touch(menu_interaction_card_center, true)
			await send_screen_touch(menu_interaction_card_center, false)
		else:
			await send_left_button(menu_interaction_card_center, true)
			await send_left_button(menu_interaction_card_center, false)
		await settle(0.30)
		var menu_card_expected_mode := "offline" if menu_interaction_index == 0 else ("online_lobby" if menu_interaction_index == 1 else "shop")
		check(scene.mode == menu_card_expected_mode, "primary card %d opens its production destination" % (menu_interaction_index + 1))
		if menu_interaction_index == 0:
			# The production entry starts an AI coroutine. Freeze this fixture at a
			# clean, ended table state before exercising page-exit routing so a
			# background decision cannot own Esc.
			scene.offline_pending_claim.clear()
			scene.offline_pending_claim_deadline_msec = 0
			scene.clear_pending_danger_discard()
			scene.offline_phase = "ended"
			scene.offline_turn_needs_draw = false
			scene.render_game()
			await settle(0.08)
			await send_key(KEY_ESCAPE, 0)
			await settle(0.05)
			var menu_card_leave_button := first_button_with_text(scene.exit_confirm_panel, "退出游戏")
			if menu_card_leave_button != null:
				var menu_card_leave_center := menu_card_leave_button.get_global_rect().get_center()
				await send_screen_touch(menu_card_leave_center, true)
				await send_screen_touch(menu_card_leave_center, false)
		else:
			await send_key(KEY_ESCAPE, 0)
		await settle(0.50)
		var menu_card_restored := scene.find_child(str(menu_interaction_card_names[menu_interaction_index]), true, false) as Button
		check(scene.mode == "menu" and menu_card_restored != null and menu_card_restored.has_focus(), "returning from primary card %d restores its focus" % (menu_interaction_index + 1))
	var menu_interaction_quick_ids := ["stats", "replay"]
	for menu_quick_interaction_index in range(menu_interaction_quick_ids.size()):
		var menu_quick_interaction_id := str(menu_interaction_quick_ids[menu_quick_interaction_index])
		var menu_quick_interaction_button := scene.find_child("MenuQuick%sButton" % menu_quick_interaction_id.capitalize(), true, false) as Button
		check(menu_quick_interaction_button != null and not menu_quick_interaction_button.disabled, "menu exposes quick entry %s as a native button" % menu_quick_interaction_id)
		if menu_quick_interaction_button == null:
			continue
		var menu_quick_interaction_center := menu_quick_interaction_button.get_global_rect().get_center()
		await send_screen_touch(menu_quick_interaction_center, true)
		await send_screen_touch(menu_quick_interaction_center, false)
		await settle(0.45)
		check(scene.mode == ("stats" if menu_quick_interaction_id == "stats" else "replay_import"), "quick entry %s opens its production destination" % menu_quick_interaction_id)
		await send_key(KEY_ESCAPE, 0)
		await settle(0.20)
		var menu_quick_restored := scene.find_child("MenuQuick%sButton" % menu_quick_interaction_id.capitalize(), true, false) as Button
		check(scene.mode == "menu" and menu_quick_restored != null and menu_quick_restored.has_focus(), "returning from quick entry %s restores its focus" % menu_quick_interaction_id)
	var menu_settings_interaction := scene.find_child("MenuSettingsButton", true, false) as Button
	check(menu_settings_interaction != null and not menu_settings_interaction.disabled, "menu settings is a real native input target")
	if menu_settings_interaction != null:
		var menu_settings_interaction_center := menu_settings_interaction.get_global_rect().get_center()
		await send_screen_touch(menu_settings_interaction_center, true)
		await send_screen_touch(menu_settings_interaction_center, false)
		await settle(0.10)
		var menu_settings_interaction_close := scene.find_child("SettingsCloseButton", true, false) as Button
		check(scene.settings_panel_open and menu_settings_interaction_close != null and menu_settings_interaction_close.has_focus(), "touch activation opens settings and transfers focus to the modal")
		await send_key(KEY_ESCAPE, 0)
		await settle(0.20)
		var menu_settings_interaction_restored := scene.find_child("MenuSettingsButton", true, false) as Button
		check(not scene.settings_panel_open and menu_settings_interaction_restored != null and menu_settings_interaction_restored.has_focus(), "closing touch-opened settings restores the source focus")

	# Stop any AI coroutine started by the real discard path before freeing the
	# scene. Its active delay must finish while the owner is still alive.
	scene.mode = "shutdown"
	scene.offline_phase = "ended"
	await settle(0.50)
	if scene.has_method("shutdown_runtime"):
		scene.shutdown_runtime()
	# Let shutdown-emitted runtime timers resume their callers before freeing the
	# scene. Godot 4.6 reports a leaked function state otherwise.
	await settle(0.10)
	scene.queue_free()
	await settle(0.05)
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
