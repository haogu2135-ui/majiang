extends SceneTree
## Round 22: AI report cache must not mix quiet Top-K results or profile assignments.
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


func run() -> void:
	print("=== ai_play_round22 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.setup_tile_order()
	scene.players = [make_player("Self"), make_player("Guard"), make_player("Attack"), make_player("Route")]
	scene.wall = scene.make_wall()
	scene.offline_phase = "await_discard"
	scene.current_seat = 1
	scene.offline_turn_needs_draw = false
	# Fourteen distinct tiles guarantee more candidates than the simulation Top-K.
	scene.players[1]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "3T", "5T", "E", "S"]

	print("--- A) quiet Top-K cannot leak into full evaluation ---")
	scene.clear_ai_report_cache()
	scene.offline_sim_quiet = true
	var fast_reports = scene.get_ai_discard_reports(1)
	print("    quiet candidates=%d" % fast_reports.size())
	check(fast_reports.size() > 0 and fast_reports.size() <= scene.AI_FAST_EVAL_TOP_K, "静默模拟只保留 Top-K 候选")
	scene.offline_sim_quiet = false
	var full_reports = scene.get_ai_discard_reports(1)
	print("    full candidates=%d" % full_reports.size())
	check(full_reports.size() > scene.AI_FAST_EVAL_TOP_K, "完整评估不会复用静默 Top-K 缓存")

	print("--- B) profile remap invalidates the report cache ---")
	scene.clear_ai_report_cache()
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL
	scene.ai_profile_seat_map = [0, 1, 2, 3]
	var guarded_reports = scene.get_ai_discard_reports(1)
	var guarded_profile = str(guarded_reports[0].get("ai_profile", "")) if not guarded_reports.is_empty() else ""
	scene.ai_profile_seat_map = [0, 2, 1, 3]
	var attack_reports = scene.get_ai_discard_reports(1)
	var attack_profile = str(attack_reports[0].get("ai_profile", "")) if not attack_reports.is_empty() else ""
	print("    profile guard=%s remapped=%s" % [guarded_profile, attack_profile])
	check(guarded_profile == "防守型", "初始映射返回防守型评分")
	check(attack_profile == "进攻型", "人设重排后报告重新计算")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
