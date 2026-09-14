extends SceneTree
## Round 227: threat-safe candidates reuse one tile-index snapshot.

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
	print("=== ai_play_round227 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["1W", "4W", "E", "5T"]
	scene.players[1]["discards"] = ["1W", "7W", "E"]

	var visible_counts: Array = scene.make_empty_tile_counts()
	visible_counts[scene.tile_index("4W")] = 2
	var candidate_index: int = scene.tile_index("4W")
	var visible_fallback: int = scene.visible_tile_count_from_counts("4W", visible_counts)
	var visible_explicit: int = scene.visible_tile_count_from_counts("4W", visible_counts, candidate_index)
	check(visible_fallback == visible_explicit, "visible-count lookup preserves the explicit tile-index result")

	var eval_context: Dictionary = scene.make_ai_evaluation_context(0, visible_counts)
	var safe_tiles: Array = scene.threat_safe_tile_labels(0, "suit", 0, 3, eval_context, 1)
	check(safe_tiles.size() <= 3, "targeted threat-safe candidates keep the requested bound")
	check(safe_tiles.all(func(item): return typeof(item) == TYPE_STRING), "targeted threat-safe candidates keep their tile labels")

	var invalid_fallback: int = scene.visible_tile_count_from_counts("ZZ", visible_counts)
	var invalid_explicit: int = scene.visible_tile_count_from_counts("ZZ", visible_counts, -1)
	check(invalid_fallback == invalid_explicit, "invalid visible-count tiles keep the legacy fallback")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
