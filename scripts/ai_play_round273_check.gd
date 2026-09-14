extends SceneTree
## Round 273: public win validation reuses the count-based boundary.

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
	print("=== ai_play_round273 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var source_273 := FileAccess.get_file_as_string("res://scripts/main_src/gameplay.gd.part")
	var start_273 := source_273.find("func can_win_for_seat(seat: int")
	var end_273 := source_273.find("func record_passed_win_tile", start_273)
	var function_273 := source_273.substr(start_273, end_273 - start_273)
	check(function_273.contains("var hand_counts: Array = tile_counts(players[seat][\"hand\"])"), "public win validation builds one count vector")
	check(function_273.contains("_can_win_for_seat_from_counts_normalized(seat, hand_counts, normalized_extra_tile, normalized_extra_tile == \"\")"), "public win validation delegates completion and scoring")
	check(not function_273.contains("has_valid_scoring_melds(seat)"), "public win validation avoids a separate meld scan")
	check(not function_273.contains("has_valid_scoring_tile_inventory(seat, tiles)"), "public win validation avoids rebuilding a tile array")
	check(not function_273.contains("rule_minimum_met_for_tiles(seat, tiles"), "public win validation avoids the array minimum-fan path")

	var self_draw_hand_273: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T", "E", "E"]
	scene.players[0]["hand"] = self_draw_hand_273.duplicate()
	scene.players[0]["melds"] = []
	var self_draw_counts_273: Array = scene.tile_counts(self_draw_hand_273)
	check(scene.can_win_for_seat(0) == scene.can_win_for_seat_from_counts(0, self_draw_counts_273, "", true), "self-draw behavior matches the count boundary")

	var ron_base_273: Array = ["2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T", "E", "E"]
	scene.players[0]["hand"] = ron_base_273.duplicate()
	var ron_counts_273: Array = scene.tile_counts(ron_base_273)
	var ron_array_result_273: bool = scene.can_win_for_seat(0, "1M")
	var ron_count_result_273: bool = scene.can_win_for_seat_from_counts(0, ron_counts_273, "1M", false)
	check(ron_array_result_273 == ron_count_result_273 and ron_array_result_273, "normalized ron tile keeps the count-boundary result")

	var open_hand_273: Array = ["4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T", "E", "E"]
	scene.players[0]["hand"] = open_hand_273.duplicate()
	scene.players[0]["melds"] = [["1W", "2W", "3W"]]
	var open_counts_273: Array = scene.tile_counts(open_hand_273)
	check(scene.can_win_for_seat(0) == scene.can_win_for_seat_from_counts(0, open_counts_273, "", true), "open-hand completion keeps the same result")

	var malformed_hand_273: Array = self_draw_hand_273.duplicate()
	malformed_hand_273[0] = "ZZ"
	scene.players[0]["hand"] = malformed_hand_273
	scene.players[0]["melds"] = []
	check(not scene.can_win_for_seat(0), "invalid stored tile remains rejected by the count boundary")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
