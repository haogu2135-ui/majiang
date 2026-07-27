extends SceneTree
## Round 45: malformed package-liability state must not crash previews or alter settlement.
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


func complete_hand() -> Array:
	return ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W", "5W"]


func reset_round(scene) -> void:
	scene.players = [make_player("Source"), make_player("Winner"), make_player("P2"), make_player("P3")]
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 1
	scene.dealer_seat = 0
	scene.players[1]["hand"] = complete_hand()
	scene.offline_last_draw = {"seat": 1, "tile": "5W", "source": "normal", "wall_empty": false, "serial": 71}
	scene.offline_package_liability.clear()
	scene.last_win_score.clear()
	scene.last_score_deltas.clear()
	for seat in range(4):
		scene.last_score_deltas.append(0)
	scene.offline_last_winner = -1


func run() -> void:
	print("=== ai_play_round45 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.offline_sim_quiet = true
	scene.setup_tile_order()

	print("--- A) malformed package payer falls back to normal self-draw payment ---")
	reset_round(scene)
	scene.offline_package_liability[1] = 99
	check(scene.package_payer_for(1) == -1, "越界包赔座位被拒绝")
	check(scene.package_preview(1) == "" and scene.active_package_lines().is_empty(), "畸形包赔状态不进入牌桌预览")
	var normal_points = int(scene.calculate_win_score(1, "5W", true).get("points", 0))
	check(scene.can_finish_offline_round(1, "5W", true, -1), "异常包赔不影响合法自摸边界")
	scene.finish_offline_round(1, "5W", true, -1)
	check(int(scene.players[1]["score"]) == 25000 + normal_points * 3, "异常包赔按普通自摸收款")
	check(int(scene.players[0]["score"]) == 25000 - normal_points and int(scene.players[2]["score"]) == 25000 - normal_points and int(scene.players[3]["score"]) == 25000 - normal_points, "异常包赔不错误索引或漏扣其他座位")

	print("--- B) valid package payer keeps the existing all-payment rule ---")
	reset_round(scene)
	scene.offline_package_liability[1] = 0
	check(scene.package_payer_for(1) == 0, "有效包赔归属保留")
	check(scene.package_preview(1) == "Source包" and scene.active_package_lines().size() == 1, "有效包赔仍展示给牌桌")
	var package_points = int(scene.calculate_win_score(1, "5W", true).get("points", 0))
	scene.finish_offline_round(1, "5W", true, -1)
	check(int(scene.players[1]["score"]) == 25000 + package_points * 3 and int(scene.players[0]["score"]) == 25000 - package_points * 3, "有效包赔仍由包家承担全部自摸支付")
	check(int(scene.players[2]["score"]) == 25000 and int(scene.players[3]["score"]) == 25000, "有效包赔不向无关座位收费")

	print("--- C) winner cannot be its own package payer ---")
	reset_round(scene)
	scene.offline_package_liability[1] = 1
	check(scene.package_payer_for(1) == -1, "赢家自包被拒绝")
	check(scene.package_preview(1) == "" and scene.active_package_lines().is_empty(), "赢家自包不渲染错误归属")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
