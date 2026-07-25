extends SceneTree
# Round-2 AI/play: difficulty scales + midgame/tenpai defense windows.
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
	print("=== ai_play_round2 check START ===")
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

	# --- A) difficulty scales ---
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL
	var normal_attack = scene.ai_profile_value(2, "attack")
	var normal_risk = scene.ai_profile_value(2, "risk")
	var normal_claim = scene.ai_profile_value(2, "claim")
	scene.ai_difficulty = scene.AI_DIFFICULTY_EASY
	var easy_attack = scene.ai_profile_value(2, "attack")
	var easy_risk = scene.ai_profile_value(2, "risk")
	var easy_claim = scene.ai_profile_value(2, "claim")
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var hard_attack = scene.ai_profile_value(2, "attack")
	var hard_risk = scene.ai_profile_value(2, "risk")
	var hard_claim = scene.ai_profile_value(2, "claim")
	print("    attack easy/normal/hard=%.3f/%.3f/%.3f" % [easy_attack, normal_attack, hard_attack])
	print("    risk easy/normal/hard=%.3f/%.3f/%.3f" % [easy_risk, normal_risk, hard_risk])
	print("    claim easy/normal/hard=%.3f/%.3f/%.3f" % [easy_claim, normal_claim, hard_claim])
	check(easy_attack < normal_attack and hard_attack > normal_attack, "困难攻更高、简单攻更低")
	check(easy_risk < normal_risk and hard_risk > normal_risk, "困难更谨慎(risk↑)、简单更松")
	check(easy_claim > normal_claim and hard_claim < normal_claim, "简单更贪吃碰、困难更挑")
	check(scene.ai_difficulty_label() == "困难", "难度标签困难")
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL
	check(scene.ai_difficulty_label() == "标准", "难度标签标准")

	# --- B) difficulty scale helper bounds ---
	scene.ai_difficulty = scene.AI_DIFFICULTY_EASY
	check(is_equal_approx(scene.ai_difficulty_scale("attack"), 0.84), "easy attack scale 0.84")
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	check(is_equal_approx(scene.ai_difficulty_scale("risk"), 1.24), "hard risk scale 1.24")
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL
	check(is_equal_approx(scene.ai_difficulty_scale("wait"), 1.0), "normal wait scale 1.0")

	# --- C) multi-threat raises defense weight ---
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL
	var cold = {"opponent_pressure": 2.0, "readiness_pressure": 3.0, "threat_rank": 0, "hot_opponents": 0, "multi_threat": false}
	var hot = {"opponent_pressure": 12.0, "readiness_pressure": 14.0, "threat_rank": 3, "hot_opponents": 3, "multi_threat": true}
	var d_cold = scene.ai_defense_weight(1, 2, cold)
	var d_hot = scene.ai_defense_weight(1, 2, hot)
	print("    defense cold=%.3f hot=%.3f" % [d_cold, d_hot])
	check(d_hot > d_cold, "多威胁时 defense_weight 更高")

	# --- D) midgame_danger rewards safe tile under multi-threat ---
	var mid_safe = scene.midgame_danger_adjustment(1, 2, 3, "安", 8.0, 5.0, hot)
	var mid_danger = scene.midgame_danger_adjustment(1, 2, 3, "", 36.0, 40.0, hot)
	print("    midgame safe=%.2f danger=%.2f" % [mid_safe, mid_danger])
	check(mid_safe > 0.0, "中盘安全牌正分")
	check(mid_danger < mid_safe, "中盘高危牌分低于安全牌")

	# --- E) tenpai_fold engages earlier for thin iishanten multi-threat ---
	# force wall count by trimming wall
	scene.wall.clear()
	for i in range(40):
		scene.wall.append("1B")
	# shanten1, ukeire2, multi threat, high risk vs safe
	var fold_safe = scene.tenpai_fold_adjustment(1, 1, 2, 400, 2, "安", 8.0, 4.0, hot)
	var fold_danger = scene.tenpai_fold_adjustment(1, 1, 2, 400, 2, "", 36.0, 40.0, hot)
	print("    fold@wall40 safe=%.2f danger=%.2f" % [fold_safe, fold_danger])
	check(fold_safe != 0.0 or fold_danger != 0.0, "薄一向听+多威胁在 wall=40 进入 fold 窗口")
	check(fold_safe > fold_danger, "fold 偏好安全弃牌")

	# cold low threat should often stay out at wall40 for non-thin without multi
	var fold_cold = scene.tenpai_fold_adjustment(1, 0, 10, 1600, 10, "安", 8.0, 4.0, cold)
	print("    fold cold strong tenpai=%.2f" % fold_cold)
	check(is_equal_approx(fold_cold, 0.0), "强听+低威胁不无故转守")

	# --- F) hard difficulty amplifies midgame vs easy ---
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var mid_hard = scene.midgame_danger_adjustment(1, 2, 3, "安", 8.0, 5.0, hot)
	scene.ai_difficulty = scene.AI_DIFFICULTY_EASY
	var mid_easy = scene.midgame_danger_adjustment(1, 2, 3, "安", 8.0, 5.0, hot)
	print("    midgame hard=%.2f easy=%.2f" % [mid_hard, mid_easy])
	check(mid_hard > mid_easy, "困难档中盘防守幅度更大")

	# --- G) settings helpers cycle ---
	scene.ai_difficulty = scene.AI_DIFFICULTY_EASY
	scene.cycle_ai_difficulty_setting()
	check(scene.ai_difficulty == scene.AI_DIFFICULTY_NORMAL, "cycle easy->normal")
	scene.cycle_ai_difficulty_setting()
	check(scene.ai_difficulty == scene.AI_DIFFICULTY_HARD, "cycle normal->hard")
	scene.cycle_ai_difficulty_setting()
	check(scene.ai_difficulty == scene.AI_DIFFICULTY_EASY, "cycle hard->easy")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
	else:
		print("=== RESULT: OK ===")
	quit(1 if failed else 0)
