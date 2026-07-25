extends SceneTree
# Round-3: tsumo leave-tenpai, opening efficiency, early claim discipline.
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
	print("=== ai_play_round3 check START ===")
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
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD

	# --- A) tsumo leave-tenpai on multi-wait low value ---
	# Fixture: tenpai multi-wait, 1W high / 2W low (same as round1 ron fixture)
	var tenpai: Array = ["2W","3W","4W","5W","6W","7W","8W","9W","9W","9W","2T","3T","4T"]
	scene.wall.clear()
	for i in range(48):
		scene.wall.append("2B")
	for s in range(4):
		scene.players[s]["hand"] = ["2B","3B","4B","5B","6B","7B","8B","9B","2B","3B","4B","5B","6B"]
		scene.players[s]["melds"] = []
		scene.players[s]["discards"] = []
		scene.players[s]["flowers"] = 0
	# seat3 大牌型: hand = tenpai + drawn low 2W
	var win_hand = tenpai.duplicate()
	win_hand.append("2W")
	scene.players[3]["hand"] = win_hand.duplicate()
	check(scene.can_win_for_seat(3), "seat3 自摸 2W 可和")
	var leave = scene.ai_tsumo_decision_report(3, "2W")
	print("    tsumo leave 2W: %s" % leave)
	check(leave.has("accept") and leave.has("reason"), "tsumo decision 字段完整")
	check(not bool(leave.get("accept", true)), "困难+大牌型深牌墙低价值自摸应留听")
	check(str(leave.get("reason", "")).find("留听") >= 0, "reason 含留听")

	var take = scene.ai_tsumo_decision_report(3, "1W")
	# need hand with 1W drawn
	var high_hand = tenpai.duplicate()
	high_hand.append("1W")
	scene.players[3]["hand"] = high_hand.duplicate()
	take = scene.ai_tsumo_decision_report(3, "1W")
	print("    tsumo take 1W: %s" % take)
	check(bool(take.get("accept", false)), "高价值自摸仍接受")

	# easy always takes low tsumo
	scene.players[3]["hand"] = win_hand.duplicate()
	scene.ai_difficulty = scene.AI_DIFFICULTY_EASY
	var easy_take = scene.ai_tsumo_decision_report(3, "2W")
	print("    easy tsumo 2W: %s" % easy_take)
	check(bool(easy_take.get("accept", false)), "简单难度低价值自摸也落袋")
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD

	# defensive seat1 takes low tsumo
	scene.players[1]["hand"] = win_hand.duplicate()
	var def_take = scene.ai_tsumo_decision_report(1, "2W")
	print("    defensive tsumo 2W: %s" % def_take)
	check(bool(def_take.get("accept", false)), "防守型低价值自摸落袋")

	# --- B) opening efficiency prefers isolated honor ---
	scene.wall.clear()
	for i in range(70):
		scene.wall.append("5B")
	# counts: isolated E vs connected 2W in a messy high-shanten hand
	var open_counts = scene.tile_counts(["E","2W","3W","5T","7T","9B","1B","3B","6B","8T","1T","4W","7W"])
	var open_honor = scene.opening_efficiency_adjustment(2, "E", 4, open_counts, 0)
	var open_middle = scene.opening_efficiency_adjustment(2, "3W", 4, open_counts, 0)
	print("    opening honor=%.2f middle=%.2f" % [open_honor, open_middle])
	check(open_honor > open_middle, "序盘优先切孤张字牌高于中张连张")

	# late game / low shanten -> near zero
	scene.wall.clear()
	for i in range(20):
		scene.wall.append("5B")
	var late = scene.opening_efficiency_adjustment(2, "E", 4, open_counts, 0)
	print("    opening late wall=%.2f" % late)
	check(is_equal_approx(late, 0.0), "残墙低时不开序盘加成")

	# --- C) early claim discipline ---
	scene.wall.clear()
	for i in range(60):
		scene.wall.append("5B")
	scene.players[2]["melds"] = []
	# 高向听散搭 + 一对 4W：序盘碰不降向听时应拒绝
	var peng_hand = ["4W","4W","1T","3T","5T","7T","9T","1B","3B","5B","7B","9B","E"]
	scene.players[2]["hand"] = peng_hand
	var claim_ctx = scene.make_ai_claim_context(2)
	var sh_before = int(claim_ctx.get("before_shanten", -1))
	print("    early before_shanten=", sh_before)
	var peng_report = scene.build_ai_claim_report(2, "peng", "4W", {}, claim_ctx)
	print("    early peng report: ", peng_report)
	check(peng_report.has("declined_by_opening"), "claim report 含 declined_by_opening")
	check(sh_before >= 3, "序盘碰夹具向听>=3")
	check(int(peng_report.get("after_shanten", 0)) >= sh_before, "该碰不降向听")
	check(not bool(peng_report.get("allow", true)), "序盘高向听无降向听碰应拒绝")

	# mid/late wall should not force 序盘蓄力
	scene.wall.clear()
	for i in range(30):
		scene.wall.append("5B")
	scene.players[2]["hand"] = ["4W","4W","2T","3T","5T","7T","9T","1B","3B","5B","7B","9B","1T"]
	claim_ctx = scene.make_ai_claim_context(2)
	var peng_mid = scene.build_ai_claim_report(2, "peng", "4W", {}, claim_ctx)
	print("    mid peng report: ", peng_mid)
	check(not bool(peng_mid.get("declined_by_opening", false)), "中后盘不触发序盘蓄力拒绝")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
	else:
		print("=== RESULT: OK ===")
	quit(1 if failed else 0)
