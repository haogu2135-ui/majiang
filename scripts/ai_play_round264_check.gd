extends SceneTree
## Round 264: ron and tsumo reports reuse wait valuation score maps.

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
	print("=== ai_play_round264 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var source_264 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var ron_start_264 := source_264.find("func ai_ron_decision_report")
	var ron_end_264 := source_264.find("func ai_tsumo_decision_report", ron_start_264)
	var ron_source_264 := source_264.substr(ron_start_264, ron_end_264 - ron_start_264)
	var tsumo_start_264 := source_264.find("func ai_tsumo_decision_report")
	var tsumo_end_264 := source_264.find("func ai_tsumo_continue_discard", tsumo_start_264)
	var tsumo_source_264 := source_264.substr(tsumo_start_264, tsumo_end_264 - tsumo_start_264)
	var wait_start_264 := source_264.find("func wait_value_metrics")
	var wait_end_264 := source_264.find("func wait_quality_penalty", wait_start_264)
	var wait_source_264 := source_264.substr(wait_start_264, wait_end_264 - wait_start_264)
	check(wait_source_264.contains("var points_by_tile: Dictionary = {}"), "wait valuation prepares per-tile points")
	check(wait_source_264.contains("var fan_by_tile: Dictionary = {}"), "wait valuation prepares per-tile fan")
	check(wait_source_264.contains("points_by_tile[tile] = points"), "wait valuation publishes each valid wait score")
	check(wait_source_264.contains("fan_by_tile[tile] = fan"), "wait valuation publishes each valid wait fan")
	check(ron_source_264.contains("wait_value_metrics(seat, tenpai_hand, open_melds"), "ron builds the wait score map once")
	check(tsumo_source_264.contains("wait_value_metrics(seat, tenpai_hand, open_melds"), "tsumo builds the wait score map once")
	check(ron_source_264.contains("if wait_points_by_tile.has(wait_tile):"), "ron keeps the score-map fast path")
	check(tsumo_source_264.contains("if wait_points_by_tile.has(wait_tile):"), "tsumo keeps the score-map fast path")
	check(ron_source_264.contains("calculate_win_score_from_tiles(seat, [], false, \"\", true, probe_counts"), "ron keeps the missing-map fallback")
	check(tsumo_source_264.contains("calculate_win_score_from_tiles(seat, [], false, \"\", true, probe_counts"), "tsumo keeps the missing-map fallback")

	var tenpai_hand_264: Array = [
		"1W", "2W", "3W",
		"4W", "5W", "6W",
		"7B", "8B", "9B",
		"1T", "1T", "2T", "3T",
	]
	var hand_counts_264: Array = scene.tile_counts(tenpai_hand_264)
	var visible_counts_264: Array = scene.make_empty_tile_counts()
	var effective_metrics_264: Dictionary = scene.effective_tile_metrics(tenpai_hand_264, 0, 1, 0, visible_counts_264, hand_counts_264)
	var waits_264: Array = effective_metrics_264.get("tiles", [])
	var remaining_264: Dictionary = effective_metrics_264.get("remaining_by_tile", {})
	var indexes_264: Dictionary = effective_metrics_264.get("tile_indices", {})
	check(waits_264.has("1T") and waits_264.has("4T"), "fixture exposes two scored waits")

	var wait_scores_264: Dictionary = scene.wait_value_metrics(1, tenpai_hand_264, 0, 0, waits_264, remaining_264, true, {}, 1.0, 1.0, hand_counts_264, 0, indexes_264)
	var points_by_tile_264: Dictionary = wait_scores_264.get("points_by_tile", {})
	var fan_by_tile_264: Dictionary = wait_scores_264.get("fan_by_tile", {})
	check(points_by_tile_264.has("1T") and points_by_tile_264.has("4T"), "wait valuation returns points for every valid wait")
	check(fan_by_tile_264.has("1T") and fan_by_tile_264.has("4T"), "wait valuation returns fan for every valid wait")
	check(not points_by_tile_264.has("ZZ") and not fan_by_tile_264.has("ZZ"), "invalid waits are absent from score maps")

	scene.offline_phase = "resolving"
	scene.dealer_seat = 0
	scene.offline_passed_win_tiles.clear()
	scene.players[1]["hand"] = tenpai_hand_264.duplicate()
	scene.players[1]["discards"] = []
	scene.players[1]["melds"] = []
	scene.players[1]["flowers"] = 0
	var ron_report_264: Dictionary = scene.ai_ron_decision_report(1, "4T")
	check(int(ron_report_264.get("alt_best_points", -1)) == int(points_by_tile_264.get("1T", -2)), "ron reuses the cached alternate-wait points")

	var tsumo_hand_264: Array = tenpai_hand_264.duplicate()
	tsumo_hand_264.append("1T")
	scene.current_seat = 3
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_last_draw = {"seat": 3, "tile": "1T", "source": "normal", "wall_empty": false, "serial": 264}
	scene.offline_self_draw_ready = {"seat": 3, "tile": "1T", "serial": 264}
	scene.players[3]["hand"] = tsumo_hand_264
	scene.players[3]["discards"] = []
	scene.players[3]["melds"] = []
	var expected_tsumo_alt_264 := int(round(float(points_by_tile_264.get("4T", 0)) * 0.45 + float(scene.score_points_for_fan(clampi(int(fan_by_tile_264.get("4T", 0)) + 1, 1, scene.SCORE_LIMIT_FAN))) * 0.55))
	var tsumo_report_264: Dictionary = scene.ai_tsumo_decision_report(3, "1T")
	check(int(tsumo_report_264.get("alt_best_points", -1)) == expected_tsumo_alt_264, "tsumo reuses the cached alternate-wait score")

	var fallback_wait_264: Dictionary = scene.wait_value_metrics(1, tenpai_hand_264, 0, 0, waits_264, remaining_264, true, {}, 1.0, 1.0, hand_counts_264)
	check(wait_scores_264 == fallback_wait_264, "missing index snapshot keeps identical wait metrics")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
