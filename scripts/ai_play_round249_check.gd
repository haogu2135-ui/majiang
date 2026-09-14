extends SceneTree
## Round 249: general threat-card ranking forwards the candidate tile index.

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
	print("=== ai_play_round249 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "3T", "E"]
	scene.players[1]["discards"] = ["1W", "7W"]

	var source_249 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	check(source_249.contains("tile_risk_vector(tile, seat, visible_counts, eval_context, tile_index_snapshot)"), "general threat cards forward the captured candidate index")
	var visible_249: Array = scene.make_empty_tile_counts()
	visible_249[scene.tile_index("4W")] = 2
	var context_249: Dictionary = scene.make_ai_evaluation_context(0, visible_249)
	var labels_249: Array = scene.threat_safe_tile_labels(0, "suit", 0, 3, context_249)
	check(labels_249.size() > 0 and labels_249.size() <= 3, "general threat cards still return a bounded safe-tile list")
	var repeated_labels_249: Array = scene.threat_safe_tile_labels(0, "suit", 0, 3, context_249)
	check(repeated_labels_249 == labels_249, "general threat-card ranking remains deterministic after index forwarding")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
