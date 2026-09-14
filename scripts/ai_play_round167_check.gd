extends SceneTree
## Round 167: score strip reuses one viewport snapshot.

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
	print("=== ai_play_round167 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.current_seat = 0
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var score_root := Control.new()
	score_root.name = "ScoreStripViewportSnapshotRoot"
	score_root.size = Vector2(1280.0, 720.0)
	root.add_child(score_root)
	scene.root_layer = score_root
	var expected_viewport: Vector2 = scene.effective_viewport_size()
	scene.draw_score_strip(score_root, Rect2(0.0, 0.0, 1.0, 1.0))
	var strip := score_root.get_node_or_null("ScoreStrip") as Control
	check(strip != null and strip.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "分数条发布本次绘制的 viewport 快照")
	check(strip != null and str(strip.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "分数条声明每次绘制只读取一次 viewport")

	scene.current_seat = 2
	check(strip != null and strip.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "后续状态变化不会改写已完成的 viewport 快照")

	score_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
