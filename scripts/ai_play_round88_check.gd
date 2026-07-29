extends SceneTree
## Round 88: quiet candidate reports must calculate their own changing plan route.
var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(cond: bool, msg: String) -> void:
	if cond:
		print("  OK  | %s" % msg)
	else:
		print("  FAIL| %s" % msg)
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


func report_after_discard(scene, hand: Array, tile: String, context: Dictionary) -> Dictionary:
	var simulated = hand.duplicate()
	simulated.erase(tile)
	var simulated_counts = scene.tile_counts(simulated)
	return scene.build_ai_discard_report(1, tile, simulated, 0, scene.visible_tile_counts(), {}, context, simulated_counts, scene.tile_counts(hand))


func run() -> void:
	print("=== ai_play_round88 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("AI"), make_player("P2"), make_player("P3")]
	# Deliberately disconnected hand: both post-discard candidates remain far
	# from tenpai, so this exercises the former quiet fast-plan shortcut.
	var hand: Array = ["1W", "4W", "7W", "1T", "4T", "7T", "1B", "4B", "7B", "E", "S", "W", "N", "P"]
	scene.players[1]["hand"] = hand.duplicate()
	scene.wall = scene.make_wall()
	var context = scene.make_ai_evaluation_context(1, scene.visible_tile_counts())
	# A stale shared plan used to leak straight into later quiet candidates.
	context["fast_plan_score"] = 999999.0
	context["fast_plan_report"] = {"label": "清一色", "score_bonus": 88.0, "suit": 0}

	print("--- A) quiet candidate ignores a stale shared route report ---")
	var report_p = report_after_discard(scene, hand, "P", context)
	var simulated_p = hand.duplicate()
	simulated_p.erase("P")
	var expected_p = scene.hand_plan_eval_for_seat_from_counts(1, scene.tile_counts(simulated_p), simulated_p.size())
	print("    P shanten=%d plan=%s/%.1f" % [int(report_p.get("shanten", -1)), str(report_p.get("plan_label", "")), float(report_p.get("plan", 0.0))])
	check(int(report_p.get("shanten", 0)) >= 3, "fixture reaches the quiet far-from-tenpai route path")
	check(is_equal_approx(float(report_p.get("plan", -1.0)), float(expected_p.get("score", -2.0))), "quiet report computes its own route score instead of using stale context")
	check(str(report_p.get("plan_label", "")) == str((expected_p.get("report", {}) as Dictionary).get("label", "")), "quiet report computes its own route label")

	print("--- B) adjacent candidates each match their own hand ---")
	var report_w = report_after_discard(scene, hand, "1W", context)
	var simulated_w = hand.duplicate()
	simulated_w.erase("1W")
	var expected_w = scene.hand_plan_eval_for_seat_from_counts(1, scene.tile_counts(simulated_w), simulated_w.size())
	check(is_equal_approx(float(report_w.get("plan", -1.0)), float(expected_w.get("score", -2.0))), "second quiet candidate uses its own route score")
	check(str(report_w.get("plan_label", "")) == str((expected_w.get("report", {}) as Dictionary).get("label", "")), "second quiet candidate uses its own route label")
	check(float(report_p.get("plan", 0.0)) < 1000.0 and float(report_w.get("plan", 0.0)) < 1000.0, "no candidate inherits the injected stale route score")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
