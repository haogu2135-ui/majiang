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

	var art_root := Control.new()
	art_root.name = "HandArtSnapshotRoot"
	art_root.size = Vector2(1280.0, 720.0)
	root.add_child(art_root)
	var hand: Array = scene.players[0]["hand"]
	var group_counts: Array[int] = scene.hand_group_counts(hand)
	var momentum_snapshot: Control = scene.draw_hand_tray_momentum_art(art_root, hand, false, "出牌", 0, 0)
	var completion_snapshot: Control = scene.draw_hand_tray_completion_bus_art(art_root, hand, group_counts, "出牌", 0)
	var suit_snapshot: Control = scene.draw_hand_tray_suit_flow(art_root, hand, false, group_counts, 0)
	check(momentum_snapshot != null and not bool(momentum_snapshot.get_meta("hand_active_snapshot", true)) and not bool(momentum_snapshot.get_meta("hand_danger_snapshot", true)), "动量装饰消费显式活动与危险快照")
	check(completion_snapshot != null and not bool(completion_snapshot.get_meta("hand_active_snapshot", true)), "完成装饰消费显式活动快照")
	check(suit_snapshot != null and not bool(suit_snapshot.get_meta("hand_danger_snapshot", true)), "花色装饰消费显式危险快照")
	art_root.queue_free()

	var hand_root := Control.new()
	hand_root.name = "HandTrayInteractionSnapshotRoot"
	hand_root.size = Vector2(1280.0, 720.0)
	root.add_child(hand_root)
	scene.root_layer = hand_root
	scene.hand_keyboard_selection = -1
	scene.draw_hand(hand_root)
	var tray := hand_root.get_node_or_null("HandTray") as Control
	var momentum := hand_root.get_node_or_null("HandTray/HandTrayMomentumArt") as Control
	var completion := hand_root.get_node_or_null("HandTray/HandTrayCompletionBusArt") as Control
	var suit := hand_root.get_node_or_null("HandTray/HandTraySuitFlow") as Control
	check(tray != null and str(tray.get_meta("hand_tray_state_snapshot_policy", "")) == "one_state_text_and_color_snapshot_per_draw", "手牌托盘仍保留状态快照契约")
	check(momentum != null and bool(momentum.get_meta("hand_active_snapshot", false)) and not bool(momentum.get_meta("hand_danger_snapshot", true)), "重绘时动量装饰复用已有交互状态")
	check(completion != null and bool(completion.get_meta("hand_active_snapshot", false)), "重绘时完成装饰复用已有活动状态")
	check(suit != null and not bool(suit.get_meta("hand_danger_snapshot", true)), "重绘时花色装饰复用已有危险状态")

	scene.pending_danger_discard_tile = "1W"
	scene.pending_danger_discard_index = 0
	check(scene.has_pending_danger_discard(), "实时危险状态在快照之后仍可变化")
	check(momentum != null and not bool(momentum.get_meta("hand_danger_snapshot", true)) and suit != null and not bool(suit.get_meta("hand_danger_snapshot", true)), "已绘制装饰快照不会被后续状态读取改写")

	hand_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
