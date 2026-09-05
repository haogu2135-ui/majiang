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
	# Production screen/modal tweens run for 0.2-0.5s. Preserve the explicit
	# settle budget for those calls so focus and visibility assertions observe
	# the completed route; shorter calls only need a frame for synchronous work.
	var settle_seconds := seconds if seconds >= 0.15 else 0.0
	await process_frame
	if settle_seconds > 0.0:
		await create_timer(settle_seconds).timeout
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


func has_toast_text(scene: Node, expected: String) -> bool:
	if scene == null:
		return false
	if scene.toast_current != null and is_instance_valid(scene.toast_current) and has_label_text(scene.toast_current, expected):
		return true
	for queued in scene.toast_queue:
		if typeof(queued) == TYPE_DICTIONARY and str((queued as Dictionary).get("text", "")) == expected:
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
		"selected_room", "online_connection_host", "online_player_name", "online_room", "online_game", "online_log_seen_count", "online_log_total_count", "online_feedback", "online_waiting_for_server", "online_last_sent_action", "online_last_sent_type", "online_last_sent_msec", "online_last_sent_payload", "online_slow_notice_shown", "online_retry_available", "online_action_sequence", "online_session_id", "online_room_revision", "online_game_revision", "online_resume_context", "online_resume_pending", "online_resume_join_sent", "online_seen_message_ids", "online_seen_voice_sequences", "online_last_chat_sent_msec", "online_last_receive_msec", "online_last_heartbeat_msec", "online_reconnect_attempts", "online_next_reconnect_msec", "online_last_malformed_notice_msec", "online_messages_received", "online_messages_rejected", "online_last_snapshot_fingerprint", "online_last_room_snapshot_fingerprint", "online_players_by_seat", "online_player_index_token", "online_announced_discard_key", "online_pending_local_discard_identity", "sent_hello", "chat_messages", "chat_panel_open", "table_log_chat_restore_pending", "table_log_chat_draft", "safe_area_test_margins_override"
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


