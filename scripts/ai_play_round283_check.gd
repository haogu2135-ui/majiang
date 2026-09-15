extends SceneTree
## Round 283: discard count-vector keys are shared across AI memo helpers.

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
	print("=== ai_play_round283 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var ai_source_283 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var report_start_283 := ai_source_283.find("func build_ai_discard_report")
	var report_end_283 := ai_source_283.find("func wait_value_metrics", report_start_283)
	var report_function_283 := ai_source_283.substr(report_start_283, report_end_283 - report_start_283)
	check(report_function_283.contains("var simulated_counts_key := counts_compact_key(simulated_counts)"), "discard reports build one candidate count key")
	check(report_function_283.contains("calculate_min_shanten_from_counts_with_memo(simulated_counts, open_melds, simulated_counts_key"), "shanten probes consume the shared count key")
	check(report_function_283.contains("effective_tile_metrics(simulated, open_melds, seat, shanten, visible_counts, simulated_counts, str(eval_context.get(\"visible_counts_key\", \"\")), simulated_counts_key)"), "effective-tile probes consume the shared count key")
	check(report_function_283.contains("hand_plan_features_from_counts(simulated_counts, simulated_tile_count, true, simulated_counts_key)"), "route features consume the shared count key")
	var feature_start_283 := ai_source_283.find("func hand_plan_features_from_counts")
	var feature_end_283 := ai_source_283.find("func touch_hand_plan_features_cache_key", feature_start_283)
	var feature_function_283 := ai_source_283.substr(feature_start_283, feature_end_283 - feature_start_283)
	check(feature_function_283.contains("counts_key_override: String = \"\""), "route feature helper keeps a direct-call key fallback")
	check(feature_function_283.contains("var counts_key := counts_key_override if counts_key_override != \"\" else counts_compact_key(counts)"), "route feature cache consumes the supplied key")
	var effective_start_283 := ai_source_283.find("func effective_tile_metrics")
	var effective_end_283 := ai_source_283.find("func touch_effective_tiles_cache_key", effective_start_283)
	var effective_function_283 := ai_source_283.substr(effective_start_283, effective_end_283 - effective_start_283)
	check(effective_function_283.contains("hand_counts_key_override: String = \"\""), "effective-tile helper keeps a direct-call key fallback")
	check(effective_function_283.contains("var hand_counts_key := hand_counts_key_override if hand_counts_key_override != \"\" else counts_compact_key(hand_counts)"), "effective-tile cache consumes the supplied key")

	var hand_283: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E", "R", "R"]
	var counts_283: Array = scene.tile_counts(hand_283)
	var count_key_283: String = scene.counts_compact_key(counts_283)
	var legacy_features_283: Dictionary = scene.hand_plan_features_from_counts(counts_283, hand_283.size(), true)
	var keyed_features_283: Dictionary = scene.hand_plan_features_from_counts(counts_283, hand_283.size(), true, count_key_283)
	check(legacy_features_283 == keyed_features_283, "explicit route-feature keys preserve all feature values")
	var visible_283: Array = scene.make_empty_tile_counts()
	var legacy_metrics_283: Dictionary = scene.effective_tile_metrics(hand_283, 0, 1, 99, visible_283, counts_283)
	var keyed_metrics_283: Dictionary = scene.effective_tile_metrics(hand_283, 0, 1, 99, visible_283, counts_283, "", count_key_283)
	check(legacy_metrics_283 == keyed_metrics_283, "explicit effective-tile keys preserve all metrics")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
