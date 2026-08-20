extends SceneTree
## Local TCP protocol contract: real StreamPeerTCP, newline framing, state normalization, and disconnect cleanup.

const PORT := 23333
var failed := false
var server := TCPServer.new()
var server_peer: StreamPeerTCP
var received_lines: Array[String] = []
var server_buffer := ""

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if condition:
		print("  OK  | %s" % message)
	else:
		print("  FAIL| %s" % message)
		failed = true

func pump_server() -> void:
	if server_peer == null and server.is_connection_available():
		server_peer = server.take_connection()
	if server_peer == null:
		return
	server_peer.poll()
	if server_peer.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		return
	var available := server_peer.get_available_bytes()
	if available <= 0:
		return
	server_buffer += server_peer.get_utf8_string(available)
	while server_buffer.find("\n") >= 0:
		var split_at := server_buffer.find("\n")
		var line := server_buffer.substr(0, split_at).strip_edges()
		server_buffer = server_buffer.substr(split_at + 1)
		if line != "":
			received_lines.append(line)

func send_fragmented(payload: Dictionary) -> void:
	if server_peer == null:
		return
	var wire := (JSON.stringify(payload) + "\n").to_utf8_buffer()
	var midpoint := maxi(1, wire.size() / 2)
	server_peer.put_data(wire.slice(0, midpoint))
	await process_frame
	server_peer.put_data(wire.slice(midpoint))

func pump(scene: Node, frames: int = 8) -> void:
	for _i in range(frames):
		pump_server()
		if scene.has_method("poll_online"):
			scene.poll_online(-1)
		await process_frame
		pump_server()

func wait_for_line(scene: Node, kind: String, frames: int = 40) -> Dictionary:
	for _i in range(frames):
		await pump(scene, 1)
		for raw in received_lines:
			var parsed = JSON.parse_string(raw)
			if typeof(parsed) == TYPE_DICTIONARY and str(parsed.get("type", "")) == kind:
				return parsed
	return {}

