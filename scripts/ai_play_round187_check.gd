extends SceneTree
## Round 187: setting-row text budgets reuse their viewport snapshot.

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
	print("=== ai_play_round187 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.large_text_enabled = false

	var row_root := Control.new()
	row_root.name = "SettingRowViewportSnapshotRoot"
	row_root.size = Vector2(1280.0, 720.0)
	root.add_child(row_root)
	scene.root_layer = row_root
	var expected_viewport: Vector2 = scene.effective_viewport_size()
	var row_button := Button.new()
	scene.make_setting_row(row_root, "AI 节奏", "已开启", row_button)
	var row := row_root.get_node_or_null("SettingRow_AI 节奏") as Control
	var title := row.get_node_or_null("SettingRowTitle_AI 节奏") as Label if row != null else null
	var status := row.get_node_or_null("SettingRowStatus_AI 节奏") as Label if row != null else null
	check(row != null and row.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "设置行发布本次绘制的 viewport 快照")
	check(row != null and str(row.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "设置行声明每次绘制只读取一次 viewport")
	check(title != null and status != null and title.text == "AI 节奏" and status.text != "", "设置行标题和状态仍完整构建")
	scene.large_text_enabled = true
	check(row != null and row.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "后续设置排版状态不会改写已完成的 viewport 快照")

	row_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
