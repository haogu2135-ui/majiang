extends SceneTree
## Round 274: count-based win validation reuses the combined inventory pass.

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
	print("=== ai_play_round274 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var source_274 := FileAccess.get_file_as_string("res://scripts/main_src/gameplay.gd.part")
	var start_274 := source_274.find("func can_win_for_seat_from_counts")
	var end_274 := source_274.find("func discard_report_for_tile", start_274)
	var function_274 := source_274.substr(start_274, end_274 - start_274)
	check(function_274.contains("validated_scoring_tile_counts_from_counts(seat, counts, tile_count)"), "count win validation uses the combined inventory pass")
	check(not function_274.contains("has_valid_scoring_melds(seat)"), "count win validation avoids a separate meld scan")
	check(not function_274.contains("has_valid_scoring_tile_inventory_from_counts(seat, counts, tile_count)"), "count win validation avoids a second inventory scan")

	var valid_hand_274: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T", "E", "E"]
	scene.players[0]["hand"] = valid_hand_274.duplicate()
	scene.players[0]["melds"] = []
	var valid_counts_274: Array = scene.tile_counts(valid_hand_274)
	var valid_combined_274: Array = scene.validated_scoring_tile_counts_from_counts(0, valid_counts_274, valid_hand_274.size())
	check(not valid_combined_274.is_empty() and scene.has_valid_scoring_melds(0) and scene.has_valid_scoring_tile_inventory_from_counts(0, valid_counts_274, valid_hand_274.size()), "valid closed hand keeps the combined validation result")
	check(scene.can_win_for_seat_from_counts(0, valid_counts_274, "", true), "valid closed hand still passes the count win boundary")

	var open_hand_274: Array = ["4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T", "E", "E"]
	scene.players[0]["hand"] = open_hand_274.duplicate()
	scene.players[0]["melds"] = [["1W", "2W", "3W"]]
	var open_counts_274: Array = scene.tile_counts(open_hand_274)
	check(scene.can_win_for_seat_from_counts(0, open_counts_274, "", true), "valid open hand still passes the count win boundary")

	scene.players[0]["melds"] = [["4W", "5W", "7W"]]
	var malformed_combined_274: Array = scene.validated_scoring_tile_counts_from_counts(0, open_counts_274, open_hand_274.size())
	check(malformed_combined_274.is_empty() and not scene.can_win_for_seat_from_counts(0, open_counts_274, "", true), "malformed meld remains rejected by one combined pass")

	scene.players[0]["melds"] = [["1W", "1W", "1W", "1W"]]
	var over_limit_hand_274: Array = ["1W", "1W", "2T", "3T", "4T", "5T", "6T", "7T", "7B", "8B", "9B"]
	scene.players[0]["hand"] = over_limit_hand_274.duplicate()
	var over_limit_counts_274: Array = scene.tile_counts(over_limit_hand_274)
	check(scene.validated_scoring_tile_counts_from_counts(0, over_limit_counts_274, over_limit_hand_274.size()).is_empty() and not scene.can_win_for_seat_from_counts(0, over_limit_counts_274, "", false), "combined inventory still enforces the four-copy limit")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
