extends SceneTree
## Round 162: table-log rendering reuses one viewport snapshot per draw.

var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if condition:
		print("  OK  | %s" % message)
	else:
		print("  FAIL| %s" % message)
		failed = true


func make_player(name: String) -> Dictionary:
	return {
		"name": name,
		"hand": [],
		"discards": [],
		"melds": [],
		"flowers": 0,
		"flower_tiles": [],
		"score": 25000,
		"bot": true,
	}


func run() -> void:
	print("=== ai_play_round162 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	var test_table_logs: Array[String] = ["event-one", "event-two", "event-three"]
	scene.table_logs = test_table_logs
	scene.table_log_archive_open = false

	var compact_signature: String = scene.table_log_render_signature(Vector2(640.0, 400.0))
	var wide_signature: String = scene.table_log_render_signature(Vector2(1280.0, 720.0))
	check(compact_signature.contains("(640.0, 400.0)") and wide_signature.contains("(1280.0, 720.0)"), "table-log signature accepts an explicit viewport snapshot")
	check(compact_signature != wide_signature and compact_signature.contains("|1|"), "table-log snapshot preserves compact-layout signature state")

	var log_root := Control.new()
	log_root.name = "TableLogSnapshotRoot"
	log_root.size = Vector2(1280.0, 720.0)
	root.add_child(log_root)
	scene.root_layer = log_root
	scene.draw_table_log(log_root)
	var ledger := log_root.get_node_or_null("TableLogLedgerPanel") as Control
	var live_viewport: Vector2 = scene.effective_viewport_size()
	check(ledger != null and ledger.get_meta("table_log_viewport_snapshot", Vector2.ZERO) == live_viewport, "table-log ledger publishes the draw viewport snapshot")
	check(ledger != null and str(ledger.get_meta("table_log_viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "table-log ledger declares one viewport snapshot per draw")
	check(ledger != null and ledger.get_node_or_null("TableLogLedgerTitle") != null and ledger.get_node_or_null("TableLogLedgerCount") != null, "table-log ledger still builds its title and count from the snapshot")

	var archive_root := Control.new()
	archive_root.name = "TableLogArchiveSnapshotRoot"
	archive_root.size = Vector2(1280.0, 720.0)
	root.add_child(archive_root)
	scene.table_log_archive_open = true
	scene.draw_table_log_archive_panel(archive_root)
	var archive := archive_root.get_node_or_null("TableLogArchivePanel") as Control
	check(archive != null and archive.get_meta("table_log_viewport_snapshot", Vector2.ZERO) == live_viewport, "table-log archive publishes the draw viewport snapshot")
	check(archive != null and str(archive.get_meta("table_log_viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "table-log archive reuses one viewport snapshot for all rows")
	check(archive != null and archive.find_child("TableLogArchiveRow_0", true, false) != null and archive.find_child("TableLogArchiveRow_2", true, false) != null, "table-log archive still lays out recent rows")

	log_root.queue_free()
	archive_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
