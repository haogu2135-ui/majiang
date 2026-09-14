extends SceneTree
## Round 194: exit-confirm geometry reuses its viewport snapshot.

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
	print("=== ai_play_round194 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame

	var page_root := Control.new()
	page_root.name = "ExitConfirmViewportSnapshotRoot"
	page_root.size = Vector2(1280.0, 720.0)
	root.add_child(page_root)
	scene.root_layer = page_root
	scene.mode = "offline"
	var expected_viewport: Vector2 = scene.effective_viewport_size()
	scene.show_exit_confirm()
	var dialog := page_root.get_node_or_null("ExitConfirmOverlay/ExitConfirmDialog") as Control
	var message := dialog.get_node_or_null("ExitConfirmMessage") as Label if dialog != null else null
	var continue_button := dialog.find_child("ExitConfirmContinueButton", true, false) as Button if dialog != null else null
	check(dialog != null and dialog.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "退出确认对话框发布本次绘制的 viewport 快照")
	check(dialog != null and str(dialog.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "退出确认对话框声明每次绘制只读取一次 viewport")
	check(message != null and continue_button != null and message.text != "", "退出确认消息和继续按钮仍完整构建")
	scene.exit_confirm_decision_locked = true
	check(dialog != null and dialog.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "后续退出状态不会改写已完成的对话框快照")

	page_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
