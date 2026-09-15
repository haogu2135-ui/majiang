extends SceneTree
## Round 284: claim shape and route scans share one feature pass.

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
	print("=== ai_play_round284 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var ai_source_284 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var context_start_284 := ai_source_284.find("func make_ai_claim_context")
	var context_end_284 := ai_source_284.find("func ai_context_pressure_context", context_start_284)
	var context_function_284 := ai_source_284.substr(context_start_284, context_end_284 - context_start_284)
	check(context_function_284.contains("var before_features: Dictionary = hand_plan_features_from_counts(hand_counts, hand.size(), true, hand_counts_key)"), "claim context fuses the before shape and route features")
	check(context_function_284.contains("hand_plan_eval_for_seat_from_counts(seat, hand_counts, hand.size(), meld_tile_indices, before_features)"), "claim context forwards the fused feature snapshot")
	check(context_function_284.contains("float(before_shape_metrics.get(\"value\", 0.0))"), "claim context consumes the fused shape value")

	var report_start_284 := ai_source_284.find("func build_ai_claim_report")
	var report_end_284 := ai_source_284.find("func ai_claim_meld_bonus", report_start_284)
	var report_function_284 := ai_source_284.substr(report_start_284, report_end_284 - report_start_284)
	check(report_function_284.contains("var after_features: Dictionary = hand_plan_features_from_counts(after_counts, after.size(), true, after_counts_key)"), "claim reports build one after-claim feature snapshot")
	check(report_function_284.contains("var after_shape_metrics: Dictionary = ai_hand_shape_metrics_from_counts(after_counts, after_features)"), "claim reports consume the fused after-claim shape value")
	check(report_function_284.contains("plan_report_with_extra_melds(seat, after_counts, after.size(), extra_meld_tiles, meld_tile_indices_snapshot, extra_meld_tile_indices_snapshot, after_features)"), "claim reports forward features into incremental route evaluation")
	check(report_function_284.contains("float(after_shape_metrics.get(\"value\", 0.0))"), "claim reports avoid a second after-claim shape scan")

	var route_start_284 := ai_source_284.find("func plan_report_with_extra_melds")
	var route_end_284 := ai_source_284.find("func hand_plan_report_for_seat", route_start_284)
	var route_function_284 := ai_source_284.substr(route_start_284, route_end_284 - route_start_284)
	check(route_function_284.contains("base_features_snapshot: Dictionary = {}"), "route helper keeps an optional feature snapshot fallback")
	check(route_function_284.contains("hand_plan_features_add_tile(plan_features, index, previous_amount)"), "route helper adds exposed tiles incrementally")
	check(route_function_284.contains("hand_plan_report_from_features(plan_counts, total, plan_features)"), "route helper consumes the incrementally updated features")

	var hand_284: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E", "R"]
	var hand_counts_284: Array = scene.tile_counts(hand_284)
	scene.players[1]["melds"] = [["1W", "2W", "3W"]]
	var existing_indices_284: Array = scene.hand_plan_meld_tile_indices_for_seat(1)
	var extra_tiles_284: Array = ["5B", "5B", "5B"]
	var extra_indices_284: Array[int] = [scene.tile_index("5B"), scene.tile_index("5B"), scene.tile_index("5B")]
	var legacy_route_284: Dictionary = scene.plan_report_with_extra_melds(1, hand_counts_284, hand_284.size(), extra_tiles_284, existing_indices_284, extra_indices_284)
	var base_features_284: Dictionary = scene.hand_plan_features_from_counts(hand_counts_284, hand_284.size(), true)
	var snapshot_route_284: Dictionary = scene.plan_report_with_extra_melds(1, hand_counts_284, hand_284.size(), extra_tiles_284, existing_indices_284, extra_indices_284, base_features_284)
	check(legacy_route_284 == snapshot_route_284, "incremental route features preserve the full route report")

	scene.players[1]["melds"] = []
	var context_hand_284: Array = ["5W", "5W", "1W", "2W", "3W", "4W", "6W", "7W", "8W", "9W", "E", "E", "R"]
	scene.players[1]["hand"] = context_hand_284.duplicate()
	var context_visible_284: Array = scene.make_empty_tile_counts()
	var claim_context_284: Dictionary = scene.make_ai_claim_context(1, context_visible_284, scene.tile_counts(context_hand_284), 0)
	var context_counts_284: Array = scene.tile_counts(context_hand_284)
	var legacy_before_score_284: float = scene.evaluate_ai_hand_from_counts(context_counts_284) + float(scene.hand_plan_eval_for_seat_from_counts(1, context_counts_284, context_hand_284.size()).get("score", 0.0)) * 0.35 * float(claim_context_284.get("route_focus", 1.0))
	check(is_equal_approx(float(claim_context_284.get("before_score", 0.0)), legacy_before_score_284), "claim context preserves the legacy before score")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
