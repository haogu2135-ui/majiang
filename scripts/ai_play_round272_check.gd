extends SceneTree
## Round 272: full-straight scoring reuses the exposed-meld grouping.

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
	print("=== ai_play_round272 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var source_272 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	var helper_start_272 := source_272.find("func full_straight_open_meld_groups_for_seat")
	var helper_end_272 := source_272.find("func full_straight_suit_from_counts", helper_start_272)
	var helper_source_272 := source_272.substr(helper_start_272, helper_end_272 - helper_start_272)
	check(helper_source_272.contains("exposed_meld_count_for_seat(seat)"), "full-straight grouping uses the meld fingerprint")
	check(helper_source_272.contains("full_straight_open_meld_groups"), "full-straight grouping publishes a cache entry")
	check(helper_source_272.contains("if typeof(cached_groups) == TYPE_ARRAY"), "full-straight grouping has a cache fast path")
	var straight_start_272 := source_272.find("func full_straight_suit_from_counts")
	var straight_end_272 := source_272.find("func full_straight_open_meld_group", straight_start_272)
	var straight_source_272 := source_272.substr(straight_start_272, straight_end_272 - straight_start_272)
	check(straight_source_272.contains("full_straight_open_meld_groups_for_seat(seat)"), "full-straight scoring consumes the cached grouping")
	check(not straight_source_272.contains("for meld in open_melds"), "full-straight scoring avoids rebuilding exposed groups")

	var full_straight_hand_272: Array = ["7W", "8W", "9W", "E", "E", "E", "S", "S"]
	scene.players[1]["hand"] = full_straight_hand_272.duplicate()
	scene.players[1]["melds"] = [["1W", "2W", "3W"], ["4W", "5W", "6W"]]
	scene.exposed_meld_count_cache.clear()
	var groups_272: Array = scene.full_straight_open_meld_groups_for_seat(1)
	check(groups_272[0] == [true, true, false], "exposed groups retain the 123/456 layout")
	check(scene.exposed_meld_count_cache.get(1, {}).has("full_straight_open_meld_groups"), "exposed cache stores the derived grouping")
	var first_result_272: int = scene.full_straight_suit_from_counts(1, scene.tile_counts(full_straight_hand_272))
	var second_result_272: int = scene.full_straight_suit_from_counts(1, scene.tile_counts(full_straight_hand_272))
	check(first_result_272 == 0 and second_result_272 == first_result_272, "repeated full-straight probes preserve the result")
	check(scene.full_straight_open_meld_groups_for_seat(1) == groups_272, "repeated probes reuse the same exposed grouping")

	scene.players[1]["melds"] = [["1W", "2W", "3W"]]
	var changed_groups_272: Array = scene.full_straight_open_meld_groups_for_seat(1)
	check(changed_groups_272[0] == [true, false, false], "meld mutation invalidates the derived grouping")
	var closed_hand_272: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E", "E", "S", "S"]
	scene.players[1]["hand"] = closed_hand_272.duplicate()
	scene.players[1]["melds"] = []
	var closed_groups_272: Array = scene.full_straight_open_meld_groups_for_seat(1)
	check(closed_groups_272[0] == [false, false, false], "closed hands keep an empty exposed grouping")
	check(scene.full_straight_suit_from_counts(1, scene.tile_counts(closed_hand_272)) == 0, "closed full straight remains recognized")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
