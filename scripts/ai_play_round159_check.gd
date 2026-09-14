extends SceneTree
## Round 159: chat candidate scoring reuses the full occupancy geometry snapshot.

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
	print("=== ai_play_round159 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_sim_quiet = true
	scene.current_seat = 0
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "2T", "3T", "5B", "E"]
	scene.wall.clear()
	for _i in range(60):
		scene.wall.append("1B")

	var occupancy_snapshot: Dictionary = scene.chat_panel_occupancy_snapshot()
	check(occupancy_snapshot.has("occupied") and occupancy_snapshot.has("ledger_geometry") and occupancy_snapshot.has("visible_meld_seats"), "chat layout publishes one complete occupancy snapshot")
	check(int(occupancy_snapshot.get("action_bar_button_count", -1)) == scene.action_bar_button_count(), "occupancy snapshot captures the action-button count")

	var candidates: Array[Rect2] = [
		Rect2(Vector2(0.620, 0.120), Vector2(0.880, 0.430)),
		Rect2(Vector2(0.115, 0.110), Vector2(0.320, 0.400)),
		Rect2(Vector2(0.115, 0.430), Vector2(0.320, 0.720)),
		Rect2(Vector2(0.645, 0.400), Vector2(0.985, 0.680)),
	]
	for candidate in candidates:
		var live_score: float = scene.chat_panel_candidate_overlap_score(candidate)
		var snapshot_score: float = scene.chat_panel_candidate_overlap_score(candidate, occupancy_snapshot)
		check((live_score == INF and snapshot_score == INF) or is_equal_approx(live_score, snapshot_score), "geometry snapshot preserves candidate exclusion result")

	var left_meld_candidate := Rect2(Vector2(0.135, 0.240), Vector2(0.205, 0.510))
	var snapshot_score_before_meld: float = scene.chat_panel_candidate_overlap_score(left_meld_candidate, occupancy_snapshot)
	scene.players[3]["melds"] = [["5W", "5W", "5W"]]
	var snapshot_score_after_meld: float = scene.chat_panel_candidate_overlap_score(left_meld_candidate, occupancy_snapshot)
	var live_score_after_meld: float = scene.chat_panel_candidate_overlap_score(left_meld_candidate)
	check(is_equal_approx(snapshot_score_before_meld, snapshot_score_after_meld), "full occupancy snapshot remains stable after table mutation")
	check(live_score_after_meld == INF and live_score_after_meld != snapshot_score_after_meld, "direct scoring still uses the live meld fallback")

	var selected_rect: Rect2 = scene.chat_panel_rect()
	check(selected_rect.size.x > 0.0 and selected_rect.size.y > 0.0, "chat panel selection remains bounded with a live occupancy change")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
