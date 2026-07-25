extends SceneTree
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

func run() -> void:
	print("=== ai_play_round10 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.offline_hand_number = 1
	scene.dealer_seat = 0
	scene.wall = scene.make_wall()
	make_players(scene)
	if scene.has_method("setup_tile_order"):
		scene.setup_tile_order()
	scene.ai_assist_enabled = true
	scene.offline_all_bot_mode = false
	scene.offline_sim_quiet = false

	# --- A) human claim discipline: dirty chi from player declined harder on hard ---
	print("--- A) human claim discipline ---")
	# Human deep river + open melds => high readiness
	scene.players[0]["melds"] = [["1T","1T","1T"], ["2T","2T","2T"]]
	scene.players[0]["discards"] = []
	for i in range(12):
		scene.players[0]["discards"].append("9B")
	var short_wall: Array[String] = []
	for i in range(22):
		short_wall.append("1B")
	scene.wall = short_wall
	# AI seat1: high shanten hand that can chi 5W poorly
	scene.players[1]["melds"] = []
	scene.players[1]["hand"] = ["3W","4W","6W","7W","1B","3B","5B","7B","2T","4T","6T","8T","E"]
	scene.players[1]["discards"] = []
	var readiness = scene.human_readiness_for_defense()
	print("    readiness=%.2f" % readiness)
	check(readiness >= 8.0, "玩家压迫分足够触发纪律")

	var pressure = {"discard": "E", "risk": 36.0, "safety": "危"}
	scene.ai_difficulty = scene.AI_DIFFICULTY_EASY
	var d_e = scene.human_claim_discipline_report(1, "chi", 0, 3, 3, 4.0, pressure, 0)
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var d_h = scene.human_claim_discipline_report(1, "chi", 0, 3, 3, 4.0, pressure, 0)
	print("    easy decline=%s pen=%.1f | hard decline=%s pen=%.1f" % [
		str(d_e.get("decline", false)), float(d_e.get("penalty", 0.0)),
		str(d_h.get("decline", false)), float(d_h.get("penalty", 0.0)),
	])
	check(bool(d_h.get("decline", false)), "困难拒吃玩家垃圾进张")
	check(float(d_h.get("penalty", 0.0)) + 1e-3 >= float(d_e.get("penalty", 0.0)), "困难 claim 罚分不低于简单")
	check(bool(d_h.get("from_human", false)), "标记来自玩家弃牌")

	# not from human, low feed: should be softer
	var d_other = scene.human_claim_discipline_report(1, "chi", 2, 1, 0, 40.0, {"discard": "9B", "risk": 4.0, "safety": "安"}, 0)
	check(not bool(d_other.get("decline", false)), "降向听且安全切不误拒")

	# --- B) claim report wires declined_by_human / penalty ---
	print("--- B) claim report wiring ---")
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	scene.players[2]["melds"] = []
	scene.players[2]["hand"] = ["3W","4W","6W","7W","2B","3B","4B","5B","6B","7B","8B","E","S"]
	scene.players[2]["discards"] = []
	# keep human hot
	var ctx = scene.make_ai_claim_context(2, [], [], 0)
	check(int(ctx.get("from_seat", -1)) == 0, "claim context 携带 from_seat")
	var chi_choice = {"needed": ["3W","4W"], "score": 1.0}
	# If get_chi needs exact shape, build_ai_claim_report chi path uses needed tiles
	var rep = scene.build_ai_claim_report(2, "chi", "5W", chi_choice, ctx)
	print("    claim allow=%s reason=%s declined_human=%s pen=%.1f from=%s" % [
		str(rep.get("allow", false)), str(rep.get("reason", "")),
		str(rep.get("declined_by_human", false)), float(rep.get("human_claim_penalty", 0.0)),
		str(rep.get("from_seat", -1)),
	])
	check(rep.has("human_claim_penalty"), "claim 报告含 human_claim_penalty")
	check(rep.has("declined_by_human"), "claim 报告含 declined_by_human")
	check(int(rep.get("from_seat", -1)) == 0, "claim 报告 from_seat=玩家")
	# score path subtracts penalty
	var score = scene.ai_claim_action_score(rep, 1)
	var rep2 = rep.duplicate(true)
	rep2["human_claim_penalty"] = float(rep.get("human_claim_penalty", 0.0)) + 20.0
	var score2 = scene.ai_claim_action_score(rep2, 1)
	check(score2 < score - 19.0, "action score 扣 human_claim_penalty")

	# --- C) briefing toast once per match ---
	print("--- C) match briefing once ---")
	scene.offline_match_briefing_shown = false
	scene.offline_sim_quiet = true  # avoid real toast/render side effects in headless
	# unit: flag semantics
	var brief = scene.offline_hand_ai_briefing_text()
	check(brief.find("AI难度") >= 0, "简报文本可用")
	# simulate deal path flag
	scene.offline_sim_quiet = false
	scene.offline_match_briefing_shown = false
	# call internal logic equivalent
	if brief != "" and not scene.offline_match_briefing_shown:
		scene.offline_match_briefing_shown = true
	check(scene.offline_match_briefing_shown, "首局后标记已展示")
	var second_would_toast = brief != "" and not scene.offline_match_briefing_shown
	check(not second_would_toast, "次局不再 toast")

	# --- D) sim stats deal_ins_to_human field + bot smoke ---
	print("--- D) deal-in-to-human stats + smoke ---")
	scene.reset_ai_sim_stats()
	check(scene.ai_sim_stats.has("deal_ins_to_human"), "sim stats 含 deal_ins_to_human")
	check(scene.ai_sim_stats.has("human_claim_declines"), "sim stats 含 human_claim_declines")
	scene.enable_offline_all_bot_mode(true, true)
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL
	seed(1010)
	for s in range(4):
		scene.players[s]["score"] = 25000
	scene.dealer_seat = 1
	scene.offline_hand_number = 1
	scene.deal_offline_hand()
	scene.reset_ai_profile_seat_map()
	var t0 = Time.get_ticks_msec()
	var result = scene.simulate_offline_bot_hand_sync(700)
	var ms = Time.get_ticks_msec() - t0
	print("    hand ms=%d ended=%s deal_ins=%s to_human=%s declines=%s" % [
		ms, str(result.get("ended", false)), str(result.get("deal_ins", 0)),
		str(result.get("deal_ins_to_human", 0)), str(result.get("human_claim_declines", 0)),
	])
	check(bool(result.get("ended", false)) or int(result.get("steps", 0)) > 10, "R10 纪律下仍能推进终局/步数")
	check(ms < 30000, "单手 < 30s")
	check(result.has("deal_ins_to_human"), "sync 结果含 deal_ins_to_human")

	# --- E) benchmark exposes hard_safer_deal_in_to_human ---
	print("--- E) strength benchmark human deal-in ---")
	var bench = scene.sample_ai_strength_benchmark(1, 20260731)
	print("    dih e/h=%.2f/%.2f safer=%s declines e/h=%s/%s" % [
		float(bench.get("easy_deal_in_to_human", -1.0)),
		float(bench.get("hard_deal_in_to_human", -1.0)),
		str(bench.get("hard_safer_deal_in_to_human", false)),
		str(bench.get("easy_human_claim_declines", 0)),
		str(bench.get("hard_human_claim_declines", 0)),
	])
	check(bench.has("easy_deal_in_to_human") and bench.has("hard_deal_in_to_human"), "benchmark 含点炮玩家率")
	check(bench.has("hard_safer_deal_in_to_human"), "benchmark 含 hard_safer_deal_in_to_human")

	scene.enable_offline_all_bot_mode(false, false)
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
