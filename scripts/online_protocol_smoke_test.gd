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

func pending_action_snapshot(scene: Node) -> Dictionary:
	var snapshot := {}
	for property_name in ["online_waiting_for_server", "online_last_sent_action", "online_last_sent_type", "online_last_sent_msec", "online_last_sent_payload", "online_retry_available", "online_slow_notice_shown", "online_feedback", "online_pending_local_discard_identity"]:
		var value: Variant = scene.get(property_name)
		snapshot[property_name] = value.duplicate(true) if value is Dictionary or value is Array else value
	return snapshot


func restore_pending_action_snapshot(scene: Node, snapshot: Dictionary) -> void:
	for property_name in snapshot:
		var value: Variant = snapshot[property_name]
		scene.set(property_name, value.duplicate(true) if value is Dictionary or value is Array else value)


func wire_action_after(kind: String, start_index: int) -> Dictionary:
	for raw in received_lines.slice(start_index):
		var payload: Variant = JSON.parse_string(raw)
		if payload is Dictionary and str(payload.get("type", "")) == kind:
			return payload
	return {}


func check_chat_action_ownership(scene: Node) -> void:
	var pending := pending_action_snapshot(scene)
	var original_id: String = pending["online_last_sent_payload"].get("requestId", "")
	check(pending["online_waiting_for_server"] and pending["online_last_sent_type"] == "discard" and original_id != "", "chat ownership fixture begins with a real unacknowledged TCP discard")
	check(not scene.send_online_action({"type": "chat", "message": "   "}, "发送消息"), "blank chat is rejected while a table request is pending")
	check(pending_action_snapshot(scene) == pending, "blank chat validation cannot unlock or alter the pending table request")
	restore_pending_action_snapshot(scene, pending)
	scene.online_last_chat_sent_msec = 0
	var chat_start := received_lines.size()
	check(scene.send_online_action({"type": "chat", "message": "并行聊天甲"}, "发送消息"), "valid chat remains usable while a table request is pending")
	check(pending_action_snapshot(scene) == pending, "a successful chat cannot replace the pending discard identity timer or feedback")
	check(not scene.send_online_action({"type": "chat", "message": "冷却中的消息"}, "发送消息"), "the chat cooldown still rejects a repeated message")
	check(pending_action_snapshot(scene) == pending, "chat cooldown feedback cannot unlock or replace the pending table request")
	await pump(scene, 8)
	var first_chat := wire_action_after("chat", chat_start)
	var first_chat_id: String = first_chat.get("requestId", "")
	check(first_chat.get("message", "") == "并行聊天甲" and first_chat_id != "" and first_chat_id != original_id, "the concurrent chat reaches real TCP with its own unique request id")
	check(scene.online_pending_chat_requests.has(first_chat_id), "a written chat owns a separate bounded response correlation")
	check(not scene.send_online({"type": "chat", "message": "   "}) and pending_action_snapshot(scene) == pending, "raw chat validation also preserves pending table ownership")
	await send_fragmented({"type": "ack", "message": "无法归属的旧版回执"})
	await send_fragmented({"type": "error", "message": "无法归属的旧版拒绝"})
	await pump(scene, 8)
	check(pending_action_snapshot(scene) == pending and scene.online_pending_chat_requests.has(first_chat_id), "untagged legacy replies cannot guess table ownership while chat also awaits a reply")
	await send_fragmented({"type": "ack", "requestId": first_chat_id, "message": "聊天甲已确认"})
	await pump(scene, 8)
	check(pending_action_snapshot(scene) == pending and not scene.online_pending_chat_requests.has(first_chat_id), "a chat ACK consumes only its correlation without overwriting the pending discard")
	await send_fragmented({"type": "error", "requestId": first_chat_id, "message": "重复的聊天回执"})
	await pump(scene, 4)
	check(pending_action_snapshot(scene) == pending, "a duplicate chat reply cannot reject the pending table action")
	restore_pending_action_snapshot(scene, pending)
	scene.online_last_chat_sent_msec = 0
	chat_start = received_lines.size()
	check(scene.send_online_action({"type": "chat", "message": "并行聊天乙"}, "发送消息"), "another chat can coexist with the same pending table request")
	await pump(scene, 8)
	var second_chat := wire_action_after("chat", chat_start)
	var second_chat_id: String = second_chat.get("requestId", "")
	await send_fragmented({"type": "error", "request_id": second_chat_id, "message": "聊天乙被拒绝"})
	await pump(scene, 8)
	check(pending_action_snapshot(scene) == pending, "a tagged chat error cannot reject or unlock the pending discard")
	restore_pending_action_snapshot(scene, pending)
	scene.update_online_action_live_state(int(pending["online_last_sent_msec"]) + scene.ONLINE_ACTION_TIMEOUT_MSEC + 1)
	var retry_pending := pending_action_snapshot(scene)
	check(retry_pending["online_retry_available"] and not retry_pending["online_waiting_for_server"], "the real pending table request enters its production retry route")
	scene.online_last_chat_sent_msec = 0
	chat_start = received_lines.size()
	check(scene.send_online_action({"type": "chat", "message": "重试期间聊天"}, "发送消息"), "chat remains usable while the original table request is retryable")
	check(pending_action_snapshot(scene) == retry_pending, "chat cannot remove or replace the retryable table request")
	await pump(scene, 8)
	var retry_chat := wire_action_after("chat", chat_start)
	var retry_start := received_lines.size()
	scene.retry_online_last_action()
	await pump(scene, 8)
	var retried_discard := wire_action_after("discard", retry_start)
	var retry_id: String = retried_discard.get("requestId", "")
	check(retried_discard.get("tile", "") == "3W" and retry_id != "" and retry_id != original_id, "retry still transmits the original discard with a fresh request id instead of resending chat")
	if retry_id != "":
		var retry_waiting := pending_action_snapshot(scene)
		await send_fragmented({"type": "ack", "requestId": original_id, "message": "旧弃牌确认"})
		await pump(scene, 8)
		check(pending_action_snapshot(scene) == retry_waiting, "a late original discard ACK cannot complete its newer retry")
		await send_fragmented({"type": "ack", "actionId": retry_chat.get("requestId", ""), "message": "重试期间聊天已确认"})
		await pump(scene, 8)
		check(pending_action_snapshot(scene) == retry_waiting, "a delayed chat ACK cannot complete the newer discard retry")
		await send_fragmented({"type": "ack", "requestId": retry_id, "message": "原弃牌重试已确认"})
		await pump(scene, 8)
		check(not scene.online_waiting_for_server and scene.online_last_sent_payload.is_empty() and scene.online_feedback.contains("原弃牌重试已确认"), "only the matching table ACK completes the discard retry")
	await send_fragmented({"type": "gameState", "game": {"room_code": "QA180", "seat": 0, "turnSeat": 0, "remainingTiles": 67, "state": "claim", "yourHand": ["m1", "m2", "m3"], "discard": {"tile": "m4", "seat": 1}, "seats": [{"seat": 0, "nickname": "协议测试者", "tiles": ["m1", "m2", "m3"], "tileCount": 3}], "claim": {"actions": ["过"], "discard": "m4", "discardSeat": 1}}})
	await pump(scene, 12)
	check(scene.send_online_action({"type": "claim", "claim": "pass"}, "过"), "the ownership fixture submits a real legal pass response")
	var claim_pending := pending_action_snapshot(scene)
	scene.online_last_chat_sent_msec = 0
	chat_start = received_lines.size()
	check(scene.send_online_action({"type": "chat", "message": "响应期间聊天"}, "发送消息"), "chat remains usable during an unacknowledged claim response")
	await pump(scene, 8)
	var claim_chat := wire_action_after("chat", chat_start)
	await send_fragmented({"type": "error", "action_id": claim_chat.get("requestId", ""), "message": "响应期间聊天被拒绝"})
	await pump(scene, 8)
	check(pending_action_snapshot(scene) == claim_pending, "a chat rejection cannot cancel or replace an unacknowledged claim")
	await send_fragmented({"type": "ack", "requestId": claim_pending["online_last_sent_payload"].get("requestId", ""), "message": "过牌已确认"})
	await pump(scene, 8)
	check(not scene.online_waiting_for_server and scene.online_feedback.contains("过牌已确认"), "the original claim ACK remains attributable after chat traffic")
	await send_fragmented({"type": "gameState", "game": {"room_code": "QA180", "seat": 0, "turnSeat": 0, "remainingTiles": 67, "state": "awaitDiscard", "yourHand": ["m1", "m2", "m3"], "players": [{"seat": 0, "nickname": "协议测试者", "tiles": ["m1", "m2", "m3"], "tileCount": 3}]}})
	await pump(scene, 12)
	scene.online_last_chat_sent_msec = 0
	check(scene.can_self_discard(), "the real server fixture exposes a legal self-discard before standalone chat")
	check(scene.send_online_action({"type": "chat", "message": "不锁牌桌的聊天"}, "发送消息"), "standalone chat still transmits normally")
	check(not scene.online_waiting_for_server and scene.online_last_sent_payload.is_empty() and scene.can_self_discard(), "standalone chat cannot put the table into a game-action waiting state")
	await pump(scene, 8)


