extends SceneTree
## Round 282: discard risk summaries reuse the candidate tile index.

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
	print("=== ai_play_round282 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var ai_source_282 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var report_start_282 := ai_source_282.find("func build_ai_discard_report")
	var report_end_282 := ai_source_282.find("func wait_value_metrics", report_start_282)
	var report_function_282 := ai_source_282.substr(report_start_282, report_end_282 - report_start_282)
	check(report_function_282.contains("deal_in_risk_summary(tile, seat, visible_counts, risk_vector, eval_context, candidate_tile_index_snapshot)"), "discard reports forward the candidate index to risk summaries")

	var summary_start_282 := ai_source_282.find("func deal_in_risk_summary")
	var summary_end_282 := ai_source_282.find("func tile_risk_vector", summary_start_282)
	var summary_function_282 := ai_source_282.substr(summary_start_282, summary_end_282 - summary_start_282)
	check(summary_function_282.contains("tile_index_snapshot: int = -2"), "risk summaries keep an optional index for direct callers")
	check(summary_function_282.contains("tile_risk_vector(tile, seat, visible_counts_snapshot, eval_context, tile_index_snapshot)"), "risk summary fallback consumes the supplied index")

	var visible_282: Array = scene.make_empty_tile_counts()
	scene.players[1]["melds"] = [["4W", "5W", "6W"]]
	scene.players[1]["discards"] = ["1W", "2W", "3W"]
	var context_282: Dictionary = scene.make_ai_evaluation_context(0, visible_282)
	var index_282: int = scene.tile_index("4W")
	var fallback_282: Dictionary = scene.deal_in_risk_summary("4W", 0, visible_282, {}, context_282)
	var explicit_282: Dictionary = scene.deal_in_risk_summary("4M", 0, visible_282, {}, context_282, index_282)
	check(is_equal_approx(float(fallback_282.get("score", 0.0)), float(explicit_282.get("score", 0.0))), "explicit risk-summary indexes preserve the score")
	check(fallback_282.get("danger_source", {}) == explicit_282.get("danger_source", {}), "explicit risk-summary indexes preserve the danger source")
	var cached_vector_282: Dictionary = {"score": 17.5, "danger_source": {"opponent": 1, "reason": "cached"}}
	var cached_summary_282: Dictionary = scene.deal_in_risk_summary("4W", 0, visible_282, cached_vector_282, context_282, index_282)
	check(float(cached_summary_282.get("score", 0.0)) == 17.5 and cached_summary_282.get("danger_source", {}).get("reason", "") == "cached", "precomputed risk vectors keep the summary fast path")
	var invalid_282: Dictionary = scene.deal_in_risk_summary("ZZ", 0, visible_282, {}, context_282, -1)
	check(invalid_282.has("score") and float(invalid_282.get("score", -1.0)) >= 0.0, "invalid risk-summary tiles retain the bounded fallback")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
