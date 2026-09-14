extends SceneTree
## Round 243: risk-vector reports reuse the candidate tile index.

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
	print("=== ai_play_round243 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[1]["discards"] = ["1W", "7W"]
	var visible_counts_243: Array = scene.make_empty_tile_counts()
	visible_counts_243[scene.tile_index("4W")] = 2
	var context_243: Dictionary = scene.make_ai_evaluation_context(0, visible_counts_243)
	var index_243: int = scene.tile_index("4W")
	var fallback_243: Dictionary = scene.tile_risk_vector("4W", 0, visible_counts_243, context_243)
	var explicit_243: Dictionary = scene.tile_risk_vector("4M", 0, visible_counts_243, context_243, index_243)
	check(is_equal_approx(float(explicit_243.get("score", 0.0)), float(fallback_243.get("score", 0.0))), "explicit risk-vector index preserves the score")
	check(is_equal_approx(float(explicit_243.get("threat", 0.0)), float(fallback_243.get("threat", 0.0))) and int(explicit_243.get("visible", -1)) == int(fallback_243.get("visible", -2)), "explicit risk-vector index preserves threat and visibility")
	var risk_fallback_243: float = scene.deal_in_risk_score("4W", 0, context_243, visible_counts_243)
	var risk_explicit_243: float = scene.deal_in_risk_score("4M", 0, context_243, visible_counts_243, index_243)
	check(is_equal_approx(risk_explicit_243, risk_fallback_243), "deal-in risk forwards the explicit candidate index")
	var invalid_fallback_243: Dictionary = scene.tile_risk_vector("ZZ", 0, visible_counts_243, context_243)
	var invalid_explicit_243: Dictionary = scene.tile_risk_vector("ZZ", 0, visible_counts_243, context_243, -1)
	check(is_equal_approx(float(invalid_explicit_243.get("score", 0.0)), float(invalid_fallback_243.get("score", 0.0))), "invalid risk-vector tiles keep the legacy fallback")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
