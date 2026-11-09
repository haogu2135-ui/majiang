extends SceneTree


var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	print("  %s| %s" % ["OK  " if condition else "FAIL", message])
	failed = failed or not condition


func make_player(name: String) -> Dictionary:
	return {"name": name, "hand": [], "discards": [], "melds": [], "flowers": 0, "flower_tiles": [], "score": 25000, "bot": true}


func setup_table(scene: Node) -> void:
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.current_seat = 1
	scene.offline_turn_needs_draw = false
	scene.offline_sim_quiet = false
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	scene.players = [make_player("Human"), make_player("Actor"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E"]
	scene.players[0]["melds"] = [["1W", "1W", "1W"]]
	scene.players[0]["discards"] = ["1T", "2T", "3T", "4T", "5T", "6T", "7T", "8T"]
	scene.players[1]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "2T", "3T", "4T", "7B", "8B", "9B", "E", "E"]
	scene.wall.resize(16)
	scene.wall.fill("9B")
	scene.offline_passed_win_tiles.clear()
	scene.clear_ai_report_cache()


func report_for_tile(reports: Array, tile: String) -> Dictionary:
	for report in reports:
		if str(report.get("tile", "")) == tile:
			return report
	return {}


func fresh_reports(scene: Node) -> Array:
	scene.clear_ai_report_cache()
	return scene.get_ai_discard_reports(1)


func check_passed_win_cache(scene: Node) -> void:
	setup_table(scene)
	var visible_before: Array = scene.visible_tile_counts_shared().duplicate()
	var revision_before: int = scene.ai_state_revision
	var baseline_key: String = scene.ai_report_cache_key(1)
	var baseline: Array = scene.get_ai_discard_reports(1)
	var baseline_tile := report_for_tile(baseline, "5W")
	check(not baseline_tile.is_empty() and float(baseline_tile.get("human_target_risk", 0.0)) > 0.0, "the public-threat fixture has a live human ron-risk component")
	check(scene.can_ron_for_seat(0, "7W"), "the human fixture can legally decline its actual seven-wan wait")
	scene.record_passed_win_tile(0, "7W")
	var passed_key: String = scene.ai_report_cache_key(1)
	var cached_passed: Array = scene.get_ai_discard_reports(1)
	var expected_passed: Array = fresh_reports(scene)
	var passed_tile := report_for_tile(expected_passed, "5W")
	check(scene.ai_state_revision == revision_before and scene.visible_tile_counts_shared() == visible_before, "a passed win changes neither the gameplay revision nor the public tile inventory")
	check(passed_key != baseline_key, "a passed win invalidates the full discard-report cache before another tile is exposed")
	check(is_zero_approx(float(passed_tile.get("human_target_risk", -1.0))), "fresh reports exclude every ron wait of the temporarily furiten player")
	check(cached_passed == expected_passed, "cached ranking, risk and player-pressure fields match a fresh passed-win evaluation")
	var hits_before: int = scene.ai_report_cache_hits
	scene.record_passed_win_tile(0, "6W")
	check(scene.ai_report_cache_key(1) == passed_key and scene.get_ai_discard_reports(1) == expected_passed and scene.ai_report_cache_hits == hits_before + 1, "adding a second passed tile preserves the same all-waits policy and its valid cache hit")
	scene.clear_passed_win_tiles(0)
	var cleared_key: String = scene.ai_report_cache_key(1)
	var cached_cleared: Array = scene.get_ai_discard_reports(1)
	var expected_cleared: Array = fresh_reports(scene)
	check(cleared_key == baseline_key and cleared_key != passed_key, "clearing temporary furiten restores the baseline policy key without a new river tile")
	check(cached_cleared == expected_cleared and expected_cleared == baseline, "clearing temporary furiten restores the exact uncached ranking and risk")
	scene.record_passed_win_tile(0, "7W")
	var human_passed_key: String = scene.ai_report_cache_key(1)
	scene.clear_passed_win_tiles(0)
	scene.record_passed_win_tile(2, "7W")
	var other_passed_key: String = scene.ai_report_cache_key(1)
	check(human_passed_key != other_passed_key, "equal numbers of passed opponents still produce seat-specific policy keys")
	scene.record_passed_win_tile(0, "7W")
	var multiple_key: String = scene.ai_report_cache_key(1)
	check(multiple_key != human_passed_key and multiple_key != other_passed_key, "simultaneous temporary furiten states remain distinct")
	var before_hidden: Array = scene.get_ai_discard_reports(1)
	var hidden_hits_before: int = scene.ai_report_cache_hits
	scene.players[0]["hand"] = ["1B", "2B", "3B", "4B", "5B", "6B", "7B", "8B", "9B", "R"]
	check(scene.ai_report_cache_key(1) == multiple_key and scene.get_ai_discard_reports(1) == before_hidden and scene.ai_report_cache_hits == hidden_hits_before + 1, "concealed opponent-hand swaps do not enter the furiten policy key or change the decision")
	scene.offline_passed_win_tiles.clear()
	check(scene.ai_report_cache_key(1) == baseline_key, "clearing the public policy map also restores its canonical cache key")


func check_context_output(scene: Node) -> void:
	setup_table(scene)
	var output_context: Dictionary = {"stale": true}
	var first_reports: Array = scene.get_ai_discard_reports(1, [], output_context)
	check(not first_reports.is_empty() and output_context.has("pressure_context") and not output_context.has("stale"), "a report miss replaces an output sink with the fresh evaluation context")
	var second_reports: Array = scene.get_ai_discard_reports(1, [], output_context)
	check(second_reports == first_reports and output_context.is_empty(), "a cache hit clears a reused sink while keeping context construction lazy")
	output_context["stale"] = true
	check(scene.get_ai_discard_reports(-1, [], output_context).is_empty() and output_context.is_empty(), "an invalid actor leaves neither reports nor a stale evaluation context")
	output_context["stale"] = true
	check(scene.get_ai_discard_reports(scene.players.size(), [], output_context).is_empty() and output_context.is_empty(), "an out-of-range actor clears the same output contract")
	output_context["stale"] = true
	scene.players[1]["hand"] = []
	check(scene.get_ai_discard_reports(1, [], output_context).is_empty() and output_context.is_empty(), "an empty actor hand cannot export stale threat-lane inputs")


func run() -> void:
	print("=== ai_play_round296 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	check_passed_win_cache(scene)
	check_context_output(scene)
	if scene.has_method("shutdown_runtime"):
		scene.shutdown_runtime()
	scene.queue_free()
	await process_frame
	print("=== RESULT: %s ===" % ("FAIL" if failed else "OK"))
	quit(1 if failed else 0)
