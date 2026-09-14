extends SceneTree
## Round 200: discard river row sizing reuses one viewport snapshot.

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
	print("=== ai_play_round200 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame

	var river_root := Control.new()
	river_root.name = "DiscardRiverViewportSnapshotRoot"
	river_root.size = Vector2(1280.0, 720.0)
	root.add_child(river_root)
	scene.root_layer = river_root
	scene.mode = "offline"
	var river_discards: Array = []
	for _i in range(60):
		river_discards.append("1W")
	while scene.players.size() < 4:
		scene.players.append({"discards": []})
	scene.players[0]["discards"] = river_discards
	scene.last_discard = "1W"
	scene.last_discard_seat = 0
	scene.draw_discards(river_root)

	var expected_viewport: Vector2 = scene.effective_viewport_size()
	check(river_root.get_meta("discard_river_viewport_snapshot", Vector2.ZERO) == expected_viewport, "discard river publishes the draw viewport snapshot")
	check(str(river_root.get_meta("discard_river_viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "discard river declares one viewport read per draw")

	var side_zone: Rect2 = scene.DISCARD_ZONES[2][1]
	var probe_table_size := Vector2(1280.0, 1600.0)
	var wide_viewport := Vector2(1280.0, 720.0)
	var compact_viewport := Vector2(960.0, 540.0)
	var wide_rows: int = scene.discard_zone_visible_rows_for_table_size(side_zone, 3, probe_table_size, wide_viewport)
	var compact_rows: int = scene.discard_zone_visible_rows_for_table_size(side_zone, 3, probe_table_size, compact_viewport)
	check(wide_rows == 4 and compact_rows == 3, "explicit viewport snapshots drive side-river row caps")

	var live_viewport: Vector2 = scene.effective_viewport_size()
	var live_rows: int = scene.discard_zone_visible_rows(side_zone, 3)
	var explicit_live_rows: int = scene.discard_zone_visible_rows(side_zone, 3, live_viewport)
	check(explicit_live_rows == live_rows, "viewport-aware row sizing preserves the live fallback result")

	var saved_viewport: Vector2 = river_root.get_meta("discard_river_viewport_snapshot", Vector2.ZERO)
	scene.large_text_enabled = true
	check(river_root.get_meta("discard_river_viewport_snapshot", Vector2.ZERO) == saved_viewport, "later state changes do not rewrite the completed river viewport snapshot")

	river_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
