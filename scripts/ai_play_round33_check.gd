extends SceneTree
## Round 33: self-draw settlement keeps the actual draw tile after hand sorting.
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


func reset_round(scene) -> void:
	scene.players = [make_player("You", false), make_player("P1"), make_player("P2"), make_player("P3")]
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


func run() -> void:
	print("=== ai_play_round33 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.offline_sim_quiet = true
	scene.setup_tile_order()

	print("--- A) actual draw survives sorted self-draw hand ---")
	reset_round(scene)
	# 1W completes the pair, but sorting puts 3B at the end of this hand.
	scene.players[0]["hand"] = ["1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "9T", "9T", "9T", "1B", "2B", "3B"]
	scene.sort_hand(scene.players[0]["hand"])
	scene.offline_last_draw = {"seat": 0, "tile": "1W", "source": "normal", "wall_empty": false, "serial": 41}
	check(scene.can_win_for_seat(0), "夹具是可自摸的完整手牌")
	check(str(scene.players[0]["hand"].back()) != "1W", "排序后的末张与实际摸牌不同")
	check(scene.current_self_draw_tile(0) == "1W", "结算读取实际摸牌记录")
	scene.human_self_win()
	check(scene.offline_phase == "ended" and scene.offline_last_winner == 0, "玩家自摸正常结算")
	check(str(scene.last_win_score.get("win_tile", "")) == "1W", "结算详情保留实际胡牌张")
	check(scene.round_summary.find(scene.tile_label("1W")) >= 0, "结算摘要展示实际胡牌张")

	print("--- B) legacy state falls back without an invalid draw record ---")
	reset_round(scene)
	scene.players[0]["hand"] = ["1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "9T", "9T", "9T", "1B", "2B", "3B"]
	scene.sort_hand(scene.players[0]["hand"])
	scene.offline_last_draw = {"seat": 2, "tile": "5B", "source": "normal"}
	check(scene.current_self_draw_tile(0) == str(scene.players[0]["hand"].back()), "旧存档缺少当前摸牌时安全回退")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
