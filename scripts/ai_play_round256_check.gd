extends SceneTree
## Round 256: furiten probes reuse one temporary count vector.

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
	print("=== ai_play_round256 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var source_256 := FileAccess.get_file_as_string("res://scripts/main_src/gameplay.gd.part")
	check(source_256.contains("var candidate_counts := hand_counts.duplicate()"), "furiten probes allocate one reusable count vector")
	check(source_256.contains("candidate_counts[index] = int(candidate_counts[index]) - 1"), "furiten probes restore the candidate slot")
	check(not source_256.contains("var candidate_counts = hand_counts.duplicate()"), "furiten probes avoid per-discard vector copies")
	var counts_256: Array = scene.tile_counts(["2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "3T", "4T"])
	var counts_before_256: Array = counts_256.duplicate()
	scene.players[0]["hand"] = scene.tiles_from_counts(counts_256)
	scene.players[0]["discards"] = ["1W", "4W", "1W"]
	var first_result_256: bool = scene.is_discard_furiten_from_counts(0, counts_256, scene.players[0]["hand"].size())
	var second_result_256: bool = scene.is_discard_furiten_from_counts(0, counts_256, scene.players[0]["hand"].size())
	check(first_result_256 == second_result_256, "furiten cache preserves repeated probe results")
	check(counts_256 == counts_before_256, "furiten probes keep the caller count vector unchanged")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
