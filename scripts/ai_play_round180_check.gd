extends SceneTree
## Round 180: stats summary chips reuse the page viewport snapshot.

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
	print("=== ai_play_round180 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	var expected_viewport: Vector2 = scene.effective_viewport_size()
	scene.show_stats_screen(true)

	var panel := scene.root_layer.get_node_or_null("StatsConsoleFrontPanel") as Control
	var dashboard := panel.find_child("StatsDashboardArt", true, false) as Control if panel != null else null
	var chip := panel.find_child("StatsSummaryChip_winrate", true, false) as Control if panel != null else null
	check(dashboard != null and dashboard.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "统计摘要 dashboard 发布页面 viewport 快照")
	check(dashboard != null and str(dashboard.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "统计摘要 dashboard 声明只读取一次 viewport")
	check(chip != null and chip.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "统计摘要 chip 复用 dashboard viewport 快照")
	check(chip != null and str(chip.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_chip", "统计摘要 chip 声明只读取一次 viewport")
	check(panel != null and panel.find_child("StatsSummaryChip_games", true, false) != null and panel.find_child("StatsSummaryChip_best", true, false) != null, "三个统计摘要 chip 仍完整构建")

	var direct_parent := Control.new()
	var direct_chip: Control = scene.make_stats_summary_chip(direct_parent, "fallback", "测试", "1局", Rect2(0.0, 0.0, 0.4, 0.4), Color.WHITE)
	check(direct_chip != null and direct_chip.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "独立统计 chip 调用保留实时 viewport 回退")
	direct_parent.queue_free()
	scene.mode = "menu"
	check(dashboard != null and dashboard.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport and chip != null and chip.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "后续页面状态不会改写已完成的统计摘要快照")

	scene.clear_screen()
	scene.root_layer = null
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
