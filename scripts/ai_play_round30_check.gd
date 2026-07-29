extends SceneTree
## Round 30: settlement must not end a hand unless the declared win is legal.
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


func reset_round(scene) -> void:
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 0
	scene.offline_last_winner = -1
	scene.offline_pending_claim.clear()
	scene.offline_last_draw.clear()
	scene.offline_self_draw_ready.clear()
	scene.last_win_score.clear()
	scene.last_score_deltas.clear()
	for i in range(4):
		scene.last_score_deltas.append(0)
	scene.round_summary = ""


func score_total(scene) -> int:
	var total = 0
	for player in scene.players:
		total += int(player.get("score", 0))
	return total


func run() -> void:
	print("=== ai_play_round30 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.offline_sim_quiet = true
	scene.setup_tile_order()
	scene.dealer_seat = 0

	print("--- A) invalid self draw is ignored before effects or settlement ---")
	reset_round(scene)
	scene.players[1]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "3T", "5T", "7T", "E"]
	var initial_total = score_total(scene)
	check(not scene.can_finish_offline_round(1, "", true, -1), "非法自摸不会通过结算守卫")
	scene.finish_offline_round(1, "", true, -1)
	check(scene.offline_phase == "await_discard" and scene.offline_last_winner == -1, "非法自摸不结束当前回合")
	check(score_total(scene) == initial_total and scene.last_win_score.is_empty(), "非法自摸不改变分数或结算详情")

	print("--- B) invalid discard payer is ignored ---")
	reset_round(scene)
	scene.players[1]["hand"] = ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W"]
	check(not scene.can_finish_offline_round(1, "5W", false, 1), "荣和不能由赢家本人支付")
	scene.finish_offline_round(1, "5W", false, 1)
	check(scene.offline_phase == "await_discard" and score_total(scene) == initial_total, "无效出铳座位不结束或改分")

	print("--- C) legal self draw and discard win still settle ---")
	reset_round(scene)
	scene.players[1]["hand"] = ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W", "5W"]
	# A self draw must carry the same live proof written by draw_tile_for.
	scene.current_seat = 1
	scene.offline_last_draw = {"seat": 1, "tile": "5W", "source": "normal", "wall_empty": false, "serial": 30}
	scene.offline_self_draw_ready = {"seat": 1, "tile": "5W", "serial": 30}
	scene.finish_offline_round(1, "5W", true, -1)
	check(scene.offline_phase == "ended" and scene.offline_last_winner == 1, "合法自摸正常结束")
	check(not scene.last_win_score.is_empty() and score_total(scene) == initial_total, "合法自摸保留详情且分数守恒")

	reset_round(scene)
	scene.players[1]["hand"] = ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W"]
	scene.players[0]["discards"] = ["5W"]
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	scene.offline_phase = "resolving"
	scene.finish_offline_round(1, "5W", false, 0)
	check(scene.offline_phase == "ended" and scene.offline_last_winner == 1, "合法荣和正常结束")
	check(not scene.last_win_score.is_empty() and int(scene.last_score_deltas[0]) < 0 and score_total(scene) == initial_total, "合法荣和由出铳座位支付且分数守恒")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
