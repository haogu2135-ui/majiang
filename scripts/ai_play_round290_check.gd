extends SceneTree

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
	print("=== ai_play_round290 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_all_bot_mode = true
	scene.offline_sim_quiet = true
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	scene.ai_benchmark_base_difficulty = scene.AI_DIFFICULTY_HARD
	scene.ai_benchmark_probe_seat = -1
	scene.ai_benchmark_probe_difficulty = -1
	scene.players = [make_player("P0"), make_player("Actor"), make_player("Route"), make_player("P3")]
	scene.wall = scene.make_wall()
	scene.players[1]["hand"] = ["1B", "2B", "3B", "4B", "5B", "6B", "7B", "8B", "9B", "2T", "4T", "6T", "5W", "E"]
	scene.players[2]["melds"] = [["1W", "2W", "3W"], ["7W", "8W", "9W"]]
	scene.players[2]["discards"] = ["1T", "2T", "3T", "4T", "5T", "6T"]
	scene.offline_claim_counts[scene.claim_source_key(2, 1)] = 2

	var quiet_reports: Array = scene.get_ai_discard_reports(1)
	var quiet_choice := str(quiet_reports[0].get("tile", "")) if not quiet_reports.is_empty() else ""
	var quiet_winner: Dictionary = quiet_reports[0] if not quiet_reports.is_empty() else {}
	scene.offline_sim_quiet = false
	scene.clear_ai_report_cache()
	var full_reports: Array = scene.get_ai_discard_reports(1)
	var full_choice := str(full_reports[0].get("tile", "")) if not full_reports.is_empty() else ""
	var full_winner: Dictionary = full_reports[0] if not full_reports.is_empty() else {}
	check(quiet_reports.size() <= scene.AI_FAST_EVAL_PRESSURE_TOP_K, "quiet evaluation remains bounded in a pressure state")
	check(not full_reports.is_empty() and full_choice == "4T", "full evaluation prefers the current-safe route-preserving discard")
	check(quiet_choice == full_choice, "hard quiet pre-ranking retains the full scorer's emergency-safe choice")
	check(bool(quiet_winner.get("fast_safety_preserved", false)), "quiet shortlist marks its preserved emergency-safe candidate")
	check(int(quiet_winner.get("ukeire", 0)) == int(full_winner.get("ukeire", -1)), "quiet emergency-safe candidate gets a complete ukeire count")
	check(is_equal_approx(float(quiet_winner.get("score", -INF)), float(full_winner.get("score", INF))), "quiet and full scores agree for the selected emergency-safe discard")

	scene.players[0]["melds"] = [["4B", "5B", "6B"]]
	var human_readiness: float = scene.human_readiness_for_defense()
	var human_visible: int = scene.visible_tile_count("5B")
	var human_tile_index: int = scene.tile_index("5B")
	var human_pattern_threat: float = scene.opponent_pattern_threat_score(0, "5B", human_visible, {}, human_tile_index)
	var fast_human_pressure: float = scene.fast_human_target_discard_pressure(1, "5B", 20.0, 2, {}, human_readiness, human_visible, human_tile_index)
	var expected_fast_human_pressure: float = max(0.0, 20.0 - 10.0) * 0.36 + human_pattern_threat * 0.90 + human_readiness * 1.05
	check(is_equal_approx(fast_human_pressure, expected_fast_human_pressure), "fast hard pressure includes the player's cached public hand-pattern threat")
	scene.players[0]["discards"].append("5B")
	var discarded_visible_counts: Array = scene.visible_tile_counts_shared()
	var discarded_context: Dictionary = scene.make_ai_evaluation_context(1, discarded_visible_counts)
	var discarded_readiness: float = float(discarded_context.get("discard_report_human_readiness", 0.0))
	var discarded_fast_pressure: float = scene.fast_human_target_discard_pressure(1, "5B", 20.0, 2, discarded_context, discarded_readiness, scene.visible_tile_count("5B"), human_tile_index)
	var expected_discarded_fast_pressure: float = max(0.0, 20.0 - 10.0) * 0.36 + discarded_readiness * 1.05
	check(is_equal_approx(discarded_fast_pressure, expected_discarded_fast_pressure), "fast pressure ignores a player-discarded ron tile")
	var discarded_full_pressure: float = scene.human_target_discard_pressure(1, "5B", 20.0, {}, 2, discarded_context, human_tile_index)
	var expected_discarded_full_pressure: float = max(0.0, 20.0 - 10.0) * 0.35 + discarded_readiness * 1.15
	check(is_equal_approx(discarded_full_pressure, expected_discarded_full_pressure), "full pressure ignores a player-discarded ron tile")

	var high_risk_two_away: Dictionary = {
		"tile": "3B",
		"score": -1097.3,
		"shanten": 2,
		"risk": 71.5,
		"feed_risk": 12.3,
		"human_target_pressure": 40.6,
		"safety_label": "熟",
	}
	var safer_one_away: Dictionary = {
		"tile": "6W",
		"score": -1258.4,
		"shanten": 1,
		"risk": 46.7,
		"feed_risk": 30.8,
		"human_target_pressure": 23.0,
		"safety_label": "",
	}
	var emergency_reports: Array = [high_risk_two_away, safer_one_away]
	scene.apply_hard_danger_push_guard(emergency_reports, -1)
	check(str(emergency_reports[0].get("tile", "")) == "6W", "hard two-away guard accepts the safer one-shanten line despite the existing 熟 cue")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
