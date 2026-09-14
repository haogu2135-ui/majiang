extends SceneTree
## Round 242: feed-risk reports reuse the candidate tile index.

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
	print("=== ai_play_round242 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[1]["melds"] = [["4W", "4W", "4W"]]
	var visible_counts_242: Array = scene.make_empty_tile_counts()
	var context_242: Dictionary = scene.make_ai_evaluation_context(0, visible_counts_242)
	var index_242: int = scene.tile_index("4W")
	var fallback_242: Dictionary = scene.discard_feed_risk_report("4W", 0, visible_counts_242, context_242)
	var explicit_242: Dictionary = scene.discard_feed_risk_report("4M", 0, visible_counts_242, context_242, index_242)
	check(is_equal_approx(float(explicit_242.get("score", 0.0)), float(fallback_242.get("score", 0.0))), "explicit feed-risk index preserves the score")
	check(explicit_242.get("details", []) == fallback_242.get("details", []), "explicit feed-risk index preserves opponent details")
	var invalid_fallback_242: Dictionary = scene.discard_feed_risk_report("ZZ", 0, visible_counts_242, context_242)
	var invalid_explicit_242: Dictionary = scene.discard_feed_risk_report("ZZ", 0, visible_counts_242, context_242, -1)
	check(is_equal_approx(float(invalid_explicit_242.get("score", 0.0)), float(invalid_fallback_242.get("score", 0.0))), "invalid feed-risk tiles keep the legacy fallback")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