func run_extended_ui_contracts(scene: Node) -> void:
	print("--- extended UI contracts: lobby, online table, persistence, and completion flows ---")

	print("--- F-191/F-192/F-193) lobby availability, start gate, and input modalities ---")
	var lobby_transport := ConnectedLobbyTransport.new()
	scene.mode = "online_lobby"
	scene.tcp = lobby_transport
	scene.selected_room = ""
	scene.online_room.clear()
	scene.online_feedback = ""
	scene.online_waiting_for_server = false
	scene._show_online_lobby_impl()
	await settle(0.10)
	var lobby_chat_button := scene.find_child("ChatLobbyButton", true, false) as Button
	var lobby_chat_probe := {"pressed": 0}
	if lobby_chat_button != null:
		lobby_chat_button.pressed.connect(func() -> void:
			lobby_chat_probe["pressed"] = int(lobby_chat_probe.get("pressed", 0)) + 1
		)
	check(lobby_chat_button != null and lobby_chat_button.disabled and lobby_chat_button.tooltip_text.contains("进入房间"), "unconnected lobby disables chat until a room context exists")
	if lobby_chat_button != null:
		await send_left_button(lobby_chat_button.get_global_rect().get_center(), true)
		await send_left_button(lobby_chat_button.get_global_rect().get_center(), false)
		check(int(lobby_chat_probe.get("pressed", 0)) == 0 and not scene.chat_panel_open, "disabled lobby chat does not open the panel or emit an action")

	var gate_rooms := [
		[{"code": "GATE3", "players": [{"seat": 0, "name": "甲", "ready": true}, {"seat": 1, "name": "乙", "ready": true}, {"seat": 2, "name": "丙", "ready": true}], "hostSeat": 0, "youSeat": 0}, "等满员", false],
		[{"code": "GATE4", "players": [{"seat": 0, "name": "甲", "ready": true}, {"seat": 1, "name": "乙", "ready": true}, {"seat": 2, "name": "丙", "ready": true}, {"seat": 3, "name": "丁", "ready": false}], "hostSeat": 0, "youSeat": 0}, "等准备", false],
		[{"code": "GATE5", "players": [{"seat": 0, "name": "甲", "ready": true}, {"seat": 1, "name": "乙", "ready": true}, {"seat": 2, "name": "丙", "ready": true}, {"seat": 3, "name": "丁", "ready": true}], "hostSeat": 0, "youSeat": 0}, "开始游戏", true],
	]
	for gate_case in gate_rooms:
		var gate_room: Dictionary = gate_case[0] as Dictionary
		scene.online_room = gate_room.duplicate(true)
		scene.selected_room = str(gate_room.get("code", ""))
		scene.online_waiting_for_server = false
		scene.online_feedback = ""
		scene.refresh_online_lobby_state()
		await settle(0.03)
		var gate_button := scene.find_child("OnlineLobbyPrimaryStartButton", true, false) as Button
		var expected_gate_text := str(gate_case[1])
		var expected_gate_enabled := bool(gate_case[2])
		check(gate_button != null and gate_button.text == expected_gate_text and gate_button.disabled == not expected_gate_enabled and gate_button.tooltip_text != "", "start gate explains %s state in the primary action" % expected_gate_text)

	var start_button := scene.find_child("OnlineLobbyPrimaryStartButton", true, false) as Button
	if start_button != null:
		for modality in ["mouse", "touch", "key"]:
			lobby_transport.writes.clear()
			scene.online_waiting_for_server = false
			scene.online_last_sent_msec = 0
			scene.online_feedback = ""
			scene.online_last_sent_payload.clear()
			scene.online_last_sent_action = ""
			scene.online_last_sent_type = ""
			scene.online_room["canStart"] = true
			scene.refresh_online_lobby_state()
			await settle(0.03)
			start_button = scene.find_child("OnlineLobbyPrimaryStartButton", true, false) as Button
			await activate_button(start_button, modality)
			var start_payload = JSON.parse_string(lobby_transport.writes[0]) if lobby_transport.writes.size() == 1 else null
			check(lobby_transport.writes.size() == 1 and typeof(start_payload) == TYPE_DICTIONARY and start_payload.get("type", "") == "startGame" and scene.online_waiting_for_server and start_button.disabled, "startGame sends once through %s input and enters server-wait state" % modality)

	print("--- F-194/F-196) disconnect, reconnect, welcome, roomState, and gameState recovery ---")
	var recovery_transport := ConnectedLobbyTransport.new()
	scene.tcp = recovery_transport
	scene.mode = "online_game"
	scene.online_connection_host = "qa.lobby.internal"
	scene.online_player_name = "恢复玩家"
	scene.selected_room = "RECOVER7"
	scene.online_room = {"code": "RECOVER7", "players": [{"seat": 0, "name": "恢复玩家", "ready": true}], "logs": ["已入房"]}
	scene.online_game = online_pending_game_fixture()
	scene.online_game["roomCode"] = "RECOVER7"
	scene.online_game["phase"] = "awaitDiscard"
	scene.online_game["pending"] = {}
	scene.online_feedback = ""
	scene.online_waiting_for_server = false
	scene.online_resume_pending = false
	scene.online_resume_join_sent = false
	scene.render_game()
	await settle(0.08)
	scene.close_online_transport("连接已断开，请重新连接。", false, true)
	await settle(0.08)
	var disconnected_reconnect := scene.find_child("OnlineReconnectGameButton", true, false) as Button
	check(scene.online_game_disconnected() and disconnected_reconnect != null and not disconnected_reconnect.disabled, "disconnected online table keeps the board and exposes reconnect")
	var disconnected_hand_tile := scene.find_child("HandTile_00_1W", true, false) as Control
	var disconnected_hand_button := first_button_in(disconnected_hand_tile)
	var recovery_write_count := recovery_transport.writes.size()
	if disconnected_hand_button != null:
		await send_left_button(disconnected_hand_button.get_global_rect().get_center(), true)
		await send_left_button(disconnected_hand_button.get_global_rect().get_center(), false)
	check(disconnected_hand_button == null or disconnected_hand_button.disabled or recovery_transport.writes.size() == recovery_write_count, "disconnected hand input cannot write an online discard")

	scene.tcp = recovery_transport
	scene.online_next_reconnect_msec = 0
	scene.online_reconnect_attempts = 0
	scene.reconnect_online_game()
	check(scene.online_resume_pending and scene.online_resume_context.get("room", "") == "RECOVER7", "reconnect records the original room context before dialing")
	scene.tcp = recovery_transport
	scene.handle_online_message(JSON.stringify({"type": "welcome", "sessionId": scene.online_session_id, "name": "QA服务器"}))
	await settle(0.05)
	var resume_join_payload = JSON.parse_string(recovery_transport.writes.back()) if not recovery_transport.writes.is_empty() else null
	check(typeof(resume_join_payload) == TYPE_DICTIONARY and resume_join_payload.get("type", "") == "joinRoom" and resume_join_payload.get("roomCode", "") == "RECOVER7", "welcome resumes the saved room with one join request")
	var recovery_room_message := {"type": "roomState", "sessionId": scene.online_session_id, "revision": 4, "room": {"roomCode": "RECOVER7", "players": [{"seat": 0, "nickname": "恢复玩家", "isReady": true}, {"seat": 1, "nickname": "乙", "isReady": true}], "logs": ["恢复成功"]}}
	scene.handle_online_message(JSON.stringify(recovery_room_message))
	await settle(0.04)
	check(scene.selected_room == "RECOVER7" and scene.online_room.get("players", []).size() == 2 and not scene.online_resume_pending, "roomState restores the room roster and clears the resume gate")
	var recovery_game := online_pending_game_fixture()
	recovery_game["roomCode"] = "RECOVER7"
	recovery_game["phase"] = "awaitDiscard"
	recovery_game["pending"] = {}
	recovery_game["revision"] = 5
	scene.handle_online_message(JSON.stringify({"type": "gameState", "sessionId": scene.online_session_id, "revision": 5, "game": recovery_game}))
	await settle(0.08)
	check(scene.mode == "online_game" and scene.online_game.get("phase", "") == "awaitDiscard" and scene.find_child("HandTray", true, false) != null, "reconnected gameState restores the playable board")
	scene.online_resume_pending = true
	scene.online_resume_join_sent = true
	scene.online_last_sent_type = "joinRoom"
	scene.online_last_sent_payload = {"requestId": "resume-failure"}
	scene.handle_online_message(JSON.stringify({"type": "error", "sessionId": scene.online_session_id, "requestId": "resume-failure", "message": "房间不存在"}))
	check(not scene.online_resume_pending and scene.online_feedback.contains("服务器拒绝"), "failed resume clears the pending flag and exposes retry feedback")

	print("--- F-195/F-197) online response buttons, payloads, duplicate guard, and modal wait ---")
	var online_claim_names := ["chi", "peng", "gang", "hu"]
	for claim_index in range(online_claim_names.size()):
		var online_claim_name := str(online_claim_names[claim_index])
		var online_claim_fixture := online_pending_game_fixture()
		scene.mode = "online_game"
		scene.online_game = online_claim_fixture
		scene.online_feedback = ""
		scene.online_waiting_for_server = false
		scene.online_last_sent_payload.clear()
		scene.online_last_sent_action = ""
		scene.online_last_sent_type = ""
		recovery_transport.writes.clear()
		scene.tcp = recovery_transport
		scene.render_game()
		await settle(0.07)
		var response_grid := scene.find_child("PendingClaimResponseGrid", true, false) as Control
		var response_button := first_button_with_text_prefix(response_grid, "吃") if online_claim_name == "chi" else first_button_with_text(response_grid, scene.claim_label(online_claim_name))
		check(response_button != null and not response_button.disabled, "online pending fixture exposes a real %s response button" % online_claim_name)
		if response_button != null:
			await activate_button(response_button, "key" if claim_index == 2 else ("touch" if claim_index == 1 else "mouse"))
			var response_payload = JSON.parse_string(recovery_transport.writes[0]) if recovery_transport.writes.size() == 1 else null
			check(recovery_transport.writes.size() == 1 and typeof(response_payload) == TYPE_DICTIONARY and response_payload.get("claim", "") == online_claim_name and scene.online_waiting_for_server, "online %s action sends its canonical claim payload once" % online_claim_name)
			var response_writes_before_repeat := recovery_transport.writes.size()
			await send_left_button(response_button.get_global_rect().get_center(), true)
			await send_left_button(response_button.get_global_rect().get_center(), false)
			check(recovery_transport.writes.size() == response_writes_before_repeat, "repeated online %s activation is blocked while waiting" % online_claim_name)
			scene.cancel_online_pending_action()
			check(not scene.online_waiting_for_server and scene.online_feedback.contains("已取消"), "online wait exposes a local cancel path without leaving the table")
	var online_pass_payload: Dictionary = scene.online_claim_payload("pass")
	check(online_pass_payload.get("claim", "") == "pass" and online_pass_payload.get("type", "") == "claim", "online pass uses the same normalized claim payload contract")

	print("--- F-198/F-199/F-200/F-201) table events, meld lanes, marker migration, and log modal ---")
	var table_players: Array = []
	for seat in range(4):
		table_players.append({"name": "座位%d" % seat, "hand": ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "3T", "4T"], "discards": [], "melds": [], "flowers": 0, "flower_tiles": [], "score": 25000, "bot": seat != 0})
	table_players[0]["melds"] = [["1W", "2W", "3W"]]
	table_players[1]["melds"] = [["E", "E", "E"]]
	table_players[2]["melds"] = [["1T", "2T", "3T"]]
	table_players[3]["melds"] = [["P", "P", "P", "P"]]
	scene.mode = "offline"
	scene.players = table_players
	var smoke_wall: Array[String] = ["8W", "9W"]
	scene.wall = smoke_wall
	scene.current_seat = 0
	scene.dealer_seat = 0
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_pending_claim.clear()
	scene.ai_assist_enabled = false
	scene.last_discard = ""
	scene.last_discard_seat = -1
	var smoke_table_logs: Array[String] = []
	scene.table_logs = smoke_table_logs
	scene.render_game()
	await settle(0.08)
	var wall_before_draw: int = int(scene.get_wall_count())
	var hand_before_draw := (scene.players[0]["hand"] as Array).size()
	var drawn_tile: String = str(scene.draw_turn_tile_or_finish(0, false, "ui_smoke"))
	scene.render_game()
	await settle(0.05)
	check(drawn_tile != "" and scene.get_wall_count() == wall_before_draw - 1 and (scene.players[0]["hand"] as Array).size() == hand_before_draw + 1, "draw event decrements the wall and increments the active hand once")
	var wall_label := scene.find_child("TopHudWallText", true, false) as Label
	var expected_wall_label := "余牌 %d/%d" % [scene.get_wall_count(), scene.display_wall_total()]
	var wall_count_token := "%d/%d" % [scene.get_wall_count(), scene.display_wall_total()]
	check(wall_label != null and wall_label.text == expected_wall_label and wall_label.tooltip_text.contains(wall_count_token) and wall_label.tooltip_text.contains("牌墙"), "wall HUD text is synchronized with the event state")
	check(scene.commit_discard(0, drawn_tile), "discard event accepts the newly drawn tile")
	scene.render_game()
	await settle(0.05)
	var first_marker := scene.find_child("LastDiscardFocusMarker", true, false) as Control
	check(scene.last_discard == drawn_tile and scene.last_discard_seat == 0 and (scene.players[0]["hand"] as Array).size() == hand_before_draw, "discard event updates hand count, river tail, and source seat together")
	check(first_marker != null and first_marker.get_meta("discard_tile_code", "") == drawn_tile, "latest discard marker follows the first river tail")
	scene.offline_phase = "await_discard"
	scene.players[0]["hand"].append("7B")
	check(scene.commit_discard(0, "7B"), "second discard event is accepted after the turn state is restored")
	scene.render_game()
	await settle(0.05)
	var marker_nodes: Array[Node] = scene.root_layer.find_children("LastDiscardFocusMarker", "Control", true, false) if scene.root_layer != null else []
	var second_marker := scene.find_child("LastDiscardFocusMarker", true, false) as Control
	check(marker_nodes.size() == 1 and second_marker != null and second_marker.get_meta("discard_tile_code", "") == "7B", "old last-discard marker is replaced by exactly one marker for the new tail")
	for seat in range(4):
		var meld_area := scene.find_child("MeldArea_%d" % seat, true, false) as Control
		var meld_group := scene.find_child("MeldGroup_0_%s" % scene.meld_kind_label(scene.players[seat]["melds"][0]), true, false) as Control
		check(meld_area != null and meld_area.get_meta("orientation", "") == ("vertical" if seat == 1 or seat == 3 else "horizontal") and is_equal_approx(float(meld_area.get_meta("face_rotation", 99.0)), scene.seat_meld_face_rotation(seat)), "seat %d meld lane preserves orientation and center-facing rotation" % seat)
		check(meld_group != null and int(meld_group.get_meta("tile_count", 0)) == (scene.players[seat]["melds"][0] as Array).size(), "seat %d meld group preserves its tile count" % seat)
	smoke_table_logs.clear()
	for log_index in range(20):
		smoke_table_logs.append("牌桌事件%02d" % (log_index + 1))
	scene.table_log_archive_open = false
	scene.render_game()
	await settle(0.06)
	var table_log_button := scene.find_child("TableLogArchiveButton", true, false) as Button
	check(table_log_button != null and not table_log_button.disabled, "table log exposes a real archive button")
	if table_log_button != null:
		await activate_button(table_log_button, "mouse")
		await settle(0.06)
	var table_archive_scroll := scene.find_child("TableLogArchiveScroll", true, false) as ScrollContainer
	var table_archive_close := scene.find_child("TableLogArchiveCloseButton", true, false) as Button
	check(scene.table_log_archive_open and table_archive_scroll != null and table_archive_close != null and table_archive_close.has_focus(), "table log opens as a focused modal with a native scroll view")
	if table_archive_scroll != null:
		var archive_bar := table_archive_scroll.get_v_scroll_bar()
		await send_wheel_down(table_archive_scroll.get_global_rect().get_center())
		check(archive_bar.max_value > archive_bar.page and table_archive_scroll.scroll_vertical > 0, "table log wheel reaches later history entries")
	if table_archive_close != null:
		await activate_button(table_archive_close, "touch")
		await settle(0.06)
	check(not scene.table_log_archive_open, "table log close input returns to the board")

	print("--- F-204/F-205) advisor detail and chat-to-log-to-chat return path ---")
	scene.ai_assist_enabled = true
	scene.offline_phase = "await_discard"
	scene.current_human_advice = [{"tile": "1W", "shanten": 1, "ukeire": 4, "reason_label": "保留多面听", "risk": 10.0}]
	scene.advisor_detail_open = false
	scene.render_game()
	await settle(0.08)
	var advisor_button := scene.find_child("AdvisorDetailButton", true, false) as Button
	check(advisor_button != null and not advisor_button.disabled, "advisor exposes a real detail action")
	if advisor_button != null:
		await activate_button(advisor_button, "mouse")
		await settle(0.07)
	var advisor_close := scene.find_child("AdvisorDetailCloseButton", true, false) as Button
	check(scene.advisor_detail_open and advisor_close != null and advisor_close.has_focus() and scene.find_child("AdvisorDetailText", true, false) != null, "advisor detail opens with readable content and modal focus")
	if advisor_close != null:
		await activate_button(advisor_close, "touch")
		await settle(0.05)
	check(not scene.advisor_detail_open and scene.find_child("AdvisorDetailPanel", true, false) == null, "advisor detail closes through its native close control")

	var nested_chat_transport := ConnectedLobbyTransport.new()
	scene.tcp = nested_chat_transport
	scene.mode = "online_game"
	scene.online_game = recovery_game.duplicate(true)
	scene.online_game["phase"] = "awaitDiscard"
	scene.online_feedback = ""
	scene.online_waiting_for_server = false
	var nested_table_logs: Array[String] = ["摸牌", "打出一万", "等待响应", "最新事件"]
	scene.table_logs = nested_table_logs
	scene.chat_messages = ["甲: 历史"]
	scene.chat_panel_open = false
	scene.table_log_archive_open = false
	scene.render_game()
	await settle(0.06)
	scene.show_chat_panel()
	await settle(0.06)
	var nested_chat_input := scene.find_child("ChatInput", true, false) as LineEdit
	var nested_log_button := scene.find_child("ChatPanelTableLogButton", true, false) as Button
	if nested_chat_input != null:
		nested_chat_input.text = "保留草稿"
	check(nested_log_button != null and nested_chat_input != null, "online chat exposes the table-log bridge and a draft input")
	if nested_log_button != null:
		await activate_button(nested_log_button, "touch")
		await settle(0.08)
	var nested_log_close := scene.find_child("TableLogArchiveCloseButton", true, false) as Button
	check(scene.table_log_archive_open and not scene.chat_panel_open and nested_log_close != null, "chat log bridge closes chat before opening the archive modal")
	if nested_log_close != null:
		await activate_button(nested_log_close, "key")
		await settle(0.08)
		nested_chat_input = scene.find_child("ChatInput", true, false) as LineEdit
	check(scene.chat_panel_open and nested_chat_input != null and nested_chat_input.text == "保留草稿", "closing the archive restores chat and preserves its draft")
	scene.close_chat_panel()
	scene.get_viewport().gui_release_focus()
	scene.last_game_keyboard_input_msec = 0
	scene.current_seat = 0
	await process_frame

	print("--- F-202/F-203) keyboard selection, Enter discard, and danger alternatives ---")
	scene.mode = "offline"
	scene.ai_assist_enabled = false
	scene.current_human_advice = []
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_pending_claim.clear()
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "3T", "4T", "5T"]
	scene.hand_keyboard_selection = -1
	scene.render_game()
	await settle(0.06)
	await send_key(KEY_RIGHT, 0)
	await settle(0.04)
	var selected_index := int(scene.hand_keyboard_selection)
	var selected_tile := str(scene.players[0]["hand"][selected_index]) if selected_index >= 0 else ""
	check(selected_index == 0 and selected_tile == "1W", "keyboard right starts at the first legal hand tile")
	await send_key(KEY_RIGHT, 0)
	await settle(0.04)
	check(scene.hand_keyboard_selection == 1, "keyboard right advances exactly one hand position")
	var keyboard_hand_count := (scene.players[0]["hand"] as Array).size()
	await send_key(KEY_ENTER, 0)
	await settle(0.05)
	check((scene.players[0]["hand"] as Array).size() == keyboard_hand_count - 1 and not (scene.players[0]["hand"] as Array).has("2W"), "Enter discards only the currently selected hand tile")
	var danger_alt_report := {"tile": "S", "risk": 55.0, "feed_risk": 45.0, "risk_label": "高", "safety_label": "", "feed_text": "危险", "danger_source": {"reason": "牌路危险", "seat": 2}}
	var danger_safe_alternative := {"tile": "1W", "risk": 4.0, "feed_risk": 2.0, "risk_label": "低", "safety_label": "安", "feed_text": "安全替代", "shanten": 1, "ukeire": 3}
	scene.ai_assist_enabled = true
	scene.current_seat = 0
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_pending_claim.clear()
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "5T", "6T", "7T", "E", "E", "P", "P", "S"]
	scene.render_game()
	await settle(0.05)
	# render_game clears deferred AI advice; install the deterministic fixture after
	# the render so the danger branch consumes the intended reports.
	scene.current_human_advice = [danger_alt_report, danger_safe_alternative]
	var danger_tile := scene.find_child("HandTile_12_S", true, false) as Control
	var danger_button := first_button_in(danger_tile)
	if danger_button != null:
		await activate_button(danger_button, "mouse")
		await settle(0.04)
	var danger_actions := buttons_in(scene.action_bar)
	var danger_has_alternative := false
	for danger_action in danger_actions:
		danger_has_alternative = danger_has_alternative or danger_action.text.begins_with("改打")
	var alternative_button: Button = null
	for action_button in danger_actions:
		if action_button.text.begins_with("改打"):
			alternative_button = action_button
			break
	check(alternative_button != null, "danger confirmation exposes a real alternative discard target")
	if alternative_button != null:
		var alternative_tile_code := str(alternative_button.text).replace("改打", "")
		var alternative_count_before := (scene.players[0]["hand"] as Array).size()
		await activate_button(alternative_button, "touch")
		await settle(0.05)
		check(not scene.has_pending_danger_discard() and (scene.players[0]["hand"] as Array).size() == alternative_count_before - 1 and str(scene.last_discard) != "S", "alternative danger action commits its selected tile and closes confirmation")

	print("--- F-206/F-207/F-208) settings persistence and telemetry actions ---")
	scene.show_menu(true)
	await settle(0.07)
	scene.settings_panel_open = true
	scene.refresh_current_screen()
	await settle(0.07)
	var music_button := scene.find_child("SettingRowButton_背景音乐", true, false) as Button
	var music_before := bool(scene.music_enabled)
	check(music_button != null and not music_button.disabled, "settings exposes the real background-music selector")
	if music_button != null:
		await activate_button(music_button, "mouse")
		await settle(0.05)
	check(scene.music_enabled != music_before and scene.settings_panel_open, "music selector changes state while retaining the settings modal")
	var accessibility_button := scene.find_child("SettingRowButton_阅读辅助", true, false) as Button
	var accessibility_before: String = str(scene.accessibility_profile_label())
	if accessibility_button != null:
		await activate_button(accessibility_button, "touch")
		await settle(0.05)
	check(scene.accessibility_profile_label() != accessibility_before, "reading-assistance selector updates its profile through native input")
	var rule_button := scene.find_child("SettingsRuleVariantButton", true, false) as Button
	var rule_before := str(scene.rule_variant)
	if rule_button != null:
		await activate_button(rule_button, "key")
		await settle(0.05)
	var rule_button_after := scene.find_child("SettingsRuleVariantButton", true, false) as Button
	check(str(scene.rule_variant) != rule_before and rule_button_after != null and rule_button_after.text == scene.rule_variant_short_label(), "rule selector refreshes its label and persisted value")
	var telemetry_entry := scene.find_child("SettingRowButton_隐私诊断", true, false) as Button
	if telemetry_entry != null:
		await activate_button(telemetry_entry, "mouse")
		await settle(0.05)
	var telemetry_consent_button := scene.find_child("TelemetryConsentButton", true, false) as Button
	var telemetry_export_button := scene.find_child("TelemetryExportButton", true, false) as Button
	var telemetry_clear_button := scene.find_child("TelemetryClearButton", true, false) as Button
	check(scene.telemetry_sheet_open and telemetry_consent_button != null and telemetry_export_button != null and telemetry_clear_button != null, "telemetry sheet exposes consent, export, and clear actions")
	var telemetry_consent_before := bool(scene.telemetry_consent)
	if telemetry_consent_button != null:
		await activate_button(telemetry_consent_button, "touch")
		await settle(0.04)
	check(scene.telemetry_consent != telemetry_consent_before and scene.telemetry_consent_decided, "telemetry consent toggles through a touch action")
	if telemetry_export_button != null:
		await activate_button(telemetry_export_button, "key")
		await settle(0.04)
	check(scene.telemetry_export_status.begins_with("已复制") and JSON.parse_string(DisplayServer.clipboard_get()) != null, "telemetry export updates status and clipboard with structured data")
	if telemetry_clear_button != null:
		await activate_button(telemetry_clear_button, "mouse")
		await settle(0.03)
		if not scene.telemetry_outbox.is_empty() or scene.telemetry_clear_confirming:
			await activate_button(telemetry_clear_button, "mouse")
			await settle(0.03)
		check(scene.telemetry_outbox.is_empty() and not scene.telemetry_clear_confirming, "telemetry clear is idempotent and leaves an empty local queue")
	var telemetry_close := scene.find_child("TelemetryDataSheetCloseButton", true, false) as Button
	if telemetry_close != null:
		await activate_button(telemetry_close, "touch")
		await settle(0.05)
	check(not scene.telemetry_sheet_open and scene.settings_panel_open, "closing telemetry returns to the settings sheet")
	scene.close_settings_panel()


