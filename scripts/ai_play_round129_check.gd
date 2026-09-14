extends SceneTree
## Round 129: threat/readiness paths reuse one wall-count snapshot.

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
	print("=== ai_play_round129 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[1]["discards"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T"]
	scene.players[1]["melds"] = [["E", "E", "E"], ["5W", "5W", "5W"]]
	scene.wall.clear()
	for _i in range(55):
		scene.wall.append("1B")

	var visible_counts: Array = scene.visible_tile_counts_shared()
	var wall_snapshot: int = scene.get_wall_count()
	print("--- A) evaluation context carries wall into opponent readiness ---")
	var eval_context: Dictionary = scene.make_ai_evaluation_context(0, visible_counts)
	var opponent_state: Dictionary = eval_context.get("opponents", {}).get(1, {})
	var plan_pressure: float = float(opponent_state.get("plan_pressure", -1.0))
	var expected_readiness: float = scene.opponent_readiness_score_from_plan(1, plan_pressure, wall_snapshot)
	check(int(eval_context.get("discard_report_wall_count", -1)) == wall_snapshot, "evaluation context stores the current wall count")
	check(is_equal_approx(float(opponent_state.get("readiness", -1.0)), expected_readiness), "runtime opponent readiness uses the context wall snapshot")

	print("--- B) retained wall snapshot remains stable during report construction ---")
	scene.wall.clear()
	var contextual_report: Dictionary = scene.opponent_readiness_report(0, 1, eval_context)
	var expected_contextual: float = scene.opponent_readiness_score_from_plan(1, plan_pressure, wall_snapshot)
	check(is_equal_approx(float(contextual_report.get("score", -1.0)), expected_contextual), "contextual readiness keeps the captured score")
	check(not contextual_report.get("reasons", []).has("末盘") and not contextual_report.get("reasons", []).has("后盘"), "contextual readiness reasons use the captured wall")

	print("--- C) context-free fallback remains equivalent ---")
	var fallback_report: Dictionary = scene.opponent_readiness_report(0, 1)
	var fallback_expected: float = scene.opponent_readiness_score_from_plan(1, plan_pressure, 0)
	check(is_equal_approx(float(fallback_report.get("score", -1.0)), fallback_expected), "context-free readiness still uses the live wall")
	check(fallback_report.get("reasons", []).has("末盘"), "context-free readiness still reports the live late-wall reason")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
