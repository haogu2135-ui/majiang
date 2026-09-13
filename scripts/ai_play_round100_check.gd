extends SceneTree
## Round 100: discard reports reuse the fast shanten and seat-static snapshots.

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
	print("=== ai_play_round100 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_sim_quiet = true
	scene.current_seat = 1
	scene.players = [make_player("P0"), make_player("AI"), make_player("P2"), make_player("P3")]
	scene.wall = scene.make_wall()
	var hand: Array = ["1W", "4W", "7W", "1T", "4T", "7T", "1B", "4B", "7B", "E", "S", "W", "N", "P"]
	scene.players[1]["hand"] = hand.duplicate()

	print("--- A) generated contexts carry candidate-invariant report inputs ---")
	var context: Dictionary = scene.make_ai_evaluation_context(1, scene.visible_tile_counts())
	check(int(context.get("discard_report_exposed_melds", -1)) == scene.exposed_meld_count_for_seat(1), "context snapshots the exposed meld count")
	check(is_equal_approx(float(context.get("discard_report_attack_multiplier", -1.0)), scene.ai_total_attack_multiplier(1)), "context snapshots the attack multiplier")
	check(is_equal_approx(float(context.get("discard_report_route_focus", -1.0)), scene.ai_route_focus(1)), "context snapshots the route focus")
	check(is_equal_approx(float(context.get("discard_report_risk_factor", -1.0)), scene.ai_risk_factor(1)), "context snapshots the risk factor")

	print("--- B) supplied shanten snapshot preserves the complete report ---")
	var tile := "P"
	var simulated: Array = hand.duplicate()
	simulated.erase(tile)
	var simulated_counts: Array = scene.tile_counts(simulated)
	var original_counts: Array = scene.tile_counts(hand)
	var expected_shanten: int = scene.calculate_min_shanten_from_counts(simulated_counts, 0)
	var expected_risk_vector: Dictionary = scene.tile_risk_vector(tile, 1, [], context)
	scene.clear_shanten_cache()
	var evaluated_report: Dictionary = scene.build_ai_discard_report(1, tile, simulated, 0, scene.visible_tile_counts(), {}, context, simulated_counts, original_counts, -1, scene.tile_index_normalized(tile))
	var evaluated_misses: int = scene.shanten_cache_misses
	scene.clear_shanten_cache()
	var snap_report: Dictionary = scene.build_ai_discard_report(1, tile, simulated, 0, scene.visible_tile_counts(), {}, context, simulated_counts, original_counts, -1, scene.tile_index_normalized(tile), expected_shanten, expected_risk_vector)
	check(int(evaluated_report.get("shanten", 99)) == expected_shanten and int(snap_report.get("shanten", 99)) == expected_shanten, "both report paths retain the candidate shanten")
	check(evaluated_misses > 0 and scene.shanten_cache_misses == 0, "the supplied shanten snapshot skips the duplicate shanten search")
	check(is_equal_approx(float(evaluated_report.get("score", -1.0)), float(snap_report.get("score", -2.0))) and evaluated_report.get("reason_label", "") == snap_report.get("reason_label", ""), "the supplied shanten snapshot preserves report scoring")
	check(is_equal_approx(float(evaluated_report.get("risk", -1.0)), float(snap_report.get("risk", -2.0))) and evaluated_report.get("danger_source", {}) == snap_report.get("danger_source", {}), "the supplied risk vector preserves risk and danger source")
	check(int(snap_report.get("plan_suit", -2)) == int(evaluated_report.get("plan_suit", -3)) and snap_report.get("effective_tiles", []) == evaluated_report.get("effective_tiles", []), "the supplied snapshot preserves route and wait details")

	print("--- C) quiet fast reports retain their precomputed shanten ---")
	var reports: Array = scene.get_ai_discard_reports(1)
	check(reports.size() <= scene.AI_FAST_EVAL_PRESSURE_TOP_K, "quiet fast evaluation keeps the bounded top-k report set")
	for report in reports:
		var report_tile := str(report.get("tile", ""))
		var report_hand: Array = hand.duplicate()
		report_hand.erase(report_tile)
		var report_shanten: int = scene.calculate_min_shanten_from_counts(scene.tile_counts(report_hand), 0)
		check(int(report.get("shanten", 99)) == report_shanten, "quiet report shanten matches its own discarded hand for %s" % report_tile)

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
