extends SceneTree
## Local TCP protocol contract: real StreamPeerTCP, newline framing, state normalization, and disconnect cleanup.

const PORT := 23333
const BURST_LOG_COUNT := 1500
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
	check(scene.online_message_protocol_version({"protocolVersion": 0.0}) == 0, "JSON float protocol versions normalize as integers")
	check(scene.online_message_revision({"revision": 7.0}, "gameState") == 7, "JSON float state revisions normalize as integers")

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
	check(str(scene.online_game.get("lastDiscard", "")) == "4W" and int(scene.online_game.get("lastDiscardSeat", -1)) == 1, "nested discard aliases normalize tile and source seat")
	check((scene.online_game.get("pending", {}) as Dictionary).get("options", []).has("chi"), "claim aliases normalize Chinese actions")

	scene.send_online_action({"type": "discard", "tile": "m3"}, "打出m3")
	await pump(scene, 8)
	var discard_seen := false
	for raw in received_lines:
		var parsed = JSON.parse_string(raw)
		if typeof(parsed) == TYPE_DICTIONARY and str(parsed.get("type", "")) == "discard" and str(parsed.get("tile", "")) == "m3":
			discard_seen = true
	check(not discard_seen and scene.online_feedback.find("出牌阶段") >= 0, "client blocks discard actions outside the current phase")
	await send_fragmented({"type": "gameState", "game": {"room_code": "QA180", "seat": 0, "turnSeat": 0, "remainingTiles": 67, "state": "awaitDiscard", "yourHand": ["m1", "m2", "m3"], "players": [{"seat": 0, "nickname": "协议测试者", "tiles": ["m1", "m2", "m3"], "tileCount": 3}]}})
	await pump(scene, 12)
	scene.send_online_action({"type": "discard", "tile": "m3"}, "打出m3")
	await pump(scene, 8)
	for raw in received_lines:
		var parsed_valid = JSON.parse_string(raw)
		if typeof(parsed_valid) == TYPE_DICTIONARY and str(parsed_valid.get("type", "")) == "discard" and str(parsed_valid.get("tile", "")) == "3W":
			discard_seen = true
	check(discard_seen, "client canonicalizes and emits a discard only during its turn")

	server_peer.disconnect_from_host()
	await pump(scene, 14)
	check(scene.online_room.is_empty() and not scene.online_game.is_empty(), "disconnect clears the room snapshot but preserves the game snapshot for recovery")
	check(not scene.online_waiting_for_server, "disconnect clears the waiting-for-server state")
	check(scene.mode == "online_game", "an in-game disconnect keeps the recovery view in the online game")
	check(scene.online_feedback.contains("连接已断开"), "the recovery view explains why the online game was interrupted")

	# Reconnect on the same listening fixture and exercise server feedback while
	# the preserved game snapshot remains available behind the recovery CTA.
	received_lines.clear()
	server_peer = null
	if not is_instance_valid(scene.online_name_edit):
		scene.online_name_edit = LineEdit.new()
		scene.add_child(scene.online_name_edit)
	check(scene.online_player_name == expected_name, "disconnect recovery preserves the normalized player identity")
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
	await send_fragmented({"type": "welcome", "name": "本地房间服务"})
	await pump(scene, 8)
	var resumed_join_count := 0
	for raw in received_lines:
		var resumed_action = JSON.parse_string(raw)
		if typeof(resumed_action) == TYPE_DICTIONARY and str(resumed_action.get("type", "")) == "joinRoom" and str(resumed_action.get("roomCode", "")) == "QA180":
			resumed_join_count += 1
	check(resumed_join_count == 1, "welcome resumes the saved room with exactly one idempotent join action")
	await send_fragmented({"type": "welcome", "name": "本地房间服务"})
	await pump(scene, 4)
	var duplicate_resumed_join_count := 0
	for raw in received_lines:
		var duplicate_action = JSON.parse_string(raw)
		if typeof(duplicate_action) == TYPE_DICTIONARY and str(duplicate_action.get("type", "")) == "joinRoom" and str(duplicate_action.get("roomCode", "")) == "QA180":
			duplicate_resumed_join_count += 1
	check(duplicate_resumed_join_count == 1, "duplicate welcome does not replay the room join")
	await send_fragmented({"type": "roomState", "room": {"roomCode": "QA180", "players": [{"seat": 0, "nickname": "协议测试者", "ready": true}], "logs": ["恢复成功"]}})
	await pump(scene, 8)
	check(str(scene.selected_room) == "QA180" and not scene.online_resume_pending and not scene.online_resume_join_sent, "resumed roomState clears the one-shot recovery marker")
	var burst_wire := ""
	for i in range(BURST_LOG_COUNT):
		burst_wire += JSON.stringify({"type": "log", "text": "突发日志%04d" % (i + 1)}) + "\n"
	check(server_peer.put_data(burst_wire.to_utf8_buffer()) == OK, "server queues a multi-chunk burst of newline-delimited messages")
	await pump(scene, 80)
	var burst_logs := scene.online_room.get("logs", []) as Array
	var first_retained_burst: int = BURST_LOG_COUNT - int(scene.ONLINE_LOG_HISTORY_LIMIT) + 1
	check(burst_logs.size() == scene.ONLINE_LOG_HISTORY_LIMIT and burst_logs.front() == "突发日志%04d" % first_retained_burst and burst_logs.back() == "突发日志%04d" % BURST_LOG_COUNT, "multi-chunk burst preserves exactly the newest bounded log history")
	check(scene.tcp_buffer.is_empty() and scene.tcp.get_status() == StreamPeerTCP.STATUS_CONNECTED, "burst framing drains completely without dropping the connection")
	await send_fragmented({"type": "log", "text": "界".repeat(scene.ONLINE_LOG_ENTRY_MAX_LENGTH + 32)})
	await pump(scene, 8)
	var bounded_server_logs := scene.online_room.get("logs", []) as Array
	check(not bounded_server_logs.is_empty() and str(bounded_server_logs.back()).length() == scene.ONLINE_LOG_ENTRY_MAX_LENGTH, "server log entries are truncated to the declared UI boundary")
	await send_fragmented({"type": "error", "reason": "房间已满"})
	await send_fragmented({"type": "log", "text": "服务器已记录拒绝"})
	await pump(scene, 10)
	check(scene.online_feedback.find("拒绝") >= 0, "server error feedback reaches the lobby")
	check((scene.online_room.get("logs", []) as Array).has("服务器已记录拒绝"), "server log messages append to the room log")
	for i in range(20):
		scene.handle_online_message(JSON.stringify({"type": "log", "text": "追加日志%02d" % (i + 1)}))
	var appended_logs := scene.online_room.get("logs", []) as Array
	check(appended_logs.size() == scene.ONLINE_LOG_HISTORY_LIMIT and appended_logs.front() == "追加日志07" and appended_logs.back() == "追加日志20", "incremental logs retain exactly the newest fourteen entries")

	var oversized_partial := ("{\"type\":\"log\",\"text\":\"" + "X".repeat(scene.ONLINE_MESSAGE_MAX_BYTES + 32)).to_utf8_buffer()
	check(server_peer.put_data(oversized_partial) == OK, "server queues an oversized unterminated frame")
	await pump(scene, 80)
	check(scene.tcp.get_status() != StreamPeerTCP.STATUS_CONNECTED, "oversized unterminated frames are rejected with a transport disconnect")
	check(scene.tcp_buffer.is_empty() and scene.online_room.is_empty() and scene.online_game.is_empty(), "protocol rejection clears buffered bytes and stale online snapshots")
	check(scene.online_feedback.contains("消息过大"), "protocol rejection exposes an actionable lobby error")

	# An old server must follow the same terminal cleanup path as a future server:
	# return to the lobby and discard any stale in-game snapshot instead of leaving
	# a transport that can continue receiving incompatible state.
	server_peer = null
	received_lines.clear()
	scene.mode = "online_game"
	scene.selected_room = "QA180"
	scene.online_resume_context = {"room": "QA180", "host": "127.0.0.1", "name": expected_name}
	scene.online_resume_pending = false
	scene.online_game = {"roomCode": "QA180", "phase": "awaitDiscard", "youSeat": 0, "currentSeat": 0, "hand": ["3W"]}
	scene.online_host_edit.text = "127.0.0.1"
	scene.connect_online()
	await pump(scene, 12)
	check(server_peer != null and server_peer.get_status() == StreamPeerTCP.STATUS_CONNECTED, "client reconnects before testing an old protocol server")
	var old_protocol_hello := await wait_for_line(scene, "hello")
	check(not old_protocol_hello.is_empty(), "old protocol fixture receives the fresh client hello")
	await send_fragmented({"type": "welcome", "protocolVersion": scene.ONLINE_PROTOCOL_VERSION - 1})
	await pump(scene, 12)
	check(scene.tcp.get_status() != StreamPeerTCP.STATUS_CONNECTED and scene.mode == "online_lobby", "old protocol version closes transport and returns to the lobby")
	check(scene.tcp_buffer.is_empty() and scene.online_room.is_empty() and scene.online_game.is_empty() and not scene.online_resume_pending, "old protocol rejection clears stale snapshots and resume markers")
	check(scene.online_feedback.contains("协议版本过旧"), "old protocol rejection explains the required server update")

	scene.shutdown_runtime()
	scene.queue_free()
	server.stop()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
