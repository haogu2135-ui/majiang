extends SceneTree
## Round 195: replay archive rows reuse their viewport snapshot.

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
	print("=== ai_play_round195 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame

	var page_root := Control.new()
	page_root.name = "ReplayArchiveViewportSnapshotRoot"
	page_root.size = Vector2(1280.0, 720.0)
	root.add_child(page_root)
	scene.root_layer = page_root
	scene.mode = "replay_import"
	var expected_viewport: Vector2 = scene.effective_viewport_size()
	var entry := {"archive_id": "snapshot195", "timestamp": 1789000000, "result_kind": "win", "replay_digest": "abc12345", "rule_variant": "standard", "favorite": false}
	var row: Control = scene.make_replay_archive_row(entry)
	page_root.add_child(row)
	var primary := row.get_node_or_null("ReplayArchiveRowPrimary") as Label
	var result := row.get_node_or_null("ReplayArchiveRowResult") as Label
	var open_button := row.find_child("ReplayArchiveOpenButton_snapshot", true, false) as Button
	check(row.get_meta("archive_viewport_snapshot", Vector2.ZERO) == expected_viewport, "回放归档行发布本次绘制的 viewport 快照")
	check(str(row.get_meta("archive_viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_row", "回放归档行声明每行只读取一次 viewport")
	check(primary != null and result != null and open_button != null and primary.text != "" and result.text != "", "归档日期、结果和操作仍完整构建")
	scene.large_text_enabled = true
	check(row.get_meta("archive_viewport_snapshot", Vector2.ZERO) == expected_viewport, "后续阅读状态不会改写已完成的归档 viewport 快照")

	page_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
