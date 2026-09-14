extends SceneTree
## Round 277: AI ron reports reuse one normalized winning tile.

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
	print("=== ai_play_round277 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_phase = "resolving"
	scene.offline_sim_quiet = true
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var source_277 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var start_277 := source_277.find("func ai_ron_decision_report")
	var end_277 := source_277.find("func ai_tsumo_decision_report", start_277)
	var function_277 := source_277.substr(start_277, end_277 - start_277)
	check(function_277.contains("var normalized_tile := normalize_tile_code(tile)"), "ron report captures one normalized winning tile")
	check(function_277.contains("_can_win_for_seat_from_counts_normalized(seat, hand_counts, normalized_tile)"), "ron validation consumes the normalized winning tile")
	check(function_277.contains("tile_index_normalized(normalized_tile)"), "ron scoring consumes the normalized winning tile index")
	check(not function_277.contains("tile_index_normalized(normalize_tile_code(tile))"), "ron report avoids a second normalization")
	check(function_277.contains("remaining_by_tile.get(normalized_tile, 0)"), "ron wait comparison uses the normalized winning tile")

	var waiting_hand_277: Array = ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W"]
	scene.players[1]["hand"] = waiting_hand_277.duplicate()
	scene.players[1]["discards"] = []
	scene.players[1]["melds"] = []
	scene.offline_passed_win_tiles.clear()
	var canonical_report_277: Dictionary = scene.ai_ron_decision_report(1, "5W")
	var alias_report_277: Dictionary = scene.ai_ron_decision_report(1, "5M")
	check(bool(canonical_report_277.get("accept", false)) == bool(alias_report_277.get("accept", false)), "legacy ron aliases preserve the accept decision")
	check(str(canonical_report_277.get("reason", "")) == str(alias_report_277.get("reason", "")) and int(canonical_report_277.get("fan", -1)) == int(alias_report_277.get("fan", -2)), "legacy ron aliases preserve decision details")
	check(int(canonical_report_277.get("points", -1)) == int(alias_report_277.get("points", -2)) and int(canonical_report_277.get("wait_variety", -1)) == int(alias_report_277.get("wait_variety", -2)), "legacy ron aliases preserve score and wait metrics")
	var invalid_report_277: Dictionary = scene.ai_ron_decision_report(1, "ZZ")
	check(not bool(invalid_report_277.get("accept", true)) and str(invalid_report_277.get("reason", "")) == "未成和", "invalid ron tiles retain the rejection result")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
