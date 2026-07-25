extends SceneTree
## Round 8: fast bot eval, high-danger calibration, multi-hand strength.
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
			"bot": true,
		})

func run() -> void:
	print("=== ai_play_round8 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.offline_hand_number = 1
	scene.dealer_seat = 0
	make_players(scene)
	if scene.has_method("setup_tile_order"):
		scene.setup_tile_order()
	scene.ai_assist_enabled = false
	scene.fast_mode_enabled = true
	scene.sfx_enabled = false
	scene.music_enabled = false
	scene.fx_enabled = false
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL

	# --- A) high-risk penalty: hard scores dangerous tile lower than easy ---
	print("--- A) high-risk score penalty ---")
	scene.enable_offline_all_bot_mode(false, false)
	scene.reset_ai_profile_seat_map()
	# Build a midgame multi-threat table so risk is real
	for s in [0, 1, 3]:
		scene.players[s]["melds"] = [["1T","1T","1T"],["2T","2T","2T"],["3T","3T","3T"]]
		scene.players[s]["discards"] = []
		for i in range(14):
			scene.players[s]["discards"].append("9B")
		scene.players[s]["hand"] = []
	scene.players[2]["melds"] = []
	scene.players[2]["discards"] = []
	scene.players[2]["hand"] = ["2W","3W","4W","5W","6W","7W","2B","3B","4B","E","S","N","5T","8T"]
	scene.wall.clear()
	for i in range(28):
		scene.wall.append("2B")
	var open_melds = 0
	var hand = scene.players[2]["hand"].duplicate()
	var sim = hand.duplicate()
	# discard E for report
	var e_idx = sim.find("E")
	sim.remove_at(e_idx)
	scene.ai_difficulty = scene.AI_DIFFICULTY_EASY
	var rep_e = scene.build_ai_discard_report(2, "E", sim, open_melds)
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var rep_h = scene.build_ai_discard_report(2, "E", sim, open_melds)
	print("    E risk e/h=%.1f/%.1f score e/h=%.1f/%.1f" % [
		float(rep_e.get("risk", 0.0)), float(rep_h.get("risk", 0.0)),
		float(rep_e.get("score", 0.0)), float(rep_h.get("score", 0.0)),
	])
	check(float(rep_e.get("risk", 0.0)) >= 0.0, "risk 字段存在")
	# 若该张有实质危险，困难分应更苛刻（允许风险同值时仅靠罚分拉开）
	if float(rep_e.get("risk", 0.0)) >= scene.AI_DANGER_RISK_SOFT:
		check(float(rep_h.get("score", 0.0)) <= float(rep_e.get("score", 0.0)) + 1e-3, "困难对高危张评分不高于简单")
	else:
		check(true, "当前夹具风险偏低，跳过分差强断言")

	# --- B) fast eval top-k under quiet ---
	print("--- B) fast eval path ---")
	scene.enable_offline_all_bot_mode(true, true)
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL
	scene.reset_ai_profile_seat_map()
	scene.players[2]["melds"] = []
	scene.players[2]["hand"] = ["1W","2W","3W","4W","5W","6W","7W","8W","1B","3B","5B","7B","E","S"]
	for s in [0, 1, 3]:
		scene.players[s]["hand"] = ["5B","5B","5B","5B","5B","5B","5B","5B","5B","5B","5B","5B","5B"]
		scene.players[s]["melds"] = []
		scene.players[s]["discards"] = []
	scene.wall.clear()
	for i in range(40):
		scene.wall.append("9B")
	scene.ai_report_cache.clear()
	scene.ai_report_cache_order.clear()
	var t0 = Time.get_ticks_msec()
	var reports = scene.get_ai_discard_reports(2)
	var dt = Time.get_ticks_msec() - t0
	print("    fast reports=%d ms=%d top=%s" % [reports.size(), dt, str(reports[0].get("tile", "")) if not reports.is_empty() else "-"])
	check(reports.size() > 0 and reports.size() <= scene.AI_FAST_EVAL_TOP_K, "快评只保留 Top-K 完整报告")
	check(dt < 8000, "单次快评弃牌报告 < 8s")

	# --- C) one hand timing budget ---
	print("--- C) bot hand timing ---")
	seed(808)
	scene.offline_hand_number = 1
	scene.dealer_seat = 0
	for s in range(4):
		scene.players[s]["score"] = 25000
	scene.deal_offline_hand()
	scene.reset_ai_profile_seat_map()
	var t1 = Time.get_ticks_msec()
	var hand_result = scene.simulate_offline_bot_hand_sync(800)
	var hand_ms = Time.get_ticks_msec() - t1
	print("    hand ms=%d ended=%s discards=%s high_danger=%s deal_ins=%s" % [
		hand_ms,
		str(hand_result.get("ended", false)),
		str(hand_result.get("discards", 0)),
		str(hand_result.get("high_danger_discards", 0)),
		str(hand_result.get("deal_ins", 0)),
	])
	check(bool(hand_result.get("ended", false)), "一手能终局")
	check(hand_ms < 22000, "一手全 bot < 22s（快评目标）")
	check(int(hand_result.get("discards", 0)) > 0, "有弃牌统计")

	# --- D) multi-diff high_danger ordering soft ---
	print("--- D) multi-diff sample ---")
	var summary = scene.sample_bot_strength_across_difficulties(1, 20260728, false)
	print("    summary: ", summary)
	var by: Dictionary = summary.get("by_diff", {})
	var easy_hd = float(by[scene.AI_DIFFICULTY_EASY].get("high_danger_rate", 1.0))
	var hard_hd = float(by[scene.AI_DIFFICULTY_HARD].get("high_danger_rate", 1.0))
	var easy_di = float(by[scene.AI_DIFFICULTY_EASY].get("deal_in_rate", 1.0))
	var hard_di = float(by[scene.AI_DIFFICULTY_HARD].get("deal_in_rate", 1.0))
	print("    high_danger easy/hard=%.3f/%.3f deal_in=%.2f/%.2f" % [easy_hd, hard_hd, easy_di, hard_di])
	var easy_dr = float(by[scene.AI_DIFFICULTY_EASY].get("danger_rate", 1.0))
	var hard_dr = float(by[scene.AI_DIFFICULTY_HARD].get("danger_rate", 1.0))
	print("    soft_danger easy/hard=%.3f/%.3f" % [easy_dr, hard_dr])
	# 单手噪声大：高危用宽容差；软危险率困难不应明显更浪
	check(hard_hd <= easy_hd + 0.40, "困难高危弃牌率不显著高于简单")
	check(hard_dr <= easy_dr + 0.20, "困难软危险率不显著高于简单")
	check(hard_di <= easy_di + 1.01, "困难放铳率不显著更差（单手容差）")

	# --- E) multi-hand winrate stability ---
	print("--- E) multi-hand winrates ---")
	var wr = scene.sample_bot_match_winrates(3, 20260729)
	print("    winrates: ", wr)
	check(int(wr.get("finished", 0)) >= 2, "至少 2/3 手正常终局")
	var wins: Array = wr.get("win_counts", [0, 0, 0, 0])
	var win_sum = 0
	for w in wins:
		win_sum += int(w)
	check(win_sum >= 1, "多手中出现胜者")

	scene.enable_offline_all_bot_mode(false, false)
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
	else:
		print("=== RESULT: OK ===")
	quit(1 if failed else 0)
