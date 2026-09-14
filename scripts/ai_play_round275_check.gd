extends SceneTree
## Round 275: minimum-fan scoring reuses the validated scoring-count snapshot.

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
	print("=== ai_play_round275 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_active_rule_variant = scene.RULE_VARIANT_GUANGDONG
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var core_source_275 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	var rule_start_275 := core_source_275.find("func rule_minimum_met_for_counts")
	var rule_end_275 := core_source_275.find("func _play_reward_claim_animation", rule_start_275)
	var rule_function_275 := core_source_275.substr(rule_start_275, rule_end_275 - rule_start_275)
	check(rule_function_275.contains("validated_scoring_counts_snapshot: Array = []"), "minimum-fan gate accepts an optional validated snapshot")
	check(rule_function_275.contains("var use_validated_snapshot := validated_scoring_counts_snapshot.size() == TILE_CODES.size()"), "minimum-fan gate selects the snapshot fast path explicitly")
	check(rule_function_275.contains("calculate_win_score_from_tiles(seat, [], self_draw, win_context, use_validated_snapshot"), "minimum-fan gate keeps the direct-call fallback")
	check(core_source_275.contains("preserve_context_bonuses: bool = false") and rule_function_275.contains("validated_scoring_counts_snapshot, use_validated_snapshot"), "minimum-fan snapshot preserves context bonuses explicitly")
	var gameplay_source_275 := FileAccess.get_file_as_string("res://scripts/main_src/gameplay.gd.part")
	var win_start_275 := gameplay_source_275.find("func can_win_for_seat_from_counts")
	var win_end_275 := gameplay_source_275.find("func discard_report_for_tile", win_start_275)
	var win_function_275 := gameplay_source_275.substr(win_start_275, win_end_275 - win_start_275)
	check(win_function_275.contains("rule_minimum_met_for_counts(seat, counts, tile_count, self_draw, \"\", validated_counts)"), "count win validation forwards its validated scoring counts")

	var complete_hand_275: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T", "E", "E"]
	scene.players[0]["hand"] = complete_hand_275.duplicate()
	scene.players[0]["melds"] = []
	var hand_counts_275: Array = scene.tile_counts(complete_hand_275)
	var validated_counts_275: Array = scene.validated_scoring_tile_counts_from_counts(0, hand_counts_275, complete_hand_275.size())
	var direct_minimum_275: bool = scene.rule_minimum_met_for_counts(0, hand_counts_275, complete_hand_275.size(), false)
	var snapshot_minimum_275: bool = scene.rule_minimum_met_for_counts(0, hand_counts_275, complete_hand_275.size(), false, "", validated_counts_275)
	check(direct_minimum_275 == snapshot_minimum_275, "snapshot minimum-fan result matches direct validation")
	var direct_score_275: Dictionary = scene.calculate_win_score_from_tiles(0, complete_hand_275, false)
	var snapshot_score_275: Dictionary = scene.calculate_win_score_from_tiles(0, [], false, "", true, hand_counts_275, complete_hand_275.size(), validated_counts_275, true)
	check(direct_score_275 == snapshot_score_275, "snapshot score preserves fan, points, and reasons")
	check(scene.can_win_for_seat_from_counts(0, hand_counts_275, "", true), "count win boundary remains valid after snapshot forwarding")

	var open_hand_275: Array = ["4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T", "E", "E"]
	scene.players[0]["hand"] = open_hand_275.duplicate()
	scene.players[0]["melds"] = [["1W", "2W", "3W"]]
	var open_counts_275: Array = scene.tile_counts(open_hand_275)
	var open_validated_275: Array = scene.validated_scoring_tile_counts_from_counts(0, open_counts_275, open_hand_275.size())
	var open_direct_275: bool = scene.rule_minimum_met_for_counts(0, open_counts_275, open_hand_275.size(), false)
	var open_snapshot_275: bool = scene.rule_minimum_met_for_counts(0, open_counts_275, open_hand_275.size(), false, "", open_validated_275)
	check(open_direct_275 == open_snapshot_275 and scene.can_win_for_seat_from_counts(0, open_counts_275, "", true), "open-hand minimum-fan behavior remains equivalent")

	scene.players[0]["melds"] = [["4W", "5W", "7W"]]
	check(scene.validated_scoring_tile_counts_from_counts(0, open_counts_275, open_hand_275.size()).is_empty() and not scene.can_win_for_seat_from_counts(0, open_counts_275, "", true), "malformed melds are rejected before the snapshot path")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
