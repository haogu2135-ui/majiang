extends SceneTree
## Round 19: win details must not leak into a drawn or newly dealt hand.
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


func stale_win() -> Dictionary:
	return {"fan": 6, "points": 6400, "winner": 2, "win_tile": "5W", "self_draw": true}


func run() -> void:
	print("=== ai_play_round19 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.dealer_seat = 0
	make_players(scene)
	scene.setup_tile_order()

	print("--- A) wall draw clears prior win details ---")
	scene.last_win_score = stale_win()
	scene.offline_last_winner = 2
	scene.finish_wall_draw()
	check(scene.last_win_score.is_empty(), "荒庄不保留上一局胡牌番种")
	check(scene.offline_last_winner == -1, "荒庄没有赢家座位")
	check(scene.round_summary.find("荒庄") >= 0, "荒庄结算摘要保持正确")

	print("--- B) a new hand also clears stale details ---")
	scene.last_win_score = stale_win()
	scene.deal_offline_hand()
	check(scene.last_win_score.is_empty(), "新局开始前清除旧胡牌详情")
	check(scene.offline_phase == "await_discard" and scene.round_summary == "", "新局不携带上局结算状态")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