func run() -> void:
	print("=== online protocol smoke START ===")
	check(server.listen(PORT, "127.0.0.1") == OK, "local TCP fixture listens on the client default port")
	if failed:
		quit(1)
		return

	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	await process_frame
	if scene.online_name_edit == null:
		scene.online_name_edit = LineEdit.new()
		scene.add_child(scene.online_name_edit)
	var expected_name := "协".repeat(scene.ONLINE_NAME_MAX_LENGTH)
	scene.online_name_edit.text = "  " + "协".repeat(scene.ONLINE_NAME_MAX_LENGTH + 4) + "  "
	if scene.online_host_edit == null:
		scene.online_host_edit = LineEdit.new()
		scene.add_child(scene.online_host_edit)
	scene.online_host_edit.text = "  127.0.0.1  "
	if scene.online_room_edit == null:
		scene.online_room_edit = LineEdit.new()
		scene.add_child(scene.online_room_edit)
	scene.mode = "online_lobby"
	scene.connect_online()
	check(scene.online_connection_host == "127.0.0.1", "connect freezes the normalized host as the active endpoint")
	check(scene.online_connection_endpoint_text() == "127.0.0.1:%d" % PORT, "endpoint helper reports the actual connected host and fixed port")
	check(scene.bounded_online_input("  ABCDE  ", 3) == "ABC", "bounded online input trims and limits client text")

	await pump(scene, 12)
	check(server_peer != null, "client establishes a real StreamPeerTCP connection")
	var hello := await wait_for_line(scene, "hello")
	check(str(hello.get("name", "")) == expected_name, "client sends newline-delimited hello with a trimmed bounded name")

	await send_fragmented({"type": "welcome", "name": "本地房间服务"})
	await send_fragmented({"type": "roomState", "room": {"room_code": "QA180", "players": [{"seat": 0, "nickname": "协议测试者", "ready": true}], "logs": ["房间已创建", "等待入席"]}})
	await pump(scene, 12)
	check(str(scene.selected_room) == "QA180", "roomState aliases normalize room_code into selected_room")
	check(scene.online_room.get("players", []).size() == 1, "roomState keeps the roster payload")
	check((scene.online_room.get("logs", []) as Array).size() == 2, "roomState keeps room logs")
	var many_logs: Array[String] = []
	for i in range(16):
		many_logs.append("协议日志%02d" % (i + 1))
	await send_fragmented({"type": "roomState", "room": {"roomCode": "QA180", "players": [], "logs": many_logs}})
	await pump(scene, 8)
	var retained_logs := scene.online_room.get("logs", []) as Array
	check(retained_logs.size() == scene.ONLINE_LOG_HISTORY_LIMIT and retained_logs.front() == "协议日志03" and retained_logs.back() == "协议日志16", "roomState bounds log history to the newest fourteen entries")

	scene.create_online_room()
	await pump(scene, 3)
	var received_before_blank_join := received_lines.size()
	scene.online_room_edit.text = "   "
	scene.join_online_room()
	await pump(scene, 3)
	check(received_lines.size() == received_before_blank_join, "blank normalized room code does not write to the TCP stream")
	scene.online_room_edit.text = "  QA180  "
	scene.join_online_room()
	scene.send_online_action({"type": "startGame"}, "开始游戏")
	await pump(scene, 10)
	var action_types: Array[String] = []
	for raw in received_lines:
		var parsed = JSON.parse_string(raw)
		if typeof(parsed) == TYPE_DICTIONARY:
			var action_type := str(parsed.get("type", ""))
			if action_type != "" and not action_types.has(action_type):
				action_types.append(action_type)
	check(action_types.has("createRoom") and action_types.has("joinRoom") and action_types.has("startGame"), "client emits create/join/start actions through the same TCP stream")
	var normalized_actions := true
	for raw in received_lines:
		var parsed_action = JSON.parse_string(raw)
		if typeof(parsed_action) != TYPE_DICTIONARY:
			continue
		if str(parsed_action.get("type", "")) == "createRoom":
			normalized_actions = normalized_actions and str(parsed_action.get("name", "")) == expected_name
		elif str(parsed_action.get("type", "")) == "joinRoom":
			normalized_actions = normalized_actions and str(parsed_action.get("roomCode", "")) == "QA180" and str(parsed_action.get("name", "")) == expected_name
	check(normalized_actions, "create and join actions use normalized bounded fields")

	await send_fragmented({"type": "gameState", "game": {"room_code": "QA180", "seat": 0, "turnSeat": 0, "remainingTiles": 68, "state": "claim", "yourHand": ["m1", "m2", "m3"], "discard": {"tile": "m4", "seat": 1}, "seats": [{"seat": 0, "nickname": "协议测试者", "tiles": ["m1", "m2", "m3"], "tileCount": 3}], "claim": {"actions": ["吃", "过"], "discard": "m4", "discardSeat": 1}}})
	await pump(scene, 12)
	check(scene.mode == "online_game", "gameState switches the client into online_game mode")
	check(str(scene.online_game.get("phase", "")) == "pendingClaim", "gameState aliases normalize claim phase")
	check(str(scene.online_game.get("lastDiscard", "")) == "m4" and int(scene.online_game.get("lastDiscardSeat", -1)) == 1, "nested discard aliases normalize tile and source seat")
	check((scene.online_game.get("pending", {}) as Dictionary).get("options", []).has("chi"), "claim aliases normalize Chinese actions")

	scene.send_online_action({"type": "discard", "tile": "m3"}, "打出m3")
	await pump(scene, 8)
	var discard_seen := false
	for raw in received_lines:
		var parsed = JSON.parse_string(raw)
		if typeof(parsed) == TYPE_DICTIONARY and str(parsed.get("type", "")) == "discard" and str(parsed.get("tile", "")) == "m3":
			discard_seen = true
	check(discard_seen, "client emits a discard action after receiving a normalized game state")

	server_peer.disconnect_from_host()
	await pump(scene, 14)
	check(scene.online_room.is_empty() and scene.online_game.is_empty(), "disconnect clears room and game snapshots")
	check(not scene.online_waiting_for_server, "disconnect clears the waiting-for-server state")

	# Reconnect on the same listening fixture and exercise server feedback after
	# the client has returned to a clean lobby state.
	received_lines.clear()
	server_peer = null
	scene.mode = "online_lobby"
	if not is_instance_valid(scene.online_name_edit):
		scene.online_name_edit = LineEdit.new()
		scene.add_child(scene.online_name_edit)
		scene.online_name_edit.text = "协议测试者"
	if not is_instance_valid(scene.online_host_edit):
		scene.online_host_edit = LineEdit.new()
		scene.add_child(scene.online_host_edit)
	scene.online_host_edit.text = "127.0.0.1"
	scene.connect_online()
	await pump(scene, 12)
	check(server_peer != null, "client can reconnect after a dropped TCP session")
	var hello_again := await wait_for_line(scene, "hello")
	check(str(hello_again.get("name", "")) == "协议测试者", "reconnect sends a fresh hello instead of reusing stale framing")
	await send_fragmented({"type": "error", "reason": "房间已满"})
	await send_fragmented({"type": "log", "text": "服务器已记录拒绝"})
	await pump(scene, 10)
	check(scene.online_feedback.find("拒绝") >= 0, "server error feedback reaches the lobby")
	check((scene.online_room.get("logs", []) as Array).has("服务器已记录拒绝"), "server log messages append to the room log")
	for i in range(20):
		scene.handle_online_message(JSON.stringify({"type": "log", "text": "追加日志%02d" % (i + 1)}))
	var appended_logs := scene.online_room.get("logs", []) as Array
	check(appended_logs.size() == scene.ONLINE_LOG_HISTORY_LIMIT and appended_logs.front() == "追加日志07" and appended_logs.back() == "追加日志20", "incremental logs retain exactly the newest fourteen entries")

	scene.shutdown_runtime()
	scene.queue_free()
	server.stop()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
