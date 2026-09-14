extends SceneTree
## Round 182: achievement completion art reuses its viewport snapshot.

var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if condition:
		print("  OK  | %s" % message)
	else:
		print("  FAIL| %s" % message)
		failed = true


func run() -> void:
	print("=== ai_play_round182 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.achievements = {"first_win": true, "ten_wins": false}

	var art_root := Control.new()
	art_root.name = "AchievementCompletionSnapshotRoot"
	art_root.size = Vector2(1280.0, 720.0)
	root.add_child(art_root)
	scene.root_layer = art_root
	var expected_viewport: Vector2 = scene.effective_viewport_size()
	var art: Control = scene.draw_achievements_completion_convergence_art(art_root)
	check(art != null and art.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "成就收集进度发布本次绘制的 viewport 快照")
	check(art != null and str(art.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "成就收集进度声明每次绘制只读取一次 viewport")
	check(art != null and art.get_node_or_null("AchievementsCompletionRoute/AchievementsCompletionFill") != null and art.get_node_or_null("AchievementsCompletionSeal") != null, "收集进度路线和成就印章仍完整构建")
	scene.achievements["first_win"] = false
	check(art != null and art.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "后续成就状态变化不会改写已完成的 viewport 快照")

	art_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
