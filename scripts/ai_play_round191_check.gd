extends SceneTree
## Round 191: replay archive rows reuse their parsed date text.

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
	print("=== ai_play_round191 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame

	var archive_root := Control.new()
	archive_root.name = "ReplayArchiveDateSnapshotRoot"
	archive_root.size = Vector2(1280.0, 720.0)
	root.add_child(archive_root)
	scene.root_layer = archive_root
	var entry := {"archive_id": "snapshot191", "timestamp": 1789000000, "result_kind": "win", "replay_digest": "abc12345", "rule_variant": "standard", "favorite": false}
	var row: Control = scene.make_replay_archive_row(entry)
	archive_root.add_child(row)
	var date_text := str(row.get_meta("archive_date_text_snapshot", ""))
	var display_date_text := str(row.get_meta("archive_display_date_text_snapshot", ""))
	var primary := row.get_node_or_null("ReplayArchiveRowPrimary") as Label
	check(row != null and date_text != "" and display_date_text != "", "回放归档行发布完整日期和展示日期快照")
	check(str(row.get_meta("archive_date_text_snapshot_policy", "")) == "one_date_parse_per_row", "回放归档行声明每行只解析一次日期")
	check(primary != null and primary.text == display_date_text and primary.tooltip_text == date_text, "归档日期显示和 tooltip 仍保持完整/短文本层级")
	entry["timestamp"] = 1790000000
	check(row.get_meta("archive_date_text_snapshot", "") == date_text and primary != null and primary.text == display_date_text, "后续归档数据变化不会改写已完成的日期快照")

	archive_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
