extends SceneTree
## Round 172: daily-login rendering consumes one viewport snapshot.

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
	print("=== ai_play_round172 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "daily_login"
	scene.large_text_enabled = false
	var expected_viewport: Vector2 = scene.effective_viewport_size()
	scene.show_daily_login_panel({"consecutive_days": 5, "claimed_today": false})

	var panel := scene.root_layer.get_node_or_null("DailyLoginPanel") as Control
	var indicators := panel.get_node_or_null("DailyLoginDayIndicators") as Control if panel != null else null
	check(panel != null and panel.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "每日签到面板发布本次绘制的 viewport 快照")
	check(panel != null and str(panel.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "每日签到面板声明每次绘制只读取一次 viewport")
	check(indicators != null and indicators.get_child_count() == 7, "七个签到日节点仍完整构建")
	var day_label := indicators.get_node_or_null("DailyLoginDayNode_1/DailyLoginDayLabel_1") as Label if indicators != null else null
	var state_label := indicators.get_node_or_null("DailyLoginDayNode_1/DailyLoginDayStateLabel_1") as Label if indicators != null else null
	var reward_label := indicators.get_node_or_null("DailyLoginDayNode_1/DailyLoginRewardLabel_1") as Label if indicators != null else null
	check(day_label != null and state_label != null and reward_label != null, "日期卡片仍保留日期、状态和奖励文本三条读取通道")

	scene.large_text_enabled = true
	scene.mode = "menu"
	check(panel != null and panel.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "后续布局状态变化不会改写已完成的签到 viewport 快照")

	panel.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
