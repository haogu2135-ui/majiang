extends SceneTree
## Round 228: discard reports reuse the candidate tile index.

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
	print("=== ai_play_round228 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "S", "W", "N"]

	var visible_counts: Array = scene.make_empty_tile_counts()
	var candidate_index: int = scene.tile_index("4W")
	var simulated: Array = scene.players[0]["hand"].duplicate()
	simulated.erase("4W")
	var simulated_counts: Array = scene.tile_counts(simulated)
	var context: Dictionary = scene.make_ai_evaluation_context(0, visible_counts)
	var report: Dictionary = scene.build_ai_discard_report(0, "4W", simulated, 0, visible_counts, {}, context, simulated_counts, [], 3, candidate_index, 3, {})
	check(int(report.get("tile_index", -1)) == candidate_index, "discard reports preserve the explicit candidate tile index")
	check(str(report.get("tile", "")) == "4W", "discard reports preserve the candidate tile")

	var invalid_simulated: Array = ["1W", "2W", "3W"]
	var invalid_report: Dictionary = scene.build_ai_discard_report(0, "ZZ", invalid_simulated, 0, visible_counts, {}, {}, scene.tile_counts(invalid_simulated), [], -1, -1, 3, {})
	check(int(invalid_report.get("tile_index", -2)) == -1, "invalid discard candidates keep the legacy index fallback")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
