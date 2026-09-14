extends SceneTree
## Round 104: standard completion probes avoid unnecessary alternate-family scans.

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
	print("=== ai_play_round104 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.players = [make_player("P0"), make_player("AI"), make_player("P2"), make_player("P3")]

	var cases: Array = [
		{"name": "standard", "tiles": ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "3T", "E", "E"], "complete": true},
		{"name": "seven pairs", "tiles": ["1W", "1W", "2W", "2W", "3W", "3W", "4W", "4W", "5T", "5T", "6T", "6T", "E", "E"], "complete": true},
		{"name": "thirteen orphans", "tiles": ["1W", "9W", "1T", "9T", "1B", "9B", "E", "S", "N", "R", "Z", "F", "P", "1W"], "complete": true},
		{"name": "incomplete", "tiles": ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "3T", "E"], "complete": false},
	]

	for completion_case in cases:
		var tiles: Array = completion_case["tiles"]
		var counts: Array = scene.tile_counts(tiles)
		var source_key: String = scene.counts_compact_key(counts)
		var result: bool = scene.is_complete_hand_from_counts(counts, tiles.size(), 0)
		check(result == bool(completion_case["complete"]), "%s completion result is preserved" % str(completion_case["name"]))
		check(scene.counts_compact_key(counts) == source_key, "%s completion restores its count vector" % str(completion_case["name"]))

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
