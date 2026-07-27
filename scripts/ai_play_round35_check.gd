extends SceneTree
## Round 35: discard state transitions reject stale, foreign, and missing tiles atomically.
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
	scene.players = [make_player("P0"), make_player("Actor"), make_player("P2"), make_player("P3")]
	scene.players[1]["hand"] = ["1W", "2W"]
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 1
	scene.last_discard = ""
	scene.last_discard_seat = -1
	scene.offline_pending_claim.clear()


func run() -> void:
	print("=== ai_play_round35 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.offline_sim_quiet = true
	scene.setup_tile_order()

	print("--- A) invalid requests leave all table state intact ---")
	reset_round(scene)
	var original_hand = scene.players[1]["hand"].duplicate()
	check(scene.discard_tile_by_value(2, "9W") == "", "非当前座位不能出牌")
	check(scene.discard_tile_by_value(1, "9W") == "", "不存在的请求牌不回退改打首张")
	check(scene.discard_tile_by_index(1, 9) == "", "越界手牌索引不修改状态")
	check(not scene.commit_discard(2, "9W"), "提交边界拒绝非当前座位")
	check(not scene.commit_discard(1, "9W"), "提交边界拒绝手牌中不存在的伪造牌")
	check(scene.players[1]["hand"] == original_hand and scene.players[1]["discards"].is_empty() and scene.offline_phase == "await_discard", "非法请求不动手牌、牌河或阶段")

	print("--- B) stale phase cannot consume a legal hand tile ---")
	scene.offline_phase = "resolving"
	check(scene.discard_tile_by_value(1, "1W") == "", "响应阶段拒绝重复出牌")
	check(scene.players[1]["hand"] == original_hand and scene.players[1]["discards"].is_empty(), "过期请求保持原状态")

	print("--- C) legal turn commits exactly the requested tile ---")
	scene.offline_phase = "await_discard"
	var committed = scene.discard_tile_by_value(1, "2W")
	check(committed == "2W", "合法请求返回实际提交牌")
	check(scene.players[1]["hand"] == ["1W"] and scene.players[1]["discards"] == ["2W"], "合法出牌只移除请求牌并写入牌河")
	check(scene.last_discard == "2W" and scene.last_discard_seat == 1 and scene.offline_phase == "resolving", "合法出牌推进到响应窗口")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
