extends SceneTree
## Round 166: score-strip delta text is resolved once per chip.

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
	print("=== ai_play_round166 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.current_seat = 0
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.last_score_deltas.clear()
	for delta in [100, -200, 0, 0]:
		scene.last_score_deltas.append(delta)

	var first_root := Control.new()
	first_root.name = "ScoreDeltaSnapshotRoot"
	first_root.size = Vector2(1280.0, 720.0)
	root.add_child(first_root)
	scene.root_layer = first_root
	scene.draw_score_strip(first_root, Rect2(0.0, 0.0, 1.0, 1.0))
	var first_delta := first_root.get_node_or_null("ScoreStrip/ScoreStripChip_1/ScoreStripDelta_1") as Label
	check(first_delta != null and first_delta.text == "变化 -200", "分数变化标签保留原有文本")
	check(first_delta != null and first_delta.tooltip_text == "分数变化： -200" and str(first_delta.get_meta("score_delta_text_snapshot", "")) == " -200", "tooltip 和无障碍元数据复用同一分数变化快照")
	check(first_delta != null and str(first_delta.get_meta("score_delta_text_snapshot_policy", "")) == "one_score_delta_snapshot_per_chip", "分数变化标签声明每个 chip 只解析一次文本")

	scene.last_score_deltas[1] = 8000
	check(first_delta != null and first_delta.text == "变化 -200" and first_delta.tooltip_text == "分数变化： -200", "后续分数变化不会改写已完成的 chip 文本快照")

	var second_root := Control.new()
	second_root.name = "ScoreDeltaFreshSnapshotRoot"
	second_root.size = Vector2(1280.0, 720.0)
	root.add_child(second_root)
	scene.root_layer = second_root
	scene.draw_score_strip(second_root, Rect2(0.0, 0.0, 1.0, 1.0))
	var second_delta := second_root.get_node_or_null("ScoreStrip/ScoreStripChip_1/ScoreStripDelta_1") as Label
	check(second_delta != null and second_delta.text == "变化 +8000" and second_delta.tooltip_text == "分数变化： +8000", "下一次分数条绘制重新获取实时分数变化")

	first_root.queue_free()
	second_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
