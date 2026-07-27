extends SceneTree
## Round 40: AI win decisions must reject invalid wins and stale drawn-tile inputs.
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


func setup_scene(scene) -> void:
	scene.players = [make_player("P0"), make_player("Actor"), make_player("P2"), make_player("P3")]
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 1
	scene.offline_last_draw.clear()


func run() -> void:
	print("=== ai_play_round40 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.offline_sim_quiet = true
	scene.setup_tile_order()

	print("--- A) AI ron decisions reject tiles that do not complete the hand ---")
	setup_scene(scene)
	scene.players[1]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "3T", "5T", "7T"]
	var invalid_ron = scene.ai_ron_decision_report(1, "5W")
	var invalid_rob = scene.ai_ron_decision_report(1, "5W", "rob_gang")
	check(not bool(invalid_ron.get("accept", true)) and str(invalid_ron.get("reason", "")) == "未成和", "普通荣和报告拒绝不成和牌")
	check(not bool(invalid_rob.get("accept", true)) and str(invalid_rob.get("reason", "")) == "未成和", "抢杠胡报告同样拒绝不成和牌")

	print("--- B) AI tsumo decisions are bound to the recorded draw tile ---")
	setup_scene(scene)
	scene.players[1]["hand"] = ["1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "9T", "9T", "9T", "1B", "2B", "3B"]
	scene.sort_hand(scene.players[1]["hand"])
	scene.offline_last_draw = {"seat": 1, "tile": "1W", "source": "normal", "wall_empty": false, "serial": 43}
	check(scene.can_win_for_seat(1), "夹具是可自摸完整手牌")
	var stale_tsumo = scene.ai_tsumo_decision_report(1, "3B")
	check(not bool(stale_tsumo.get("accept", true)) and str(stale_tsumo.get("reason", "")) == "非当前摸牌", "非实际摸牌不会生成自摸接受决定")
	var actual_tsumo = scene.ai_tsumo_decision_report(1, "1W")
	check(str(actual_tsumo.get("reason", "")) != "未成和" and str(actual_tsumo.get("reason", "")) != "非当前摸牌", "实际摸牌保留正常自摸决策")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
