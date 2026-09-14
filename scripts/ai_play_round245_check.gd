extends SceneTree
## Round 245: human-target discard pressure reuses the candidate tile index.

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
	print("=== ai_play_round245 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["melds"] = [["4W", "4W", "4W"]]
	scene.players[0]["discards"] = ["1W", "7W"]
	var visible_counts_245: Array = scene.make_empty_tile_counts()
	var index_245: int = scene.tile_index("4W")
	visible_counts_245[index_245] = 2
	var context_245: Dictionary = scene.make_ai_evaluation_context(1, visible_counts_245)
	var feed_report_245: Dictionary = {"details": [{"opponent": 0, "score": 14.0}]}
	var fallback_245: float = scene.human_target_discard_pressure(1, "4W", 24.0, feed_report_245, 2, context_245)
	var explicit_245: float = scene.human_target_discard_pressure(1, "4M", 24.0, feed_report_245, 2, context_245, index_245)
	check(is_equal_approx(explicit_245, fallback_245), "human-target pressure preserves normalized aliases")
	var penalty_fallback_245: float = scene.human_target_discard_penalty(1, "4W", 24.0, feed_report_245, 2, context_245)
	var penalty_explicit_245: float = scene.human_target_discard_penalty(1, "4M", 24.0, feed_report_245, 2, context_245, index_245)
	check(is_equal_approx(penalty_explicit_245, penalty_fallback_245), "human-target penalty forwards the candidate index")
	var fast_pressure_245: Dictionary = scene.ai_context_pressure_context(1, context_245)
	var fast_report_245: Dictionary = scene.build_ai_fast_post_claim_discard_report(1, "4M", 0, fast_pressure_245, context_245, scene.make_empty_tile_counts(), visible_counts_245, index_245)
	check(int(fast_report_245.get("tile_index", -2)) == index_245, "post-claim fast reports retain the candidate index")
	var invalid_fallback_245: float = scene.human_target_discard_pressure(1, "ZZ", 0.0, {}, 2, context_245)
	var invalid_explicit_245: float = scene.human_target_discard_pressure(1, "ZZ", 0.0, {}, 2, context_245, -1)
	check(is_equal_approx(invalid_explicit_245, invalid_fallback_245), "invalid candidate keeps the legacy pressure fallback")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
