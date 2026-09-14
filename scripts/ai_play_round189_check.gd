extends SceneTree
## Round 189: online feedback art reuses its viewport snapshot.

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
	print("=== ai_play_round189 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.online_feedback = "等待服务器确认"
	scene.online_waiting_for_server = true

	var feedback_root := Control.new()
	feedback_root.name = "OnlineFeedbackViewportSnapshotRoot"
	feedback_root.size = Vector2(1280.0, 720.0)
	root.add_child(feedback_root)
	scene.root_layer = feedback_root
	var expected_viewport: Vector2 = scene.effective_viewport_size()
	var art: Control = scene.draw_online_feedback_art(feedback_root)
	var label := art.get_node_or_null("OnlineFeedbackText") as Label if art != null else null
	check(art != null and art.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "联机反馈插画发布本次绘制的 viewport 快照")
	check(art != null and str(art.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "联机反馈插画声明每次绘制只读取一次 viewport")
	check(label != null and label.text != "", "联机反馈文字仍完整构建")
	scene.online_feedback = "连接已恢复"
	check(art != null and art.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "后续联机状态变化不会改写已完成的 viewport 快照")

	scene.online_feedback = ""
	scene.online_waiting_for_server = false
	check(scene.draw_online_feedback_art(feedback_root) == null, "无联机反馈时仍保留早退路径")

	feedback_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
