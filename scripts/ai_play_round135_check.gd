extends SceneTree
## Round 135: chat candidate scoring reuses the visible meld-seat snapshot.

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
	print("=== ai_play_round135 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.wall.clear()
	for _i in range(60):
		scene.wall.append("1B")

	# This candidate occupies the left-seat meld lane without touching the seat
	# plaque, river, center console, hand tray, or action bar.
	var meld_lane_candidate := Rect2(Vector2(0.135, 0.240), Vector2(0.205, 0.510))
	var empty_snapshot: Dictionary = {}
	var empty_score: float = scene.chat_panel_candidate_overlap_score(meld_lane_candidate, empty_snapshot)
	scene.players[3]["melds"] = [["5W", "5W", "5W"]]
	var reused_empty_score: float = scene.chat_panel_candidate_overlap_score(meld_lane_candidate, empty_snapshot)
	var live_score: float = scene.chat_panel_candidate_overlap_score(meld_lane_candidate)
	check(is_equal_approx(empty_score, reused_empty_score), "an explicit empty meld snapshot remains stable after table mutation")
	check(live_score == INF and live_score != reused_empty_score, "the live fallback still rejects a candidate occupied by a meld")

	scene.players[1]["melds"] = [["6W", "6W", "6W"]]
	var selected_rect: Rect2 = scene.chat_panel_rect()
	check(selected_rect.size.x > 0.0 and selected_rect.size.y > 0.0, "chat panel selection remains bounded with multiple visible melds")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
