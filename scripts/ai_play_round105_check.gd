extends SceneTree
## Round 105: standard shanten search stops when the -1 lower bound is found.

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
	print("=== ai_play_round105 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("AI"), make_player("P2"), make_player("P3")]

	var cases: Array = [
		{"name": "standard win", "tiles": ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "3T", "E", "E"], "expected": -1},
		{"name": "standard tenpai", "tiles": ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "3T", "E"], "expected": 0},
		{"name": "standard one shanten", "tiles": ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "E", "S"], "expected": 1},
		{"name": "seven pairs", "tiles": ["1W", "1W", "2W", "2W", "3W", "3W", "4W", "4W", "5T", "5T", "6T", "6T", "E", "E"], "expected": -1},
		{"name": "thirteen orphans", "tiles": ["1W", "9W", "1T", "9T", "1B", "9B", "E", "S", "N", "R", "Z", "F", "P", "1W"], "expected": -1},
	]

	print("--- A) lower-bound short circuit ---")
	scene.clear_shanten_cache()
	var complete_counts: Array = scene.tile_counts(cases[0]["tiles"])
	var complete_key: String = scene.counts_compact_key(complete_counts)
	var complete_result: int = scene.calculate_min_shanten_from_counts(complete_counts, 0)
	check(complete_result == -1, "standard winning hand still returns -1")
	check(scene.shanten_standard_lower_bound_hits > 0, "winning search records a -1 lower-bound exit")
	check(scene.counts_compact_key(complete_counts) == complete_key, "short-circuited search restores the caller count vector")

	print("--- B) exact shanten results and alternate routes ---")
	for test_case in cases:
		var tiles: Array = test_case["tiles"]
		var counts: Array = scene.tile_counts(tiles)
		var source_key: String = scene.counts_compact_key(counts)
		var result: int = scene.calculate_min_shanten_from_counts(counts, 0)
		check(result == int(test_case["expected"]), "%s result is preserved" % str(test_case["name"]))
		check(scene.counts_compact_key(counts) == source_key, "%s restores its count vector" % str(test_case["name"]))

	print("--- C) open-group terminal bound ---")
	scene.clear_shanten_cache()
	var open_counts: Array = scene.tile_counts(["E"])
	var open_key: String = scene.counts_compact_key(open_counts)
	check(scene.calculate_min_shanten_from_counts(open_counts, 4) == 0, "four open groups retain the exact tenpai bound")
	check(scene.counts_compact_key(open_counts) == open_key, "open-group terminal path restores its count vector")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
