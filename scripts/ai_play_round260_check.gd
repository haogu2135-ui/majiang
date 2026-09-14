extends SceneTree
## Round 260: scoring suit-pattern checks share one count scan.

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


func legacy_profile(scene, counts: Array) -> Dictionary:
	return {
		"all_honor": scene.is_all_honor_from_counts(counts),
		"pure_one_suit": scene.is_pure_one_suit_from_counts(counts),
		"mixed_one_suit": scene.is_mixed_one_suit_from_counts(counts),
		"all_simples": scene.is_all_simples_from_counts(counts),
	}


func run() -> void:
	print("=== ai_play_round260 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var source_260 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	var score_start_260 := source_260.find("func calculate_win_score_from_tiles")
	var score_end_260 := source_260.find("func is_last_draw_context", score_start_260)
	var score_source_260 := source_260.substr(score_start_260, score_end_260 - score_start_260)
	check(source_260.contains("func scoring_tile_profile_from_counts"), "scoring patterns expose a shared count profile")
	check(score_source_260.contains("var scoring_profile := scoring_tile_profile_from_counts(scoring_counts)"), "win scoring builds one shared suit profile")
	check(not score_source_260.contains("is_all_honor_from_counts(scoring_counts)"), "win scoring avoids the separate honor scan")
	check(not score_source_260.contains("is_pure_one_suit_from_counts(scoring_counts)"), "win scoring avoids the separate pure-suit scan")
	check(not score_source_260.contains("is_mixed_one_suit_from_counts(scoring_counts)"), "win scoring avoids the separate mixed-suit scan")
	check(not score_source_260.contains("is_all_simples_from_counts(scoring_counts)"), "win scoring avoids the separate simples scan")

	var cases_260: Array = [
		["honors", ["E", "S", "N", "R"]],
		["pure", ["1W", "2W", "3W", "4W"]],
		["mixed", ["2W", "3W", "4W", "E"]],
		["simples", ["2T", "3T", "4T", "5T"]],
		["terminal", ["1B", "2B", "3B"]],
		["multi-suit", ["2W", "3W", "4T", "E"]],
		["empty", []],
	]
	for case in cases_260:
		var label_260 := str(case[0])
		var counts_260: Array = scene.tile_counts(case[1])
		var expected_260: Dictionary = legacy_profile(scene, counts_260)
		var actual_260: Dictionary = scene.scoring_tile_profile_from_counts(counts_260)
		check(actual_260 == expected_260, "%s profile preserves the four legacy flags" % label_260)

	var invalid_counts_260: Array = scene.make_empty_tile_counts()
	invalid_counts_260.append(1)
	var invalid_expected_260: Dictionary = legacy_profile(scene, invalid_counts_260)
	check(scene.scoring_tile_profile_from_counts(invalid_counts_260) == invalid_expected_260, "out-of-range profile values keep legacy flags")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
