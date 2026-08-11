extends SceneTree
## Round 91: added-gang AI uses public information, while gameplay still resolves real chankan.
var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(cond: bool, msg: String) -> void:
	if cond:
		print("  OK  | %s" % msg)
	else:
		print("  FAIL| %s" % msg)
		failed = true


func make_player(name: String, bot: bool) -> Dictionary:
	return {
		"name": name,
		"hand": [],
		"discards": [],
		"melds": [],
		"flowers": 0,
		"flower_tiles": [],
		"score": 25000,
		"bot": bot,
	}


func rob_gang_wait_hand() -> Array:
	# 5W completes 111/234/678/999/55.
	return ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W"]


func non_winning_hand() -> Array:
	return ["1B", "2B", "3B", "4B", "5B", "6B", "7B", "8B", "9B", "1T", "2T", "3T", "4T"]


func setup_low_public_state(scene) -> void:
	scene.players = [
		make_player("玩家", false),
		make_player("AI", true),
		make_player("P2", true),
		make_player("P3", true),
	]
	for seat in range(4):
		scene.players[seat]["hand"] = non_winning_hand()
	scene.players[1]["hand"] = ["5W", "1B", "2B", "3B", "4B", "5B", "6B", "7B", "8B", "9B"]
	scene.players[1]["melds"] = [["5W", "5W", "5W"]]
	scene.wall = scene.make_wall()
	scene.offline_phase = "await_discard"
	scene.current_seat = 1
	scene.offline_turn_needs_draw = false
	scene.clear_threat_report_cache()


func run() -> void:
	print("=== ai_play_round91 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL
	scene.offline_all_bot_mode = false
	scene.offline_sim_quiet = true

	print("--- A) concealed opponent tiles cannot change the declaration decision ---")
	setup_low_public_state(scene)
	scene.players[0]["hand"] = rob_gang_wait_hand()
	check(scene.can_ron_for_seat(0, "5W"), "hidden fixture really can rob the added gang")
	var hidden_wait_threat = scene.added_gang_rob_threat_report(1, "5W")
	var hidden_wait_report = scene.build_ai_self_gang_report(1, "5W", "added")
	var hidden_wait_choice = scene.choose_ai_added_gang(1)

	setup_low_public_state(scene)
	scene.players[0]["hand"] = non_winning_hand()
	check(not scene.can_ron_for_seat(0, "5W"), "control fixture cannot rob the added gang")
	var hidden_safe_threat = scene.added_gang_rob_threat_report(1, "5W")
	var hidden_safe_report = scene.build_ai_self_gang_report(1, "5W", "added")
	var hidden_safe_choice = scene.choose_ai_added_gang(1)
	print("    wait risk=%.2f allow=%s choice=%s | safe risk=%.2f allow=%s choice=%s" % [
		float(hidden_wait_threat.get("risk_score", -1.0)),
		str(hidden_wait_report.get("allow", false)),
		hidden_wait_choice,
		float(hidden_safe_threat.get("risk_score", -2.0)),
		str(hidden_safe_report.get("allow", false)),
		hidden_safe_choice,
	])
	check(bool(hidden_wait_threat.get("public_only", false)), "added-gang threat report declares the public-information boundary")
	check(is_equal_approx(float(hidden_wait_threat.get("risk_score", -1.0)), float(hidden_safe_threat.get("risk_score", -2.0))), "public risk is identical across hidden-hand swaps")
	check(bool(hidden_wait_report.get("rob_risk", false)) == bool(hidden_safe_report.get("rob_risk", true)), "rob-risk decision is hidden-hand invariant")
	check(bool(hidden_wait_report.get("allow", false)) == bool(hidden_safe_report.get("allow", true)), "added-gang allow decision is hidden-hand invariant")
	check(hidden_wait_choice == hidden_safe_choice, "added-gang selector is hidden-hand invariant")
	check(int(hidden_wait_threat.get("winner_seat", -2)) == -1 and not bool(hidden_wait_threat.get("human_robber", true)) and not bool(hidden_wait_threat.get("ai_robber", true)), "AI report does not expose an exact concealed winner")

	print("--- B) strong public readiness can still deter a risky added gang ---")
	setup_low_public_state(scene)
	scene.wall.clear()
	for i in range(16):
		scene.wall.append("9B")
	scene.players[0]["melds"] = [
		["1W", "2W", "3W"],
		["6W", "7W", "8W"],
		["E", "E", "E"],
	]
	scene.players[0]["discards"] = ["1T", "2T", "3T", "4T", "5T", "6T", "7T", "8T", "9T", "1B", "2B", "3B"]
	scene.clear_threat_report_cache()
	var public_hot = scene.added_gang_rob_threat_report(1, "5W")
	var public_hot_report = scene.build_ai_self_gang_report(1, "5W", "added")
	print("    public hot=%s report risk=%.2f/%.2f" % [public_hot, float(public_hot_report.get("rob_risk_score", 0.0)), float(public_hot_report.get("rob_risk_threshold", 0.0))])
	check(float(public_hot.get("max_risk", 0.0)) >= float(public_hot.get("risk_threshold", 999.0)), "late three-meld public pressure crosses the chankan risk gate")
	check(bool(public_hot_report.get("rob_risk", false)), "AI marks high public chankan risk")
	check(not bool(public_hot_report.get("allow", true)), "AI declines the publicly dangerous added gang")

	print("--- C) real gameplay still offers chankan after declaration ---")
	setup_low_public_state(scene)
	scene.players[0]["hand"] = rob_gang_wait_hand()
	scene.perform_added_gang(1, "5W")
	check(scene.offline_phase == "pending_claim", "declared added gang opens the human response window")
	check(bool(scene.offline_pending_claim.get("rob_gang", false)), "response window is marked as chankan")
	check(scene.offline_pending_claim.get("options", []) == ["hu"], "actual concealed winner receives the hu option")

	scene.shutdown_runtime()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
