extends SceneTree
## Round 36: self-gang transitions require a live turn or an authenticated rob-gang pass.
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
	scene.players = [make_player("You", false), make_player("Actor"), make_player("P2"), make_player("P3")]
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 1
	scene.last_discard = ""
	scene.last_discard_seat = -1
	scene.offline_pending_claim.clear()


func rob_wait_hand() -> Array:
	return ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W"]


func run() -> void:
	print("=== ai_play_round36 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.offline_sim_quiet = true
	scene.setup_tile_order()

	print("--- A) stale or foreign self-gang cannot mutate the table ---")
	reset_round(scene)
	scene.players[1]["hand"] = ["5W", "5W", "5W", "5W"]
	scene.wall = ["7B"]
	check(not scene.perform_concealed_gang(2, "5W"), "非当前座位不能暗杠")
	scene.offline_phase = "resolving"
	check(not scene.perform_concealed_gang(1, "5W"), "响应阶段不能暗杠")
	check(scene.players[1]["hand"] == ["5W", "5W", "5W", "5W"] and scene.players[1]["melds"].is_empty() and scene.wall == ["7B"], "非法暗杠不消耗手牌或牌墙")

	print("--- B) live self-gang still consumes the exact tile and replaces it ---")
	scene.offline_phase = "await_discard"
	check(scene.perform_concealed_gang(1, "5W"), "当前行动座位可合法暗杠")
	check(scene.players[1]["melds"] == [["5W", "5W", "5W", "5W"]] and scene.players[1]["hand"] == ["7B"], "暗杠只移除四张杠牌并补入替代牌")
	check(str(scene.offline_last_draw.get("source", "")) == "gang" and scene.offline_phase == "await_discard", "暗杠补牌保留杠来源和行动阶段")

	print("--- C) added gang may complete only after the authenticated rob-gang pass ---")
	reset_round(scene)
	scene.players[0]["hand"] = rob_wait_hand()
	scene.players[1]["melds"] = [["3W", "3W", "3W"]]
	scene.players[1]["hand"] = ["3W"]
	scene.wall = ["8B"]
	check(scene.perform_added_gang(1, "3W"), "补杠进入合法抢杠响应")
	check(scene.offline_phase == "pending_claim" and bool(scene.offline_pending_claim.get("rob_gang", false)), "补杠保留抢杠来源上下文")
	scene.human_claim("pass")
	check(scene.offline_phase == "await_discard" and scene.players[1]["melds"] == [["3W", "3W", "3W", "3W"]], "玩家过抢杠后合法完成补杠")
	check(scene.players[1]["hand"] == ["8B"] and str(scene.offline_last_draw.get("source", "")) == "gang", "过抢杠后补入替代牌")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
