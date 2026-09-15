extends SceneTree
## Round 286: general threat-card safety labels reuse the candidate tile index.

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
	print("=== ai_play_round286 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var source_286 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	var labels_start_286 := source_286.find("func threat_safe_tile_labels")
	var labels_end_286 := source_286.find("func visible_tile_counts_state_cache_key", labels_start_286)
	var labels_function_286 := source_286.substr(labels_start_286, labels_end_286 - labels_start_286)
	check(labels_function_286.contains("var tile_index_snapshot := tile_index(tile)"), "general threat cards capture one candidate tile index")
	check(labels_function_286.contains("safety = tile_safety_label(tile, seat, visible_counts, eval_context, tile_index_snapshot)"), "general threat cards forward the captured index to safety labels")

	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "S"]
	scene.players[1]["discards"] = ["1W", "4W", "7W"]
	var visible_286: Array = scene.make_empty_tile_counts()
	var context_286: Dictionary = scene.make_ai_evaluation_context(0, visible_286)
	var labels_286: Array = scene.threat_safe_tile_labels(0, "suit", 0, 4, context_286)
	var repeated_labels_286: Array = scene.threat_safe_tile_labels(0, "suit", 0, 4, context_286)
	check(labels_286.size() > 0 and labels_286.size() <= 4, "general threat cards keep their bounded safe-tile output")
	check(labels_286 == repeated_labels_286, "forwarded safety indexes preserve deterministic threat-card results")

	var fallback_context_286: Dictionary = scene.make_ai_evaluation_context(0, visible_286)
	var explicit_context_286: Dictionary = scene.make_ai_evaluation_context(0, visible_286)
	var safety_fallback_286: String = scene.tile_safety_label("5W", 0, visible_286, fallback_context_286)
	var safety_explicit_286: String = scene.tile_safety_label("5W", 0, visible_286, explicit_context_286, scene.tile_index("5W"))
	check(safety_fallback_286 == safety_explicit_286, "explicit safety indexes preserve the legacy label")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
