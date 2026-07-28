extends SceneTree
## Round 52: replacement draws share the normal tsumo decision window.
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


func replacement_tenpai_hand() -> Array:
	# After removing four 1B tiles, an E replacement makes three sequences plus EE.
	return ["1B", "1B", "1B", "1B", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E"]


func reset_round(scene, actor_bot: bool) -> void:
	scene.players = [make_player("You", false), make_player("Actor", actor_bot), make_player("P2"), make_player("P3")]
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 1
	scene.dealer_seat = 0
	# 同步模拟要求四家已发牌且牌墙仍有余牌，避免它为测试夹具自动重开一局。
	scene.players[0]["hand"] = ["1T", "2T", "3T", "4T", "5T", "6T", "7T", "8T", "9T", "E", "S", "W", "N"]
	scene.players[1]["hand"] = replacement_tenpai_hand()
	scene.wall.clear()
	scene.wall.append("2B")
	scene.wall.append("E")
	scene.offline_last_draw.clear()
	scene.offline_self_draw_ready.clear()
	scene.last_win_score.clear()
	scene.offline_last_winner = -1


func run() -> void:
	print("=== ai_play_round52 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.offline_sim_quiet = true
	scene.setup_tile_order()

	print("--- A) a human replacement win remains an explicit action ---")
	reset_round(scene, false)
	check(scene.perform_concealed_gang(1, "1B"), "夹具可完成当前暗杠")
	check(scene.offline_phase == "await_discard" and scene.offline_last_winner == -1, "杠后和牌不被绘制层直接结算")
	check(scene.current_self_draw_tile(1) == "E" and scene.can_win_for_seat(1), "补牌保留当前自摸资格和完整牌形")
	# Rebind the same setup to the human seat to exercise the public self-win action.
	reset_round(scene, false)
	scene.players[0] = make_player("You", false)
	scene.players[0]["hand"] = replacement_tenpai_hand()
	scene.players[1] = make_player("Actor")
	scene.current_seat = 0
	scene.wall.clear()
	scene.wall.append("2B")
	scene.wall.append("E")
	check(scene.perform_concealed_gang(0, "1B"), "玩家可完成当前暗杠")
	check(scene.offline_last_winner == -1 and scene.can_win_for_seat(0), "玩家杠上和牌等待显式确认")
	scene.human_self_win()
	check(scene.offline_phase == "ended" and scene.offline_last_winner == 0 and bool(scene.last_win_score.get("self_draw", false)), "玩家自摸入口完成杠上结算")

	print("--- B) sync all-bot path evaluates the replacement draw before discarding ---")
	reset_round(scene, true)
	check(scene.perform_concealed_gang(1, "1B"), "AI 夹具可完成暗杠并获得补牌")
	check(scene.offline_phase == "await_discard" and scene.offline_last_winner == -1, "AI 补牌同样未被立即结算")
	var result = scene.simulate_offline_bot_hand_sync(2)
	print("    result=%s" % str(result))
	check(bool(result.get("ended", false)) and int(result.get("winner", -1)) == 1, "同步 AI 在补牌行动窗裁决自摸")
	check(bool(scene.last_win_score.get("self_draw", false)) and (scene.last_win_score.get("reasons", []) as Array).has("杠上开花"), "补牌自摸保留杠上开花计分")

	print("--- C) visible-table AI uses the same replacement-draw decision ---")
	reset_round(scene, true)
	check(scene.perform_concealed_gang(1, "1B"), "可见桌面 AI 夹具可获得补牌")
	await scene.run_ai_until_human()
	check(scene.offline_phase == "ended" and scene.offline_last_winner == 1, "可见桌面 AI 在补牌行动窗完成自摸")
	check(bool(scene.last_win_score.get("self_draw", false)), "可见桌面 AI 保留自摸结算类型")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
