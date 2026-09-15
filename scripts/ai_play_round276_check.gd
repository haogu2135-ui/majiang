extends SceneTree
## Round 276: ron and public win boundaries reuse normalized tile codes.

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
	print("=== ai_play_round276 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var source_276 := FileAccess.get_file_as_string("res://scripts/main_src/gameplay.gd.part")
	var public_start_276 := source_276.find("func can_win_for_seat(seat: int")
	var public_end_276 := source_276.find("func record_passed_win_tile", public_start_276)
	var public_function_276 := source_276.substr(public_start_276, public_end_276 - public_start_276)
	var ron_start_276 := source_276.find("func can_ron_for_seat(seat: int")
	var ron_end_276 := source_276.find("func can_win_for_seat_from_counts", ron_start_276)
	var ron_function_276 := source_276.substr(ron_start_276, ron_end_276 - ron_start_276)
	var ron_counts_start_276 := source_276.find("func can_ron_for_seat_from_counts")
	var ron_counts_end_276 := source_276.find("func can_win_for_seat_from_counts", ron_counts_start_276)
	var ron_counts_function_276 := source_276.substr(ron_counts_start_276, ron_counts_end_276 - ron_counts_start_276)
	var count_start_276 := source_276.find("func can_win_for_seat_from_counts")
	var count_end_276 := source_276.find("func _can_win_for_seat_from_counts_normalized", count_start_276)
	var count_function_276 := source_276.substr(count_start_276, count_end_276 - count_start_276)
	check(public_function_276.contains("var normalized_extra_tile := normalize_tile_code(extra_tile)"), "public win boundary normalizes the extra tile once")
	check(public_function_276.contains("_can_win_for_seat_from_counts_normalized(seat, hand_counts, normalized_extra_tile"), "public win boundary forwards its normalized tile directly")
	check(ron_function_276.contains("tile = normalize_tile_code(tile)"), "ron boundary normalizes the winning tile once")
	check(ron_function_276.contains("_can_ron_for_seat_from_counts_normalized(seat, hand_counts, tile)"), "ron boundary forwards its normalized tile directly")
	check(not ron_function_276.contains("\tif not can_win_for_seat_from_counts("), "ron boundary avoids re-entering the normalizing wrapper")
	check(ron_counts_function_276.contains("_can_ron_for_seat_from_counts_normalized(seat, hand_counts, normalize_tile_code(tile))"), "count ron boundary normalizes its tile once")
	check(not ron_counts_function_276.contains("\tif not can_win_for_seat_from_counts("), "count ron boundary avoids duplicate normalization")
	check(count_function_276.contains("normalize_tile_code(extra_tile)"), "direct count callers retain the normalization fallback")

	var ron_hand_276: Array = ["2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T", "E", "E"]
	scene.players[0]["hand"] = ron_hand_276.duplicate()
	scene.players[0]["melds"] = []
	scene.players[0]["discards"] = []
	scene.offline_passed_win_tiles.clear()
	var ron_counts_276: Array = scene.tile_counts(ron_hand_276)
	var canonical_ron_276: bool = scene.can_ron_for_seat(0, "1W")
	var alias_ron_276: bool = scene.can_ron_for_seat(0, "1M")
	var count_alias_ron_276: bool = scene.can_ron_for_seat_from_counts(0, ron_counts_276, "1M")
	check(canonical_ron_276 and alias_ron_276 and count_alias_ron_276, "canonical and legacy ron tiles keep the same valid result")
	check(scene.can_win_for_seat(0, "1M") and scene.can_win_for_seat_from_counts(0, ron_counts_276, "1M"), "public and count win boundaries preserve normalized aliases")
	check(not scene.can_ron_for_seat(0, "ZZ") and not scene.can_ron_for_seat_from_counts(0, ron_counts_276, "ZZ"), "invalid ron tiles remain rejected")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
