extends SceneTree
## Round 41: discard furiten blocks ron/rob-gang while leaving self-draw intact.
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


func score_total(scene) -> int:
	var total := 0
	for player in scene.players:
		total += int(player.get("score", 0))
	return total


func reset_round(scene) -> void:
	scene.players = [make_player("You", false), make_player("AI"), make_player("P2"), make_player("P3")]
	scene.mode = "offline"
	scene.offline_phase = "resolving"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 0
	scene.dealer_seat = 0
	scene.offline_last_winner = -1
	scene.offline_pending_claim.clear()
	scene.last_win_score.clear()
	scene.last_score_deltas.clear()
	for seat in range(4):
		scene.last_score_deltas.append(0)
	scene.round_summary = ""
	scene.last_discard = ""
	scene.last_discard_seat = -1


func run() -> void:
	print("=== ai_play_round41 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.offline_sim_quiet = true
	scene.setup_tile_order()

	print("--- A) furiten helper and claim options ---")
	reset_round(scene)
	scene.players[1]["hand"] = winning_wait_hand()
	scene.players[1]["discards"] = ["5W", "2T"]
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	scene.players[0]["discards"] = ["5W"]
	check(scene.is_discard_furiten(1, "5W"), "河牌同名张判定为舍张振听")
	check(not scene.is_discard_furiten(1, "3T"), "未打过的张不是振听")
	check(scene.can_win_for_seat(1, "5W"), "牌形本身仍可成和")
	check(not scene.can_ron_for_seat(1, "5W"), "舍张振听禁止荣和")
	var options = scene.get_claim_options(1, 0, "5W")
	check(not options.has("hu"), "响应选项不展示振听荣和")

	print("--- B) AI ron report and settlement reject furiten ---")
	var ron = scene.ai_ron_decision_report(1, "5W")
	check(not bool(ron.get("accept", true)) and str(ron.get("reason", "")) == "舍张振听", "AI 荣和报告拒绝舍张振听")
	var total_before = score_total(scene)
	check(not scene.can_finish_offline_round(1, "5W", false, 0), "结算守卫拒绝振听荣和")
	scene.finish_offline_round(1, "5W", false, 0)
	check(scene.offline_phase == "resolving" and scene.last_win_score.is_empty() and score_total(scene) == total_before, "振听荣和不改分不结束")

	print("--- C) non-furiten ron still works ---")
	reset_round(scene)
	scene.players[1]["hand"] = winning_wait_hand()
	scene.players[1]["discards"] = ["2T", "3T"]
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	scene.players[0]["discards"] = ["5W"]
	check(scene.can_ron_for_seat(1, "5W"), "未打过的听口可荣和")
	check(scene.get_claim_options(1, 0, "5W").has("hu"), "合法荣和出现在响应选项")
	scene.finish_offline_round(1, "5W", false, 0)
	check(scene.offline_phase == "ended" and scene.offline_last_winner == 1, "合法荣和正常结算")

	print("--- D) furiten also blocks rob-gang, self-draw remains ---")
	reset_round(scene)
	scene.players[1]["hand"] = winning_wait_hand()
	scene.players[1]["discards"] = ["5W"]
	scene.players[0]["hand"] = ["5W"]
	scene.players[0]["melds"] = [["5W", "5W", "5W"]]
	scene.offline_phase = "await_discard"
	check(not scene.can_ron_for_seat(1, "5W"), "舍张振听同样禁止抢杠胡")
	var threat = scene.added_gang_rob_threat_report(0, "5W")
	check(not bool(threat.get("can_rob", true)), "补杠威胁扫描忽略振听座位")
	check(scene.choose_ai_rob_gang(0, "5W").is_empty(), "AI 抢杠选择跳过振听")
	check(not scene.can_finish_offline_round(1, "5W", false, 0, "rob_gang"), "结算守卫拒绝振听抢杠胡")

	reset_round(scene)
	scene.offline_phase = "await_discard"
	scene.current_seat = 1
	scene.players[1]["hand"] = ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W", "5W"]
	scene.players[1]["discards"] = ["5W", "2T"]
	scene.sort_hand(scene.players[1]["hand"])
	scene.offline_last_draw = {"seat": 1, "tile": "5W", "source": "normal", "wall_empty": false, "serial": 51}
	check(scene.is_discard_furiten(1, "5W"), "自摸前仍标记舍张振听")
	check(scene.can_win_for_seat(1), "自摸只看牌形，不受舍张振听影响")
	check(scene.can_finish_offline_round(1, "5W", true, -1), "舍张振听不阻止自摸结算")
	scene.finish_offline_round(1, "5W", true, -1)
	check(scene.offline_phase == "ended" and scene.offline_last_winner == 1, "振听座位仍可自摸结束")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
