extends SceneTree
## Round 263: wait score probes reuse one meld-inclusive count vector.

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
	print("=== ai_play_round263 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var core_source_263 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	var score_start_263 := core_source_263.find("func calculate_win_score_from_tiles")
	var score_end_263 := core_source_263.find("func is_last_draw_context", score_start_263)
	var score_source_263 := core_source_263.substr(score_start_263, score_end_263 - score_start_263)
	var ai_source_263 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var wait_start_263 := ai_source_263.find("func wait_value_metrics")
	var wait_end_263 := ai_source_263.find("func wait_quality_penalty", wait_start_263)
	var wait_source_263 := ai_source_263.substr(wait_start_263, wait_end_263 - wait_start_263)
	check(score_source_263.contains("scoring_counts_snapshot: Array = []"), "scoring accepts an optional meld-inclusive vector")
	check(score_source_263.contains("scoring_counts = scoring_counts_snapshot if scoring_counts_snapshot.size() == TILE_CODES.size() else scoring_tile_counts_from_counts(seat, hand_counts)"), "scoring keeps the vector fallback")
	check(wait_source_263.contains("var winning_scoring_counts: Array = []"), "wait valuation prepares one scoring vector")
	check(wait_source_263.contains("winning_scoring_counts[tile_index_value] = int(winning_scoring_counts[tile_index_value]) + 1"), "wait valuation mutates only the candidate scoring slot")
	check(wait_source_263.contains("next_tile_count, winning_scoring_counts)"), "wait valuation forwards the scoring snapshot")

	var tenpai_hand: Array = ["4W", "5W", "6W", "7B", "8B", "9B", "1T", "1T", "2T", "3T"]
	scene.players[1]["hand"] = tenpai_hand.duplicate()
	scene.players[1]["melds"] = [["1W", "2W", "3W"]]
	var hand_counts: Array = scene.tile_counts(tenpai_hand)
	var visible_counts: Array = scene.make_empty_tile_counts()
	var metrics: Dictionary = scene.effective_tile_metrics(tenpai_hand, 1, 1, 0, visible_counts, hand_counts)
	var waits: Array = metrics.get("tiles", [])
	var remaining: Dictionary = metrics.get("remaining_by_tile", {})
	var indexes: Dictionary = metrics.get("tile_indices", {})
	check(waits.has("1T") and waits.has("4T"), "open tenpai exposes multiple waits")
	check(int(indexes.get("1T", -1)) == scene.tile_index("1T") and int(indexes.get("4T", -1)) == scene.tile_index("4T"), "open waits retain canonical indexes")

	var winning_counts: Array = hand_counts.duplicate()
	var winning_index: int = scene.tile_index("4T")
	winning_counts[winning_index] = int(winning_counts[winning_index]) + 1
	var scoring_counts: Array = scene.scoring_tile_counts_from_counts(1, hand_counts)
	scoring_counts[winning_index] = int(scoring_counts[winning_index]) + 1
	var legacy_score: Dictionary = scene.calculate_win_score_from_tiles(1, [], false, "", true, winning_counts, 11)
	var snapshot_score: Dictionary = scene.calculate_win_score_from_tiles(1, [], false, "", true, winning_counts, 11, scoring_counts)
	check(legacy_score == snapshot_score, "scoring vector snapshot preserves the open-hand score")

	var counts_key_before: String = scene.counts_compact_key(hand_counts)
	var array_wait: Dictionary = scene.wait_value_metrics(1, tenpai_hand, 1, 0, waits, remaining, true)
	var snapshot_wait: Dictionary = scene.wait_value_metrics(1, tenpai_hand, 1, 0, waits, remaining, true, {}, -1.0, -1.0, hand_counts, -1, indexes)
	check(array_wait == snapshot_wait, "wait valuation snapshot preserves open-hand wait values")
	check(scene.counts_compact_key(hand_counts) == counts_key_before, "source hand counts remain available after probes")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
