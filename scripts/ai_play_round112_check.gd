extends SceneTree
## Round 112: claim reports reuse seat-static strategy snapshots.

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
	print("=== ai_play_round112 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.wall = scene.make_wall()
	scene.players[1]["hand"] = ["1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E", "R"]

	print("--- A) claim context snapshots ---")
	var context: Dictionary = scene.make_ai_claim_context(1, scene.visible_tile_counts_shared(), [], 0)
	check(context.has("claim_report_attack_multiplier") and context.has("claim_report_claim_aggression") and context.has("claim_report_risk_factor") and context.has("claim_report_route_focus"), "claim context carries seat-static strategy values")
	check(is_equal_approx(float(context.get("claim_report_attack_multiplier", -1.0)), scene.ai_total_attack_multiplier(1)), "claim context attack snapshot matches the live value")
	check(is_equal_approx(float(context.get("claim_report_claim_aggression", -1.0)), scene.ai_claim_aggression(1)), "claim context claim snapshot matches the live value")
	check(is_equal_approx(float(context.get("claim_report_risk_factor", -1.0)), scene.ai_risk_factor(1)), "claim context risk snapshot matches the live value")
	check(is_equal_approx(float(context.get("claim_report_route_focus", -1.0)), scene.ai_route_focus(1)), "claim context route snapshot matches the live value")

	print("--- B) report and score equivalence ---")
	var cached_report: Dictionary = scene.build_ai_claim_report(1, "peng", "1W", {}, context)
	var standalone_report: Dictionary = scene.build_ai_claim_report(1, "peng", "1W")
	check(bool(cached_report.get("allow", false)) == bool(standalone_report.get("allow", false)) and str(cached_report.get("reason", "")) == str(standalone_report.get("reason", "")), "cached and standalone claim decisions agree")
	check(is_equal_approx(float(cached_report.get("shape_gain", -1.0)), float(standalone_report.get("shape_gain", -2.0))) and is_equal_approx(float(cached_report.get("threshold", -1.0)), float(standalone_report.get("threshold", -2.0))), "cached and standalone claim shape values agree")
	check(is_equal_approx(float(cached_report.get("ai_attack_multiplier", -1.0)), float(context.get("claim_report_attack_multiplier", -2.0))) and is_equal_approx(float(cached_report.get("ai_claim_aggression", -1.0)), float(context.get("claim_report_claim_aggression", -2.0))) and is_equal_approx(float(cached_report.get("ai_risk_factor", -1.0)), float(context.get("claim_report_risk_factor", -2.0))) and is_equal_approx(float(cached_report.get("ai_route_focus", -1.0)), float(context.get("claim_report_route_focus", -2.0))), "claim report carries the shared strategy values")
	var cached_score: float = scene.ai_claim_action_score(cached_report, 1)
	var fallback_report: Dictionary = cached_report.duplicate(true)
	for key in ["ai_attack_multiplier", "ai_claim_aggression", "ai_risk_factor", "ai_route_focus"]:
		fallback_report.erase(key)
	var fallback_score: float = scene.ai_claim_action_score(fallback_report, 1)
	check(is_equal_approx(cached_score, fallback_score), "snapshot claim score matches the fallback score")
	check(is_equal_approx(scene.ai_claim_route_bonus(cached_report), scene.ai_claim_route_bonus(fallback_report)), "snapshot route bonus matches the fallback bonus")

	print("--- C) claim helper snapshots ---")
	var aggression: float = float(context.get("claim_report_claim_aggression", -1.0))
	check(is_equal_approx(scene.ai_claim_meld_bonus(1, "peng", "1W"), scene.ai_claim_meld_bonus(1, "peng", "1W", {}, aggression)), "meld bonus accepts the shared aggression snapshot")
	check(is_equal_approx(scene.ai_claim_shape_threshold(1, "peng", 0), scene.ai_claim_shape_threshold(1, "peng", 0, aggression)), "shape threshold accepts the shared aggression snapshot")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
