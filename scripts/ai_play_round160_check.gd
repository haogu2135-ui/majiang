extends SceneTree
## Round 160: pending-claim context scoring reuses occupancy geometry.

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
	print("=== ai_play_round160 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_phase = "pending_claim"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var content_size: Vector2 = scene.safe_content_pixel_size()
	var table_outer: Rect2 = scene.table_outer_rect_for_viewport()
	var outer_width := maxf(0.001, table_outer.size.x - table_outer.position.x)
	var outer_height := maxf(0.001, table_outer.size.y - table_outer.position.y)
	var table_left: float = float(table_outer.position.x + scene.TABLE_INNER_RECT.position.x * outer_width)
	var table_top: float = float(table_outer.position.y + scene.TABLE_INNER_RECT.position.y * outer_height)
	var table_width: float = float(outer_width * maxf(0.001, scene.TABLE_INNER_RECT.size.x - scene.TABLE_INNER_RECT.position.x))
	var table_height: float = float(outer_height * maxf(0.001, scene.TABLE_INNER_RECT.size.y - scene.TABLE_INNER_RECT.position.y))
	var occupancy_snapshot: Array = scene.pending_claim_context_occupancy_snapshot(table_left, table_top, table_width, table_height, content_size)
	check(occupancy_snapshot.size() > 0, "pending claim layout publishes bounded occupancy geometry")

	var candidates: Array[Rect2] = [
		Rect2(Vector2(0.015, 0.108), Vector2(0.280, 0.220)),
		Rect2(Vector2(0.110, 0.300), Vector2(0.320, 0.390)),
		Rect2(Vector2(0.350, 0.300), Vector2(0.500, 0.390)),
	]
	for candidate in candidates:
		var live_clear: bool = scene.pending_claim_context_candidate_is_clear(candidate, table_left, table_top, table_width, table_height)
		var snapshot_clear: bool = scene.pending_claim_context_candidate_is_clear(candidate, table_left, table_top, table_width, table_height, occupancy_snapshot)
		check(live_clear == snapshot_clear, "occupancy snapshot preserves candidate clearance")

	var selected_rect: Rect2 = scene.pending_claim_context_layout_rect(content_size)
	check(selected_rect.size.x > 0.0 and selected_rect.size.y > 0.0, "pending claim context still selects a bounded lane")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