func check_chat_correlations(scene: Node) -> void:
	for request_id in scene.online_pending_chat_requests.keys():
		await send_fragmented({"type": "ack", "requestId": request_id})
	await pump(scene, 8)
	check(scene.online_pending_chat_requests.is_empty(), "standalone chat ACK releases its correlation")
	var batch_start := received_lines.size()
	var batch_count: int = scene.ONLINE_CHAT_PENDING_REQUEST_LIMIT + 3
	var all_sent := true
	for message_index in range(batch_count):
		scene.online_last_chat_sent_msec = 0
		all_sent = scene.send_online_action({"type": "chat", "message": "有限回执%02d" % message_index}) and all_sent
	await pump(scene, 8)
	var chat_ids: Array[String] = []
	for raw in received_lines.slice(batch_start):
		var outbound: Variant = JSON.parse_string(raw)
		if outbound is Dictionary and outbound.get("type", "") == "chat":
			chat_ids.append(str(outbound.get("requestId", "")))
	check(all_sent and chat_ids.size() == batch_count and not chat_ids.has("") and scene.online_pending_chat_requests.size() == scene.ONLINE_CHAT_PENDING_REQUEST_LIMIT, "all chats reach real TCP while pending correlations stay within their declared bound")
	if chat_ids.size() != batch_count:
		return
	check(not scene.online_pending_chat_requests.has(chat_ids.front()) and scene.online_pending_chat_requests.has(chat_ids.back()), "bounded chat correlation evicts the oldest request instead of blocking new messages")
	check(scene.send_online_action({"type": "discard", "tile": "3W"}), "pending chats do not block a legal table discard")
	var pending := pending_action_snapshot(scene)
	var table_id: String = pending["online_last_sent_payload"].get("requestId", "")
	var retained_id: String = chat_ids.back()
	var registry: Dictionary = scene.online_pending_chat_requests.duplicate(true)
	await send_fragmented({"type": "ack", "requestId": chat_ids.front()})
	await send_fragmented({"type": "ack", "requestId": retained_id, "sessionId": scene.online_session_id - 1})
	await send_fragmented({"type": "ack", "requestId": retained_id, "actionType": "discard"})
	await send_fragmented({"type": "ack", "requestType": "chat"})
	await pump(scene, 8)
	check(pending_action_snapshot(scene) == pending and scene.online_pending_chat_requests == registry, "evicted wrong-session contradictory and ambiguous chat replies cannot consume a table or another chat")
	await send_fragmented({"type": "ack", "action_id": retained_id, "request_type": "chat"})
	await pump(scene, 8)
	registry.erase(retained_id)
	check(pending_action_snapshot(scene) == pending and scene.online_pending_chat_requests == registry, "out-of-order aliased chat ACK consumes exactly its own pending entry")
	await send_fragmented({"type": "ack", "requestId": table_id})
	await pump(scene, 8)
	check(not scene.online_waiting_for_server and scene.online_last_sent_payload.is_empty() and scene.online_pending_chat_requests == registry, "table ACK leaves unrelated chat correlations intact")
	var game_fixture := {"room_code": "QA180", "seat": 0, "turnSeat": 0, "remainingTiles": 66, "state": "awaitDiscard", "yourHand": ["m1", "m2", "m3"], "players": [{"seat": 0, "nickname": "协议测试者", "tiles": ["m1", "m2", "m3"], "tileCount": 3}]}
	await send_fragmented({"type": "gameState", "game": game_fixture})
	await pump(scene, 8)
	check(scene.online_pending_chat_requests == registry, "ordinary same-room snapshots do not erase pending chat correlations")
	for request_id in registry:
		await send_fragmented({"type": "ack", "request_id": request_id})
	await pump(scene, 12)
	check(scene.online_pending_chat_requests.is_empty(), "all retained out-of-order chats eventually release their correlations")
	scene.online_last_chat_sent_msec = 0
	check(scene.send_online_action({"type": "chat", "message": "旧版聊天回执"}), "standalone legacy chat still sends")
	await send_fragmented({"type": "ack", "action_type": "chat", "message": "旧版聊天已确认"})
	await pump(scene, 8)
	check(scene.online_pending_chat_requests.is_empty() and scene.online_feedback.contains("旧版聊天已确认") and scene.can_self_discard(), "a uniquely typed legacy chat ACK remains compatible without locking the table")
	check(scene.send_online_action({"type": "discard", "tile": "3W"}), "legacy table-only discard still sends")
	await send_fragmented({"type": "ack", "message": "旧版弃牌已确认"})
	await pump(scene, 8)
	check(not scene.online_waiting_for_server and scene.online_last_sent_payload.is_empty() and scene.online_feedback.contains("旧版弃牌已确认"), "unambiguous legacy table-only ACK retains existing compatibility")
	var borrowed_payload := {"type": "chat", "message": "原始聊天发送", "requestId": table_id}
	check(scene.send_online(borrowed_payload), "raw chat transport also registers a unique request")
	await pump(scene, 8)
	check(borrowed_payload.get("requestId", "") == table_id and scene.online_pending_chat_requests.size() == 1 and not scene.online_pending_chat_requests.has(table_id), "raw chat does not mutate caller payload or reuse a table request id")
	await send_fragmented({"type": "error", "message": "旧版聊天被拒绝"})
	await pump(scene, 8)
	check(scene.online_pending_chat_requests.is_empty() and scene.online_feedback.contains("旧版聊天被拒绝") and not scene.online_waiting_for_server, "unambiguous standalone legacy chat rejection remains independent")
	check(scene.send_online({"type": "chat", "message": "牌局房间切换前"}), "room-switch fixture queues a real chat")
	game_fixture["room_code"] = "QA180-side"
	await send_fragmented({"type": "gameState", "game": game_fixture})
	await pump(scene, 8)
	check(scene.online_pending_chat_requests.is_empty(), "an authoritative game-room switch clears old-room chat correlations")
	check(scene.send_online({"type": "chat", "message": "大厅房间切换前"}), "lobby room-switch fixture queues a real chat")
	await send_fragmented({"type": "roomState", "room": {"roomCode": "QA180-side", "players": []}})
	await pump(scene, 8)
	check(scene.online_pending_chat_requests.is_empty(), "an authoritative lobby-room switch clears old-room chat correlations")
	game_fixture["room_code"] = "QA180"
	await send_fragmented({"type": "gameState", "game": game_fixture})
	await send_fragmented({"type": "roomState", "room": {"roomCode": "QA180", "players": []}})
	await pump(scene, 8)
	check(scene.send_online({"type": "chat", "message": "断线前未回执"}), "disconnect fixture retains a real pending chat")
	await pump(scene, 4)


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
	await check_chat_action_ownership(scene)
	await check_chat_correlations(scene)

	server_peer.disconnect_from_host()
	await pump(scene, 14)
	check(scene.online_room.is_empty() and not scene.online_game.is_empty(), "disconnect clears the room snapshot but preserves the game snapshot for recovery")
	check(not scene.online_waiting_for_server, "disconnect clears the waiting-for-server state")
	check(scene.online_pending_chat_requests.is_empty(), "transport loss clears all session-owned chat correlations")
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
	scene.online_pending_chat_requests["stale-session"] = {"session": scene.online_session_id, "room": "QA180"}
	scene.connect_online()
	check(scene.online_pending_chat_requests.is_empty(), "new connection clears correlations even while preserving a recoverable game board")
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
	var received_before_idle_batch: int = scene.online_messages_received
	var idle_batch_count: int = scene.ONLINE_MAX_FRAMES_PER_POLL + 3
	var idle_batch_wire := ""
	for message_index in range(idle_batch_count):
		idle_batch_wire += JSON.stringify({"type": "log", "text": "仅一批字节%02d" % message_index}) + "\n"
	check(server_peer.put_data(idle_batch_wire.to_utf8_buffer()) == OK, "server queues more than one poll budget without another socket write")
	await pump(scene, 8)
	check(scene.online_messages_received == received_before_idle_batch + idle_batch_count and scene.tcp_buffer.is_empty(), "buffered complete frames continue draining after the socket has no new bytes")
	var received_before_burst: int = scene.online_messages_received
	var burst_wire := ""
	for i in range(BURST_LOG_COUNT):
		burst_wire += JSON.stringify({"type": "log", "text": "突发日志%04d" % (i + 1)}) + "\n"
	check(server_peer.put_data(burst_wire.to_utf8_buffer()) == OK, "server queues a multi-chunk burst of newline-delimited messages")
	var burst_frame_budget := ceili(float(BURST_LOG_COUNT) / float(scene.ONLINE_MAX_FRAMES_PER_POLL)) + 24
	for frame_index in range(burst_frame_budget):
		await pump(scene, 1)
		if scene.online_messages_received >= received_before_burst + BURST_LOG_COUNT and scene.tcp_buffer.is_empty():
			break
	check(scene.online_messages_received == received_before_burst + BURST_LOG_COUNT, "the full fifteen-hundred-frame burst completes within the unchanged per-poll processing budget")
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
