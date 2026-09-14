extends SceneTree
## Round 176: stats rendering consumes one viewport and content-size snapshot.

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
	print("=== ai_play_round176 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	var expected_viewport: Vector2 = scene.effective_viewport_size()
	var expected_content_size: Vector2 = scene.safe_content_pixel_size()
	scene.show_stats_screen(true)

	var panel := scene.root_layer.get_node_or_null("StatsConsoleFrontPanel") as Control
	var rows := panel.get_node_or_null("StatsRows") as Control if panel != null else null
	var status := panel.get_node_or_null("StatsRowsScrollStatus") as Label if panel != null else null
	check(panel != null and panel.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "统计面板发布本次绘制的 viewport 快照")
	check(panel != null and str(panel.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "统计面板声明每次绘制只读取一次 viewport")
	check(panel != null and panel.get_meta("content_size_snapshot", Vector2.ZERO) == expected_content_size, "统计面板发布本次绘制的 content-size 快照")
	check(panel != null and str(panel.get_meta("content_size_snapshot_policy", "")) == "one_content_size_snapshot_per_draw", "统计面板声明每次绘制只读取一次 content-size")
	check(rows != null and status != null, "统计页仍完整构建滚动容器和位置状态")

	scene.stats_selected_rule = "local"
	scene.mode = "menu"
	check(panel != null and panel.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport and panel.get_meta("content_size_snapshot", Vector2.ZERO) == expected_content_size, "后续状态变化不会改写已完成的统计快照")

	scene.clear_screen()
	scene.root_layer = null
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
