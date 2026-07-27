extends SceneTree
## Round 37: pending human claim windows cannot be bypassed by another seat or option.
var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(cond: bool, msg: String) -> void:
	if cond:
		print("  OK  | %s" % msg)
	else:
		print("  FAIL| %s" % msg)
		failed = true


func make_player(name: String, bot: bool = true) -> Dictionary:
	return {
		"name": name,
		"hand": [],
		"discards": [],
		"melds": [],
		"flowers": 0,
		"flower_tiles": [],
		"score": 25000,
		"bot": bot,
	}


func reset_pending_claim(scene, ai_claim: Dictionary = {}) -> void:
	scene.players = [make_player("You", false), make_player("Discarder"), make_player("AI"), make_player("P3")]
	scene.players[0]["hand"] = ["5W", "5W", "5W", "1B"]
	scene.players[2]["hand"] = ["5W", "5W", "9B"]
	scene.players[1]["discards"] = ["5W"]
	scene.mode = "offline"
	scene.offline_phase = "pending_claim"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 1
	scene.last_discard = "5W"
	scene.last_discard_seat = 1
	scene.offline_pending_claim = {
		"from_seat": 1,
		"tile": "5W",
		"options": ["peng"],
		"ai_claim": ai_claim,
	}


func run() -> void:
	print("=== ai_play_round37 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.offline_sim_quiet = true
	scene.setup_tile_order()

	print("--- A) pending claim is bound to the presented human option ---")
	reset_pending_claim(scene)
	var ai_hand = scene.players[2]["hand"].duplicate()
	check(not scene.is_valid_offline_claim(2, 1, "5W", "peng"), "待响应窗口拒绝其他座位抢先碰牌")
	check(not scene.is_valid_offline_claim(0, 1, "5W", "gang"), "待响应窗口拒绝未展示的杠选项")
	scene.apply_offline_claim(2, 1, "5W", "peng")
	check(scene.players[2]["hand"] == ai_hand and scene.players[1]["discards"] == ["5W"] and scene.offline_phase == "pending_claim", "非法提交不改手牌、牌河或阶段")

	print("--- B) the displayed option still resolves normally ---")
	scene.apply_offline_claim(0, 1, "5W", "peng")
	check(scene.players[0]["melds"] == [["5W", "5W", "5W"]], "玩家可提交待响应窗口展示的碰牌")
	check(scene.players[1]["discards"].is_empty() and scene.current_seat == 0 and scene.offline_phase == "await_discard", "合法碰牌原子地消费弃牌并获得出牌权")

	print("--- C) passing returns to arbitration before the prepared AI claim ---")
	reset_pending_claim(scene, {"seat": 2, "claim": "peng"})
	# Keep this test at the post-pass boundary instead of letting the next AI turn discard.
	scene.offline_ai_active = true
	scene.human_claim("pass")
	scene.offline_ai_active = false
	check(scene.players[2]["melds"] == [["5W", "5W", "5W"]], "玩家过后预选 AI 响应可正常结算")
	check(scene.players[1]["discards"].is_empty() and scene.current_seat == 2 and scene.offline_phase == "await_discard", "过牌后 AI 响应获得正确行动权")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
