extends SceneTree
## Round 197: replay archive row pooling shares its parsed date snapshot.

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
	print("=== ai_play_round197 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame

	var archive_root := Control.new()
	archive_root.name = "ReplayArchiveDateBuildSnapshotRoot"
	archive_root.size = Vector2(1280.0, 720.0)
	root.add_child(archive_root)
	scene.root_layer = archive_root
	scene.mode = "replay_import"
	var entry := {"archive_id": "snapshot197", "timestamp": 1789000000, "result_kind": "win", "replay_digest": "abc12345", "rule_variant": "standard", "favorite": false}
	var expected_date: String = scene.replay_archive_date_text(entry)
	var row: Control = scene.replay_archive_row_for_entry(entry)
	archive_root.add_child(row)
	var primary := row.get_node_or_null("ReplayArchiveRowPrimary") as Label
	check(row.get_meta("archive_date_text_snapshot", "") == expected_date, "归档行仍发布完整日期快照")
	check(str(row.get_meta("archive_date_build_policy", "")) == "shared_precomputed_date", "归档行构建复用行签名已解析的日期")
	check(primary != null and primary.tooltip_text == expected_date and primary.text != "", "共享日期快照仍保持显示和 tooltip 文本")
	entry["timestamp"] = 1790000000
	check(row.get_meta("archive_date_text_snapshot", "") == expected_date and primary != null and primary.tooltip_text == expected_date, "后续归档数据变化不会改写已完成的日期快照")

	archive_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
