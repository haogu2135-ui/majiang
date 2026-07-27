extends SceneTree
## Round 48: self-draw settlement and AI decisions require the live post-draw action window.
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


func score_total(scene) -> int:
	var total = 0
	for player in scene.players:
		total += int(player.get("score", 0))
	return total


func reset_round(scene) -> void:
	scene.players = [make_player("P0"), make_player("Winner"), make_player("P2"), make_player("P3")]
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 1
	scene.dealer_seat = 0
	scene.players[1]["hand"] = complete_hand()
	scene.offline_last_draw = {"seat": 1, "tile": "5W", "source": "normal", "wall_empty": false, "serial": 91}
	scene.offline_self_draw_ready = {"seat": 1, "tile": "5W", "serial": 91}
	scene.last_win_score.clear()


func run() -> void:
	print("=== ai_play_round48 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.offline_sim_quiet = true
	scene.setup_tile_order()

	print("--- A) normal live post-draw state remains valid ---")
	reset_round(scene)
	check(scene.can_finish_offline_round(1, "5W", true, -1), "当前行动座位的真实摸牌可自摸结算")
	var live_ai = scene.ai_tsumo_decision_report(1, "5W")
	check(bool(live_ai.get("accept", false)) and str(live_ai.get("reason", "")) != "非自摸回合", "AI 在真实摸牌窗口保留自摸决策")

	print("--- B) resolver state cannot settle a stale self draw ---")
	reset_round(scene)
	var total_before = score_total(scene)
	scene.offline_phase = "resolving"
	check(not scene.can_finish_offline_round(1, "5W", true, -1), "弃牌响应阶段拒绝自摸结算")
	var resolving_ai = scene.ai_tsumo_decision_report(1, "5W")
	check(not bool(resolving_ai.get("accept", true)) and str(resolving_ai.get("reason", "")) == "非自摸回合", "AI 拒绝响应阶段的伪自摸")
	scene.finish_offline_round(1, "5W", true, -1)
	check(scene.offline_phase == "resolving" and scene.last_win_score.is_empty() and score_total(scene) == total_before, "过期自摸不改分或结束牌局")

	print("--- C) foreign seat and pending draw also reject settlement ---")
	reset_round(scene)
	scene.current_seat = 2
	check(not scene.can_finish_offline_round(1, "5W", true, -1), "非当前座位不能以历史摸牌自摸")
	reset_round(scene)
	scene.offline_turn_needs_draw = true
	check(not scene.can_finish_offline_round(1, "5W", true, -1), "尚待摸牌时不能伪造自摸")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
