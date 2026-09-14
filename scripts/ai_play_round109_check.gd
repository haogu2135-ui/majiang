extends SceneTree
## Round 109: discard evaluation reuses invariant defense snapshots.

var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if condition:
		print("  OK  | %s" % message)
	else:
		print("  FAIL| %s" % message)
		failed = true


func make_player(name: String, score: int) -> Dictionary:
	return {
		"name": name,
		"hand": [],
		"discards": [],
		"melds": [],
		"flowers": 0,
		"flower_tiles": [],
		"score": score,
		"bot": true,
	}


func run() -> void:
	print("=== ai_play_round109 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_hand_number = scene.MATCH_MAX_HANDS
	scene.offline_sim_quiet = true
	scene.players = [
		make_player("P0", 30000),
		make_player("AI", 42000),
		make_player("P2", 20000),
		make_player("P3", 18000),
	]
	scene.current_seat = 1
	scene.wall = scene.make_wall()
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL
	scene.ai_profile_seat_map = [0, 0, 2, 3]

	print("--- A) context snapshots invariant defense inputs ---")
	var visible_counts: Array = scene.visible_tile_counts()
	var context: Dictionary = scene.make_ai_evaluation_context(1, visible_counts)
	var expected_progress: float = clamp(1.0 - float(scene.get_wall_count()) / float(maxi(1, scene.display_wall_total())), 0.0, 1.0)
	check(is_equal_approx(float(context.get("discard_report_wall_progress", -1.0)), expected_progress), "context snapshots wall progress")
	check(is_equal_approx(float(context.get("discard_report_defense_adjustment", -99.0)), scene.score_defense_adjustment(1)), "context snapshots score defense adjustment")
	check(is_equal_approx(float(context.get("discard_report_risk_factor", -1.0)), scene.ai_risk_factor(1)), "context snapshots risk factor")

	var pressure: Dictionary = scene.ai_pressure_context(1, context)
	var snapshot_defense: float = scene.ai_defense_weight(1, 2, pressure, context)
	var legacy_defense: float = scene.ai_defense_weight(1, 2, pressure)
	check(is_equal_approx(snapshot_defense, legacy_defense), "snapshot and legacy defense weights initially match")

	print("--- B) supplied context keeps one evaluation pass stable ---")
	# Change live score rank and profile after the context was made. A candidate
	# scan carrying the context must retain the original pass inputs, while the
	# legacy call remains state-sensitive.
	scene.players[0]["score"] = 70000
	scene.players[1]["score"] = 12000
	scene.ai_profile_seat_map = [0, 1, 2, 3]
	var live_defense: float = scene.ai_defense_weight(1, 2, pressure)
	var preserved_defense: float = scene.ai_defense_weight(1, 2, pressure, context)
	check(not is_equal_approx(live_defense, snapshot_defense), "legacy defense weight reflects changed live state")
	check(is_equal_approx(preserved_defense, snapshot_defense), "context defense weight retains original state")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
