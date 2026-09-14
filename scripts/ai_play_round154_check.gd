extends SceneTree
## Round 154: hand-tray status text is reused across one render.

var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if condition:
		print("  OK  | %s" % message)
	else:
		print("  FAIL| %s" % message)
		failed = true


func make_player(name: String) -> Dictionary:
	return {
		"name": name,
		"hand": [],
		"discards": [],
		"melds": [],
		"flowers": 0,
		"flower_tiles": [],
		"score": 25000,
		"bot": true,
	}


func run() -> void:
	print("=== ai_play_round154 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_sim_quiet = true
	scene.ai_assist_enabled = true
	scene.current_seat = 0
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "2T", "3T", "5B", "E"]
	scene.current_human_advice = [{"tile": "1W", "ukeire": 8, "score": 42.0, "safety_label": "安"}]
	scene.wall.clear()
	for _i in range(60):
		scene.wall.append("1B")

	var detail_snapshot: String = scene.hand_tray_text()
	var legacy_visible: String = scene.hand_tray_visible_text()
	var snapshot_visible: String = scene.hand_tray_visible_text(detail_snapshot)
	check(detail_snapshot != "" and snapshot_visible == legacy_visible, "显式状态文本快照保持紧凑显示结果")

	scene.hand_keyboard_selection = 0
	var changed_live_detail: String = scene.hand_tray_text()
	check(changed_live_detail != detail_snapshot, "夹具能区分状态文本变化前后的实时结果")
	check(scene.hand_tray_visible_text(detail_snapshot) == snapshot_visible, "文本快照不会被后续状态读取改写")

	var hand_root := Control.new()
	hand_root.name = "HandTrayTextSnapshotRoot"
	hand_root.size = Vector2(1280.0, 720.0)
	root.add_child(hand_root)
	scene.root_layer = hand_root
	scene.hand_keyboard_selection = -1
	scene.draw_hand(hand_root)
	var tray := hand_root.get_node_or_null("HandTray") as Control
	var status := hand_root.get_node_or_null("HandTray/HandTrayStatusText") as Label
	var badge := hand_root.get_node_or_null("HandTray/HandTrayStateBadge") as Control
	check(tray != null and str(tray.get_meta("hand_tray_text_snapshot_policy", "")) == "one_status_text_snapshot_per_draw", "手牌托盘声明每次重绘只解析一次状态文本")
	check(tray != null and str(tray.get_meta("hand_tray_detail_text_snapshot", "")) == detail_snapshot, "托盘保留本次重绘的状态文本快照")
	check(status != null and status.text == scene.hand_tray_visible_text(detail_snapshot), "状态标签消费已捕获的可见文本")
	check(badge != null and str(badge.get_meta("state_detail", "")) == detail_snapshot, "状态徽章和无障碍详情复用同一快照")

	hand_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
