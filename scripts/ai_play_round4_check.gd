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
		})

func run() -> void:
	print("=== ai_play_round4 check START ===")
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

	# --- A) post-meld route: dump off-suit after open pure-suit lean ---
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	# seat2 has open meld of W, hand mostly W + off-suit T
	scene.players[2]["melds"] = [["1W", "1W", "1W"]]
	scene.players[2]["hand"] = ["2W", "3W", "4W", "5W", "6W", "7W", "8W", "2T", "9T", "E"]
	var counts = scene.tile_counts(scene.players[2]["hand"] + ["2T"])  # original with candidate
	# Simulate discarding 2T vs 5W under 清一色-ish plan
	var dump_off = scene.post_meld_route_adjustment(2, "2T", 1, scene.tile_counts(["2W","3W","4W","5W","6W","7W","8W","2T","9T","E"]), "清一色", 0, 2)
	var keep_main = scene.post_meld_route_adjustment(2, "5W", 1, scene.tile_counts(["2W","3W","4W","5W","6W","7W","8W","2T","9T","E"]), "清一色", 0, 2)
	print("    post-meld dump_off=%.2f keep_main=%.2f" % [dump_off, keep_main])
	check(dump_off > keep_main, "副露清一色优先切外花色")
	check(dump_off > 0.0, "切外花色得正分")

	# closed hand no post-meld bonus
	var closed = scene.post_meld_route_adjustment(2, "2T", 0, scene.tile_counts(["2W","3W","4W","5W","6W","7W","8W","2T","9T","E"]), "清一色", 0, 2)
	check(is_equal_approx(closed, 0.0), "未副露无 post-meld 加成")

	# --- B) plan_report_with_extra_melds ---
	scene.players[3]["melds"] = []
	scene.players[3]["hand"] = ["2W","3W","4W","5W","6W","7W","8W","9W","2T","3T"]
	var hand_counts = scene.tile_counts(scene.players[3]["hand"])
	var with_peng = scene.plan_report_with_extra_melds(3, hand_counts, scene.players[3]["hand"].size(), ["1W","1W","1W"])
	print("    plan with extra peng: ", with_peng)
	check(with_peng.has("label"), "extra meld plan 有 label")
	check(str(with_peng.get("label", "")) != "七对", "副露后不标七对")

	# --- C) claim route bonus ---
	var route_up = scene.ai_claim_route_bonus({
		"seat": 3,
		"plan_label": "标准",
		"after_plan_label": "清一色",
		"plan_bonus": 0.0,
		"after_plan_bonus": 40.0,
	})
	var route_down = scene.ai_claim_route_bonus({
		"seat": 3,
		"plan_label": "清一色",
		"after_plan_label": "标准",
		"plan_bonus": 40.0,
		"after_plan_bonus": 0.0,
	})
	print("    route_up=%.2f route_down=%.2f" % [route_up, route_down])
	check(route_up > 0.0, "锁定清一色 claim 加分")
	check(route_down < 0.0, "破坏清一色 claim 减分")

	# --- D) human-relative calibration late game ---
	scene.offline_hand_number = scene.MATCH_MAX_HANDS  # late
	scene.players[0]["score"] = 32000
	scene.players[1]["score"] = 18000
	scene.players[2]["score"] = 25000
	scene.players[3]["score"] = 25000
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var late_ctx = scene.score_context_report(1)
	print("    late ctx seat1: ", late_ctx)
	var atk_behind = scene.score_attack_multiplier(1)
	var atk_neutral = 1.0
	# seat2 even with human - use equal scores
	scene.players[2]["score"] = 32000
	var atk_evenish = scene.human_relative_attack_bias(2)
	scene.players[1]["score"] = 40000  # ahead of human
	var atk_ahead_bias = scene.human_relative_attack_bias(1)
	var def_ahead = scene.human_relative_defense_bias(1)
	print("    atk_behind=%.3f ahead_bias=%.3f def_ahead=%.3f" % [atk_behind, atk_ahead_bias, def_ahead])
	check(atk_behind > 1.0, "落后玩家时进攻偏置 > 1")
	check(atk_ahead_bias < 1.0, "领先玩家时进攻偏置 < 1")
	check(def_ahead > 0.0, "领先玩家时防守偏置 > 0")

	# early game no bias
	scene.offline_hand_number = 1
	var early_bias = scene.human_relative_attack_bias(1)
	check(is_equal_approx(early_bias, 1.0), "序盘无人机分差偏置")

	# --- E) pacing ---
	scene.ai_difficulty = scene.AI_DIFFICULTY_EASY
	scene.fast_mode_enabled = true
	scene.wall.clear()
	for i in range(60):
		scene.wall.append("5B")
	var easy_pace = scene.ai_pace_multiplier()
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var hard_pace = scene.ai_pace_multiplier()
	print("    pace easy=%.3f hard=%.3f" % [easy_pace, hard_pace])
	check(easy_pace > hard_pace, "简单节奏慢于困难")
	scene.wall.clear()
	for i in range(15):
		scene.wall.append("5B")
	var late_wall_pace = scene.ai_pace_multiplier()
	print("    pace hard late-wall=%.3f" % late_wall_pace)
	check(late_wall_pace < hard_pace, "残墙时 AI 节奏更快")
	var draw_d = scene.ai_draw_delay()
	var disc_d = scene.ai_discard_delay()
	check(draw_d > 0.0 and disc_d > 0.0, "延迟为正")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
	else:
		print("=== RESULT: OK ===")
	quit(1 if failed else 0)
