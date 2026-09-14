extends SceneTree
## Round 192: toast geometry reuses its viewport snapshot.

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
	print("=== ai_play_round192 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "menu"
	scene.ensure_fx_layer()

	var page_root := Control.new()
	page_root.name = "ToastViewportSnapshotRoot"
	page_root.size = Vector2(1280.0, 720.0)
	root.add_child(page_root)
	scene.root_layer = page_root
	var expected_viewport: Vector2 = scene.effective_viewport_size()
	scene.show_toast("一条较长的连接反馈提示", 1000)
	var toast := scene.toast_current as Control
	var label := toast.get_node_or_null("ToastPendingLabel") as Label if toast != null else null
	check(toast != null and toast.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "提示条发布本次绘制的 viewport 快照")
	check(toast != null and str(toast.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "提示条声明每次绘制只读取一次 viewport")
	check(label != null, "提示条仍完整构建队列状态节点")
	scene.mode = "offline"
	check(toast != null and toast.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "后续页面状态不会改写已完成的提示条快照")

	page_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
