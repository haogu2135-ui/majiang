extends SceneTree
## Round 13: added-gang risk must respect the public-information boundary.
var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(cond: bool, msg: String) -> void:
	if cond:
		print("  OK  | %s" % msg)
	else:
		print("  FAIL| %s" % msg)
		failed = true


func make_players(scene) -> void:
	scene.players = []
	for i in range(4):
		scene.players.append({
			"name": "P%d" % i,
			"hand": [],
			"discards": [],
			"melds": [],
			"flowers": 0,
			"flower_tiles": [],
			"score": 25000,
			"bot": i != 0,
		})


func rob_gang_wait_hand() -> Array:
	# 5W completes 111/234/678/999/55.
	return ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W"]


func non_winning_hand() -> Array:
	return ["1B", "2B", "3B", "4B", "5B", "6B", "7B", "8B", "9B", "1T", "2T", "3T", "4T"]


func setup_added_gang_fixture(scene) -> void:
	for seat in range(4):
		scene.players[seat]["hand"] = non_winning_hand()
		scene.players[seat]["melds"] = []
		scene.players[seat]["discards"] = []
	scene.players[1]["hand"] = ["5W", "1B", "2B", "3B", "4B", "5B", "6B", "7B", "8B", "9B"]
	scene.players[1]["melds"] = [["5W", "5W", "5W"]]
	scene.offline_phase = "await_discard"
	scene.current_seat = 1
	scene.offline_turn_needs_draw = false


func run() -> void:
	print("=== ai_play_round13 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.offline_hand_number = 3
	scene.dealer_seat = 0
	scene.wall = scene.make_wall()
	make_players(scene)
	if scene.has_method("setup_tile_order"):
		scene.setup_tile_order()
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL
	scene.offline_all_bot_mode = false
	scene.offline_sim_quiet = true

	print("--- A) hidden AI wait is not exposed to the declarer ---")
	setup_added_gang_fixture(scene)
	scene.players[2]["hand"] = rob_gang_wait_hand()
	check(scene.can_win_for_seat(2, "5W"), "AI 对手具备抢杠胡")
	var ai_threat = scene.added_gang_rob_threat_report(1, "5W")
	var ai_report = scene.build_ai_self_gang_report(1, "5W", "added")
	print("    threat=%s report=%s" % [ai_threat, ai_report])
	check(bool(ai_threat.get("public_only", false)), "补杠威胁报告只使用公开信息")
	check(int(ai_threat.get("winner_seat", -2)) == -1 and not bool(ai_threat.get("ai_robber", true)), "报告不泄露暗手中的 AI 抢杠者")
	var ai_choice = scene.choose_ai_added_gang(1)

	print("--- B) human hidden wait produces the same public decision ---")
	setup_added_gang_fixture(scene)
	scene.players[0]["hand"] = rob_gang_wait_hand()
	var human_threat = scene.added_gang_rob_threat_report(1, "5W")
	var human_report = scene.build_ai_self_gang_report(1, "5W", "added")
	var human_choice = scene.choose_ai_added_gang(1)
	check(is_equal_approx(float(human_threat.get("risk_score", -1.0)), float(ai_threat.get("risk_score", -2.0))), "AI/玩家暗手互换不改变公开风险")
	check(bool(human_report.get("rob_risk", false)) == bool(ai_report.get("rob_risk", true)) and bool(human_report.get("allow", false)) == bool(ai_report.get("allow", true)), "AI/玩家暗手互换不改变补杠决定")
	check(human_choice == ai_choice, "AI/玩家暗手互换不改变选择器输出")
	check(not bool(human_threat.get("human_robber", true)), "报告不泄露玩家暗手抢杠")

	print("--- C) non-winning hidden hand keeps the same public decision ---")
	setup_added_gang_fixture(scene)
	var safe_threat = scene.added_gang_rob_threat_report(1, "5W")
	var safe_report = scene.build_ai_self_gang_report(1, "5W", "added")
	var safe_choice = scene.choose_ai_added_gang(1)
	check(is_equal_approx(float(safe_threat.get("risk_score", -1.0)), float(ai_threat.get("risk_score", -2.0))), "能否实际抢杠不改变公开风险")
	check(bool(safe_report.get("rob_risk", false)) == bool(ai_report.get("rob_risk", true)) and bool(safe_report.get("allow", false)) == bool(ai_report.get("allow", true)), "能否实际抢杠不改变补杠决定")
	check(safe_choice == ai_choice, "能否实际抢杠不改变选择器输出")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
