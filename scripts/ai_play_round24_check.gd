extends SceneTree
## Round 24: declining a low-value tsumo must preserve the original higher-value tenpai.
var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(cond: bool, msg: String) -> void:
	if cond:
		print("  OK  | %s" % msg)
	else:
		print("  FAIL| %s" % msg)
		failed = true


func make_player(name: String) -> Dictionary:
	return {
		"name": name,
		"hand": [],
		"discards": [],
		"melds": [],
		"flowers": 0,
		"flower_tiles": [],
		"score": 25000,
		"bot": true,
	}


func run() -> void:
	print("=== ai_play_round24 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.setup_tile_order()
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	scene.dealer_seat = 0
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	# 2W is a low-value self draw; returning it preserves the 1W high-value route.
	var tenpai: Array = ["2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W", "2T", "3T", "4T"]
	for seat in range(3):
		scene.players[seat]["hand"] = ["1B", "3B", "5B", "7B", "9B", "1T", "3T", "5T", "7T", "9T", "E", "S", "W"]
	scene.players[3]["hand"] = tenpai.duplicate()
	# Keep the wall deep enough for the hard AI to consider preserving a more
	# valuable wait. draw_tile_for() pops from the end, so 2W must be last.
	var test_wall: Array[String] = []
	for i in range(48):
		test_wall.append("2B")
	test_wall.append("2W")
	scene.wall = test_wall
	scene.current_seat = 3
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = true

	print("--- A) decision contains an executable preserve-tenpai action ---")
	var prospective_hand = tenpai.duplicate()
	prospective_hand.append("2W")
	scene.players[3]["hand"] = prospective_hand
	# The report is now intentionally bound to a real post-draw action window.
	scene.offline_turn_needs_draw = false
	scene.offline_last_draw = {"seat": 3, "tile": "2W", "source": "normal", "wall_empty": false, "serial": 24}
	scene.offline_self_draw_ready = {"seat": 3, "tile": "2W", "serial": 24}
	var decision = scene.ai_tsumo_decision_report(3, "2W")
	print("    decision=%s" % str(decision))
	check(not bool(decision.get("accept", true)), "困难档会放弃低价值自摸")
	check(bool(decision.get("preserves_tenpai", false)), "留听决策标记保留原听牌")
	check(scene.ai_tsumo_continue_discard(3, "2W", decision) == "2W", "留听决策指定打回本次进张")

	print("--- B) sync bot path actually returns the drawn tile ---")
	scene.players[3]["hand"] = tenpai.duplicate()
	scene.offline_turn_needs_draw = true
	scene.offline_last_draw.clear()
	scene.offline_self_draw_ready.clear()
	var result = scene.simulate_offline_bot_hand_sync(1)
	print("    result=%s discard=%s" % [str(result), str(scene.players[3]["discards"])])
	check(scene.players[3]["discards"].size() == 1 and str(scene.players[3]["discards"].back()) == "2W", "全机器人路径打回低价值自摸牌")
	check(scene.players[3]["hand"].size() == tenpai.size(), "打回后手牌恢复为原始十三张")
	check(scene.can_win_for_seat(3, "1W"), "高价值听口仍被保留")

	print("--- C) visible-table coroutine returns the drawn tile too ---")
	scene.players[3]["hand"] = tenpai.duplicate()
	for seat in range(3):
		scene.players[seat]["discards"] = []
	scene.players[3]["discards"] = []
	test_wall = []
	for i in range(48):
		test_wall.append("2B")
	test_wall.append("2W")
	scene.wall = test_wall
	scene.current_seat = 3
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = true
	await scene.run_ai_until_human()
	check(scene.players[3]["discards"].size() == 1 and str(scene.players[3]["discards"].back()) == "2W", "可见牌桌路径同样打回低价值自摸牌")
	check(scene.current_seat == 0 and scene.offline_phase == "await_discard", "可见牌桌路径正常交回玩家回合")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
