extends SceneTree
## Round 155: hand-tray state text and colors are reused from one draw snapshot.

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


func colors_match(left, right) -> bool:
	return is_equal_approx(left.r, right.r) and is_equal_approx(left.g, right.g) and is_equal_approx(left.b, right.b) and is_equal_approx(left.a, right.a)


func run() -> void:
	print("=== ai_play_round155 check START ===")
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

	var state_snapshot: String = scene.hand_tray_state_text()
	var live_fill: Color = scene.hand_tray_state_fill()
	var snapshot_fill: Color = scene.hand_tray_state_fill(state_snapshot)
	var live_border: Color = scene.hand_tray_state_border()
	var snapshot_border: Color = scene.hand_tray_state_border(state_snapshot, snapshot_fill)
	check(state_snapshot == "出牌", "测试状态使用可出牌分支")
	check(colors_match(live_fill, snapshot_fill), "状态填充色的快照调用保持旧结果")
	check(colors_match(live_border, snapshot_border), "状态边框色可直接复用填充色快照")

	var hand_root := Control.new()
	hand_root.name = "HandTrayStateSnapshotRoot"
	hand_root.size = Vector2(1280.0, 720.0)
	root.add_child(hand_root)
	scene.root_layer = hand_root
	scene.hand_keyboard_selection = -1
	scene.draw_hand(hand_root)
	var tray := hand_root.get_node_or_null("HandTray") as Control
	var badge := hand_root.get_node_or_null("HandTray/HandTrayStateBadge") as Control
	var badge_fill = badge.get_meta("state_fill_snapshot", Color.TRANSPARENT) if badge != null else Color.TRANSPARENT
	var badge_border = badge.get_meta("state_border_snapshot", Color.TRANSPARENT) if badge != null else Color.TRANSPARENT
	check(tray != null and str(tray.get_meta("hand_tray_state_snapshot_policy", "")) == "one_state_text_and_color_snapshot_per_draw", "托盘声明一次状态文本和颜色快照")
	check(tray != null and str(tray.get_meta("hand_tray_state_text_snapshot", "")) == state_snapshot, "托盘保留本次状态文本快照")
	check(badge != null and str(badge.get_meta("state_text_snapshot", "")) == state_snapshot and colors_match(badge_fill, snapshot_fill) and colors_match(badge_border, snapshot_border), "状态徽章复用同一文本、填充色和边框色")

	scene.offline_phase = "ended"
	check(scene.hand_tray_state_text() == "结算", "状态变化后的实时查询仍然更新")
	check(tray != null and str(tray.get_meta("hand_tray_state_text_snapshot", "")) == state_snapshot, "已绘制托盘的快照不会被后续状态读取改写")

	hand_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
