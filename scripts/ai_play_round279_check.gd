extends SceneTree
## Round 279: claim response paths reuse one normalized tile index.

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
	print("=== ai_play_round279 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_phase = "resolving"
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var base_source_279 := FileAccess.get_file_as_string("res://scripts/main_base.gd")
	check(base_source_279.contains("func tile_count_from_counts(tile: String, counts: Array, tile_index_snapshot: int = -2)"), "count lookup accepts an optional tile index")
	check(base_source_279.contains("if index == -2:"), "count lookup keeps its normalization fallback")
	var gameplay_source_279 := FileAccess.get_file_as_string("res://scripts/main_src/gameplay.gd.part")
	var options_start_279 := gameplay_source_279.find("func get_claim_options")
	var options_end_279 := gameplay_source_279.find("func is_valid_offline_claim", options_start_279)
	var options_function_279 := gameplay_source_279.substr(options_start_279, options_end_279 - options_start_279)
	check(options_function_279.contains("var normalized_tile := normalize_tile_code(tile)"), "claim options captures one normalized tile")
	check(options_function_279.contains("var tile_index_snapshot := tile_index_normalized(normalized_tile)"), "claim options captures one tile index")
	check(options_function_279.contains("_can_ron_for_seat_from_counts_normalized(seat, hand_counts, normalized_tile)"), "claim options reuses the normalized ron boundary")
	check(options_function_279.contains("tile_count_from_counts(normalized_tile, hand_counts, tile_index_snapshot)"), "claim options reuses the captured count index")
	check(options_function_279.contains("get_chi_choices_from_counts(hand_counts, normalized_tile, tile_index_snapshot)"), "claim options reuses the captured chi index")
	var claim_validation_start_279 := gameplay_source_279.find("func _is_valid_offline_claim_normalized")
	var claim_validation_end_279 := gameplay_source_279.find("func apply_offline_claim", claim_validation_start_279)
	var claim_validation_function_279 := gameplay_source_279.substr(claim_validation_start_279, claim_validation_end_279 - claim_validation_start_279)
	check(claim_validation_function_279.contains("var tile_index_snapshot := tile_index_normalized(tile)"), "claim validation captures one tile index")
	check(claim_validation_function_279.contains("_can_ron_for_seat_from_counts_normalized(seat, hand_counts, tile)"), "claim validation reuses normalized ron validation")
	check(claim_validation_function_279.contains("tile_count_from_counts(tile, hand_counts, tile_index_snapshot)"), "claim validation reuses the captured count index")
	check(claim_validation_function_279.contains("get_chi_choices_from_counts(hand_counts, tile, tile_index_snapshot)"), "claim validation reuses the captured chi index")
	var chi_source_279 := gameplay_source_279.substr(gameplay_source_279.find("func best_chi_choice"), gameplay_source_279.find("func play_ai_discard_fly_animation") - gameplay_source_279.find("func best_chi_choice"))
	check(chi_source_279.contains("tile_index_snapshot: int = -2"), "chi selection keeps a direct-call index fallback")
	check(chi_source_279.contains("get_chi_choices_from_counts(hand_counts, normalized_tile, index)"), "chi selection forwards its captured index")

	var claim_hand_279: Array = ["3W", "4W", "7W", "8W", "9W", "1T", "2T", "3T", "4T", "5T", "6T", "E", "E"]
	scene.players[1]["hand"] = claim_hand_279.duplicate()
	scene.players[0]["discards"] = ["5W"]
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	var claim_counts_279: Array = scene.tile_counts(claim_hand_279)
	var canonical_choices_279: Array = scene.get_claim_options(1, 0, "5W", claim_counts_279)
	var alias_choices_279: Array = scene.get_claim_options(1, 0, "5M", claim_counts_279)
	check(canonical_choices_279 == alias_choices_279 and canonical_choices_279.has("chi"), "claim options preserve canonical and legacy aliases")
	var canonical_chi_279: Array = scene.get_chi_choices_from_counts(claim_counts_279, "5W")
	var alias_chi_279: Array = scene.get_chi_choices_from_counts(claim_counts_279, "5M", scene.tile_index("5W"))
	check(canonical_chi_279 == alias_chi_279 and not alias_chi_279.is_empty(), "explicit chi index preserves the generated meld choices")
	var canonical_best_279: Dictionary = scene.best_chi_choice(claim_hand_279, "5W")
	var alias_best_279: Dictionary = scene.best_chi_choice(claim_hand_279, "5M")
	check(canonical_best_279 == alias_best_279, "best chi selection preserves normalized aliases")
	check(scene.is_valid_offline_claim(1, 0, "5M", "chi", alias_chi_279[0]), "claim validation accepts the normalized alias with the captured index")
	check(scene.get_claim_options(1, 0, "ZZ", claim_counts_279).is_empty(), "invalid claim tiles remain outside response options")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
