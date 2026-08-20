extends SceneTree
## Runtime interaction coverage for hover, press, focus, and connected lobby UI.

class ConnectedLobbyTransport:
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
		"logs": ["甲加入房间", "乙准备就绪", "丙加入房间"],
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

	var viewport_size := Vector2i(1280, 720)
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
		await move_pointer(Vector2(4.0, 4.0))
		var rest_scale := create_button.scale
		check(not create_button.is_hovered() and rest_scale.distance_to(Vector2.ONE) <= 0.015, "mouse exit reaches the stable resting transform")
		await move_pointer(create_button.get_global_rect().get_center())
		check(create_button.is_hovered(), "mouse motion enters the create button hit target")
		check(create_button.scale.x >= rest_scale.x + 0.035, "hover motion reaches the authored enlarged transform")
		await send_left_button(create_button.get_global_rect().get_center(), true)
		check(create_button.button_pressed, "left-button down produces the native pressed state")
		check(create_button.find_child("LobbyActionPressFeedback_创建", true, false) != null, "button-down signal produces authored press feedback")
		await send_left_button(create_button.get_global_rect().get_center(), false)
		check(not create_button.button_pressed, "left-button release clears the native pressed state")
		await move_pointer(Vector2(4.0, 4.0))
		check(not create_button.is_hovered(), "mouse exit clears the native hover state")

	print("--- B) keyboard focus and editing drive the real line edit ---")
	var name_edit := scene.online_name_edit as LineEdit
	check(name_edit != null, "lobby exposes its nickname editor")
	if name_edit != null:
		name_edit.grab_focus()
		await process_frame
		check(name_edit.has_focus(), "grab_focus enters the native line-edit focus state")
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

	print("--- C) connected transport state renders a usable room lobby ---")
	scene.tcp = ConnectedLobbyTransport.new()
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
	var room_art = scene.find_child("OnlineLobbyRoomArt", true, false) as Control
	var roster = scene.find_child("OnlineLobbyRosterPanel", true, false) as Control
	var log_list = scene.find_child("OnlineLobbyLogListPanel", true, false) as Control
	var offline_state = scene.find_child("OnlineLobbyRoomOfflineState", true, false) as Control
	check(connection_label != null and connection_label.text == "已连接", "connection badge reports the connected state")
	check(start_button != null and not start_button.disabled and start_button.text == "开始游戏", "connected lobby enables the primary start action")
	check(room_art != null and room_art.visible and roster != null and roster.visible and log_list != null and log_list.visible, "connected lobby reveals room summary, roster, and logs")
	check(offline_state != null and not offline_state.visible, "connected lobby hides the disconnected empty state")
	var room_badge = scene.find_child("OnlineLobbyRoomBadge", true, false) as Control
	var room_badge_label = room_badge.get_child(room_badge.get_child_count() - 1) as Label if room_badge != null and room_badge.get_child_count() > 0 else null
	check(room_badge_label != null and room_badge_label.text == "房间号 ROOM7", "connected lobby displays the active room code")
	var occupancy = scene.find_child("OnlineLobbyRoomSummaryOccupancyLabel", true, false) as Label
	var ready = scene.find_child("OnlineLobbyRoomSummaryReadyLabel", true, false) as Label
	check(occupancy != null and occupancy.text == "入席 3/4" and ready != null and ready.text == "已备 2", "connected summary reflects player and ready counts")
	var roster_name = scene.find_child("OnlineLobbyRosterName_2", true, false) as Label
	var logs = scene.find_child("OnlineLobbyLogListText", true, false) as Label
	check(roster_name != null and roster_name.text == "丙", "connected roster renders server-provided seat identity")
	check(logs != null and logs.text.contains("甲加入房间") and logs.text.contains("丙加入房间"), "connected log panel renders the room event stream")

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
