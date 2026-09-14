extends SceneTree
## Round 201: discard river chrome signatures reuse one viewport snapshot.

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
	print("=== ai_play_round201 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame

	var river_root := Control.new()
	river_root.name = "DiscardRiverChromeViewportSnapshotRoot"
	river_root.size = Vector2(1280.0, 720.0)
	root.add_child(river_root)
	scene.root_layer = river_root
	scene.mode = "offline"
	while scene.players.size() < 4:
		scene.players.append({"discards": []})
	var river_discards: Array = []
	for _i in range(20):
		river_discards.append("1W")
	scene.players[0]["discards"] = river_discards
	scene.last_discard = "1W"
	scene.last_discard_seat = 0
	scene.draw_discards(river_root)

	var expected_viewport: Vector2 = scene.effective_viewport_size()
	check(river_root.get_meta("discard_river_viewport_snapshot", Vector2.ZERO) == expected_viewport, "discard river chrome consumes the draw viewport snapshot")

	var zone: Rect2 = scene.DISCARD_ZONES[0][1]
	var live_viewport: Vector2 = scene.effective_viewport_size()
	var compact_viewport := Vector2(960.0, 540.0)
	var fallback_art_signature: String = scene.discard_river_art_render_signature(0, zone, 20, 0)
	var explicit_art_signature: String = scene.discard_river_art_render_signature(0, zone, 20, 0, live_viewport)
	var compact_art_signature: String = scene.discard_river_art_render_signature(0, zone, 20, 0, compact_viewport)
	check(explicit_art_signature == fallback_art_signature, "river art signature preserves the live fallback result")
	check(compact_art_signature != fallback_art_signature, "river art signature consumes an explicit viewport snapshot")

	var fallback_owner_signature: String = scene.discard_river_owner_overlay_render_signature(0, zone, 20, 0, 16, 16, 8, 2, -1, 0, 0, false, 0)
	var explicit_owner_signature: String = scene.discard_river_owner_overlay_render_signature(0, zone, 20, 0, 16, 16, 8, 2, -1, 0, 0, false, 0, live_viewport)
	var compact_owner_signature: String = scene.discard_river_owner_overlay_render_signature(0, zone, 20, 0, 16, 16, 8, 2, -1, 0, 0, false, 0, compact_viewport)
	check(explicit_owner_signature == fallback_owner_signature, "owner overlay signature preserves the live fallback result")
	check(compact_owner_signature != fallback_owner_signature, "owner overlay signature consumes an explicit viewport snapshot")

	var saved_viewport: Vector2 = river_root.get_meta("discard_river_viewport_snapshot", Vector2.ZERO)
	scene.large_text_enabled = true
	check(river_root.get_meta("discard_river_viewport_snapshot", Vector2.ZERO) == saved_viewport, "later state changes do not rewrite the completed chrome viewport snapshot")

	river_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