func run_new_ui_optimization_contracts(scene: Node) -> void:
	print("--- F-383/F-413) refreshed UI focus, state labels, and timeline contracts ---")
	scene.ui_optimization_ids.clear()

	scene.show_achievements_screen(true)
	await settle(0.08)
	var achievement_rows := scene.find_child("AchievementsGrid", true, false).find_children("AchievementRowFocusTarget", "Button", true, false) if scene.find_child("AchievementsGrid", true, false) != null else []
	var achievement_scroll := scene.find_child("AchievementsScroll", true, false) as ScrollContainer
	check(achievement_rows.size() >= 2 and achievement_scroll != null, "achievement gallery exposes individually focusable rows and a scroll host")
	if achievement_rows.size() >= 2:
		var first_achievement := achievement_rows[0] as Control
		var second_achievement := achievement_rows[1] as Control
		first_achievement.grab_focus()
		await process_frame
		scene.restore_control_focus_by_id(first_achievement.get_instance_id())
		await process_frame
		check(first_achievement.focus_next == second_achievement.get_path() and first_achievement.focus_neighbor_bottom == second_achievement.get_path(), "achievement keyboard focus advances row by row")
		check(scene.achievement_focused_index == 0 and int(scene.find_child("AchievementsBrowseStatusLabel", true, false).get_meta("focused_item", 0)) == 1, "achievement browse status follows the focused row")
		check(bool(first_achievement.get_meta("ui_optimization_ids", []).has("F-388")), "achievement focus marks the auto-scroll contract")
	check(achievement_scroll != null and bool(achievement_scroll.get_meta("ui_scroll_keyboard_commands", "").contains("Home")), "achievement scroll exposes complete keyboard commands")

	var lobby_transport := ConnectedLobbyTransport.new()
	scene.tcp = lobby_transport
	scene.online_feedback = ""
	scene.online_room.clear()
	scene.selected_room = ""
	scene._show_online_lobby_impl()
	await settle(0.08)
	var host_edit := scene.find_child("OnlineLobbyHostEdit", true, false) as LineEdit
	var host_caption: Label = null
	for candidate in scene.find_children("LobbyFieldCaption_*", "Label", true, false):
		var candidate_label := candidate as Label
		if candidate_label != null and str(candidate_label.get_meta("label_for", "")) == "服务器 IP/域名":
			host_caption = candidate_label
	var room_target := scene.find_child("OnlineLobbyRoomBadgeTouchTarget", true, false) as Button
	check(host_edit != null and host_edit.get_meta("label_node_name", "") == host_caption.name if host_edit != null and host_caption != null else false, "lobby fields expose an explicit caption-to-input relationship")
	check(room_target != null and bool(room_target.get_meta("detail_rect_synced", false)), "room detail hit target is synchronized after layout settles")
	scene.online_feedback = "房间号格式不正确"
	scene.refresh_online_lobby_state()
	scene.configure_online_lobby_focus_navigation(true)
	await process_frame
	check(scene.get_viewport().gui_get_focus_owner() != null and scene.get_viewport().gui_get_focus_owner().name == "OnlineLobbyRoomEdit", "lobby validation focuses the field that needs correction")

	scene.currency = {"coins": 0, "gems": 0}
	scene._show_shop_screen_impl()
	await settle(0.08)
	var insufficient_shop_buy := scene.find_child("ShopItemBuyButton_swap_card", true, false) as Button
	var shop_end := scene.find_child("ShopItemsEndMarker", true, false) as Label
	check(insufficient_shop_buy != null and str(insufficient_shop_buy.get_meta("shop_item_id", "")) == "swap_card" and insufficient_shop_buy.tooltip_text.contains("缺少"), "shop purchase state exposes the item id and insufficient-balance reason")
	check(shop_end != null and shop_end.get_meta("shop_list_end", false), "shop list exposes an explicit end marker")

	scene.game_stats = {"games_played": 0, "games_won": 0, "win_rate": 0.0, "total_score": 0, "best_score": 0, "total_hands": 0}
	scene.round_history = []
	scene.show_stats_screen(true)
	await settle(0.08)
	var stats_filter := scene.find_child("StatsRuleFilterButton", true, false) as Button
	var stats_copy := scene.find_child("StatsCopyButton", true, false) as Button
	check(stats_filter != null and stats_filter.disabled and stats_filter.focus_mode == Control.FOCUS_NONE and stats_copy != null and stats_copy.disabled, "empty stats removes dead-end header actions from keyboard focus")
	scene.game_stats = {"games_played": 1, "games_won": 1, "win_rate": 1.0, "total_score": 120, "best_score": 120, "total_hands": 13}
	scene.round_history = [{"summary": "新 UI smoke"}]
	scene.show_stats_screen(true)
	await settle(0.08)

	scene.show_menu(true)
	await settle(0.05)
	scene.settings_panel_open = true
	scene.refresh_current_screen()
	await settle(0.08)
	var telemetry_entry := scene.find_child("SettingRowButton_隐私诊断", true, false) as Button
	if telemetry_entry != null:
		telemetry_entry.grab_focus()
		await process_frame
	scene.show_telemetry_data_sheet()
	await settle(0.04)
	var telemetry_clear := scene.find_child("TelemetryClearButton", true, false) as Button
	if telemetry_clear != null:
		scene.telemetry_clear_confirming = false
		scene.clear_telemetry_data(false)
		await process_frame
		await process_frame
	var telemetry_hint := scene.find_child("TelemetryClearConfirmHint", true, false) as Label
	check(telemetry_hint != null and telemetry_hint.visible and telemetry_clear != null and telemetry_clear.has_focus(), "telemetry destructive action exposes inline confirmation and keeps focus on the action")
	check(scene.telemetry_sheet_focus_restore_name == "SettingRowButton_隐私诊断", "telemetry sheet records its source focus for close restoration")
	scene.close_telemetry_data_sheet()

	scene.show_daily_login_panel({"consecutive_days": 3, "claimed_today": false})
	await settle(0.08)
	var daily_progress := scene.find_child("DailyLoginProgressText", true, false) as Label
	var daily_node := scene.find_child("DailyLoginDayNode_3", true, false) as Control
	check(daily_progress != null and daily_progress.get_meta("accessible_name", "").contains("签到进度") and daily_node != null and daily_node.get_meta("accessible_name", "").contains("第3天"), "daily login exposes text-equivalent progress and day state")

	scene.show_replay_import_screen(true)
	await settle(0.08)
	var replay_events := valid_replay_events(scene, "NEW-UI")
	scene.replay_import_payload = {"events": replay_events}
	scene.render_replay_timeline_events(scene.replay_import_payload, true)
	await settle(0.04)
	var replay_event_list := scene.find_child("ReplayImportEventList", true, false) as VBoxContainer
	var replay_event_scroll := scene.find_child("ReplayImportTimelineScroll", true, false) as ScrollContainer
	check(replay_event_list != null and replay_event_list.get_child_count() == replay_events.size() and replay_event_list.get_child(0).get_meta("ui_optimization_ids", []).has("F-411"), "replay timeline keeps each event as a native focusable row")
	scene.select_replay_timeline_event(2)
	var selected_before_scroll: int = int(scene.replay_timeline_selected_index)
	if replay_event_scroll != null:
		replay_event_scroll.scroll_vertical = int(round(maxf(0.0, replay_event_scroll.get_v_scroll_bar().max_value - replay_event_scroll.get_v_scroll_bar().page)))
		scene.update_replay_timeline_status(replay_event_scroll)
	check(scene.replay_timeline_selected_index == selected_before_scroll and replay_event_scroll.get_meta("timeline_selected_index", -1) == selected_before_scroll, "manual timeline scrolling preserves the selected event")
	check(scene.replay_import_shape_error_text("@").contains("第1个字符"), "replay validation identifies the first invalid character")

	var expected_ids: Array[String] = []
	for id_number in range(383, 413):
		expected_ids.append("F-%d" % id_number)
	expected_ids.append("F-413")
	for finding_id in expected_ids:
		check(scene.ui_optimization_ids.has(finding_id), "optimization registry records %s" % finding_id)
	await settle(0.05)
	scene.show_menu(true)
	await settle(0.05)
	scene.settings_panel_open = true
	scene.refresh_current_screen()
	await settle(0.05)
	var music_reopened := scene.find_child("SettingRowButton_背景音乐", true, false) as Button
	check(music_reopened != null and music_reopened.get_meta("setting_label", "") == "音乐" and music_reopened.get_meta("setting_state", "") == ("on" if scene.music_enabled else "off") and music_reopened.text in ["已开", "已关"], "settings rebuild retains the changed audio control")
	scene.close_settings_panel()

	print("--- F-209/F-210/F-211/F-212) stats empty state, latest result, and signed semantics ---")
	var stats_saved: Dictionary = scene.game_stats.duplicate(true)
	var history_saved: Array = scene.round_history.duplicate(true)
	scene.game_stats = {"games_played": 0, "games_won": 0, "win_rate": 0.0, "total_score": 0, "best_score": 0, "total_hands": 0}
	scene.round_history = []
	scene.show_stats_screen(true)
	await settle(0.07)
	var stats_empty := scene.find_child("StatsEmptyState", true, false) as Label
	var stats_first_game := scene.find_child("StatsStartFirstGameButton", true, false) as Button
	var stats_back := scene.find_child("StatsBackButton", true, false) as Button
	check(stats_empty != null and stats_empty.text.contains("暂无对局") and stats_first_game != null and stats_back != null, "empty stats retains an explicit next-step action and return button")
	if stats_back != null:
		await activate_button(stats_back, "touch")
		await settle(0.45)
	check(scene.mode == "menu", "stats back button returns to menu through touch input")
	scene.game_stats = stats_saved
	scene.round_history = history_saved
	var games_before_result := int(scene.game_stats.get("games_played", 0))
	scene.record_game_result(true, 1200, 5, "UI-SMOKE-STATS")
	scene.record_game_result(true, 1200, 5, "UI-SMOKE-STATS")
	check(int(scene.game_stats.get("games_played", 0)) == games_before_result + 1, "latest result transaction updates stats once despite duplicate settlement calls")
	scene.show_stats_screen(true)
	await settle(0.06)
	check(has_label_text(scene, "%d 局" % int(scene.game_stats.get("games_played", 0))) and scene.find_child("StatsBackButton", true, false) != null, "stats page renders the latest committed result")
	check(scene.round_summary_delta_text(-120) == "-120" and scene.round_summary_delta_text(120) == "+120" and scene.round_summary_delta_text(0) == "+0", "positive, zero, and negative score text carries explicit sign semantics")
	check(bool(scene.score_delta_breakdown([120, -120, 0, 0]).get("conserved", false)) and (scene.score_delta_breakdown([120, -120, 0, 0]).get("losses", []) as Array).size() == 1, "score breakdown distinguishes losses without relying on color")
	if scene.find_child("StatsBackButton", true, false) != null:
		await activate_button(scene.find_child("StatsBackButton", true, false) as Button, "mouse")
		await settle(0.05)

	print("--- F-213/F-214) real shop purchase, balance/inventory feedback, and end-row hit ---")
	var shop_item_ids: Array = scene.ITEM_TYPES.keys()
	var shop_item_id := str(shop_item_ids[0]) if not shop_item_ids.is_empty() else "swap_card"
	var shop_cost := int((scene.ITEM_TYPES.get(shop_item_id, {}) as Dictionary).get("cost_gems", 10))
	scene.currency = {"coins": 0, "gems": shop_cost}
	scene.inventory = {}
	scene._show_shop_screen_impl()
	await settle(0.08)
	var shop_buy := scene.find_child("ShopItemBuyButton_%s" % shop_item_id, true, false) as Button
	var inventory_before_buy: int = int(scene.get_item_count(shop_item_id))
	if shop_buy != null:
		await activate_button(shop_buy, "mouse")
		await settle(0.08)
	check(scene.get_item_count(shop_item_id) == inventory_before_buy + 1 and int(scene.currency.get("gems", 0)) == 0 and scene.toast_current != null, "real shop purchase updates balance, inventory, and feedback once")
	var shop_buy_after := scene.find_child("ShopItemBuyButton_%s" % shop_item_id, true, false) as Button
	if shop_buy_after != null:
		var inventory_after_buy: int = int(scene.get_item_count(shop_item_id))
		await activate_button(shop_buy_after, "touch")
		await settle(0.04)
		check(scene.get_item_count(shop_item_id) == inventory_after_buy and shop_buy_after.disabled, "insufficient balance blocks a repeated shop activation")
	var shop_scroll_extended := scene.find_child("ShopItemsScroll", true, false) as ScrollContainer
	var shop_content_extended := scene.find_child("ShopItemsContent", true, false) as Control
	if shop_scroll_extended != null and shop_content_extended != null:
		var real_shop_rows := shop_content_extended.find_children("ShopItemRow_*", "Panel", true, false)
		if not real_shop_rows.is_empty():
			var end_shop_row := real_shop_rows[real_shop_rows.size() - 1] as Control
			end_shop_row.custom_minimum_size.y = maxf(end_shop_row.custom_minimum_size.y, shop_scroll_extended.size.y + 220.0)
			await settle(0.06)
			shop_scroll_extended.scroll_vertical = int(round(maxf(0.0, shop_scroll_extended.get_v_scroll_bar().max_value - shop_scroll_extended.get_v_scroll_bar().page)))
			await settle(0.04)
			var end_shop_button := first_button_in(end_shop_row)
			var end_shop_button_rect := end_shop_button.get_global_rect() if end_shop_button != null else Rect2()
			var shop_view_rect := shop_scroll_extended.get_global_rect()
			var end_shop_cta_visible := end_shop_button != null and shop_view_rect.intersects(end_shop_button_rect) and shop_view_rect.has_point(end_shop_button_rect.get_center())
			check(end_shop_cta_visible, "real final shop row CTA is visible and reachable after scrolling")

	print("--- F-215/F-216) daily login claim state, reward, and idempotency ---")
	var today := Time.get_date_string_from_system()
	scene.last_login_date = today
	scene.login_reward_claimed_date = ""
	scene.consecutive_login_days = 3
	var coins_before_claim := int(scene.currency.get("coins", 0))
	scene.show_daily_login_panel({"consecutive_days": 3, "claimed_today": false})
	await settle(0.08)
	var daily_claim := scene.find_child("DailyLoginClaimButton", true, false) as Button
	check(daily_claim != null and not daily_claim.disabled and scene.find_child("DailyLoginProgressText", true, false) != null, "daily login exposes an active claim action and progress state")
	if daily_claim != null:
		# The page starts with a 0.3s scale-in; use its settled hit rectangle for
		# the touch path so the claim assertion tests activation, not animation.
		await settle(0.30)
		await activate_button(daily_claim, "touch")
		await settle(0.08)
	var daily_claim_again := scene.find_child("DailyLoginClaimButton", true, false) as Button
	check(int(scene.currency.get("coins", 0)) == coins_before_claim + 100 and scene.login_reward_claimed_date == today and daily_claim_again != null and daily_claim_again.disabled, "daily claim credits the reward, marks the day, and disables repeats")
	scene.show_menu(true)

	print("--- F-217) tutorial checkpoint, skip, and complete routes ---")
	scene.tutorial_step = scene.TUTORIAL_STEP_NEW
	scene.active_round_id = "UI-SMOKE-TUTORIAL"
	scene.offline_phase = "await_discard"
	scene.open_tutorial_entry_sheet()
	await settle(0.05)
	var tutorial_start := scene.find_child("TutorialStartButton", true, false) as Button
	check(tutorial_start != null and not tutorial_start.disabled, "new tutorial opens with a native start action")
	scene.set_tutorial_checkpoint(scene.TUTORIAL_STEP_DISCARD, "smoke checkpoint")
	check(scene.tutorial_step == scene.TUTORIAL_STEP_DISCARD and scene.tutorial_checkpoint_reason == "smoke checkpoint", "tutorial checkpoint persists its step and reason")
	scene.close_tutorial_entry_sheet()
	scene.open_tutorial_entry_sheet()
	await settle(0.04)
	check(scene.find_child("TutorialContinueButton", true, false) != null, "tutorial reopen exposes continue from the saved checkpoint")
	scene.skip_tutorial()
	check(scene.tutorial_step == scene.TUTORIAL_STEP_SKIPPED and scene.tutorial_panel == null, "tutorial skip closes the entry sheet and persists skipped state")
	scene.tutorial_step = scene.TUTORIAL_STEP_WIN
	scene.complete_tutorial("smoke complete")
	check(scene.tutorial_step == scene.TUTORIAL_STEP_COMPLETE and not scene.show_hand_hint, "tutorial completion clears the hint and persists complete state")
	scene.show_menu(true)

	print("--- F-218/F-219/F-220) settlement, replay copy, update states, and toast replacement ---")
	scene.mode = "offline"
	scene.offline_phase = "ended"
	scene.offline_hand_number = 1
	scene.offline_last_winner = 0
	scene.offline_dealer_repeat = true
	scene.round_result_kind = "win"
	scene.round_summary = "座位0胡一万，2番 1200分。"
	var settlement_deltas: Array[int] = [1200, -400, -400, -400]
	scene.last_score_deltas = settlement_deltas
	scene.last_win_score = {"winner": 0, "win_tile": "1W", "self_draw": false, "fan": 2, "points": 1200, "reasons": ["平胡"]}
	scene.active_round_id = "UI-SMOKE-SETTLEMENT"
	scene.round_event_history = valid_replay_events(scene, scene.active_round_id)
	scene.render_game()
	await settle(0.08)
	var summary_panel := scene.find_child("RoundSummaryPanel", true, false) as Control
	var win_detail_panel := scene.find_child("WinDetailPanel", true, false) as Control
	var replay_copy_button := scene.find_child("CopyReplayCodeButton", true, false) as Button
	check(summary_panel != null and win_detail_panel != null and replay_copy_button != null and not replay_copy_button.disabled, "ended table renders settlement and win detail with a valid replay action")
	if replay_copy_button != null:
		DisplayServer.clipboard_set("")
		await activate_button(replay_copy_button, "key")
		check(DisplayServer.clipboard_get() == scene.round_replay_share_code() and scene.toast_current != null, "settlement replay action copies the current verified code")
	var summary_menu := scene.find_child("SummaryMenuSecondaryButton", true, false) as Button
	if summary_menu != null:
		await activate_button(summary_menu, "touch")
		await settle(0.72)
	check(scene.mode == "menu", "settlement menu route leaves the ended table")
	scene.update_state = "checking"
	scene.update_message = "正在检查更新。"
	scene.update_remote_version = "1.0.181"
	scene.ensure_update_dialog()
	await settle(0.05)
	var update_primary := scene.find_child("UpdatePrimaryButton", true, false) as Button
	var update_secondary := scene.find_child("UpdateSecondaryButton", true, false) as Button
	check(update_primary != null and update_primary.disabled and update_primary.text == "检查中" and update_secondary != null and update_secondary.text == "取消", "update checking state disables install and exposes cancel")
	scene.update_state = "downloading"
	scene.update_message = "正在下载升级包。"
	scene.update_downloaded_bytes = 50
	scene.update_total_bytes = 100
	scene.refresh_update_dialog()
	check(scene.update_progress_label != null and scene.update_progress_label.text.contains("50%"), "update downloading state synchronizes its progress label")
	scene.update_state = "ready"
	scene.update_message = "升级包已保存。"
	scene.update_file_path = "user://updates/ui-smoke-missing.apk"
	scene.refresh_update_dialog()
	update_primary = scene.find_child("UpdatePrimaryButton", true, false) as Button
	if update_primary != null:
		await activate_button(update_primary, "mouse")
		await settle(0.03)
	check(scene.update_state == "error" and scene.update_message.contains("安装包不存在"), "ready state refuses to open a missing package with explicit error feedback")
	scene.update_state = "idle"
	scene.refresh_update_dialog()
	scene.show_menu(true)
	scene.dismiss_active_toast()
	scene.show_toast("toast-A", 1000)
	var first_toast_id: int = scene.toast_current.get_instance_id() if scene.toast_current != null else 0
	scene.show_toast("toast-B", 1000)
	check(scene.toast_current != null and scene.toast_current.get_instance_id() == first_toast_id and has_label_text(scene.toast_current, "toast-A") and scene.toast_queue.size() == 1 and str(scene.toast_queue[0].get("text", "")) == "toast-B", "new toast queues without stacking stale content")
	scene.dismiss_active_toast()
	scene.show_toast("长消息".repeat(80), 100)
	await settle(1.00)
	check(scene.toast_current == null, "expired long toast is cleaned up after its dwell and fade interval")


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
	# Disable desktop visual effects and audio backends that are unrelated to
	# pointer, focus, and state coverage in this low-resource virtual display.
	# Press-feedback nodes are still created, so input contracts remain observable.
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
	scene.fx_enabled = false
	root.add_child(scene)
	await settle(0.10)
	var initial_smoke_snapshot := capture_smoke_state(scene)
	run_optimization_contract_checks(scene)
	scene._show_online_lobby_impl()
	await settle(0.65)
	var initial_connect_button := first_button_with_text(scene, "连接")
	check(initial_connect_button != null and initial_connect_button.has_focus(), "lobby assigns default keyboard focus to its connection action")
	if initial_connect_button != null:
		initial_connect_button.release_focus()
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
		check(has_toast_text(scene, "玩家 1：%s" % long_name), "single-finger roster press reveals the complete nickname")
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
		check(has_toast_text(scene, "房间号：%s" % long_room), "single-finger room-badge press reveals the complete room code")

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
		check(scene.find_child("DiagnosticDialogPanel", true, false) != null and has_toast_text(scene, "诊断报告已复制"), "mouse copy keeps the dialog open and shows feedback")
	scene.show_diagnostic_dialog(diagnostic_lines)
	await settle(0.05)
	var diagnostic_copy_touch := scene.find_child("DiagnosticCopyButton", true, false) as Button
	if diagnostic_copy_touch != null:
		await send_screen_touch(diagnostic_copy_touch.get_global_rect().get_center(), true)
		await send_screen_touch(diagnostic_copy_touch.get_global_rect().get_center(), false)
		await settle(0.04)
	check(DisplayServer.clipboard_get() == diagnostic_report_text and scene.find_child("DiagnosticDialogPanel", true, false) != null and has_toast_text(scene, "诊断报告已复制"), "single-finger copy writes the same complete diagnostic report without dismissing the dialog")
	scene.show_diagnostic_dialog(diagnostic_lines)
	await settle(0.05)
	var diagnostic_copy_keyboard := scene.find_child("DiagnosticCopyButton", true, false) as Button
	if diagnostic_copy_keyboard != null:
		diagnostic_copy_keyboard.grab_focus()
		await send_key(KEY_ENTER, 0)
		await settle(0.04)
	check(DisplayServer.clipboard_get() == diagnostic_report_text and scene.find_child("DiagnosticDialogPanel", true, false) != null and has_toast_text(scene, "诊断报告已复制"), "keyboard copy writes the same complete diagnostic report without dismissing the dialog")
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
		# The production four-item fixture fits at 960x540. Expand a real catalog
		# row so the scroll path exercises the same row and button hit targets.
		if shop_scrollbar.max_value <= shop_scrollbar.page and shop_content != null:
			var shop_rows := shop_content.find_children("ShopItemRow_*", "Panel", true, false)
			if not shop_rows.is_empty():
				var real_overflow_row := shop_rows[shop_rows.size() - 1] as Control
				if real_overflow_row != null:
					real_overflow_row.custom_minimum_size.y = maxf(real_overflow_row.custom_minimum_size.y, shop_scroll.size.y + 240.0)
			await settle(0.05)
		check(shop_scrollbar.max_value > shop_scrollbar.page and shop_content.find_children("ShopItemRow_*", "Panel", true, false).size() >= 1, "real shop item rows create a native vertical range for scrollbar interaction")
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
	# A previous fixture may have left run_ai_until_human() awaiting a delay. Give
	# that coroutine a non-offline boundary before installing this deterministic
	# hand, otherwise it can mutate the new fixture between input assertions.
	scene.mode = "menu"
	scene.offline_phase = "ended"
	scene.offline_ai_active = false
	scene.offline_ai_run_queued = false
	await settle()
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
	var danger_discard_event_before := 0
	for raw_event in scene.round_event_history:
		if typeof(raw_event) == TYPE_DICTIONARY and str(raw_event.get("type", "")) == "discard" and int(raw_event.get("seat", -1)) == 0 and str(raw_event.get("tile", "")) == "S":
			danger_discard_event_before += 1
	if danger_confirm_button != null:
		var danger_confirm_center := danger_confirm_button.get_global_rect().get_center()
		await send_left_button(danger_confirm_center, true)
		await send_left_button(danger_confirm_center, false)
		await settle(0.18)
	var danger_discard_event_after := 0
	for raw_event in scene.round_event_history:
		if typeof(raw_event) == TYPE_DICTIONARY and str(raw_event.get("type", "")) == "discard" and int(raw_event.get("seat", -1)) == 0 and str(raw_event.get("tile", "")) == "S":
			danger_discard_event_after += 1
	var danger_commit_ok: bool = not scene.has_pending_danger_discard() and not (scene.players[0]["hand"] as Array).has("S") and danger_discard_event_after == danger_discard_event_before + 1
	check(danger_commit_ok, "mouse confirmation commits exactly one dangerous discard (pending=%s hand_has_s=%s last=%s phase=%s)" % [scene.has_pending_danger_discard(), (scene.players[0]["hand"] as Array).has("S"), str(scene.last_discard), str(scene.offline_phase)])

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
	var chat_interaction_close := scene.find_child("ChatPanelCloseButton", true, false) as Button
	check(chat_interaction_input != null and chat_interaction_send != null and chat_interaction_close != null and chat_interaction_close.has_focus(), "chat panel opens with its close action focused")
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
	var replay_archive_fixture_entries: Array = []
	var replay_archive_fixture_specs := [
		["UI-SMOKE-ARCHIVE-A", "win", "交互归档甲", 180],
		["UI-SMOKE-ARCHIVE-B", "wall_draw", "交互归档乙", 181],
		["UI-SMOKE-ARCHIVE-C", "win", "交互归档丙", 182],
		["UI-SMOKE-ARCHIVE-D", "wall_draw", "交互归档丁", 183],
		["UI-SMOKE-ARCHIVE-E", "win", "交互归档戊", 184],
		["UI-SMOKE-ARCHIVE-F", "wall_draw", "交互归档己", 185],
		["UI-SMOKE-ARCHIVE-G", "win", "交互归档庚", 186],
		["UI-SMOKE-ARCHIVE-H", "wall_draw", "交互归档辛", 187],
	]
	for replay_fixture_spec in replay_archive_fixture_specs:
		var replay_fixture_round_id := str(replay_fixture_spec[0])
		var replay_fixture_events: Array = valid_replay_events(scene, replay_fixture_round_id)
		var replay_fixture_entry := {
			"round_id": replay_fixture_round_id,
			"rule_variant": "yangzhou",
			"result_kind": str(replay_fixture_spec[1]),
			"summary": str(replay_fixture_spec[2]),
			"seed": int(replay_fixture_spec[3]),
			"events": replay_fixture_events,
			"replay_digest": scene.round_replay_digest(replay_fixture_events),
			"saved_at": int(replay_fixture_spec[3]),
			"archived_at": int(replay_fixture_spec[3]),
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
	var replay_archive_row_nodes := replay_archive_rows.find_children("ReplayArchiveRow_*", "Control", true, false) if replay_archive_rows != null else []
	check(replay_archive_rows != null and replay_archive_row_nodes.size() == 8 and replay_archive_row_a != null and replay_archive_buttons.size() == 4 and replay_archive_favorite != null and replay_archive_open != null and replay_archive_copy != null and replay_archive_delete != null, "replay archive renders eight rows with four real action targets for the fixture row (entries=%d id=%s rows=%d)" % [scene.replay_archive.size(), replay_archive_id_a, replay_archive_row_nodes.size()])
	var replay_archive_scroll := scene.find_child("ReplayArchiveScroll", true, false) as ScrollContainer
	if replay_archive_scroll != null:
		var replay_archive_scrollbar := replay_archive_scroll.get_v_scroll_bar()
		check(replay_archive_scrollbar != null and replay_archive_scrollbar.max_value > replay_archive_scrollbar.page, "eight archive rows create a native vertical range")
		if replay_archive_scrollbar != null and replay_archive_scrollbar.max_value > replay_archive_scrollbar.page:
			replay_archive_scroll.scroll_vertical = 0
			await send_wheel_down(replay_archive_scroll.get_global_rect().get_center())
			check(replay_archive_scroll.scroll_vertical > 0, "mouse wheel advances the real archive list")
			replay_archive_scroll.scroll_vertical = 0
			replay_archive_scroll.grab_focus()
			await send_key(KEY_PAGEDOWN, 0)
			check(replay_archive_scroll.scroll_vertical > 0, "PageDown advances the focused archive list")
			await send_key(KEY_END, 0)
			var archive_scroll_range := replay_archive_scrollbar.max_value - replay_archive_scrollbar.page
			check(replay_archive_scroll.scroll_vertical >= archive_scroll_range - 1.0, "End reaches the archive list tail")
			var archive_drag_start := replay_archive_scroll.get_global_rect().get_center() + Vector2(0.0, 22.0)
			var archive_drag_end := archive_drag_start - Vector2(0.0, 96.0)
			replay_archive_scroll.scroll_vertical = 0
			await send_screen_touch(archive_drag_start, true)
			await send_screen_drag(archive_drag_start, archive_drag_end)
			await send_screen_touch(archive_drag_end, false)
			await settle(0.04)
			if DisplayServer.is_touchscreen_available():
				check(replay_archive_scroll.scroll_vertical > 0, "single-finger drag advances the archive list on a touchscreen")
			else:
				check(replay_archive_scroll.has_meta("ui_scroll_view"), "archive exposes a native touch scroll surface for real-device validation")
			replay_archive_scroll.scroll_vertical = int(ceil(archive_scroll_range))
			await settle(0.04)
	var replay_archive_view_rect := replay_archive_scroll.get_global_rect() if replay_archive_scroll != null else Rect2()
	var replay_archive_oldest_row_rect := replay_archive_row_a.get_global_rect() if replay_archive_row_a != null else Rect2()
	var replay_archive_oldest_action_rect := replay_archive_favorite.get_global_rect() if replay_archive_favorite != null else Rect2()
	check(replay_archive_scroll != null and replay_archive_row_a != null and replay_archive_view_rect.encloses(replay_archive_oldest_row_rect.grow(-1.0)), "archive End state reveals the complete oldest row content (view=%s row=%s)" % [replay_archive_view_rect, replay_archive_oldest_row_rect])
	check(replay_archive_scroll != null and replay_archive_favorite != null and replay_archive_view_rect.encloses(replay_archive_oldest_action_rect), "archive End state reveals the oldest row action lane (view=%s action=%s)" % [replay_archive_view_rect, replay_archive_oldest_action_rect])
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
		var replay_archive_scroll_before_favorite := replay_archive_scroll.scroll_vertical if replay_archive_scroll != null else -1
		await move_pointer(replay_archive_favorite_mouse_center, 0.04)
		await send_left_button(replay_archive_favorite_mouse_center, true)
		await send_left_button(replay_archive_favorite_mouse_center, false)
		await settle(0.04)
		check(bool(scene.replay_archive_entry(replay_archive_id_a).get("favorite", false)), "mouse activation adds the archive to favorites")
		check(replay_archive_scroll == null or absf(replay_archive_scroll.scroll_vertical - replay_archive_scroll_before_favorite) <= 1.0, "favorite refresh preserves the archive reading position")
		replay_archive_row_a = scene.find_child("ReplayArchiveRow_%s" % replay_archive_node_key, true, false) as Control
		replay_archive_buttons = buttons_in(replay_archive_row_a)
		replay_archive_favorite = replay_archive_row_a.find_child("ReplayArchiveFavoriteButton_%s" % replay_archive_button_key, true, false) as Button if replay_archive_row_a != null else null
		replay_archive_open = replay_archive_row_a.find_child("ReplayArchiveOpenButton_%s" % replay_archive_button_key, true, false) as Button if replay_archive_row_a != null else null
		replay_archive_copy = replay_archive_row_a.find_child("ReplayArchiveCopyButton_%s" % replay_archive_button_key, true, false) as Button if replay_archive_row_a != null else null
		replay_archive_delete = replay_archive_row_a.find_child("ReplayArchiveDeleteButton_%s" % replay_archive_button_key, true, false) as Button if replay_archive_row_a != null else null
		check(replay_archive_row_a != null and replay_archive_buttons.size() == 4 and replay_archive_favorite != null and replay_archive_open != null and replay_archive_copy != null and replay_archive_delete != null, "archive refresh preserves all four action targets")
		var replay_archive_scroll_before_touch := replay_archive_scroll.scroll_vertical if replay_archive_scroll != null else -1
		if replay_archive_favorite != null:
			var replay_archive_favorite_touch_center := replay_archive_favorite.get_global_rect().get_center()
			await send_screen_touch(replay_archive_favorite_touch_center, true)
			await send_screen_touch(replay_archive_favorite_touch_center, false)
			await settle(0.04)
		check(not bool(scene.replay_archive_entry(replay_archive_id_a).get("favorite", false)), "single-finger activation reverses the archive favorite state")
		check(replay_archive_scroll == null or absf(replay_archive_scroll.scroll_vertical - replay_archive_scroll_before_touch) <= 1.0, "touch favorite refresh preserves the archive reading position")
		replay_archive_row_a = scene.find_child("ReplayArchiveRow_%s" % replay_archive_node_key, true, false) as Control
		replay_archive_buttons = buttons_in(replay_archive_row_a)
		replay_archive_favorite = replay_archive_row_a.find_child("ReplayArchiveFavoriteButton_%s" % replay_archive_button_key, true, false) as Button if replay_archive_row_a != null else null
		replay_archive_open = replay_archive_row_a.find_child("ReplayArchiveOpenButton_%s" % replay_archive_button_key, true, false) as Button if replay_archive_row_a != null else null
		replay_archive_copy = replay_archive_row_a.find_child("ReplayArchiveCopyButton_%s" % replay_archive_button_key, true, false) as Button if replay_archive_row_a != null else null
		replay_archive_delete = replay_archive_row_a.find_child("ReplayArchiveDeleteButton_%s" % replay_archive_button_key, true, false) as Button if replay_archive_row_a != null else null
		check(replay_archive_row_a != null and replay_archive_buttons.size() == 4 and replay_archive_favorite != null and replay_archive_open != null and replay_archive_copy != null and replay_archive_delete != null, "touch refresh preserves all four archive action targets")
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
		var replay_archive_scroll_before_delete := replay_archive_scroll.scroll_vertical if replay_archive_scroll != null else -1
		await move_pointer(replay_archive_delete_mouse_center, 0.04)
		await send_left_button(replay_archive_delete_mouse_center, true)
		await send_left_button(replay_archive_delete_mouse_center, false)
		await settle(0.04)
		check(scene.replay_archive.size() == replay_archive_count_before_delete and scene.replay_delete_confirming and scene.replay_delete_target_id == replay_archive_id_a, "first archive delete activation only arms the confirmation")
		check(replay_archive_scroll == null or absf(replay_archive_scroll.scroll_vertical - replay_archive_scroll_before_delete) <= 1.0, "delete confirmation refresh preserves the archive reading position")
		replay_archive_row_a = scene.find_child("ReplayArchiveRow_%s" % replay_archive_node_key, true, false) as Control
		replay_archive_buttons = buttons_in(replay_archive_row_a)
		replay_archive_delete = replay_archive_row_a.find_child("ReplayArchiveDeleteButton_%s" % replay_archive_button_key, true, false) as Button if replay_archive_row_a != null else null
		check(replay_archive_row_a != null and replay_archive_buttons.size() == 4 and replay_archive_delete != null, "delete confirmation refresh preserves the target action")
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
			await settle(0.30)
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

	await run_extended_ui_contracts(scene)
	await run_new_ui_optimization_contracts(scene)

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
	restore_smoke_state(scene, initial_smoke_snapshot)
	scene.queue_free()
	await settle(0.05)
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
