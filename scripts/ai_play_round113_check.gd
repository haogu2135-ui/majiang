extends SceneTree
## Round 113: self-gang reports reuse selector-level strategy snapshots.

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
	print("=== ai_play_round113 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.wall = scene.make_wall()
	scene.players[1]["hand"] = ["5W", "5W", "5W", "5W", "1W", "2W", "3W", "7W", "8W", "9W", "2T", "3T", "4T", "E"]

	print("--- A) selector context snapshots ---")
	var hand_counts: Array = scene.tile_counts(scene.players[1]["hand"])
	var context: Dictionary = scene.make_ai_evaluation_context(1, scene.visible_tile_counts_shared())
	context["hand_counts"] = hand_counts
	context["self_gang_attack_multiplier"] = scene.ai_total_attack_multiplier(1)
	context["self_gang_gang_aggression"] = scene.ai_gang_aggression(1)
	context["self_gang_wait_focus"] = scene.ai_wait_value_focus(1)
	context["self_gang_difficulty"] = scene.AI_DIFFICULTY_NORMAL
	check(context.has("self_gang_attack_multiplier") and context.has("self_gang_gang_aggression") and context.has("self_gang_wait_focus") and context.has("self_gang_difficulty"), "self-gang context carries static strategy values")
	check(is_equal_approx(float(context.get("self_gang_attack_multiplier", -1.0)), scene.ai_total_attack_multiplier(1)), "self-gang attack snapshot matches the live value")
	check(is_equal_approx(float(context.get("self_gang_gang_aggression", -1.0)), scene.ai_gang_aggression(1)), "self-gang aggression snapshot matches the live value")
	check(is_equal_approx(float(context.get("self_gang_wait_focus", -1.0)), scene.ai_wait_value_focus(1)), "self-gang wait snapshot matches the live value")

	print("--- B) report and score equivalence ---")
	var cached_report: Dictionary = scene.build_ai_self_gang_report(1, "5W", "concealed", context)
	var standalone_report: Dictionary = scene.build_ai_self_gang_report(1, "5W", "concealed")
	check(bool(cached_report.get("allow", false)) == bool(standalone_report.get("allow", false)) and str(cached_report.get("reason", "")) == str(standalone_report.get("reason", "")), "cached and standalone self-gang decisions agree")
	check(int(cached_report.get("before_shanten", 99)) == int(standalone_report.get("before_shanten", -1)) and int(cached_report.get("after_shanten", 99)) == int(standalone_report.get("after_shanten", -1)), "cached and standalone self-gang shanten values agree")
	check(is_equal_approx(float(cached_report.get("ai_attack_multiplier", -1.0)), float(context.get("self_gang_attack_multiplier", -2.0))) and is_equal_approx(float(cached_report.get("ai_gang_aggression", -1.0)), float(context.get("self_gang_gang_aggression", -2.0))) and is_equal_approx(float(cached_report.get("ai_wait_focus", -1.0)), float(context.get("self_gang_wait_focus", -2.0))), "self-gang report carries the shared strategy values")
	var cached_score: float = scene.ai_self_gang_action_score(cached_report)
	var fallback_report: Dictionary = cached_report.duplicate(true)
	for key in ["ai_attack_multiplier", "ai_gang_aggression", "ai_wait_focus", "ai_difficulty"]:
		fallback_report.erase(key)
	var fallback_score: float = scene.ai_self_gang_action_score(fallback_report)
	check(is_equal_approx(cached_score, fallback_score), "snapshot self-gang score matches the fallback score")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
