extends SceneTree
## Round 101: tsumo decisions reuse count snapshots for scoring and alternate waits.

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
	print("=== ai_play_round101 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 3
	scene.dealer_seat = 0
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("AI")]
	for seat in range(3):
		scene.players[seat]["hand"] = ["1B", "3B", "5B", "7B", "9B", "1T", "3T", "5T", "7T", "9T", "E", "S", "W"]
	var tenpai: Array = ["2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W", "2T", "3T", "4T"]
	var win_hand: Array = tenpai.duplicate()
	win_hand.append("2W")
	scene.players[3]["hand"] = win_hand.duplicate()
	scene.offline_last_draw = {"seat": 3, "tile": "2W", "source": "normal", "wall_empty": false, "serial": 101}
	scene.offline_self_draw_ready = {"seat": 3, "tile": "2W", "serial": 101}
	scene.wall.clear()
	for _i in range(48):
		scene.wall.append("2B")
	scene.wall.append("2W")
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD

	print("--- A) count scoring preserves the array score ---")
	var win_counts: Array = scene.tile_counts(win_hand)
	var array_score: Dictionary = scene.calculate_win_score_from_tiles(3, win_hand, true)
	var count_score: Dictionary = scene.calculate_win_score_from_tiles(3, [], true, "", false, win_counts, win_hand.size())
	check(int(array_score.get("fan", -1)) == int(count_score.get("fan", -2)) and int(array_score.get("points", -1)) == int(count_score.get("points", -2)) and array_score.get("reasons", []) == count_score.get("reasons", []), "count-based tsumo scoring matches the array path")

	print("--- B) count-based waits preserve alternate valuation ---")
	var drawn_index: int = scene.tile_index_normalized("2W")
	var tenpai_counts: Array = win_counts.duplicate()
	tenpai_counts[drawn_index] = int(tenpai_counts[drawn_index]) - 1
	var array_metrics: Dictionary = scene.effective_tile_metrics(tenpai, 0, 3, 0)
	var count_metrics: Dictionary = scene.effective_tile_metrics(tenpai, 0, 3, 0, [], tenpai_counts)
	check(array_metrics.get("tiles", []) == count_metrics.get("tiles", []) and array_metrics.get("remaining_by_tile", {}) == count_metrics.get("remaining_by_tile", {}), "count-based tsumo waits match the array path")
	var expected_alt_best := 0
	var expected_alt_remaining := 0
	for item in array_metrics.get("tiles", []):
		var wait_tile := str(item)
		if wait_tile == "2W":
			continue
		var remaining := int(array_metrics.get("remaining_by_tile", {}).get(wait_tile, 0))
		if remaining <= 0:
			continue
		var alternate_hand: Array = tenpai.duplicate()
		alternate_hand.append(wait_tile)
		var alternate_score: Dictionary = scene.calculate_win_score_from_tiles(3, alternate_hand, false, "", true)
		var alternate_fan := int(alternate_score.get("fan", 0))
		var alternate_tsumo_points: int = scene.score_points_for_fan(clampi(alternate_fan + 1, 1, scene.SCORE_LIMIT_FAN))
		var alternate_expected := int(round(float(alternate_score.get("points", 0)) * 0.45 + float(alternate_tsumo_points) * 0.55))
		expected_alt_remaining += remaining
		if alternate_expected > expected_alt_best:
			expected_alt_best = alternate_expected
	check(expected_alt_remaining > 0, "fixture exposes an alternate tsumo wait")

	print("--- C) optimized tsumo report preserves decision fields ---")
	var decision: Dictionary = scene.ai_tsumo_decision_report(3, "2W")
	print("    decision=%s" % decision)
	check(int(decision.get("fan", -1)) == int(array_score.get("fan", -2)) and int(decision.get("points", -1)) == int(array_score.get("points", -2)), "tsumo report keeps the winning score")
	check(int(decision.get("wait_variety", -1)) == int(array_metrics.get("variety", -2)), "tsumo report keeps wait variety")
	check(int(decision.get("alt_best_points", -1)) == expected_alt_best and int(decision.get("alt_remaining", -1)) == expected_alt_remaining, "tsumo report keeps alternate wait valuation")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
