extends SceneTree
## Round 280: claim selection reuses one normalized tile and tile index.

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
	print("=== ai_play_round280 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_phase = "resolving"
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var ai_source_280 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var chooser_start_280 := ai_source_280.find("func choose_ai_claim")
	var chooser_end_280 := ai_source_280.find("func claim_turn_offset", chooser_start_280)
	var chooser_function_280 := ai_source_280.substr(chooser_start_280, chooser_end_280 - chooser_start_280)
	check(chooser_function_280.contains("var normalized_tile := normalize_tile_code(tile)"), "claim chooser normalizes the discard once")
	check(chooser_function_280.contains("var tile_index_snapshot := tile_index_normalized(normalized_tile)"), "claim chooser resolves the discard index once")
	check(chooser_function_280.contains("_get_claim_options_normalized(seat, from_seat, normalized_tile, hand_counts, tile_index_snapshot)"), "claim chooser forwards the normalized claim snapshot")
	check(chooser_function_280.contains("claim_context[\"claim_tile\"] = normalized_tile") and chooser_function_280.contains("claim_context[\"claim_tile_index\"] = tile_index_snapshot"), "claim context publishes the normalized claim snapshot")
	check(not chooser_function_280.contains("get_claim_options(seat, from_seat, tile, hand_counts)"), "claim chooser avoids the normalizing options wrapper")

	var gameplay_source_280 := FileAccess.get_file_as_string("res://scripts/main_src/gameplay.gd.part")
	var options_start_280 := gameplay_source_280.find("func get_claim_options")
	var options_end_280 := gameplay_source_280.find("func is_valid_offline_claim", options_start_280)
	var options_function_280 := gameplay_source_280.substr(options_start_280, options_end_280 - options_start_280)
	check(options_function_280.contains("func _get_claim_options_normalized"), "claim options exposes a normalized internal boundary")
	check(options_function_280.contains("return _get_claim_options_normalized(seat, from_seat, normalized_tile, hand_counts, tile_index_snapshot)"), "public claim options keeps its normalization fallback")
	check(options_function_280.contains("tile_count_from_counts(normalized_tile, hand_counts, tile_index_snapshot)"), "normalized claim options consumes the supplied tile index")

	var chi_start_280 := ai_source_280.find("func best_ai_chi_claim")
	var chi_end_280 := ai_source_280.find("func ai_chi_choice_tiebreak", chi_start_280)
	var chi_function_280 := ai_source_280.substr(chi_start_280, chi_end_280 - chi_start_280)
	check(chi_function_280.contains("claim_tile_index_snapshot := -2"), "AI chi selection keeps a direct-call index fallback")
	check(chi_function_280.contains("get_chi_choices_from_counts(claim_context.get(\"hand_counts\", []), tile, claim_tile_index_snapshot)"), "AI chi selection consumes the claim context index")

	var report_start_280 := ai_source_280.find("func build_ai_claim_report")
	var report_end_280 := ai_source_280.find("func ai_claim_meld_bonus", report_start_280)
	var report_function_280 := ai_source_280.substr(report_start_280, report_end_280 - report_start_280)
	check(report_function_280.contains("str(claim_context.get(\"claim_tile\", \"\")) == tile"), "claim reports verify the context tile before reusing its index")
	check(report_function_280.contains("claim_tile_index_snapshot = int(claim_context.get(\"claim_tile_index\", -2))"), "claim reports consume the shared claim index")

	var human_source_280 := gameplay_source_280.substr(gameplay_source_280.find("func human_claim_candidate_reports"), gameplay_source_280.find("func human_claim_report_score") - gameplay_source_280.find("func human_claim_candidate_reports"))
	check(human_source_280.contains("var tile := normalize_tile_code(str(offline_pending_claim.get(\"tile\", \"\")))"), "human claim reports normalize the pending tile once")
	check(human_source_280.contains("best_chi_choice_from_counts(claim_context.get(\"hand_counts\", []), tile, tile_index_snapshot)"), "human claim reports forward the pending tile index")

	var claim_hand_280: Array = ["3W", "4W", "7W", "8W", "9W", "1T", "2T", "3T", "4T", "5T", "6T", "E", "E"]
	scene.players[1]["hand"] = claim_hand_280.duplicate()
	scene.players[0]["discards"] = ["5W"]
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	var claim_counts_280: Array = scene.tile_counts(claim_hand_280)
	var claim_index_280: int = scene.tile_index("5W")
	var public_canonical_280: Array = scene.get_claim_options(1, 0, "5W", claim_counts_280)
	var public_alias_280: Array = scene.get_claim_options(1, 0, "5M", claim_counts_280)
	var normalized_canonical_280: Array = scene._get_claim_options_normalized(1, 0, "5W", claim_counts_280, claim_index_280)
	var normalized_alias_280: Array = scene._get_claim_options_normalized(1, 0, "5W", claim_counts_280, claim_index_280)
	check(public_canonical_280 == public_alias_280 and public_canonical_280 == normalized_canonical_280 and normalized_alias_280 == normalized_canonical_280, "normalized claim options preserve canonical, alias, and fast-path results")

	var claim_context_280: Dictionary = scene.make_ai_claim_context(1, [], claim_counts_280, 0)
	claim_context_280["claim_tile"] = "5W"
	claim_context_280["claim_tile_index"] = claim_index_280
	var context_choices_280: Array = scene.get_chi_choices_from_counts(claim_counts_280, "5W", claim_index_280)
	var context_chi_280: Dictionary = scene.best_ai_chi_claim(1, "5W", 1, claim_context_280)
	check(not context_choices_280.is_empty() and not context_chi_280.is_empty(), "AI chi selection remains valid with the shared claim snapshot")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
