extends SceneTree
## Round 225: opponent risk components reuse one candidate tile index.

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
	print("=== ai_play_round225 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[1]["discards"] = ["1W", "7W"]

	var visible_counts: Array = scene.make_empty_tile_counts()
	var candidate_index: int = scene.tile_index("4W")
	var fallback_context: Dictionary = scene.make_ai_evaluation_context(0, visible_counts)
	var explicit_context: Dictionary = scene.make_ai_evaluation_context(0, visible_counts)
	var fallback_components: Dictionary = scene.single_opponent_deal_in_risk_components("4W", 0, 1, 0, visible_counts, fallback_context)
	var explicit_components: Dictionary = scene.single_opponent_deal_in_risk_components("4W", 0, 1, 0, visible_counts, explicit_context, candidate_index)
	check(is_equal_approx(float(fallback_components.get("risk", 0.0)), float(explicit_components.get("risk", 0.0))), "single-opponent risk preserves the explicit tile-index result")
	check(is_equal_approx(float(fallback_components.get("pattern_threat", 0.0)), float(explicit_components.get("pattern_threat", 0.0))), "single-opponent threat preserves the explicit tile-index result")

	var wrapper_fallback: float = scene.single_opponent_deal_in_risk("4W", 0, 1, 0, visible_counts)
	var wrapper_explicit: float = scene.single_opponent_deal_in_risk("4W", 0, 1, 0, visible_counts, candidate_index)
	check(is_equal_approx(wrapper_fallback, wrapper_explicit), "single-opponent scalar wrapper preserves the explicit tile-index result")

	var vector: Dictionary = scene.tile_risk_vector("4W", 0, visible_counts, fallback_context)
	check(vector.has("score") and vector.has("threat") and vector.has("visible"), "aggregate risk vector keeps its result structure")

	var invalid_fallback: Dictionary = scene.single_opponent_deal_in_risk_components("ZZ", 0, 1, 0, visible_counts)
	var invalid_explicit: Dictionary = scene.single_opponent_deal_in_risk_components("ZZ", 0, 1, 0, visible_counts, {}, -1)
	check(is_equal_approx(float(invalid_fallback.get("risk", 0.0)), float(invalid_explicit.get("risk", 0.0))), "invalid tiles keep the legacy risk fallback")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
