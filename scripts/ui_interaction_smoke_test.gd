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
	for candidate in scope.find_children("*", "Button", true, false):
		var button := candidate as Button
		if button != null and button.text == text:
			return button
	return null


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


func connected_room_fixture() -> Dictionary:
	return {
		"code": "ROOM7",
		"players": [
			{"seat": 0, "name": "甲", "ready": true},
			{"seat": 1, "name": "乙", "ready": true},
			{"seat": 2, "name": "丙", "ready": false},
		],
		"logs": ["甲加入房间", "乙准备就绪", "丙加入房间", "房间同步完成"],
	}


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
	scene._show_online_lobby_impl()
	await settle(0.65)

	print("--- A) pointer hover and press drive the real lobby button ---")
	var create_button := first_button_with_text(scene, "创建")
	check(create_button != null, "disconnected lobby exposes the create action")
	if create_button != null:
		var hover_probe := {"entered": false, "exited": false}
		create_button.mouse_entered.connect(func() -> void:
			hover_probe["entered"] = true
		)
		create_button.mouse_exited.connect(func() -> void:
			hover_probe["exited"] = true
		)
		await move_pointer(Vector2(4.0, 4.0))
		var rest_scale := create_button.scale
		check(not create_button.is_hovered() and rest_scale.distance_to(Vector2.ONE) <= 0.015, "mouse exit reaches the stable resting transform")
		await move_pointer(create_button.get_global_rect().get_center())
		check(create_button.is_hovered() and bool(hover_probe.get("entered", false)), "mouse motion enters the hit target and emits the native hover signal")
		await send_left_button(create_button.get_global_rect().get_center(), true)
		check(create_button.button_pressed, "left-button down produces the native pressed state")
		check(create_button.find_child("LobbyActionPressFeedback_创建", true, false) != null, "button-down signal produces authored press feedback")
		await send_left_button(create_button.get_global_rect().get_center(), false)
		check(not create_button.button_pressed, "left-button release clears the native pressed state")
		await move_pointer(Vector2(4.0, 4.0))
		check(not create_button.is_hovered() and bool(hover_probe.get("exited", false)), "mouse exit clears hover and emits the native exit signal")
		var touch_probe := {"pressed": false}
		create_button.pressed.connect(func() -> void:
			touch_probe["pressed"] = true
		)
		await send_screen_touch(create_button.get_global_rect().get_center(), true)
		check(create_button.button_pressed, "screen-touch down produces the native pressed state")
		await send_screen_touch(create_button.get_global_rect().get_center(), false)
		check(bool(touch_probe.get("pressed", false)) and not create_button.button_pressed, "screen-touch release activates the real lobby button")

	print("--- B) keyboard focus and editing drive the real line edit ---")
	var name_edit := scene.online_name_edit as LineEdit
	check(name_edit != null, "lobby exposes its nickname editor")
	if name_edit != null:
		await send_screen_touch(name_edit.get_global_rect().get_center(), true)
		await send_screen_touch(name_edit.get_global_rect().get_center(), false)
		check(name_edit.has_focus(), "screen touch enters the native line-edit focus state")
		check(name_edit.find_child("LineEditInputFeedback_name", false, false) != null, "focus-entered signal produces authored input feedback")
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
	check(start_button != null and not start_button.disabled and start_button.text == "开始游戏", "connected lobby enables the primary start action")
	check(start_button != null and return_button != null and start_button.size.x > return_button.size.x + 36.0 and return_button.modulate.a <= 0.85, "connected lobby gives start a unique primary hierarchy")
	check(room_art != null and room_art.visible and roster != null and roster.visible and log_list != null and log_list.visible, "connected lobby reveals room summary, roster, and logs")
	check(offline_state != null and not offline_state.visible, "connected lobby hides the disconnected empty state")
	var room_badge = scene.find_child("OnlineLobbyRoomBadge", true, false) as Control
	var room_badge_label = room_badge.get_child(room_badge.get_child_count() - 1) as Label if room_badge != null and room_badge.get_child_count() > 0 else null
	check(room_badge_label != null and room_badge_label.text == "房间号 ROOM7", "connected lobby displays the active room code")
	var occupancy = scene.find_child("OnlineLobbyRoomSummaryOccupancyLabel", true, false) as Label
	var ready = scene.find_child("OnlineLobbyRoomSummaryReadyLabel", true, false) as Label
	check(occupancy != null and occupancy.text == "入席 3/4" and ready != null and ready.text == "已备 2", "connected summary reflects player and ready counts")
	var roster_name = scene.find_child("OnlineLobbyRosterName_2", true, false) as Label
	var logs = scene.find_child("OnlineLobbyLogListText", true, false) as RichTextLabel
	check(roster_name != null and roster_name.text == "丙", "connected roster renders server-provided seat identity")
	check(logs != null and logs.text.contains("甲加入房间") and logs.text.contains("房间同步完成"), "connected log panel renders the complete room event stream")
	check(logs != null and logs.fit_content and not logs.scroll_active, "connected log text delegates overflow to the native scroll container")

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
	scene.handle_online_message(JSON.stringify({"type": "log", "text": "实时日志15"}))
	await settle(0.05)
	check((scene.online_room.get("logs", []) as Array).size() == scene.ONLINE_LOG_HISTORY_LIMIT, "appended logs stay within the fourteen-entry history limit")
	check(logs != null and not logs.text.contains("实时日志01") and logs.text.contains("实时日志15") and log_count_label != null and log_count_label.text == "14条", "log append evicts the oldest line and refreshes text and count")

	if scene.has_method("shutdown_runtime"):
		scene.shutdown_runtime()
	scene.queue_free()
	await settle(0.05)
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
