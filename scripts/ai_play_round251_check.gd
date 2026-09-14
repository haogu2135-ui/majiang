extends SceneTree
## Round 251: danger-source reasons reuse the risk-vector tile index.

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
	print("=== ai_play_round251 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.offline_all_bot_mode = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[1]["melds"] = [["4W", "4W", "4W"]]

	var source_251 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var gameplay_source_251 := FileAccess.get_file_as_string("res://scripts/main_src/gameplay.gd.part")
	check(source_251.contains("discard_danger_reason(tile, seat, best_opponent, eval_context, index)"), "risk vectors forward their captured index to danger-source reasons")
	check(gameplay_source_251.contains("visible_tile_count_from_counts(tile, visible_counts, index)"), "danger-source reasons reuse the supplied tile index for visibility")
	var visible_251: Array = scene.make_empty_tile_counts()
	var index_251: int = scene.tile_index("4W")
	visible_251[index_251] = 1
	var context_251: Dictionary = scene.make_ai_evaluation_context(0, visible_251)
	var fallback_reason_251: String = scene.discard_danger_reason("4W", 0, 1, context_251)
	var explicit_reason_251: String = scene.discard_danger_reason("4M", 0, 1, context_251, index_251)
	check(explicit_reason_251 == fallback_reason_251 and explicit_reason_251 != "", "danger-source reason preserves normalized aliases with the explicit index")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
