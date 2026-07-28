extends SceneTree
## Round 53: settlement must reject malformed offline table player counts.
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


func reset_valid_ron(scene) -> void:
	scene.players = [make_player("Source"), make_player("Winner"), make_player("P2"), make_player("P3")]
	scene.players[1]["hand"] = winning_wait_hand()
	scene.players[0]["discards"] = ["5W"]
	scene.mode = "offline"
	scene.offline_phase = "resolving"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 0
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	scene.last_win_score.clear()
	scene.offline_last_winner = -1


func run() -> void:
	print("=== ai_play_round53 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.offline_sim_quiet = true
	scene.setup_tile_order()

	print("--- A) a normal four-player ron remains eligible ---")
	reset_valid_ron(scene)
	check(scene.can_finish_offline_round(1, "5W", false, 0), "四家牌桌的真实荣和保持可结算")

	print("--- B) missing seats cannot reach the four-way settlement loop ---")
	reset_valid_ron(scene)
	scene.players.resize(2)
	check(not scene.can_finish_offline_round(1, "5W", false, 0), "少于四家的异常桌面被结算守卫拒绝")
	scene.finish_offline_round(1, "5W", false, 0)
	check(scene.offline_phase == "resolving" and scene.last_win_score.is_empty() and scene.offline_last_winner == -1, "少座位请求不改分、不结束且不越界")

	print("--- C) extra seats are rejected rather than silently ignored ---")
	reset_valid_ron(scene)
	scene.players.append(make_player("Unexpected"))
	check(not scene.can_finish_offline_round(1, "5W", false, 0), "多于四家的异常桌面同样被拒绝")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
