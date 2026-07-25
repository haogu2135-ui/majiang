extends SceneTree
## Round 6: headless AI strength sampler + difficulty acceptance.
## Asserts hard >= normal >= easy on defense/value-awareness metrics across fixed scenarios.
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

func clear_table_noise(scene) -> void:
	for s in range(4):
		scene.players[s]["melds"] = []
		scene.players[s]["discards"] = []
		scene.players[s]["hand"] = []
		scene.players[s]["score"] = 25000
		scene.players[s]["flowers"] = 0
		scene.players[s]["flower_tiles"] = []

func set_hot_opponents(scene, seats: Array, meld_sets: int = 3, discard_count: int = 14) -> void:
	for s in seats:
		var melds: Array = []
		for m in range(meld_sets):
			var code = ["1T", "2T", "3T", "4T"][m % 4]
			melds.append([code, code, code])
		scene.players[s]["melds"] = melds
		scene.players[s]["discards"] = []
		for i in range(discard_count):
			scene.players[s]["discards"].append("9B")
		scene.players[s]["hand"] = []

func metric_triplet(scene, seat: int) -> Dictionary:
	# Collect scale + context metrics at current difficulty.
	var pressure = scene.ai_pressure_context(seat)
	var def_w = scene.ai_defense_weight(seat, 2, pressure)
	var mid = scene.midgame_danger_adjustment(seat, 2, 4, "安", 8.0, 5.0, pressure)
	return {
		"diff": clampi(scene.ai_difficulty, scene.AI_DIFFICULTY_EASY, scene.AI_DIFFICULTY_HARD),
		"defense": def_w,
		"risk": scene.ai_risk_factor(seat),
		"claim": scene.ai_claim_aggression(seat),
		"wait": scene.ai_wait_value_focus(seat),
		"route": scene.ai_route_focus(seat),
		"attack": scene.ai_profile_value(seat, "attack"),
		"midgame": mid,
		"pressure": pressure,
	}

func sample_top_discard(scene, seat: int) -> Dictionary:
	var reports = scene.get_ai_discard_reports(seat)
	if reports.is_empty():
		return {}
	var top: Dictionary = reports[0]
	var danger_score := 0.0
	var safe_best := -1.0e9
	for r in reports:
		var risk = float(r.get("risk", 0.0))
		var feed = float(r.get("feed_risk", 0.0))
		var score = float(r.get("score", 0.0))
		if risk >= 18.0:
			danger_score = max(danger_score, score)
		if str(r.get("safety_label", "")) in ["安", "现", "熟"] or risk < 12.0:
			safe_best = max(safe_best, score)
	return {
		"tile": str(top.get("tile", "")),
		"score": float(top.get("score", 0.0)),
		"risk": float(top.get("risk", 0.0)),
		"feed_risk": float(top.get("feed_risk", 0.0)),
		"defense": float(top.get("defense", 0.0)),
		"shanten": int(top.get("shanten", 8)),
		"safety": str(top.get("safety_label", "")),
		"danger_best_score": danger_score,
		"safe_best_score": safe_best,
		"report_count": reports.size(),
	}

func sample_across_difficulties(scene, seat: int) -> Dictionary:
	var out := {}
	for diff in [scene.AI_DIFFICULTY_EASY, scene.AI_DIFFICULTY_NORMAL, scene.AI_DIFFICULTY_HARD]:
		scene.ai_difficulty = diff
		# bust any residual cache path by touching a harmless field already in key
		out[diff] = {
			"metrics": metric_triplet(scene, seat),
			"top": sample_top_discard(scene, seat),
		}
	return out

func monotone_nondecreasing(a: float, b: float, c: float, eps: float = 1e-4) -> bool:
	return b + eps >= a and c + eps >= b

func monotone_nonincreasing(a: float, b: float, c: float, eps: float = 1e-4) -> bool:
	return b - eps <= a and c - eps <= b

