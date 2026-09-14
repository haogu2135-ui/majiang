extends SceneTree
## Round 232: targeted threat candidates reuse their captured sort index.

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
	print("=== ai_play_round232 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	for index_232 in range(scene.TILE_CODES.size()):
		var tile_232 := str(scene.TILE_CODES[index_232])
		check(scene.tile_index(tile_232) == scene.tile_sort_index(tile_232), "canonical tile sort key matches its captured index")
	var alias_index_232: int = scene.tile_index("4M")
	check(alias_index_232 >= 0 and alias_index_232 == scene.tile_sort_index("4M"), "normalized aliases keep the direct sort key")
	var flower_sort_232: int = scene.tile_sort_index("H1")
	check(scene.tile_index("H1") < 0 and flower_sort_232 == scene.TILE_CODES.size(), "flower candidates keep the sort fallback")
	var invalid_sort_232: int = scene.tile_sort_index("ZZ")
	check(scene.tile_index("ZZ") < 0 and invalid_sort_232 > flower_sort_232, "invalid candidates keep the terminal sort fallback")

	var visible_counts_232: Array = scene.make_empty_tile_counts()
	var context_232: Dictionary = scene.make_ai_evaluation_context(0, visible_counts_232)
	scene.players[0]["hand"] = ["1W", "4M", "E", "H1", "ZZ"]
	var first_labels_232: Array = scene.threat_safe_tile_labels(0, "honor", -1, 5, context_232, 1)
	var second_labels_232: Array = scene.threat_safe_tile_labels(0, "honor", -1, 5, context_232, 1)
	check(first_labels_232.size() <= 5, "threat candidates retain the requested bound")
	check(first_labels_232 == second_labels_232, "threat candidate ordering remains deterministic")
	check(first_labels_232.has(scene.tile_label("4M")) and first_labels_232.has(scene.tile_label("H1")), "canonical aliases and flowers remain visible candidates")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
