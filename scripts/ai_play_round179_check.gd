extends SceneTree
## Round 179: rules rendering reuses one viewport snapshot.

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
	print("=== ai_play_round179 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	var expected_viewport: Vector2 = scene.effective_viewport_size()
	scene.show_rules_screen(true)

	var panel := scene.root_layer.get_node_or_null("RulesCodexFrontPanel") as Control
	var guide := panel.get_node_or_null("RulesGuideArt") as Control if panel != null else null
	var content_scroll := panel.get_node_or_null("RulesContentScroll") as Control if panel != null else null
	var content := panel.find_child("RulesContentList", true, false) as Control if panel != null else null
	check(panel != null and panel.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "规则面板发布本次绘制的 viewport 快照")
	check(panel != null and str(panel.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "规则面板声明每次绘制只读取一次 viewport")
	check(guide != null and guide.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "规则导航复用页面 viewport 快照")
	check(guide != null and str(guide.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "规则导航声明复用页面 viewport 快照")
	check(content_scroll != null and content != null, "规则页仍完整构建滚动容器和内容列表")

	var direct_parent := Control.new()
	var direct_guide: Control = scene.draw_rules_guide_art(direct_parent)
	check(direct_guide != null and direct_guide.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "独立规则导航调用保留实时 viewport 回退")
	direct_parent.queue_free()
	scene.mode = "menu"
	check(panel != null and panel.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport and guide != null and guide.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "后续页面状态不会改写已完成的规则快照")

	scene.clear_screen()
	scene.root_layer = null
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
