extends SceneTree
## Round 268: discard evaluation reuses the visible-count key it already built.

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
	print("=== ai_play_round268 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var source_268 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var context_start_268 := source_268.find("func make_ai_evaluation_context")
	var context_end_268 := source_268.find("func ai_context_visible_counts", context_start_268)
	var context_source_268 := source_268.substr(context_start_268, context_end_268 - context_start_268)
	check(context_source_268.contains("visible_counts_key_override: String = \"\""), "evaluation context accepts a visible-count key snapshot")
	check(context_source_268.contains("visible_counts_key_override if visible_counts_key_override != \"\" else counts_compact_key(visible_counts)"), "evaluation context keeps the compact-key fallback")
	var report_key_start_268 := source_268.find("func ai_report_cache_key")
	var report_key_end_268 := source_268.find("func ai_profile_map_cache_key", report_key_start_268)
	var report_key_source_268 := source_268.substr(report_key_start_268, report_key_end_268 - report_key_start_268)
	check(report_key_source_268.contains("visible_counts_key_override: String = \"\""), "discard report cache key accepts the shared count key")
	check(report_key_source_268.contains("threat_report_table_state_cache_key(seat, visible_counts, visible_counts_key_override, wall_count)"), "discard report key forwards the shared count key")
	var reports_start_268 := source_268.find("func get_ai_discard_reports")
	var reports_end_268 := source_268.find("func sort_ai_discard_reports", reports_start_268)
	var reports_source_268 := source_268.substr(reports_start_268, reports_end_268 - reports_start_268)
	check(reports_source_268.contains("var visible_counts_key_snapshot := counts_compact_key(visible_counts_snapshot)"), "discard evaluation builds one visible-count key snapshot")
	check(reports_source_268.contains("ai_report_cache_key(seat, visible_counts_snapshot, -1, visible_counts_key_snapshot)"), "discard cache lookup receives the shared count key")
	check(reports_source_268.contains("make_ai_evaluation_context(seat, visible_counts_snapshot, visible_counts_key_snapshot)"), "discard evaluation forwards the key into its context")

	var visible_counts_268: Array = scene.make_empty_tile_counts()
	visible_counts_268[scene.tile_index("3W")] = 2
	visible_counts_268[scene.tile_index("E")] = 1
	var visible_key_268: String = scene.counts_compact_key(visible_counts_268)
	var baseline_context_268: Dictionary = scene.make_ai_evaluation_context(1, visible_counts_268)
	var snapshot_context_268: Dictionary = scene.make_ai_evaluation_context(1, visible_counts_268, visible_key_268)
	check(snapshot_context_268 == baseline_context_268, "key snapshot preserves the complete evaluation context")
	check(str(snapshot_context_268.get("visible_counts_key", "")) == visible_key_268, "context publishes the forwarded visible-count key")

	var baseline_report_key_268: String = scene.ai_report_cache_key(1, visible_counts_268)
	var snapshot_report_key_268: String = scene.ai_report_cache_key(1, visible_counts_268, -1, visible_key_268)
	check(snapshot_report_key_268 == baseline_report_key_268, "forwarded key preserves the discard report cache partition")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