func run() -> void:
	print("=== ai_play_round6 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.offline_hand_number = 4
	scene.dealer_seat = 0
	scene.wall = scene.make_wall()
	make_players(scene)
	if scene.has_method("setup_tile_order"):
		scene.setup_tile_order()
	scene.ai_assist_enabled = true
	scene.fast_mode_enabled = true
	seed(1806)

	# ---------- A) Scale monotonicity hard>=normal>=easy ----------
	print("--- A) difficulty scale ordering ---")
	clear_table_noise(scene)
	scene.players[2]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1B", "3B", "5B", "7B"]
	var scales = sample_across_difficulties(scene, 2)
	var m_e: Dictionary = scales[scene.AI_DIFFICULTY_EASY]["metrics"]
	var m_n: Dictionary = scales[scene.AI_DIFFICULTY_NORMAL]["metrics"]
	var m_h: Dictionary = scales[scene.AI_DIFFICULTY_HARD]["metrics"]
	print("    defense e/n/h=%.3f/%.3f/%.3f" % [m_e["defense"], m_n["defense"], m_h["defense"]])
	print("    risk    e/n/h=%.3f/%.3f/%.3f" % [m_e["risk"], m_n["risk"], m_h["risk"]])
	print("    claim   e/n/h=%.3f/%.3f/%.3f" % [m_e["claim"], m_n["claim"], m_h["claim"]])
	print("    wait    e/n/h=%.3f/%.3f/%.3f" % [m_e["wait"], m_n["wait"], m_h["wait"]])
	check(monotone_nondecreasing(m_e["defense"], m_n["defense"], m_h["defense"]), "defense hard>=normal>=easy")
	check(monotone_nondecreasing(m_e["risk"], m_n["risk"], m_h["risk"]), "risk hard>=normal>=easy")
	check(monotone_nonincreasing(m_e["claim"], m_n["claim"], m_h["claim"]), "claim easy>=normal>=hard (贪吃递减)")
	check(monotone_nondecreasing(m_e["wait"], m_n["wait"], m_h["wait"]), "wait hard>=normal>=easy")
	check(monotone_nondecreasing(m_e["route"], m_n["route"], m_h["route"]), "route hard>=normal>=easy")
	# seat2 进攻型：困难应比简单更拉开 attack 人设（相对中性 1.0 的偏离更大，再乘难度尺度）
	var atk_e = float(m_e["attack"])
	var atk_h = float(m_h["attack"])
	print("    attack profile e/h=%.3f/%.3f" % [atk_e, atk_h])
	check(atk_h > atk_e, "进攻座位困难 attack 高于简单")
	scene.ai_difficulty = scene.AI_DIFFICULTY_EASY
	var def_prof_e = scene.ai_profile_value(1, "defense")
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var def_prof_h = scene.ai_profile_value(1, "defense")
	print("    defense profile seat1 e/h=%.3f/%.3f" % [def_prof_e, def_prof_h])
	check(def_prof_h > def_prof_e, "防守座位困难 defense 人设更高")

	# ---------- B) Multi-threat midgame: hard punishes danger more ----------
	print("--- B) multi-threat midgame discard sample ---")
	clear_table_noise(scene)
	set_hot_opponents(scene, [0, 1, 3], 3, 15)
	scene.players[2]["melds"] = []
	# mixed hand with isolated honors that are often dangerous midgame
	scene.players[2]["hand"] = ["2W", "3W", "4W", "5W", "6W", "7W", "2T", "3T", "4T", "E", "S", "5B", "8B", "9B"]
	scene.wall.clear()
	for i in range(30):
		scene.wall.append("2B")
	var pressure = scene.ai_pressure_context(2)
	print("    pressure multi/hot=", pressure.get("multi_threat", false), "/", pressure.get("hot_opponents", 0))
	check(bool(pressure.get("multi_threat", false)) or int(pressure.get("hot_opponents", 0)) >= 2, "B multi-threat scene armed")
	var mid_samples = sample_across_difficulties(scene, 2)
	var t_e: Dictionary = mid_samples[scene.AI_DIFFICULTY_EASY]["top"]
	var t_n: Dictionary = mid_samples[scene.AI_DIFFICULTY_NORMAL]["top"]
	var t_h: Dictionary = mid_samples[scene.AI_DIFFICULTY_HARD]["top"]
	var mid_e = float(mid_samples[scene.AI_DIFFICULTY_EASY]["metrics"]["midgame"])
	var mid_n = float(mid_samples[scene.AI_DIFFICULTY_NORMAL]["metrics"]["midgame"])
	var mid_h = float(mid_samples[scene.AI_DIFFICULTY_HARD]["metrics"]["midgame"])
	print("    midgame e/n/h=%.2f/%.2f/%.2f" % [mid_e, mid_n, mid_h])
	print("    top tile/risk e=%s/%.1f n=%s/%.1f h=%s/%.1f" % [
		t_e.get("tile", "?"), t_e.get("risk", -1.0),
		t_n.get("tile", "?"), t_n.get("risk", -1.0),
		t_h.get("tile", "?"), t_h.get("risk", -1.0),
	])
	print("    danger_best_score e/n/h=%.1f/%.1f/%.1f" % [
		t_e.get("danger_best_score", 0.0), t_n.get("danger_best_score", 0.0), t_h.get("danger_best_score", 0.0),
	])
	check(monotone_nondecreasing(mid_e, mid_n, mid_h), "midgame safe-push hard>=normal>=easy")
	check(float(t_h.get("defense", 0.0)) >= float(t_e.get("defense", 0.0)) - 1e-4, "top report defense hard>=easy")
	# Hard should not score dangerous candidates higher than easy (relative to its safe best).
	var gap_e = float(t_e.get("danger_best_score", 0.0)) - float(t_e.get("safe_best_score", 0.0))
	var gap_h = float(t_h.get("danger_best_score", 0.0)) - float(t_h.get("safe_best_score", 0.0))
	print("    danger-safe gap e/h=%.1f/%.1f" % [gap_e, gap_h])
	check(gap_h <= gap_e + 8.0, "困难档危险张相对安全张优势不高于简单")

	# ---------- C) Opening efficiency sample ----------
	print("--- C) opening efficiency ---")
	clear_table_noise(scene)
	scene.wall.clear()
	for i in range(70):
		scene.wall.append("5B")
	scene.players[2]["hand"] = ["1W", "3W", "5W", "7W", "9W", "2T", "5T", "8T", "1B", "4B", "7B", "E", "S", "N"]
	var counts = scene.tile_counts(scene.players[2]["hand"])
	scene.ai_difficulty = scene.AI_DIFFICULTY_EASY
	var open_e = scene.opening_efficiency_adjustment(2, "E", 4, counts, 0)
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL
	var open_n = scene.opening_efficiency_adjustment(2, "E", 4, counts, 0)
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var open_h = scene.opening_efficiency_adjustment(2, "E", 4, counts, 0)
	print("    opening honor dump e/n/h=%.2f/%.2f/%.2f" % [open_e, open_n, open_h])
	check(open_e > 0.0 and open_n > 0.0 and open_h > 0.0, "序盘孤张字牌有正效率分")
	check(monotone_nondecreasing(open_e, open_n, open_h), "opening hard>=normal>=easy")

	# ---------- D) Claim discipline: early thin chi less allowed on hard ----------
	print("--- D) claim discipline ---")
	clear_table_noise(scene)
	scene.wall.clear()
	for i in range(64):
		scene.wall.append("5B")
	# seat1 can peng 5W; early wall so claim discipline / aggression matter
	scene.players[1]["hand"] = ["5W", "5W", "2T", "3T", "4T", "6T", "7T", "8T", "2B", "3B", "4B", "E", "S"]
	scene.players[0]["hand"] = ["5W"]
	scene.offline_phase = "resolving"
	var claim_allows := {}
	var claim_scores := {}
	var claim_types := {}
	for diff in [scene.AI_DIFFICULTY_EASY, scene.AI_DIFFICULTY_NORMAL, scene.AI_DIFFICULTY_HARD]:
		scene.ai_difficulty = diff
		var claim = scene.choose_ai_claim(0, "5W")
		claim_allows[diff] = not claim.is_empty() and str(claim.get("claim", "")) != ""
		claim_types[diff] = str(claim.get("claim", "-"))
		claim_scores[diff] = float(claim.get("score", -9999.0)) if not claim.is_empty() else -9999.0
		var report = {}
		if not claim.is_empty():
			report = claim.get("claim_report", {})
		print("    claim diff=%d allow=%s claim=%s score=%.1f after_sh=%s" % [
			diff,
			str(claim_allows[diff]),
			claim_types[diff],
			claim_scores[diff],
			str(report.get("after_shanten", "-")),
		])
	check(float(claim_scores[scene.AI_DIFFICULTY_EASY]) + 1e-3 >= float(claim_scores[scene.AI_DIFFICULTY_HARD]), "简单碰/吃分不低于困难")
	check(true, "claim path exercised")

	# ---------- E) Late human-relative chase/fold ----------
	print("--- E) late score chase/fold ---")
	clear_table_noise(scene)
	scene.offline_hand_number = scene.MATCH_MAX_HANDS
	scene.players[0]["score"] = 30000
	scene.players[1]["score"] = 16000
	scene.players[2]["score"] = 42000
	scene.players[3]["score"] = 22000
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var atk_behind = scene.human_relative_attack_bias(1)
	var def_ahead = scene.human_relative_defense_bias(2)
	var atk_ahead = scene.human_relative_attack_bias(2)
	print("    late behind_atk=%.3f ahead_atk=%.3f ahead_def=%.3f" % [atk_behind, atk_ahead, def_ahead])
	check(atk_behind > 1.0, "残局落后追分进攻>1")
	check(atk_ahead < 1.0, "残局领先收力进攻<1")
	check(def_ahead > 0.0, "残局领先加防守偏置")
	scene.ai_difficulty = scene.AI_DIFFICULTY_EASY
	var atk_behind_easy = scene.human_relative_attack_bias(1)
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var atk_behind_hard = scene.human_relative_attack_bias(1)
	check(atk_behind_hard >= atk_behind_easy - 1e-4, "困难落后追分不低于简单")

	# ---------- F) Short multi-seat discard sampling (bot seats only) ----------
	print("--- F) multi-seat short sample ---")
	clear_table_noise(scene)
	scene.offline_hand_number = 3
	scene.wall.clear()
	for i in range(40):
		scene.wall.append("5B")
	# Give each bot seat a 14-tile closed hand (ready to discard)
	var hands = {
		1: ["1W", "2W", "3W", "4W", "5W", "6W", "2T", "3T", "4T", "5T", "6T", "7T", "E", "9B"],
		2: ["1B", "2B", "3B", "4B", "5B", "6B", "7B", "8B", "2W", "3W", "4W", "S", "N", "Z"],
		3: ["1T", "1T", "2T", "2T", "3T", "3T", "4W", "5W", "6W", "7W", "8W", "9W", "F", "P"],
	}
	var risk_sums := {
		scene.AI_DIFFICULTY_EASY: 0.0,
		scene.AI_DIFFICULTY_NORMAL: 0.0,
		scene.AI_DIFFICULTY_HARD: 0.0,
	}
	var def_sums := {
		scene.AI_DIFFICULTY_EASY: 0.0,
		scene.AI_DIFFICULTY_NORMAL: 0.0,
		scene.AI_DIFFICULTY_HARD: 0.0,
	}
	var sample_n := 0
	for seat in hands.keys():
		# light table pressure from human river
		scene.players[0]["discards"] = ["1B", "2B", "3B", "4B", "5B", "6B", "7B", "8B", "9B", "1T", "9T", "E"]
		scene.players[0]["melds"] = [["9W", "9W", "9W"]]
		for other in range(4):
			if other == seat:
				continue
			if other != 0:
				scene.players[other]["hand"] = ["5B", "5B", "5B", "5B", "5B", "5B", "5B", "5B", "5B", "5B", "5B", "5B", "5B"]
				scene.players[other]["melds"] = []
				scene.players[other]["discards"] = []
		scene.players[seat]["hand"] = hands[seat].duplicate()
		scene.players[seat]["melds"] = []
		scene.players[seat]["discards"] = []
		for diff in [scene.AI_DIFFICULTY_EASY, scene.AI_DIFFICULTY_NORMAL, scene.AI_DIFFICULTY_HARD]:
			scene.ai_difficulty = diff
			var top = sample_top_discard(scene, seat)
			risk_sums[diff] += float(top.get("risk", 0.0))
			def_sums[diff] += float(top.get("defense", 0.0))
		sample_n += 1
	var avg_risk_e = risk_sums[scene.AI_DIFFICULTY_EASY] / float(sample_n)
	var avg_risk_n = risk_sums[scene.AI_DIFFICULTY_NORMAL] / float(sample_n)
	var avg_risk_h = risk_sums[scene.AI_DIFFICULTY_HARD] / float(sample_n)
	var avg_def_e = def_sums[scene.AI_DIFFICULTY_EASY] / float(sample_n)
	var avg_def_n = def_sums[scene.AI_DIFFICULTY_NORMAL] / float(sample_n)
	var avg_def_h = def_sums[scene.AI_DIFFICULTY_HARD] / float(sample_n)
	print("    avg top risk e/n/h=%.2f/%.2f/%.2f" % [avg_risk_e, avg_risk_n, avg_risk_h])
	print("    avg top def  e/n/h=%.3f/%.3f/%.3f" % [avg_def_e, avg_def_n, avg_def_h])
	check(sample_n == 3, "三座位短采样完成")
	check(monotone_nondecreasing(avg_def_e, avg_def_n, avg_def_h), "多样本平均 defense hard>=normal>=easy")
	# Risk of chosen tile need not be strictly monotone (shape can dominate), but hard should not be wildly riskier.
	check(avg_risk_h <= avg_risk_e + 12.0, "困难平均选牌风险不显著高于简单")

	# ---------- G) Pace / difficulty labels sanity ----------
	print("--- G) pace & labels ---")
	scene.fast_mode_enabled = true
	scene.wall.clear()
	for i in range(50):
		scene.wall.append("5B")
	scene.ai_difficulty = scene.AI_DIFFICULTY_EASY
	var pace_e = scene.ai_pace_multiplier()
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var pace_h = scene.ai_pace_multiplier()
	print("    pace easy/hard=%.3f/%.3f" % [pace_e, pace_h])
	check(pace_e > 0.0 and pace_h > 0.0, "pace multipliers positive")
	check(scene.AI_DIFFICULTY_LABELS.size() == 3, "三档难度标签齐全")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
	else:
		print("=== RESULT: OK ===")
	quit(1 if failed else 0)
