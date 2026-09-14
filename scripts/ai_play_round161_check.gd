extends SceneTree
## Round 161: advisor candidate scoring reuses occupancy geometry.

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
	print("=== ai_play_round161 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var occupancy_snapshot: Array = scene.advisor_panel_occupancy_snapshot()
	check(occupancy_snapshot.size() > 0, "advisor layout publishes bounded occupancy geometry")
	var candidates: Array[Rect2] = [
		Rect2(Vector2(0.015, 0.115), Vector2(0.350, 0.305)),
		Rect2(Vector2(0.650, 0.115), Vector2(0.985, 0.305)),
		Rect2(Vector2(0.015, 0.535), Vector2(0.350, 0.705)),
		Rect2(Vector2(0.650, 0.535), Vector2(0.985, 0.705)),
	]
	for candidate in candidates:
		var live_clear: bool = scene.advisor_panel_candidate_is_clear(candidate)
		var snapshot_clear: bool = scene.advisor_panel_candidate_is_clear(candidate, occupancy_snapshot)
		check(live_clear == snapshot_clear, "advisor occupancy snapshot preserves candidate clearance")

	var selected_rect: Rect2 = scene.advisor_panel_layout_rect()
	check(selected_rect.size.x > 0.0 and selected_rect.size.y > 0.0, "advisor panel still selects a bounded lane")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
