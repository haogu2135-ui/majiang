extends SceneTree
## Round 174: loading-page rendering consumes one viewport snapshot.

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
	print("=== ai_play_round174 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	var expected_viewport: Vector2 = scene.effective_viewport_size()
	scene.show_loading_screen({"status": "正在加载中", "progress_ratio": 0.5, "tip": "提示：保持手牌灵活性，避免过早定型"})

	var loading_panel := scene.root_layer.get_node_or_null("LoadingPanel") as Control
	var loading_center := loading_panel.get_node_or_null("LoadingCenterPanel") as Control if loading_panel != null else null
	var title := loading_panel.find_child("LoadingTitleLabel", true, false) as Label if loading_panel != null else null
	var status := loading_panel.find_child("LoadingStatusLabel", true, false) as Label if loading_panel != null else null
	var tip := loading_panel.find_child("LoadingTipLabel", true, false) as Label if loading_panel != null else null
	check(loading_panel != null and loading_panel.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "加载面板发布本次绘制的 viewport 快照")
	check(loading_panel != null and str(loading_panel.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "加载面板声明每次绘制只读取一次 viewport")
	check(loading_center != null and title != null and status != null and tip != null, "正常加载页仍完整构建标题、状态和提示文本")

	scene.show_loading_screen({"error": true, "status": "网络超时", "progress_ratio": -1.0, "tip": "提示：注意观察对手弃牌，判断危险牌"})
	var error_panel := scene.root_layer.get_node_or_null("LoadingPanel") as Control
	var error_hint := error_panel.find_child("LoadingErrorHint", true, false) as Label if error_panel != null else null
	check(error_panel != null and error_panel.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "错误加载页复用同一 viewport 快照语义")
	check(error_hint != null and error_hint.visible, "错误加载页仍构建可见恢复提示")

	scene.mode = "menu"
	check(error_panel != null and error_panel.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "后续状态变化不会改写已完成的加载 viewport 快照")

	scene.clear_screen()
	scene.root_layer = null
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
