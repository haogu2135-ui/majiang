extends SceneTree
## Round 114: discard reports reuse fixed evaluation inputs across candidates.

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
	print("=== ai_play_round114 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.wall = scene.make_wall()
	scene.players[1]["melds"] = [["1W", "1W", "1W"]]
	scene.players[1]["hand"] = ["2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "2T", "3T", "4T", "E", "S"]

	print("--- A) fixed discard context ---")
	var context: Dictionary = scene.make_ai_evaluation_context(1, scene.visible_tile_counts_shared())
	for key in [
		"discard_report_difficulty",
		"discard_report_wall_count",
		"discard_report_wait_focus",
		"discard_report_profile_label",
		"discard_report_profile_short",
	]:
		check(context.has(key), "discard context carries " + key)
	check(int(context.get("discard_report_difficulty", -1)) == clampi(scene.ai_difficulty, scene.AI_DIFFICULTY_EASY, scene.AI_DIFFICULTY_HARD), "discard context difficulty matches the live value")
	check(int(context.get("discard_report_wall_count", -1)) == scene.get_wall_count(), "discard context wall count matches the live value")
	check(is_equal_approx(float(context.get("discard_report_wait_focus", -1.0)), scene.ai_wait_value_focus(1)), "discard context wait focus matches the live value")

	print("--- B) helper snapshot equivalence ---")
	var pressure: Dictionary = scene.ai_pressure_context(1, context)
	var snapshot_defense: float = scene.ai_defense_weight(1, 2, pressure, context)
	var fallback_context: Dictionary = context.duplicate(true)
	for key in [
		"discard_report_difficulty",
		"discard_report_wall_count",
		"discard_report_wait_focus",
		"discard_report_profile_label",
		"discard_report_profile_short",
	]:
		fallback_context.erase(key)
	var fallback_defense: float = scene.ai_defense_weight(1, 2, pressure, fallback_context)
	check(is_equal_approx(snapshot_defense, fallback_defense), "defense weight preserves the legacy fallback result")
	check(is_equal_approx(
		scene.opening_efficiency_adjustment(1, "E", 4, scene.tile_counts(scene.players[1]["hand"]), 1, context),
		scene.opening_efficiency_adjustment(1, "E", 4, scene.tile_counts(scene.players[1]["hand"]), 1, fallback_context)
	), "opening adjustment preserves the legacy fallback result")
	check(is_equal_approx(
		scene.post_meld_route_adjustment(1, "E", 1, scene.tile_counts(scene.players[1]["hand"]), "标准", -1, 2, context),
		scene.post_meld_route_adjustment(1, "E", 1, scene.tile_counts(scene.players[1]["hand"]), "标准", -1, 2, fallback_context)
	), "post-meld adjustment preserves the legacy fallback result")

	print("--- C) report snapshot equivalence ---")
	var report_hand: Array = scene.players[1]["hand"]
	var report_tile := "E"
	var simulated: Array = report_hand.duplicate()
	simulated.erase(report_tile)
	var simulated_counts: Array = scene.tile_counts(simulated)
	var original_counts: Array = scene.tile_counts(report_hand)
	var pressure_report: Dictionary = scene.ai_pressure_context(1, context)
	var snapshot_report: Dictionary = scene.build_ai_discard_report(1, report_tile, simulated, 1, scene.visible_tile_counts_shared(), pressure_report, context, simulated_counts, original_counts, -1, scene.tile_index_normalized(report_tile))
	var fallback_report: Dictionary = scene.build_ai_discard_report(1, report_tile, simulated, 1, scene.visible_tile_counts_shared(), pressure_report, fallback_context, simulated_counts, original_counts, -1, scene.tile_index_normalized(report_tile))
	check(is_equal_approx(float(snapshot_report.get("score", -1.0)), float(fallback_report.get("score", -2.0))), "snapshot discard report preserves the legacy score")
	check(str(snapshot_report.get("ai_profile", "")) == str(fallback_report.get("ai_profile", "?")) and str(snapshot_report.get("ai_profile_short", "")) == str(fallback_report.get("ai_profile_short", "?")), "snapshot discard report preserves profile labels")
	check(int(snapshot_report.get("shanten", 99)) == int(fallback_report.get("shanten", -1)) and float(snapshot_report.get("risk", -1.0)) == float(fallback_report.get("risk", -2.0)), "snapshot discard report preserves state fields")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
