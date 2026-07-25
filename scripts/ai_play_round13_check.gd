extends SceneTree
## Round 13: AI must not declare an added gang that any opponent can rob.
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

	print("--- A) AI opponent rob threat ---")
	setup_added_gang_fixture(scene)
	scene.players[2]["hand"] = rob_gang_wait_hand()
	check(scene.can_win_for_seat(2, "5W"), "AI 对手具备抢杠胡")
	var ai_threat = scene.added_gang_rob_threat_report(1, "5W")
	var ai_report = scene.build_ai_self_gang_report(1, "5W", "added")
	print("    threat=%s report=%s" % [ai_threat, ai_report])
	check(bool(ai_threat.get("can_rob", false)), "全桌威胁报告识别 AI 抢杠")
	check(int(ai_threat.get("winner_seat", -1)) == 2, "抢杠仲裁记录近家 AI")
	check(bool(ai_report.get("rob_risk", false)), "补杠报告带 AI 抢杠风险")
	check(not bool(ai_report.get("allow", true)) and str(ai_report.get("reason", "")) == "防抢杠", "AI 拒绝必被 AI 抢走的补杠")
	check(scene.choose_ai_added_gang(1) == "", "补杠选择器不会输出必抢杠牌")

	print("--- B) human rob threat remains protected ---")
	setup_added_gang_fixture(scene)
	scene.players[0]["hand"] = rob_gang_wait_hand()
	var human_threat = scene.added_gang_rob_threat_report(1, "5W")
	var human_report = scene.build_ai_self_gang_report(1, "5W", "added")
	check(bool(human_threat.get("human_robber", false)), "全桌威胁报告保留玩家抢杠")
	check(bool(human_report.get("rob_risk", false)), "玩家抢杠仍会阻止 AI 补杠")

	print("--- C) safe added gang has no false positive ---")
	setup_added_gang_fixture(scene)
	var safe_threat = scene.added_gang_rob_threat_report(1, "5W")
	var safe_report = scene.build_ai_self_gang_report(1, "5W", "added")
	check(not bool(safe_threat.get("can_rob", true)), "无人可抢时威胁报告为空")
	check(not bool(safe_report.get("rob_risk", true)), "无人可抢时补杠不带虚假风险")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
