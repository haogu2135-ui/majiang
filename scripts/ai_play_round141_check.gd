extends SceneTree
## Round 141: quiet discard pre-ranking reuses the visible-count snapshot.

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
	print("=== ai_play_round141 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.offline_all_bot_mode = true
	scene.current_seat = 1
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.players = [make_player("P0"), make_player("AI"), make_player("P2"), make_player("P3")]
	scene.wall = scene.make_wall()
	scene.players[1]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "3T", "5T", "E", "S"]

	var visible_counts: Array = scene.visible_tile_counts_shared()
	var explicit_context: Dictionary = scene.make_ai_evaluation_context(1, visible_counts)
	var legacy_context: Dictionary = scene.make_ai_evaluation_context(1, visible_counts)
	var explicit_risk: Dictionary = scene.tile_risk_vector("1W", 1, visible_counts, explicit_context)
	var legacy_risk: Dictionary = scene.tile_risk_vector("1W", 1, [], legacy_context)

	print("--- A) fast risk vector preserves the legacy result ---")
	print("    explicit risk=%.1f threat=%.1f | legacy risk=%.1f threat=%.1f" % [
		float(explicit_risk.get("score", 0.0)),
		float(explicit_risk.get("threat", 0.0)),
		float(legacy_risk.get("score", 0.0)),
		float(legacy_risk.get("threat", 0.0)),
	])
	check(is_equal_approx(float(explicit_risk.get("score", 0.0)), float(legacy_risk.get("score", 0.0))) and is_equal_approx(float(explicit_risk.get("threat", 0.0)), float(legacy_risk.get("threat", 0.0))) and int(explicit_risk.get("visible", -1)) == int(legacy_risk.get("visible", -2)), "显式可见牌快照保持风险向量结果一致")
	check(explicit_risk.get("danger_source", {}) == legacy_risk.get("danger_source", {}), "显式可见牌快照保持危险来源一致")

	print("--- B) quiet discard pre-ranking remains bounded ---")
	var context_output: Dictionary = {}
	var reports: Array = scene.get_ai_discard_reports(1, visible_counts, context_output)
	print("    reports=%d top_k=%d" % [reports.size(), scene.AI_FAST_EVAL_TOP_K])
	check(reports.size() > 0 and reports.size() <= scene.AI_FAST_EVAL_PRESSURE_TOP_K, "静默弃牌粗排仍保留有界 Top-K 完整报告")
	check(context_output.has("visible_counts") and (context_output.get("visible_counts", []) as Array).size() == scene.TILE_CODES.size(), "粗排上下文保留本轮可见牌快照")
	var report_risks_match := true
	for report_variant in reports:
		if typeof(report_variant) != TYPE_DICTIONARY:
			continue
		var report: Dictionary = report_variant
		var tile := str(report.get("tile", ""))
		var risk: Dictionary = scene.tile_risk_vector(tile, 1, visible_counts, context_output)
		if not is_equal_approx(float(report.get("risk", 0.0)), float(risk.get("score", 0.0))):
			report_risks_match = false
	check(report_risks_match, "粗排报告风险值与共享可见牌快照一致")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
