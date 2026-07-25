extends SceneTree
# Round-1 AI/play regression: smarter ron pass/accept + multi-threat pressure fields.
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
		})

func run() -> void:
	print("=== ai_play_round1 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.offline_hand_number = 1
	scene.dealer_seat = 0
	scene.wall = scene.make_wall()  # typed Array[String]
	make_players(scene)
	if scene.has_method("setup_tile_order"):
		scene.setup_tile_order()
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL

	# --- A) single wait must accept ron ---
	# Seat 1: closed standard tenpai waiting only 5W (approx via complete hand-1).
	# Use a known complete hand and remove 5W.
	var complete = ["1W","1W","1W","2W","3W","4W","5W","6W","7W","8W","9W","9W","9W","5W"]
	# 14-tile complete; tenpai removes one 5W -> wait includes 5W
	scene.players[1]["hand"] = complete.duplicate()
	scene.players[1]["hand"].erase("5W")
	scene.players[1]["melds"] = []
	scene.players[1]["flowers"] = 0
	check(scene.can_win_for_seat(1, "5W"), "seat1 can ron 5W on constructed hand")
	var accept_single = scene.ai_ron_decision_report(1, "5W")
	print("    single-wait decision: %s" % accept_single)
	check(bool(accept_single.get("accept", false)), "单听/无更优听口时必须接受荣和")

	# --- B) multi-wait: deep wall + 大牌型 may pass low-value for better wait ---
	scene.wall.clear()
	for i in range(48):
		scene.wall.append("2B")
	scene.dealer_seat = 0
	# True tenpai fixture:
	# 1W = 一条龙 4番1600; 2W/4W/... = 2番400
	var multi_hand: Array = ["2W","3W","4W","5W","6W","7W","8W","9W","9W","9W","2T","3T","4T"]
	for s in range(4):
		scene.players[s]["discards"] = []
		scene.players[s]["melds"] = []
		scene.players[s]["flowers"] = 0
		scene.players[s]["hand"] = ["2B","3B","4B","5B","6B","7B","8B","9B","2B","3B","4B","5B","6B"]
	scene.players[3]["hand"] = multi_hand.duplicate()
	check(scene.can_win_for_seat(3, "2W"), "seat3 can ron low-value 2W")
	check(scene.can_win_for_seat(3, "1W"), "seat3 can ron high-value 1W")
	var low_score = scene.calculate_win_score_from_tiles(3, multi_hand + ["2W"], false)
	var high_score = scene.calculate_win_score_from_tiles(3, multi_hand + ["1W"], false)
	print("    low2W=%s high1W=%s" % [low_score, high_score])
	check(int(high_score.get("points", 0)) > int(low_score.get("points", 0)), "1W 分数应高于 2W")
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var leave = scene.ai_ron_decision_report(3, "2W")
	print("    leave-tenpai decision on 2W: %s" % leave)
	check(leave.has("accept") and leave.has("reason"), "多面听 decision 字段完整")
	check(not bool(leave.get("accept", true)), "大牌型深牌墙面对低价值听口应留听高番")
	check(str(leave.get("reason", "")).find("留听") >= 0, "reason 标记留听")
	var take_high = scene.ai_ron_decision_report(3, "1W")
	print("    take high 1W: %s" % take_high)
	check(bool(take_high.get("accept", false)), "高价值听口仍接受")
	# 防守型 seat1 更倾向落袋（标准档）
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL
	scene.players[1]["hand"] = multi_hand.duplicate()
	var defensive = scene.ai_ron_decision_report(1, "2W")
	print("    defensive seat1 on 2W: %s" % defensive)
	check(bool(defensive.get("accept", false)), "防守型低价值荣和也倾向落袋")

	# Restore a simple winning seat for claim-path checks below.
	var claim_hand: Array = ["1W","1W","1W","2W","3W","4W","5W","6W","7W","8W","9W","9W","9W"]
	scene.players[1]["hand"] = claim_hand.duplicate()
	scene.players[2]["hand"] = ["1B","2B","3B","4B","5B","6B","7B","8B","9B","1T","2T","3T","4T"]
	scene.players[3]["hand"] = ["1B","2B","3B","4B","5B","6B","7B","8B","9B","1T","2T","3T","4T"]

	# --- C) rob-gang path always accept via choose_ai_rob_gang ---
	scene.players[2]["hand"] = scene.players[1]["hand"].duplicate()
	var rob = scene.choose_ai_rob_gang(0, "5W")
	print("    rob gang: %s" % rob)
	check(str(rob.get("claim", "")) == "hu", "抢杠可和时返回 hu")

	# --- D) choose_ai_claim returns hu with claim_report when accepting ---
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	scene.offline_phase = "resolving"
	# only seat1 can claim; seats 2/3 empty-ish
	scene.players[2]["hand"] = ["1B","2B","3B","4B","5B","6B","7B","8B","9B","1T","2T","3T","4T"]
	scene.players[3]["hand"] = ["1B","2B","3B","4B","5B","6B","7B","8B","9B","1T","2T","3T","4T"]
	var claim = scene.choose_ai_claim(0, "5W")
	print("    choose_ai_claim: %s" % claim)
	check(str(claim.get("claim", "")) == "hu", "choose_ai_claim 在可和时返回 hu")
	check(claim.has("claim_report"), "choose_ai_claim hu 带 claim_report")

	# --- E) multi-threat pressure fields ---
	# Inflate opponents readiness via many melds/discards.
	for seat in [0, 2, 3]:
		scene.players[seat]["melds"] = [["1T","1T","1T"], ["2T","2T","2T"], ["3T","3T","3T"]]
		scene.players[seat]["discards"] = []
		for i in range(15):
			scene.players[seat]["discards"].append("9B")
	var pressure = scene.ai_pressure_context(1)
	print("    pressure: %s" % pressure)
	check(pressure.has("hot_opponents"), "pressure 含 hot_opponents")
	check(pressure.has("multi_threat"), "pressure 含 multi_threat")
	check(int(pressure.get("hot_opponents", 0)) >= 2, "多副露多河牌对手计为 multi hot")
	check(bool(pressure.get("multi_threat", false)), "multi_threat 为 true")

	# --- F) chi threshold first open stricter than continued open ---
	var chi0 = scene.ai_claim_shape_threshold(1, "chi", 0)
	var chi1 = scene.ai_claim_shape_threshold(1, "chi", 1)
	print("    chi thresholds open0=%.2f open1=%.2f" % [chi0, chi1])
	check(chi0 > chi1, "首副露吃门槛高于已副露")

	# --- G) defensive profile chi threshold >= balanced ---
	var chi_def = scene.ai_claim_shape_threshold(1, "chi", 0)  # seat1 防守型
	var chi_bal = scene.ai_claim_shape_threshold(0, "chi", 0)  # seat0 均衡（函数不看人类，只看 profile）
	print("    chi def=%.2f bal=%.2f" % [chi_def, chi_bal])
	check(chi_def >= chi_bal - 1e-4, "防守型首吃门槛不低于均衡")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
	else:
		print("=== RESULT: OK ===")
	quit(1 if failed else 0)
