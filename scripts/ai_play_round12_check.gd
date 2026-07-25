extends SceneTree
## Round 12: deterministic claim arbitration by action priority and seat order.
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


func peng_hand() -> Array:
	return ["5W", "5W", "2T", "3T", "4T", "6T", "7T", "8T", "2B", "3B", "4B", "E", "S"]


func reset_claim_table(scene) -> void:
	for seat in range(4):
		scene.players[seat]["hand"] = []
		scene.players[seat]["discards"] = []
		scene.players[seat]["melds"] = []
	scene.offline_phase = "resolving"
	scene.offline_pending_claim.clear()
	scene.last_discard = "5W"
	scene.last_discard_seat = -1


func run() -> void:
	print("=== ai_play_round12 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.offline_hand_number = 2
	scene.dealer_seat = 0
	scene.wall = scene.make_wall()
	make_players(scene)
	if scene.has_method("setup_tile_order"):
		scene.setup_tile_order()
	scene.ai_difficulty = scene.AI_DIFFICULTY_EASY
	scene.offline_all_bot_mode = false
	scene.offline_sim_quiet = true

	print("--- A) arbitration comparator ---")
	var rich_chi = {"seat": 1, "claim": "chi", "score": 999.0}
	var weak_peng = {"seat": 2, "claim": "peng", "score": 1.0}
	check(scene.ai_claim_candidate_precedes(weak_peng, rich_chi, 0), "碰优先于更高估值的吃")
	check(not scene.ai_claim_candidate_precedes(rich_chi, weak_peng, 0), "吃不能用估值越过碰")
	var near_peng = {"seat": 1, "claim": "peng", "score": 1.0}
	var far_peng = {"seat": 3, "claim": "peng", "score": 999.0}
	check(scene.ai_claim_candidate_precedes(near_peng, far_peng, 0), "同级响应由近家优先")
	check(not scene.ai_claim_candidate_precedes(far_peng, near_peng, 0), "远家同级高分不能越位")
	var same_seat_peng = {"seat": 1, "claim": "peng", "score": 60.0}
	var same_seat_gang = {"seat": 1, "claim": "gang", "score": 80.0}
	check(scene.ai_claim_candidate_precedes(same_seat_gang, same_seat_peng, 0), "同一座位的碰杠再按策略估值选择")

	print("--- B) human/AI equal-priority seat order ---")
	var ai_near = {"seat": 2, "claim": "peng", "score": 10.0}
	var filtered_far = scene.filter_human_claim_options(["peng", "hu"], 1, ai_near)
	check(not filtered_far.has("peng"), "玩家较远时不越过 AI 同级碰")
	check(filtered_far.has("hu"), "玩家胡牌仍高于 AI 碰")
	var ai_far = {"seat": 1, "claim": "peng", "score": 10.0}
	var filtered_near = scene.filter_human_claim_options(["peng"], 3, ai_far)
	check(filtered_near == ["peng"], "玩家较近时保留同级碰")
	var ai_hu = {"seat": 2, "claim": "hu", "score": 1000.0}
	check(scene.filter_human_claim_options(["hu"], 1, ai_hu) == ["hu"], "保留项目现有多人可胡选择")

	print("--- C) resolver integration + prepared claim ---")
	reset_claim_table(scene)
	scene.players[0]["hand"] = peng_hand()
	scene.players[2]["hand"] = peng_hand()
	scene.players[1]["discards"] = ["5W"]
	scene.last_discard_seat = 1
	var farther_human_ai_claim = scene.choose_ai_claim(1, "5W")
	check(str(farther_human_ai_claim.get("claim", "")) == "peng" and int(farther_human_ai_claim.get("seat", -1)) == 2, "近家 AI 生成碰响应")
	scene.resolve_after_discard(1, "5W")
	check(scene.offline_phase != "pending_claim", "较远玩家不收到同级响应窗口")
	check(scene.players[2]["melds"].size() == 1, "近家 AI 碰直接落地")

	reset_claim_table(scene)
	scene.players[0]["hand"] = peng_hand()
	scene.players[1]["hand"] = peng_hand()
	scene.players[3]["discards"] = ["5W"]
	scene.last_discard_seat = 3
	scene.resolve_after_discard(3, "5W")
	check(scene.offline_phase == "pending_claim", "近家玩家获得同级响应窗口")
	check(scene.offline_pending_claim.get("options", []).has("peng"), "玩家响应窗口保留碰")
	var prepared: Dictionary = scene.offline_pending_claim.get("ai_claim", {})
	check(str(prepared.get("claim", "")) == "peng" and int(prepared.get("seat", -1)) == 1, "响应窗口保存已评估 AI 结果")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
