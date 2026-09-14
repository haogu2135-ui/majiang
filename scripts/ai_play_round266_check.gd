extends SceneTree
## Round 266: minimum-fan validation reuses the prepared count vector.

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
	print("=== ai_play_round266 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_active_rule_variant = scene.RULE_VARIANT_GUANGDONG
	scene.dealer_seat = 0
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var source_266 := FileAccess.get_file_as_string("res://scripts/main_src/gameplay.gd.part")
	var start_266 := source_266.find("func can_win_for_seat_from_counts")
	var end_266 := source_266.find("func discard_report_for_tile", start_266)
	var function_266 := source_266.substr(start_266, end_266 - start_266)
	check(function_266.contains("rule_minimum_met_for_counts(seat, counts, tile_count, self_draw, \"\", validated_counts)"), "count-based win validation reaches the count minimum-fan gate")
	check(not function_266.contains("tiles_from_counts(counts)"), "count-based win validation avoids expanding the prepared vector")

	var low_fan_hand_266: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7T", "8T", "9T", "E", "E", "E", "S", "S"]
	var low_fan_counts_266: Array = scene.tile_counts(low_fan_hand_266)
	var low_fan_array_result_266: bool = scene.rule_minimum_met_for_tiles(1, scene.tiles_from_counts(low_fan_counts_266), false)
	var low_fan_count_result_266: bool = scene.rule_minimum_met_for_counts(1, low_fan_counts_266, low_fan_hand_266.size(), false)
	check(low_fan_count_result_266 == low_fan_array_result_266 and not low_fan_count_result_266, "the count gate preserves a Guangdong hand below the minimum fan")

	var full_straight_hand_266: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E", "E", "S", "S"]
	var full_straight_counts_266: Array = scene.tile_counts(full_straight_hand_266)
	var full_straight_array_result_266: bool = scene.rule_minimum_met_for_tiles(1, scene.tiles_from_counts(full_straight_counts_266), false)
	var full_straight_count_result_266: bool = scene.rule_minimum_met_for_counts(1, full_straight_counts_266, full_straight_hand_266.size(), false)
	check(full_straight_count_result_266 == full_straight_array_result_266 and full_straight_count_result_266, "the count gate preserves a qualifying full-straight hand")

	var bottom_wait_base_266: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7T", "8T", "9T", "E", "E", "E", "S"]
	var bottom_winning_hand_266: Array = bottom_wait_base_266.duplicate()
	bottom_winning_hand_266.append("S")
	var bottom_winning_counts_266: Array = scene.tile_counts(bottom_winning_hand_266)
	scene.offline_phase = "pending_claim"
	scene.last_discard = "S"
	scene.last_discard_seat = 0
	scene.offline_last_draw = {"wall_empty": true, "seat": 0}
	var bottom_array_result_266: bool = scene.rule_minimum_met_for_tiles(1, scene.tiles_from_counts(bottom_winning_counts_266), false)
	var bottom_count_result_266: bool = scene.rule_minimum_met_for_counts(1, bottom_winning_counts_266, bottom_winning_hand_266.size(), false)
	check(bottom_count_result_266 == bottom_array_result_266 and bottom_count_result_266, "the count gate preserves the river-bottom bonus context")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
