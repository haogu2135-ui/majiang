extends SceneTree
## Round 252: quiet discard safety ties reuse canonical candidate indexes.

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
	print("=== ai_play_round252 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.offline_all_bot_mode = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var source_252 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	check(source_252.contains('var safest_index := int(safest_candidate.get("tile_index", -1))'), "quiet safety ties use the saved candidate index")
	check(not source_252.contains("tile_sort_index(cand)"), "quiet safety ties avoid candidate normalization")
	var canonical_sort_order_252 := true
	for code in scene.TILE_CODES:
		var canonical_code := str(code)
		if scene.tile_sort_index(canonical_code) != scene.tile_index_normalized(canonical_code):
			canonical_sort_order_252 = false
			break
	check(canonical_sort_order_252, "canonical indexes retain tile sort order")
	check(scene.tile_sort_index("4M") == scene.tile_index_normalized("4W"), "normalized aliases retain the candidate sort index")

	scene.players[1]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "3T", "E"]
	var context_output_252: Dictionary = {}
	var reports_252: Array = scene.get_ai_discard_reports(1, [], context_output_252)
	check(reports_252.size() > 0, "quiet discard fast evaluation still returns reports")
	var indexes_valid_252 := true
	for report_value in reports_252:
		if typeof(report_value) != TYPE_DICTIONARY:
			indexes_valid_252 = false
			break
		var report_252: Dictionary = report_value
		var tile_252 := str(report_252.get("tile", ""))
		var index_252 := int(report_252.get("tile_index", -1))
		if index_252 < 0 or index_252 >= scene.TILE_CODES.size() or index_252 != scene.tile_index(tile_252):
			indexes_valid_252 = false
			break
	check(indexes_valid_252, "quiet reports retain canonical indexes for safety ranking")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
