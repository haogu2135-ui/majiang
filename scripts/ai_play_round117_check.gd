extends SceneTree
## Round 117: discard reports reuse parsed difficulty and wait-focus inputs.

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
	print("=== ai_play_round117 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.wall = scene.make_wall()
	scene.players[0]["melds"] = [["E", "E", "E"]]
	scene.players[0]["discards"] = ["1W", "9W", "E"]
	scene.players[1]["melds"] = [["1W", "1W", "1W"]]
	var tenpai_hand: Array = ["2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W"]
	scene.players[1]["hand"] = tenpai_hand.duplicate()

	print("--- A) fixed context and wait-focus reuse ---")
	var context: Dictionary = scene.make_ai_evaluation_context(1, scene.visible_tile_counts_shared())
	check(context.has("discard_report_wait_focus") and context.has("discard_report_difficulty"), "discard context carries wait focus and parsed difficulty")
	check(is_equal_approx(float(context.get("discard_report_wait_focus", -1.0)), scene.ai_wait_value_focus(1)), "wait focus snapshot matches the live value")

	var counts: Array = scene.tile_counts(tenpai_hand)
	var report: Dictionary = scene.build_ai_discard_report(1, "1W", tenpai_hand, 1, scene.visible_tile_counts_shared(), {}, context, counts, counts, -1, scene.tile_index_normalized("1W"), 0)
	var expected: Dictionary = scene.wait_value_metrics(1, tenpai_hand, 1, 0, report.get("effective_tiles", []), report.get("effective_remaining", {}), true, {}, float(context.get("discard_report_attack_multiplier", -1.0)), float(context.get("discard_report_wait_focus", -1.0)), counts, 1)
	check(is_equal_approx(float(report.get("wait_value", -1.0)), float(expected.get("score", -2.0))), "discard report uses the captured wait focus")
	var fallback_context: Dictionary = context.duplicate(true)
	fallback_context.erase("discard_report_wait_focus")
	var fallback_report: Dictionary = scene.build_ai_discard_report(1, "1W", tenpai_hand, 1, scene.visible_tile_counts_shared(), {}, fallback_context, counts, counts, -1, scene.tile_index_normalized("1W"), 0)
	check(is_equal_approx(float(report.get("wait_value", -1.0)), float(fallback_report.get("wait_value", -2.0))), "wait-focus snapshot preserves the standalone fallback result")

	print("--- B) readiness cache result ---")
	var first_readiness: float = scene.human_readiness_for_defense()
	var second_readiness: float = scene.human_readiness_for_defense()
	check(is_equal_approx(first_readiness, second_readiness), "human readiness remains stable across cached reads")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
