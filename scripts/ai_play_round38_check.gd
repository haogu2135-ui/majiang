extends SceneTree
## Round 38: self-draw settlement must use the actual draw tile, not any tile in a complete hand.
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


func score_total(scene) -> int:
	var total := 0
	for player in scene.players:
		total += int(player.get("score", 0))
	return total


func reset_round(scene) -> void:
	scene.players = [make_player("You", false), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "9T", "9T", "9T", "1B", "2B", "3B"]
	scene.sort_hand(scene.players[0]["hand"])
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 0
	scene.dealer_seat = 0
	scene.offline_last_winner = -1
	scene.last_win_score.clear()
	scene.last_score_deltas.clear()
	for seat in range(4):
		scene.last_score_deltas.append(0)
	scene.offline_last_draw = {"seat": 0, "tile": "1W", "source": "normal", "wall_empty": false, "serial": 42}


func run() -> void:
	print("=== ai_play_round38 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.offline_sim_quiet = true
	scene.setup_tile_order()

	print("--- A) a different tile in the winning hand cannot be declared as self-drawn ---")
	reset_round(scene)
	var total_before = score_total(scene)
	check(scene.current_self_draw_tile(0) == "1W", "夹具记录实际自摸牌")
	check(str(scene.players[0]["hand"].back()) != "1W", "排序末张不同于实际自摸牌")
	check(not scene.can_finish_offline_round(0, "3B", true, -1), "完整手牌中的非摸牌不能通过自摸结算守卫")
	check(not scene.can_finish_offline_round(0, "E", true, -1), "不在手牌中的伪造自摸牌不能通过结算守卫")
	scene.finish_offline_round(0, "3B", true, -1)
	check(scene.offline_phase == "await_discard" and scene.last_win_score.is_empty() and score_total(scene) == total_before, "错误自摸声明不结束或改分")

	print("--- B) the recorded draw tile still settles normally ---")
	scene.finish_offline_round(0, "1W", true, -1)
	check(scene.offline_phase == "ended" and scene.offline_last_winner == 0, "实际自摸牌正常结束")
	check(str(scene.last_win_score.get("win_tile", "")) == "1W" and score_total(scene) == total_before, "结算详情保留实际摸牌且分数守恒")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
