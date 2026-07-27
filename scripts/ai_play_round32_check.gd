extends SceneTree
## Round 32: non-self-draw settlement must prove the declared tile source.
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


func winning_wait_hand() -> Array:
	return ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W"]


func reset_round(scene) -> void:
	scene.players = [make_player("Source"), make_player("Winner"), make_player("Third"), make_player("Fourth")]
	scene.mode = "offline"
	scene.offline_phase = "resolving"
	scene.offline_turn_needs_draw = false
	scene.offline_last_winner = -1
	scene.offline_pending_claim.clear()
	scene.last_win_score.clear()
	scene.last_score_deltas.clear()
	for seat in range(4):
		scene.last_score_deltas.append(0)
	scene.round_summary = ""
	scene.last_discard = ""
	scene.last_discard_seat = -1


func check_rejected(scene, label: String, win_context: String = "", expected_phase: String = "resolving") -> void:
	var before_scores: Array = []
	for player in scene.players:
		before_scores.append(int(player.get("score", 0)))
	check(not scene.can_finish_offline_round(1, "5W", false, 0, win_context), "%s被结算守卫拒绝" % label)
	scene.finish_offline_round(1, "5W", false, 0, win_context)
	check(scene.offline_phase == expected_phase and scene.offline_last_winner == -1 and scene.last_win_score.is_empty(), "%s不结束当前回合" % label)
	var scores_unchanged = true
	for seat in range(4):
		if int(scene.players[seat].get("score", 0)) != int(before_scores[seat]):
			scores_unchanged = false
	check(scores_unchanged, "%s不改动分数" % label)


func run() -> void:
	print("=== ai_play_round32 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.offline_sim_quiet = true
	scene.setup_tile_order()
	scene.dealer_seat = 0

	print("--- A) forged discard win is rejected ---")
	reset_round(scene)
	scene.players[1]["hand"] = winning_wait_hand()
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	scene.players[0]["discards"] = ["6W"]
	check_rejected(scene, "牌河与声明牌不一致的荣和")

	print("--- B) genuine discard win still settles ---")
	reset_round(scene)
	scene.players[1]["hand"] = winning_wait_hand()
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	scene.players[0]["discards"] = ["5W"]
	check(scene.can_finish_offline_round(1, "5W", false, 0), "真实弃牌来源通过结算守卫")
	scene.finish_offline_round(1, "5W", false, 0)
	check(scene.offline_phase == "ended" and scene.offline_last_winner == 1, "真实荣和正常结束")

	print("--- C) genuine rob gang win does not require a discard ---")
	reset_round(scene)
	scene.players[1]["hand"] = winning_wait_hand()
	scene.players[0]["hand"] = ["5W"]
	scene.players[0]["melds"] = [["5W", "5W", "5W"]]
	scene.offline_phase = "await_discard"
	check(scene.can_finish_offline_round(1, "5W", false, 0, "rob_gang"), "未完成补杠可作为抢杠胡来源")
	scene.finish_offline_round(1, "5W", false, 0, "rob_gang")
	check(scene.offline_phase == "ended" and scene.offline_last_winner == 1 and scene.last_win_score.get("reasons", []).has("抢杠胡"), "合法抢杠胡正常结束并保留番种")

	print("--- D) stale discard win is rejected after the response window ---")
	reset_round(scene)
	scene.players[1]["hand"] = winning_wait_hand()
	scene.players[0]["discards"] = ["5W"]
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	scene.offline_phase = "await_discard"
	check_rejected(scene, "响应窗口结束后的过期荣和", "", "await_discard")

	print("--- E) forged rob gang win is rejected ---")
	reset_round(scene)
	scene.players[1]["hand"] = winning_wait_hand()
	scene.players[0]["discards"] = ["5W"]
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	check_rejected(scene, "没有可补杠碰牌的抢杠胡", "rob_gang")

	print("--- F) ended or non-offline state cannot settle again ---")
	reset_round(scene)
	scene.players[1]["hand"] = winning_wait_hand()
	scene.players[0]["discards"] = ["5W"]
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	scene.offline_phase = "ended"
	check_rejected(scene, "已结束对局的重复荣和", "", "ended")
	reset_round(scene)
	scene.players[1]["hand"] = winning_wait_hand()
	scene.players[0]["discards"] = ["5W"]
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	scene.mode = "online_game"
	check_rejected(scene, "非单机状态的伪造荣和")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
