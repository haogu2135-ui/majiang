extends SceneTree
## Round 178: achievement rows reuse the page viewport snapshot.

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
	print("=== ai_play_round178 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	var expected_viewport: Vector2 = scene.effective_viewport_size()
	scene.show_achievements_screen(true)

	var panel := scene.root_layer.get_node_or_null("AchievementGalleryFrontPanel") as Control
	var row := panel.find_child("AchievementRow_first_win", true, false) as Control if panel != null else null
	check(row != null and row.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "成就行发布页面传入的 viewport 快照")
	check(row != null and str(row.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_row", "成就行声明只读取一次 viewport")
	check(row != null and is_equal_approx(float(row.get_meta("row_height_px", -1.0)), scene.achievement_row_height_contract(expected_viewport)), "成就行高继续使用页面快照")

	var direct_row: Control = scene.make_achievement_row("first_win", 0)
	check(direct_row != null and direct_row.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "独立成就行调用保留实时 viewport 回退")
	direct_row.queue_free()
	scene.mode = "menu"
	check(row != null and row.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "后续页面状态不会改写已完成的成就行快照")

	scene.clear_screen()
	scene.root_layer = null
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
