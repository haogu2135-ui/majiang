extends SceneTree
## Round 7: all-bot sync sim, profile shuffle, late chase/fold acceptance.
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
	print("=== ai_play_round7 check START ===")
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
	scene.ai_assist_enabled = false
	scene.fast_mode_enabled = true
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL
	scene.sfx_enabled = false
	scene.music_enabled = false

	# --- A) seat0 bot control ---
	print("--- A) all-bot seat control ---")
	scene.enable_offline_all_bot_mode(false, false)
	check(not scene.is_ai_controlled_seat(0), "常规模式 seat0 非 AI")
	check(scene.is_ai_controlled_seat(2), "常规模式 seat2 是 AI")
	scene.enable_offline_all_bot_mode(true, true)
	check(scene.is_ai_controlled_seat(0), "全 bot 模式 seat0 是 AI")
	check(scene.is_ai_controlled_seat(3), "全 bot 模式 seat3 是 AI")

	# seat0 can be selected in choose_ai_claim
	scene.players[0]["hand"] = ["5W", "5W", "2T", "3T", "4T", "6T", "7T", "8T", "2B", "3B", "4B", "E", "S"]
	scene.players[1]["hand"] = ["1B", "2B", "3B", "4B", "5B", "6B", "7B", "8B", "9B", "1T", "2T", "3T", "4T"]
	scene.players[2]["hand"] = scene.players[1]["hand"].duplicate()
	scene.players[3]["hand"] = scene.players[1]["hand"].duplicate()
	for s in range(4):
		scene.players[s]["melds"] = []
		scene.players[s]["discards"] = []
	scene.wall.clear()
	for i in range(40):
		scene.wall.append("9B")
	scene.offline_phase = "resolving"
	var claim0 = scene.choose_ai_claim(1, "5W")
	print("    claim involving seat0: ", claim0)
	check(not claim0.is_empty(), "全 bot 下 seat0 可参与 claim")
	check(int(claim0.get("seat", -1)) == 0, "碰/响应座位为 0")

	# --- B) profile shuffle ---
	print("--- B) profile shuffle ---")
	scene.ai_difficulty = scene.AI_DIFFICULTY_EASY
	scene.reset_ai_profile_seat_map()
	scene.reshuffle_ai_profiles_for_hand()
	check(scene.ai_profile_seat_map == [0, 1, 2, 3], "简单档人设固定")
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	seed(42)
	scene.reshuffle_ai_profiles_for_hand()
	var map_a = scene.ai_profile_seat_map.duplicate()
	seed(99)
	scene.reshuffle_ai_profiles_for_hand()
	var map_b = scene.ai_profile_seat_map.duplicate()
	print("    hard map a/b=", map_a, "/", map_b)
	var sorted_a = map_a.duplicate(); sorted_a.sort()
	check(sorted_a == [0, 1, 2, 3], "困难档映射仍是 0-3 排列")
	# not required different, but labels resolvable
	check(scene.ai_profile_label(0) != "", "profile label 可读")

	# --- C) late chase/fold unit ---
	print("--- C) late chase/fold ---")
	scene.enable_offline_all_bot_mode(false, false)
	scene.offline_hand_number = scene.MATCH_MAX_HANDS
	scene.players[0]["score"] = 30000
	scene.players[1]["score"] = 15000
	scene.players[2]["score"] = 42000
	scene.players[3]["score"] = 22000
	scene.wall.clear()
	for i in range(20):
		scene.wall.append("5B")
	# thin tenpai-ish fold scale: use synthetic mid values
	var pressure = {"hot_opponents": 2, "multi_threat": true, "readiness_pressure": 12.0, "threat_rank": 3}
	scene.reset_ai_profile_seat_map()
	# 同一座位：先领先守成，再改分差为落后追分，排除人设干扰
	scene.players[2]["score"] = 42000
	scene.ai_difficulty = scene.AI_DIFFICULTY_EASY
	var fold_e = scene.tenpai_fold_adjustment(2, 1, 2, 400, 2, "安", 8.0, 3.0, pressure)
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var fold_h = scene.tenpai_fold_adjustment(2, 1, 2, 400, 2, "安", 8.0, 3.0, pressure)
	print("    fold easy/hard (ahead seat2)=%.2f/%.2f strategy=%s" % [fold_e, fold_h, str(scene.score_context_report(2).get("strategy", ""))])
	check(fold_h >= fold_e - 1e-3, "残局守成困难弃攻不低于简单")
	scene.players[2]["score"] = 12000
	var fold_chase = scene.tenpai_fold_adjustment(2, 1, 2, 400, 2, "安", 8.0, 3.0, pressure)
	print("    fold chase/ahead seat2=%.2f/%.2f strategy=%s" % [fold_chase, fold_h, str(scene.score_context_report(2).get("strategy", ""))])
	check(fold_chase <= fold_h + 1e-3, "同一座位追分弃攻不高于守成")

	# --- D) one sync bot hand completes ---
	print("--- D) sync bot hand ---")
	scene.enable_offline_all_bot_mode(true, true)
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL
	seed(1807)
	scene.offline_hand_number = 1
	scene.dealer_seat = 0
	for s in range(4):
		scene.players[s]["score"] = 25000
	scene.deal_offline_hand()
	var t0 = Time.get_ticks_msec()
	var result = scene.simulate_offline_bot_hand_sync(800)
	var elapsed = Time.get_ticks_msec() - t0
	print("    hand result: ended=%s winner=%s steps=%s discards=%s danger=%s wall=%s elapsed_ms=%s" % [
		str(result.get("ended", false)),
		str(result.get("winner", -1)),
		str(result.get("steps", 0)),
		str(result.get("discards", 0)),
		str(result.get("dangerous_discards", 0)),
		str(result.get("wall", -1)),
		str(elapsed),
	])
	check(bool(result.get("ended", false)) or int(result.get("steps", 0)) >= 50, "模拟推进足够步数或正常终局")
	check(int(result.get("discards", 0)) > 0, "产生弃牌")
	check(int(result.get("steps", 0)) < 800, "未死循环顶满步数")

	# --- E) multi-diff danger sample (1 hand each for runtime) ---
	print("--- E) difficulty danger sample ---")
	var summary = scene.sample_bot_strength_across_difficulties(1, 20260725)
	print("    summary: ", summary)
	var by: Dictionary = summary.get("by_diff", {})
	check(by.has(scene.AI_DIFFICULTY_EASY) and by.has(scene.AI_DIFFICULTY_HARD), "三档采样含 easy/hard")
	var easy_rate = float(by[scene.AI_DIFFICULTY_EASY].get("danger_rate", 1.0))
	var hard_rate = float(by[scene.AI_DIFFICULTY_HARD].get("danger_rate", 1.0))
	print("    danger_rate easy/hard=%.3f/%.3f" % [easy_rate, hard_rate])
	# 允许噪声：困难不应显著更浪
	check(hard_rate <= easy_rate + 0.35, "困难危险弃牌率不显著高于简单")

	# cleanup bot mode
	scene.enable_offline_all_bot_mode(false, false)
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
	else:
		print("=== RESULT: OK ===")
	quit(1 if failed else 0)
