extends SceneTree
## Round 156: hand-tray decorative art reuses the draw interaction snapshots.

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
	print("=== ai_play_round156 check START ===")
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

	var hand_root := Control.new()
	hand_root.name = "HandTrayInteractionSnapshotRoot"
	hand_root.size = Vector2(1280.0, 720.0)
	root.add_child(hand_root)
	scene.root_layer = hand_root
	scene.hand_keyboard_selection = -1
	scene.draw_hand(hand_root)
	var tray := hand_root.get_node_or_null("HandTray") as Control
	var tile_lane := hand_root.get_node_or_null("HandTray/HandTrayTiles") as Control
	check(tray != null and str(tray.get_meta("hand_tray_state_snapshot_policy", "")) == "one_state_text_snapshot_per_draw", "手牌托盘保留原生状态文本快照契约")
	check(tile_lane != null and bool(tile_lane.get_meta("hand_can_self_discard_snapshot", false)) and not bool(tile_lane.get_meta("hand_pending_danger_discard_snapshot", true)), "原生牌区消费同一次活动与危险快照")
	check(tile_lane != null and not bool(tile_lane.get_meta("hand_pending_claim_window_snapshot", true)), "原生牌区消费同一次响应快照")
	check(tray != null and tray.find_child("HandTrayMomentumArt", true, false) == null and tray.find_child("HandTrayCompletionBusArt", true, false) == null and tray.find_child("HandTraySuitFlow", true, false) == null, "实际手牌托盘不再挂载冗余装饰树")
	scene.pending_danger_discard_tile = "1W"
	scene.pending_danger_discard_index = 0
	check(scene.has_pending_danger_discard(), "实时危险状态在快照之后仍可变化")
	check(tile_lane != null and not bool(tile_lane.get_meta("hand_pending_danger_discard_snapshot", true)), "已绘制原生牌区快照不会被后续状态读取改写")

	hand_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
