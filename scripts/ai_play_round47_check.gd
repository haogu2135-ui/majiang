extends SceneTree
## Round 47: only the current live draw may be settled as tsumo.
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


func claimed_chi_complete_hand() -> Array:
	# 1W/2W will call 3W. The remaining eleven tiles are three sets plus a pair.
	return ["1W", "2W", "4T", "5T", "6T", "7T", "8T", "9T", "1B", "2B", "3B", "E", "E"]


func tsumo_wait_hand() -> Array:
	return ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W"]


func reset_round(scene) -> void:
	scene.players = [make_player("You", false), make_player("Source"), make_player("P2"), make_player("P3")]
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 0
	scene.dealer_seat = 1
	scene.wall.clear()
	scene.offline_last_draw.clear()
	scene.offline_self_draw_ready.clear()
	scene.last_win_score.clear()


func run() -> void:
	print("=== ai_play_round47 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.offline_sim_quiet = true
	scene.setup_tile_order()

	print("--- A) claiming a winning discard cannot reuse an earlier draw as tsumo ---")
	reset_round(scene)
	scene.players[0]["hand"] = claimed_chi_complete_hand()
	scene.players[3]["discards"] = ["3W"]
	scene.current_seat = 3
	scene.offline_phase = "resolving"
	scene.last_discard = "3W"
	scene.last_discard_seat = 3
	scene.offline_last_draw = {"seat": 0, "tile": "4T", "source": "normal", "wall_empty": false, "serial": 81}
	scene.offline_self_draw_ready = {"seat": 0, "tile": "4T", "serial": 81}
	var chi_choice = {"meld": ["1W", "2W", "3W"], "needed": ["1W", "2W"]}
	check(scene.is_valid_offline_claim(0, 3, "3W", "chi", chi_choice), "夹具吃牌响应合法")
	scene.apply_offline_claim(0, 3, "3W", "chi", chi_choice)
	check(scene.can_win_for_seat(0), "吃牌后牌形完整，覆盖历史摸牌复用场景")
	check(scene.current_self_draw_tile(0) == "", "吃牌后旧摸牌不再是当前自摸牌")
	check(not scene.can_finish_offline_round(0, "4T", true, -1), "吃牌后不能把旧摸牌作为自摸结算")
	var stale_report = scene.ai_tsumo_decision_report(0, "4T")
	check(not bool(stale_report.get("accept", true)) and str(stale_report.get("reason", "")) == "非当前摸牌", "AI 同样拒绝吃牌后的伪自摸")
	scene.human_self_win()
	check(scene.offline_phase == "await_discard" and scene.last_win_score.is_empty(), "玩家入口不会以旧摸牌结束牌局")

	print("--- B) a real current draw stays eligible and invalidates after discard ---")
	reset_round(scene)
	scene.players[0]["hand"] = tsumo_wait_hand()
	scene.wall.append("5W")
	var drawn = scene.draw_tile_for(0, false, "normal")
	check(drawn == "5W" and scene.can_win_for_seat(0) and scene.current_self_draw_tile(0) == "5W", "实际摸入的和牌仍可自摸")
	check(scene.commit_discard(0, "1W"), "实际摸牌后仍可正常出牌")
	check(scene.current_self_draw_tile(0) == "" and int(scene.offline_last_draw.get("serial", -1)) > 0, "出牌失效自摸资格但保留历史摸牌供河底判定")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
