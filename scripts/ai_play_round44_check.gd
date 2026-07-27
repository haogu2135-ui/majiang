extends SceneTree
## Round 44: the last wall discard scores river-bottom ron without leaking to other contexts.
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
	scene.players = [make_player("Source"), make_player("Winner"), make_player("P2"), make_player("P3")]
	scene.mode = "offline"
	scene.offline_phase = "resolving"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 0
	scene.dealer_seat = 0
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	scene.players[0]["discards"] = ["5W"]
	scene.players[1]["hand"] = winning_wait_hand()
	scene.offline_pending_claim.clear()
	scene.last_win_score.clear()
	scene.offline_last_winner = -1


func run() -> void:
	print("=== ai_play_round44 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.offline_sim_quiet = true
	scene.setup_tile_order()

	print("--- A) final wall discard adds river-bottom ron ---")
	reset_round(scene)
	scene.offline_last_draw = {"seat": 0, "tile": "1B", "source": "normal", "wall_empty": true, "serial": 61}
	check(scene.is_last_discard_context(), "最后实牌由当前弃牌者摸到时识别河底上下文")
	var river_score = scene.calculate_win_score(1, "5W", false)
	print("    river score=%s" % str(river_score))
	check((river_score.get("reasons", []) as Array).has("河底捞鱼"), "最后弃牌荣和包含河底捞鱼")
	check(scene.can_finish_offline_round(1, "5W", false, 0), "河底荣和仍通过结算守卫")
	scene.finish_offline_round(1, "5W", false, 0)
	check(scene.offline_phase == "ended" and (scene.last_win_score.get("reasons", []) as Array).has("河底捞鱼"), "河底荣和结算保留番种")

	print("--- B) normal discard and stale phase do not receive river-bottom fan ---")
	reset_round(scene)
	scene.offline_last_draw = {"seat": 0, "tile": "1B", "source": "normal", "wall_empty": false, "serial": 62}
	var normal_score = scene.calculate_win_score(1, "5W", false)
	check(not (normal_score.get("reasons", []) as Array).has("河底捞鱼"), "非最后实牌弃牌没有河底番")
	reset_round(scene)
	scene.offline_last_draw = {"seat": 0, "tile": "1B", "source": "normal", "wall_empty": true, "serial": 63}
	scene.offline_phase = "await_discard"
	check(not scene.is_last_discard_context(), "离开响应窗口后不保留河底上下文")
	check(not (scene.calculate_win_score(1, "5W", false).get("reasons", []) as Array).has("河底捞鱼"), "陈旧状态的预览不虚增河底番")

	print("--- C) final self draw remains sea-bottom, not river-bottom ---")
	reset_round(scene)
	scene.offline_phase = "await_discard"
	scene.players[1]["hand"] = winning_wait_hand()
	scene.players[1]["hand"].append("5W")
	scene.offline_last_draw = {"seat": 1, "tile": "5W", "source": "normal", "wall_empty": true, "serial": 64}
	var sea_score = scene.calculate_win_score(1, "5W", true)
	check((sea_score.get("reasons", []) as Array).has("海底捞月"), "最后实牌自摸保留海底捞月")
	check(not (sea_score.get("reasons", []) as Array).has("河底捞鱼"), "自摸不会叠加河底捞鱼")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
