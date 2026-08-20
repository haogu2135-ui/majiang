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


func has_label_text(scope: Node, expected: String) -> bool:
	if scope == null:
		return false
	for candidate in scope.find_children("*", "Label", true, false):
		var label := candidate as Label
		if label != null and label.text == expected:
			return true
	return false


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


func diagnostic_interaction_lines() -> Array[String]:
	return [
		"【音频系统诊断 v1.0.156】", "",
		"1. 用户激活: 是", "2. 设备: 小米手机 (MIUI)", "",
		"⚠️ v1.0.156重大改动", "BGM已从WAV改为MP3格式", "因为您能听到TTS语音提示",
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
		check(log_scroll.scroll_vertical == after_follow_max and after_follow_max > review_scroll, "new logs remain visible when the user was already at the bottom (value=%d max=%d)" % [log_scroll.scroll_vertical, after_follow_max])

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
	check(long_name_label != null and long_name_label.tooltip_text == long_name and long_room_label != null and long_room_label.tooltip_text.contains(long_room), "clipped roster and room labels retain their complete source values")
	var roster_row = scene.find_child("OnlineLobbyRosterRow_0", true, false) as Control
	if roster_row != null:
		await send_screen_touch(roster_row.get_global_rect().get_center(), true)
		await send_screen_touch(roster_row.get_global_rect().get_center(), false)
		await settle(0.05)
		check(scene.toast_current != null and has_label_text(scene.toast_current, "玩家 1：%s" % long_name), "single-finger roster press reveals the complete nickname")
	var room_badge_touch = scene.find_child("OnlineLobbyRoomBadge", true, false) as Control
	if room_badge_touch != null:
		await send_screen_touch(room_badge_touch.get_global_rect().get_center(), true)
		await send_screen_touch(room_badge_touch.get_global_rect().get_center(), false)
		await settle(0.05)
		check(scene.toast_current != null and has_label_text(scene.toast_current, "房间号：%s" % long_room), "single-finger room-badge press reveals the complete room code")

	print("--- F) diagnostic report scroll and modal dismiss paths ---")
	var diagnostic_lines := diagnostic_interaction_lines()
	scene.show_diagnostic_dialog(diagnostic_lines)
	await settle(0.10)
	var diagnostic_scroll = scene.find_child("DiagnosticContentScroll", true, false) as ScrollContainer
	var diagnostic_close = scene.find_child("DiagnosticCloseButton", true, false) as Button
	check(diagnostic_scroll != null and diagnostic_close != null, "diagnostic exposes its native scroll and explicit close action")
	if diagnostic_scroll != null:
		var diagnostic_bar := diagnostic_scroll.get_v_scroll_bar()
		check(diagnostic_bar.max_value > diagnostic_bar.page, "full diagnostic report creates a native vertical range")
		diagnostic_scroll.scroll_vertical = 0
		await send_wheel_down(diagnostic_scroll.get_global_rect().get_center())
		check(diagnostic_scroll.scroll_vertical > 0, "desktop wheel scrolls the full diagnostic report")
	if diagnostic_close != null:
		check(diagnostic_close.focus_mode == Control.FOCUS_ALL and diagnostic_close.has_focus(), "diagnostic close action receives modal keyboard focus")
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
	check(settings_close != null and settings_close.has_focus(), "settings traps sequential keyboard focus inside the modal")
	if settings_underlay != null:
		var covered_settings_position := settings_underlay.get_global_rect().get_center()
		await send_left_button(covered_settings_position, true)
		await send_left_button(covered_settings_position, false)
		await send_screen_touch(covered_settings_position, true)
		await send_screen_touch(covered_settings_position, false)
	check(int(settings_underlay_probe.get("pressed", 0)) == 0 and scene.settings_panel_open, "settings blocks desktop and touch input from reaching the menu")
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

	scene._show_shop_screen_impl()
	await settle(0.05)
	await send_key(KEY_ESCAPE, 0)
	await settle(0.10)
	check(scene.mode == "menu" and scene.find_child("MenuSettingsButton", true, false) != null, "ui_cancel returns from the shop to the menu")

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
