extends SceneTree
## Round 42: passed ron locks only the same tile until the seat draws again.
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


func winning_wait_hand() -> Array:
	return ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W"]


func reset_round(scene) -> void:
	scene.players = [make_player("You", false), make_player("AI"), make_player("P2"), make_player("P3")]
	scene.mode = "offline"
	scene.offline_phase = "resolving"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 0
	scene.dealer_seat = 0
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	scene.players[0]["discards"] = ["5W"]
	scene.offline_pending_claim.clear()
	scene.offline_passed_win_tiles.clear()
	scene.last_win_score.clear()
	scene.offline_last_winner = -1


func run() -> void:
	print("=== ai_play_round42 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.offline_sim_quiet = true
	scene.setup_tile_order()

	print("--- A) direct passed-win state blocks the declined tile ---")
	reset_round(scene)
	scene.players[1]["hand"] = winning_wait_hand()
	check(scene.can_ron_for_seat(1, "5W"), "过水前同张可以荣和")
	scene.record_passed_win_tile(1, "5W")
	check(scene.is_passed_win_tile(1, "5W"), "记录同张过水")
	check(not scene.can_ron_for_seat(1, "5W"), "过水阻止再次荣和同张")
	check(not scene.get_claim_options(1, 0, "5W").has("hu"), "响应层不展示过水胡")
	var report = scene.ai_ron_decision_report(1, "5W")
	check(not bool(report.get("accept", true)) and str(report.get("reason", "")) == "过水", "AI 报告明确标记过水")
	check(not scene.can_finish_offline_round(1, "5W", false, 0), "结算守卫拒绝过水荣和")
	scene.finish_offline_round(1, "5W", false, 0)
	check(scene.offline_phase == "resolving" and scene.last_win_score.is_empty(), "过水荣和不结束当前回合")
	check(scene.can_win_for_seat(1, "5W"), "过水不篡改牌形或自摸判定")

	print("--- B) actual draw clears the temporary lock ---")
	scene.wall.clear()
	scene.wall.append("2B")
	scene.offline_phase = "await_discard"
	scene.current_seat = 1
	var drawn = scene.draw_tile_for(1, false)
	check(drawn == "2B", "夹具摸到实际牌")
	check(not scene.is_passed_win_tile(1, "5W"), "下一次摸牌清除同张过水")
	scene.players[1]["hand"].erase("2B")
	check(scene.can_ron_for_seat(1, "5W"), "摸牌后原听口恢复可荣和")

	print("--- C) human pass records the visible hu tile ---")
	reset_round(scene)
	scene.players[0]["hand"] = winning_wait_hand()
	scene.offline_phase = "pending_claim"
	scene.offline_pending_claim = {
		"from_seat": 1,
		"tile": "5W",
		"options": ["hu"],
		"ai_claim": {},
	}
	scene.last_discard_seat = 1
	scene.players[1]["discards"] = ["5W"]
	scene.last_discard = "5W"
	scene.human_claim("pass")
	check(scene.is_passed_win_tile(0, "5W"), "玩家放弃胡后记录过水")
	check(not scene.can_ron_for_seat(0, "5W"), "玩家过水不能立即再荣和同张")

	print("--- D) AI value pass records the same state through live selection ---")
	reset_round(scene)
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	scene.wall.clear()
	for i in range(48):
		scene.wall.append("2B")
	var multi_hand: Array = ["2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W", "2T", "3T", "4T"]
	scene.players[3]["hand"] = multi_hand
	scene.last_discard = "2W"
	scene.last_discard_seat = 0
	scene.players[0]["discards"] = ["2W"]
	var decision = scene.ai_ron_decision_report(3, "2W")
	check(not bool(decision.get("accept", true)), "夹具触发 AI 低价值荣和留听")
	var claim = scene.choose_ai_claim(0, "2W")
	check(claim.is_empty(), "AI 留听不提交荣和")
	check(scene.is_passed_win_tile(3, "2W"), "AI 留听记录同张过水")
	check(not scene.can_ron_for_seat(3, "2W"), "AI 过水阻止同张重复荣和")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
