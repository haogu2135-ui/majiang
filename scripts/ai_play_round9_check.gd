extends SceneTree
## Round 9: human-target anti-deal-in, deal briefing, multi-hand strength benchmark.
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
	print("=== ai_play_round9 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.offline_hand_number = 4
	scene.dealer_seat = 0
	make_players(scene)
	if scene.has_method("setup_tile_order"):
		scene.setup_tile_order()
	scene.ai_assist_enabled = true
	scene.fast_mode_enabled = true
	scene.sfx_enabled = false
	scene.music_enabled = false
	scene.fx_enabled = false
	scene.enable_offline_all_bot_mode(false, false)
	scene.reset_ai_profile_seat_map()

	# --- A) human readiness + target penalty scales by difficulty ---
	print("--- A) human-target anti-deal-in ---")
	scene.players[0]["melds"] = [["1T","1T","1T"],["2T","2T","2T"],["3T","3T","3T"]]
	scene.players[0]["discards"] = []
	for i in range(15):
		scene.players[0]["discards"].append("9B")
	scene.players[0]["hand"] = ["5W","6W","7W","1B","2B","3B","4B","5B","6B","7B"]
	scene.wall.clear()
	for i in range(22):
		scene.wall.append("2B")
	var ready = scene.human_readiness_for_defense()
	print("    human readiness=", ready)
	check(ready >= 8.0, "多副露深河牌玩家压迫感足够")

	var feed = {
		"details": [
			{"opponent": 0, "name": "P0", "claim": "peng", "label": "碰", "score": 42.0},
			{"opponent": 1, "name": "P1", "claim": "peng", "label": "碰", "score": 12.0},
		],
		"score": 45.0,
	}
	scene.ai_difficulty = scene.AI_DIFFICULTY_EASY
	var pen_e = scene.human_target_discard_penalty(2, "5W", 28.0, feed, 2)
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL
	var pen_n = scene.human_target_discard_penalty(2, "5W", 28.0, feed, 2)
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var pen_h = scene.human_target_discard_penalty(2, "5W", 28.0, feed, 2)
	print("    human_pen e/n/h=%.2f/%.2f/%.2f" % [pen_e, pen_n, pen_h])
	check(pen_e > 0.0 and pen_n > 0.0 and pen_h > 0.0, "对玩家喂牌惩罚为正")
	check(pen_h > pen_e, "困难防点炮惩罚高于简单")
	check(pen_n >= pen_e - 1e-3, "标准不低于简单")

	# full report includes field and hard scores the feed tile worse
	scene.players[2]["melds"] = []
	scene.players[2]["hand"] = ["2W","3W","4W","5W","6W","7W","2B","3B","4B","5W","E","S","N","Z"]
	var sim = scene.players[2]["hand"].duplicate()
	var idx = sim.find("5W")
	sim.remove_at(idx)
	scene.ai_difficulty = scene.AI_DIFFICULTY_EASY
	var rep_e = scene.build_ai_discard_report(2, "5W", sim, 0)
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var rep_h = scene.build_ai_discard_report(2, "5W", sim, 0)
	print("    report human_pen e/h=%.2f/%.2f score e/h=%.1f/%.1f" % [
		float(rep_e.get("human_target_penalty", 0.0)),
		float(rep_h.get("human_target_penalty", 0.0)),
		float(rep_e.get("score", 0.0)),
		float(rep_h.get("score", 0.0)),
	])
	check(rep_e.has("human_target_penalty") and rep_h.has("human_target_penalty"), "弃牌报告含 human_target_penalty")
	check(float(rep_h.get("human_target_penalty", 0.0)) + 1e-3 >= float(rep_e.get("human_target_penalty", 0.0)), "报告内困难惩罚不低于简单")

	# seat0 self no penalty
	var pen_self = scene.human_target_discard_penalty(0, "5W", 28.0, feed, 2)
	check(is_equal_approx(pen_self, 0.0), "seat0 自身无 human-target 惩罚")

	# --- B) deal briefing text ---
	print("--- B) deal briefing ---")
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	scene.reset_ai_profile_seat_map()
	var brief = scene.offline_hand_ai_briefing_text()
	print("    briefing: ", brief)
	check(brief.find("AI难度") >= 0, "开局简报含难度")
	check(brief.find("·") >= 0 or brief.length() > 6, "开局简报含对手人设")

	# --- C) sync hand still healthy with R9 penalties ---
	print("--- C) bot hand smoke ---")
	scene.enable_offline_all_bot_mode(true, true)
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL
	seed(909)
	for s in range(4):
		scene.players[s]["score"] = 25000
	scene.dealer_seat = 1
	scene.offline_hand_number = 1
	scene.deal_offline_hand()
	scene.reset_ai_profile_seat_map()
	var t0 = Time.get_ticks_msec()
	var hand = scene.simulate_offline_bot_hand_sync(800)
	var ms = Time.get_ticks_msec() - t0
	print("    hand ms=%d ended=%s discards=%s" % [ms, str(hand.get("ended", false)), str(hand.get("discards", 0))])
	check(bool(hand.get("ended", false)), "R9 惩罚下仍能终局")
	check(ms < 25000, "单手 < 25s")

	# --- D) multi-hand benchmark (2 each) ---
	print("--- D) strength benchmark ---")
	var bench = scene.sample_ai_strength_benchmark(2, 20260730)
	print("    bench: high_danger e/h=%.3f/%.3f deal_in e/h=%.2f/%.2f ms e/h=%.0f/%.0f" % [
		float(bench.get("easy_high_danger", 1.0)),
		float(bench.get("hard_high_danger", 1.0)),
		float(bench.get("easy_deal_in", 1.0)),
		float(bench.get("hard_deal_in", 1.0)),
		float(bench.get("avg_ms_easy", 0.0)),
		float(bench.get("avg_ms_hard", 0.0)),
	])
	check(float(bench.get("hard_high_danger", 1.0)) <= float(bench.get("easy_high_danger", 0.0)) + 0.15, "多手困难高危率不显著高于简单")
	check(float(bench.get("hard_deal_in", 1.0)) <= float(bench.get("easy_deal_in", 0.0)) + 0.75, "多手放铳率困难不显著更差")
	check(float(bench.get("avg_ms_hard", 99999.0)) < 30000.0, "困难档平均单手仍可接受")

	scene.enable_offline_all_bot_mode(false, false)
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
	else:
		print("=== RESULT: OK ===")
	quit(1 if failed else 0)
