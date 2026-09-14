extends SceneTree
## Round 175: online-lobby rendering reuses one viewport snapshot through its initial refresh.

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
	print("=== ai_play_round175 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	var expected_viewport: Vector2 = scene.effective_viewport_size()
	scene.show_online_lobby(true)

	var panel := scene.root_layer.get_node_or_null("OnlineLobbyLowFrequencyPagePlate") as Control
	var form := panel.get_node_or_null("OnlineLobbyFormPanel") as Control if panel != null else null
	var log_scroll := panel.find_child("OnlineLobbyLogScroll", true, false) as Control if panel != null else null
	var room_badge := panel.find_child("OnlineLobbyRoomBadge", true, false) as Control if panel != null else null
	check(panel != null and panel.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "联机大厅面板发布本次绘制的 viewport 快照")
	check(panel != null and str(panel.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "联机大厅面板声明每次绘制只读取一次 viewport")
	check(form != null and log_scroll != null and room_badge != null, "联机大厅首次刷新仍完整构建表单、日志和房间摘要")

	scene.online_waiting_for_server = true
	scene.online_feedback = "等待服务器确认"
	scene.refresh_online_lobby_state()
	check(panel != null and panel.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "后续联机状态刷新不会改写已完成的大厅 viewport 快照")

	scene.clear_screen()
	scene.root_layer = null
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
