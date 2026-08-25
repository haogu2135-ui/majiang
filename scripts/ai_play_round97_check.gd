extends SceneTree
## Round 97: exposed melds must affect the numeric route score used by AI choices.

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


func run() -> void:
	print("=== ai_play_round97 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("AI"), make_player("P2"), make_player("P3")]
	scene.players[1]["hand"] = ["4W", "5W", "6W", "7W", "8W", "9W", "E", "E"]
	scene.players[1]["melds"] = [["1W", "2W", "3W"]]
	scene.wall = scene.make_wall()

	print("--- A) exposed tiles participate in the route scalar ---")
	var concealed_counts = scene.tile_counts(scene.players[1]["hand"])
	var concealed_eval = scene.hand_plan_score_from_features(concealed_counts, scene.hand_plan_features_from_counts(concealed_counts, 8))
	var open_eval = scene.hand_plan_eval_for_seat_from_counts(1, concealed_counts, 8)
	var open_report: Dictionary = open_eval.get("report", {})
	print("    concealed=%.1f open=%.1f route=%s" % [
		concealed_eval,
		float(open_eval.get("score", 0.0)),
		str(open_report.get("label", "")),
	])
	check(float(open_eval.get("score", -1.0)) == float(open_report.get("score", -2.0)), "seat-aware route scalar matches its merged report")
	check(float(open_eval.get("score", 0.0)) > concealed_eval, "the exposed 123W meld strengthens the same-suit route")

	print("--- B) discard reports use that same merged score ---")
	var hand: Array = scene.players[1]["hand"].duplicate()
	var simulated: Array = hand.duplicate()
	simulated.erase("E")
	var simulated_counts = scene.tile_counts(simulated)
	var original_counts = scene.tile_counts(hand)
	var context = scene.make_ai_evaluation_context(1, scene.visible_tile_counts())
	var discard_report = scene.build_ai_discard_report(1, "E", simulated, 1, scene.visible_tile_counts(), {}, context, simulated_counts, original_counts)
	var expected_eval = scene.hand_plan_eval_for_seat_from_counts(1, simulated_counts, simulated.size())
	check(is_equal_approx(float(discard_report.get("plan", -1.0)), float((expected_eval.get("report", {}) as Dictionary).get("score", -2.0))), "post-meld discard report uses the merged route score")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
