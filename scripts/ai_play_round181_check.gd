extends SceneTree
## Round 181: hand rendering reuses its existing viewport snapshot.

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
	print("=== ai_play_round181 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 0
	scene.tutorial_step = scene.TUTORIAL_STEP_DISCARD
	scene.show_hand_hint = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "2T", "3T", "5B", "E", "E"]
	scene.hand_keyboard_selection = -1

	var hand_root := Control.new()
	hand_root.name = "HandViewportSnapshotRoot"
	hand_root.size = Vector2(1280.0, 720.0)
	root.add_child(hand_root)
	scene.root_layer = hand_root
	var expected_viewport: Vector2 = scene.effective_viewport_size()
	scene.draw_hand(hand_root)

	var tray := hand_root.get_node_or_null("HandTray") as Control
	var tutorial_hint := hand_root.get_node_or_null("HandTray/HandTrayTutorialHint") as Control
	check(tray != null and tray.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "手牌托盘发布本次绘制的 viewport 快照")
	check(tray != null and str(tray.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "手牌托盘声明每次绘制只读取一次 viewport")
	check(tutorial_hint != null, "教程状态仍完整构建手牌提示区域")

	scene.offline_phase = "ended"
	check(tray != null and tray.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "后续牌局状态不会改写已完成的手牌 viewport 快照")

	hand_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
