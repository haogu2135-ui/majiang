extends SceneTree
## Round 157: self-gang discipline reuses the evaluation wall snapshot.

var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if condition:
		print("  OK  | %s" % message)
	else:
		print("  FAIL| %s" % message)
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
	print("=== ai_play_round157 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_sim_quiet = true
	scene.current_seat = 1
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[1]["hand"] = ["5W", "5W", "5W", "5W", "1W", "4W", "7W", "2T", "5T", "8T", "E", "S", "W", "N"]
	scene.wall.clear()
	for _i in range(50):
		scene.wall.append("1B")

	var visible_counts: Array = scene.visible_tile_counts_shared()
	var eval_context: Dictionary = scene.make_ai_evaluation_context(1, visible_counts)
	eval_context["hand_counts"] = scene.tile_counts(scene.players[1]["hand"])
	eval_context["self_gang_attack_multiplier"] = scene.ai_total_attack_multiplier(1)
	eval_context["self_gang_gang_aggression"] = scene.ai_gang_aggression(1)
	eval_context["self_gang_wait_focus"] = scene.ai_wait_value_focus(1)
	eval_context["self_gang_difficulty"] = scene.AI_DIFFICULTY_NORMAL
	eval_context["pressure_context"] = scene.ai_pressure_context(1, eval_context)
	var report_live: Dictionary = scene.build_ai_self_gang_report(1, "5W", "concealed", eval_context)
	check(int(report_live.get("wall_draw_wall_count", -1)) == 50, "暗杠报告消费评估上下文中的牌墙快照")

	var snapshot_context: Dictionary = eval_context.duplicate(true)
	snapshot_context["discard_report_wall_count"] = 8
	var report_snapshot: Dictionary = scene.build_ai_self_gang_report(1, "5W", "concealed", snapshot_context)
	var expected_snapshot: Dictionary = scene.wall_draw_self_gang_discipline_report(1, "concealed", int(report_snapshot.get("before_shanten", 8)), int(report_snapshot.get("after_shanten", 8)), 8)
	check(int(report_snapshot.get("wall_draw_wall_count", -1)) == 8 and bool(report_snapshot.get("declined_by_wall_draw", false)) == bool(expected_snapshot.get("decline", false)) and is_equal_approx(float(report_snapshot.get("wall_draw_gang_penalty", 0.0)), float(expected_snapshot.get("penalty", 0.0))), "暗杠残墙规则保持显式牌墙结果")

	var direct_explicit: Dictionary = scene.wall_draw_self_gang_discipline_report(1, "concealed", 3, 3, 8)
	scene.wall.clear()
	for _i in range(8):
		scene.wall.append("1B")
	var direct_live: Dictionary = scene.wall_draw_self_gang_discipline_report(1, "concealed", 3, 3)
	check(direct_explicit == direct_live, "无上下文残墙规则仍保持实时回退结果")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
