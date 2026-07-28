extends SceneTree
## Round 51: rob-gang settlement must belong to the active added-gang action.
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


func reset_direct_rob_gang(scene) -> void:
	scene.players = [make_player("Source", false), make_player("Winner"), make_player("P2"), make_player("P3")]
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 0
	scene.dealer_seat = 0
	scene.players[0]["hand"] = ["5W"]
	scene.players[0]["melds"] = [["5W", "5W", "5W"]]
	scene.players[1]["hand"] = winning_wait_hand()
	scene.offline_pending_claim.clear()
	scene.last_win_score.clear()
	scene.offline_last_winner = -1


func round_unchanged(scene) -> bool:
	return scene.offline_phase != "ended" and scene.offline_last_winner == -1 and scene.last_win_score.is_empty()


func run() -> void:
	print("=== ai_play_round51 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.offline_sim_quiet = true
	scene.setup_tile_order()

	print("--- A) active AI added-gang still permits direct rob-gang settlement ---")
	reset_direct_rob_gang(scene)
	check(scene.is_valid_offline_added_gang(0, "5W"), "夹具中的放杠方正处于合法补杠回合")
	check(scene.can_finish_offline_round(1, "5W", false, 0, "rob_gang"), "当前 AI 补杠可被抢杠胡")

	print("--- B) stale source outside its turn cannot be used as a rob-gang tile source ---")
	reset_direct_rob_gang(scene)
	scene.current_seat = 2
	check(scene.can_added_gang(0, "5W"), "错座位时牌形本身仍呈可补杠")
	check(not scene.is_valid_offline_added_gang(0, "5W"), "错座位不再是当前补杠动作")
	check(not scene.can_finish_offline_round(1, "5W", false, 0, "rob_gang"), "过期错座位抢杠胡被结算守卫拒绝")
	scene.finish_offline_round(1, "5W", false, 0, "rob_gang")
	check(round_unchanged(scene), "错座位请求不结束牌局或产生结算")

	print("--- C) a source waiting to draw cannot expose a rob-gang tile ---")
	reset_direct_rob_gang(scene)
	scene.offline_turn_needs_draw = true
	check(not scene.is_valid_offline_added_gang(0, "5W"), "待摸牌阶段不允许补杠")
	check(not scene.can_finish_offline_round(1, "5W", false, 0, "rob_gang"), "待摸牌阶段拒绝伪造抢杠胡")

	print("--- D) an authenticated human rob-gang response remains valid ---")
	reset_direct_rob_gang(scene)
	scene.players[0] = make_player("You", false)
	scene.players[1] = make_player("Source")
	scene.players[0]["hand"] = winning_wait_hand()
	scene.players[1]["hand"] = ["5W"]
	scene.players[1]["melds"] = [["5W", "5W", "5W"]]
	scene.offline_phase = "pending_claim"
	scene.offline_pending_claim = {
		"from_seat": 1,
		"tile": "5W",
		"options": ["hu"],
		"rob_gang": true,
		"ai_claim": {},
	}
	check(scene.can_finish_offline_round(0, "5W", false, 1, "rob_gang"), "已认证的人类抢杠响应仍可结算")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
