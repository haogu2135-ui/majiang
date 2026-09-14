extends SceneTree
## Round 270: scoring derives closed special-hand flags in one count pass.

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
	print("=== ai_play_round270 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var source_270 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	var score_start_270 := source_270.find("func calculate_win_score_from_tiles")
	var score_end_270 := source_270.find("func is_last_draw_context", score_start_270)
	var score_source_270 := source_270.substr(score_start_270, score_end_270 - score_start_270)
	check(score_source_270.contains("scoring_special_hand_profile_from_counts(hand_counts, canonical_tile_count)"), "scoring uses the shared special-hand profile")
	check(score_source_270.contains("special_hand_profile.get(\"seven_pairs\""), "scoring consumes the shared seven-pairs flag")
	check(score_source_270.contains("special_hand_profile.get(\"thirteen_orphans\""), "scoring consumes the shared thirteen-orphans flag")
	var profile_start_270 := source_270.find("func scoring_special_hand_profile_from_counts")
	var profile_end_270 := source_270.find("func is_thirteen_orphans_tile", profile_start_270)
	var profile_source_270 := source_270.substr(profile_start_270, profile_end_270 - profile_start_270)
	check(profile_source_270.contains("for index in range(TILE_CODES.size())"), "special-hand profile scans the count vector once")
	check(profile_source_270.contains("result[\"seven_pairs\"]"), "special-hand profile publishes seven-pairs classification")
	check(profile_source_270.contains("result[\"thirteen_orphans\"]"), "special-hand profile publishes thirteen-orphans classification")

	var standard_hand_270: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E", "E", "S", "S"]
	var standard_counts_270: Array = scene.tile_counts(standard_hand_270)
	var standard_profile_270: Dictionary = scene.scoring_special_hand_profile_from_counts(standard_counts_270, standard_hand_270.size())
	check(not bool(standard_profile_270.get("seven_pairs", false)) and not bool(standard_profile_270.get("thirteen_orphans", false)), "standard hand keeps both special flags false")
	check(bool(scene.is_complete_hand_from_counts(standard_counts_270, standard_hand_270.size(), 0)), "standard hand remains complete")

	var seven_pairs_hand_270: Array = ["1W", "1W", "2W", "2W", "3W", "3W", "4T", "4T", "5T", "5T", "6B", "6B", "E", "E"]
	var seven_pairs_counts_270: Array = scene.tile_counts(seven_pairs_hand_270)
	var seven_pairs_profile_270: Dictionary = scene.scoring_special_hand_profile_from_counts(seven_pairs_counts_270, seven_pairs_hand_270.size())
	check(bool(seven_pairs_profile_270.get("seven_pairs", false)) and not bool(seven_pairs_profile_270.get("thirteen_orphans", false)), "seven-pairs hand keeps only the seven-pairs flag")
	check(scene.is_seven_pairs_from_counts(seven_pairs_counts_270, seven_pairs_hand_270.size()), "seven-pairs public predicate agrees with the shared profile")

	var thirteen_hand_270: Array = ["1W", "9W", "1T", "9T", "1B", "9B", "E", "S", "N", "R", "Z", "F", "P", "E"]
	var thirteen_counts_270: Array = scene.tile_counts(thirteen_hand_270)
	var thirteen_profile_270: Dictionary = scene.scoring_special_hand_profile_from_counts(thirteen_counts_270, thirteen_hand_270.size())
	check(not bool(thirteen_profile_270.get("seven_pairs", false)) and bool(thirteen_profile_270.get("thirteen_orphans", false)), "thirteen-orphans hand keeps only the thirteen-orphans flag")
	check(scene.is_thirteen_orphans_from_counts(thirteen_counts_270, thirteen_hand_270.size()), "thirteen-orphans public predicate agrees with the shared profile")

	var short_counts_270: Array = scene.tile_counts(seven_pairs_hand_270.slice(0, 13))
	var short_profile_270: Dictionary = scene.scoring_special_hand_profile_from_counts(short_counts_270, 13)
	check(not bool(short_profile_270.get("seven_pairs", false)) and not bool(short_profile_270.get("thirteen_orphans", false)), "non-fourteen-tile inputs keep both special flags false")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
