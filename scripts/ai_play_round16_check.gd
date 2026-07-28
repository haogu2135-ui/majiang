extends SceneTree
## Round 16: all-bot metrics must use the settled win type, not the triggering action.
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
			"hand": ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W", "5W"],
			"discards": [],
			"melds": [],
			"flowers": 0,
			"flower_tiles": [],
			"score": 25000,
			"bot": true,
		})


func prepare_round(scene) -> void:
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.offline_phase = "await_discard"
	scene.offline_last_winner = -1
	scene.last_win_score.clear()
	scene.reset_ai_sim_stats()


func run() -> void:
	print("=== ai_play_round16 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	make_players(scene)
	if scene.has_method("setup_tile_order"):
		scene.setup_tile_order()

	print("--- A) gang self draw is not a deal-in ---")
	prepare_round(scene)
	# A gang replacement draw can finish during a discard resolver. The actor is
	# intentionally seat 0 while seat 1 is the actual self-draw winner.
	scene.current_seat = 1
	scene.offline_last_draw = {"seat": 1, "tile": "5W", "source": "gang", "wall_empty": false, "serial": 16}
	scene.offline_self_draw_ready = {"seat": 1, "tile": "5W", "serial": 16}
	scene.finish_offline_round(1, "5W", true, -1)
	scene._ai_sim_note_terminal_result(0)
	check(int(scene.ai_sim_stats.get("wins", 0)) == 1, "杠上自摸计入胜局")
	check(int(scene.ai_sim_stats.get("winner", -1)) == 1 and bool(scene.ai_sim_stats.get("self_draw", false)), "杠上自摸保留实际赢家与自摸类型")
	check(int(scene.ai_sim_stats.get("deal_ins", 0)) == 0 and int(scene.ai_sim_stats.get("deal_in_seat", -1)) == -1, "杠上自摸不误记为出牌者点炮")

	print("--- B) discard win remains a deal-in ---")
	prepare_round(scene)
	# 荣和者在收到 5W 前只有十三张，保持真实结算前置条件。
	scene.players[2]["hand"] = ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W"]
	scene.players[0]["discards"] = ["5W"]
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	scene.offline_phase = "resolving"
	scene.finish_offline_round(2, "5W", false, 0)
	scene._ai_sim_note_terminal_result(0)
	check(int(scene.ai_sim_stats.get("wins", 0)) == 1 and not bool(scene.ai_sim_stats.get("self_draw", true)), "荣和保留非自摸类型")
	check(int(scene.ai_sim_stats.get("deal_ins", 0)) == 1 and int(scene.ai_sim_stats.get("deal_in_seat", -1)) == 0, "荣和仍记为出牌者点炮")

	print("--- C) wall draw has no fabricated win ---")
	prepare_round(scene)
	scene.finish_wall_draw()
	scene._ai_sim_note_terminal_result(3)
	check(int(scene.ai_sim_stats.get("wins", 0)) == 0 and int(scene.ai_sim_stats.get("winner", -1)) == -1, "荒庄不计入胜局")
	check(int(scene.ai_sim_stats.get("deal_ins", 0)) == 0, "荒庄不生成点炮记录")
	check(int(scene.ai_sim_stats.get("wall_ends", 0)) == 1, "特殊路径荒庄计入牌墙耗尽统计")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
