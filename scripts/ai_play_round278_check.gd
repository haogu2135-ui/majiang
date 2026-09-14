extends SceneTree
## Round 278: AI tsumo reports reuse one normalized drawn tile.

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
	print("=== ai_play_round278 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.current_seat = 3
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var source_278 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var start_278 := source_278.find("func ai_tsumo_decision_report")
	var end_278 := source_278.find("func ai_tsumo_continue_discard", start_278)
	var function_278 := source_278.substr(start_278, end_278 - start_278)
	check(function_278.contains("var normalized_drawn_tile := normalize_tile_code(drawn_tile)"), "tsumo report captures one normalized drawn tile")
	check(function_278.contains("current_self_draw_tile(seat) != normalized_drawn_tile"), "tsumo validation consumes the normalized drawn tile")
	check(function_278.contains("tile_index_normalized(normalized_drawn_tile)"), "tsumo hand removal consumes the normalized tile index")
	check(not function_278.contains("tile_index_normalized(normalize_tile_code(drawn_tile))"), "tsumo report avoids a second normalization")
	check(function_278.contains("remaining_by_tile.get(normalized_drawn_tile, 0)"), "tsumo wait comparison uses the normalized drawn tile")
	check(function_278.contains("deal_in_risk_score(normalized_drawn_tile") and function_278.contains("discard_feed_risk_report(normalized_drawn_tile"), "tsumo continuation risk uses the normalized drawn tile")

	var tenpai_hand_278: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7B", "8B", "9B", "1T", "1T", "2T", "3T"]
	var tsumo_hand_278: Array = tenpai_hand_278.duplicate()
	tsumo_hand_278.append("1T")
	scene.players[3]["hand"] = tsumo_hand_278
	scene.players[3]["discards"] = []
	scene.players[3]["melds"] = []
	scene.offline_last_draw = {"seat": 3, "tile": "1T", "source": "normal", "wall_empty": false, "serial": 278}
	scene.offline_self_draw_ready = {"seat": 3, "tile": "1T", "serial": 278}
	var canonical_report_278: Dictionary = scene.ai_tsumo_decision_report(3, "1T")
	var alias_report_278: Dictionary = scene.ai_tsumo_decision_report(3, "1S")
	check(bool(canonical_report_278.get("win_valid", false)) and bool(alias_report_278.get("win_valid", false)), "canonical and legacy tsumo tiles remain valid")
	check(bool(canonical_report_278.get("accept", false)) == bool(alias_report_278.get("accept", false)) and str(canonical_report_278.get("reason", "")) == str(alias_report_278.get("reason", "")), "legacy tsumo aliases preserve the decision")
	check(int(canonical_report_278.get("fan", -1)) == int(alias_report_278.get("fan", -2)) and int(canonical_report_278.get("points", -1)) == int(alias_report_278.get("points", -2)), "legacy tsumo aliases preserve score details")
	var invalid_report_278: Dictionary = scene.ai_tsumo_decision_report(3, "ZZ")
	check(not bool(invalid_report_278.get("accept", true)) and str(invalid_report_278.get("reason", "")) == "无效", "invalid tsumo tiles retain the invalid result")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
