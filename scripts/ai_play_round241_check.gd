extends SceneTree
## Round 241: discard pressure reuses the candidate tile index.

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
	return {"name": name, "hand": [], "discards": [], "melds": [], "flowers": 0, "flower_tiles": [], "score": 25000, "bot": true}


func run() -> void:
	print("=== ai_play_round241 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[1]["discards"] = ["4W", "5W"]
	var visible_counts_241: Array = scene.make_empty_tile_counts()
	visible_counts_241[scene.tile_index("4W")] = 2
	var context_241: Dictionary = scene.make_ai_evaluation_context(0, visible_counts_241)
	var index_241: int = scene.tile_index("4W")
	var fallback_241: float = scene.discard_pressure_score("4W", 0, visible_counts_241, context_241)
	var explicit_241: float = scene.discard_pressure_score("4M", 0, visible_counts_241, context_241, index_241)
	check(is_equal_approx(explicit_241, fallback_241), "explicit discard-pressure index preserves normalized aliases")
	var invalid_fallback_241: float = scene.discard_pressure_score("ZZ", 0, visible_counts_241, context_241)
	var invalid_explicit_241: float = scene.discard_pressure_score("ZZ", 0, visible_counts_241, context_241, -1)
	check(is_equal_approx(invalid_explicit_241, invalid_fallback_241), "invalid discard-pressure tiles keep the legacy fallback")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
