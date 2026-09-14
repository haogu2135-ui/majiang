extends SceneTree
## Round 177: achievement rendering consumes one viewport snapshot.

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
	print("=== ai_play_round177 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	var expected_viewport: Vector2 = scene.effective_viewport_size()
	scene.show_achievements_screen(true)

	var panel := scene.root_layer.get_node_or_null("AchievementGalleryFrontPanel") as Control
	var grid := panel.find_child("AchievementsGrid", true, false) as Control if panel != null else null
	var row := panel.find_child("AchievementRow_first_win", true, false) as Control if panel != null else null
	check(panel != null and panel.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "成就面板发布本次绘制的 viewport 快照")
	check(panel != null and str(panel.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "成就面板声明每次绘制只读取一次 viewport")
	check(grid != null and row != null, "成就页仍完整构建列表和成就行")
	check(row != null and is_equal_approx(float(row.get_meta("row_height_px", -1.0)), scene.achievement_row_height_contract(expected_viewport)), "成就行使用页面 viewport 快照计算行高")
	check(is_equal_approx(scene.achievement_row_height_contract(), scene.achievement_row_height_contract(expected_viewport)), "成就行高契约保留无参实时回退")

	scene.large_text_enabled = true
	scene.mode = "menu"
	check(panel != null and panel.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "后续状态变化不会改写已完成的成就 viewport 快照")

	scene.clear_screen()
	scene.root_layer = null
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
