extends SceneTree
## Round 93: all-opponent avoidable-danger telemetry is actionable, bounded, and guard-aware.
var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(cond: bool, msg: String) -> void:
	if cond:
		print("  OK  | %s" % msg)
	else:
		print("  FAIL| %s" % msg)
		failed = true


func run() -> void:
	print("=== ai_play_round93 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame

	print("--- A) forced danger stays diagnostic, not avoidable ---")
	var forced := {
		"tile": "5W",
		"score": 1240.0,
		"shanten": 1,
		"ukeire": 12,
		"risk": 58.0,
		"feed_risk": 46.0,
	}
	var worse_shanten := {
		"tile": "9B",
		"score": 1110.0,
		"shanten": 2,
		"ukeire": 11,
		"risk": 6.0,
		"feed_risk": 4.0,
	}
	var weak_same_shanten := {
		"tile": "N",
		"score": 900.0,
		"shanten": 1,
		"ukeire": 4,
		"risk": 8.0,
		"feed_risk": 3.0,
	}
	scene.reset_ai_sim_stats()
	scene._ai_sim_note_avoidable_danger_report(forced, [forced, worse_shanten, weak_same_shanten])
	check(int(scene.ai_sim_stats.get("avoidable_dangerous_discards", 0)) == 0, "worse shanten or materially weaker alternatives are not avoidable")
	check(int(scene.ai_sim_stats.get("avoidable_high_danger_discards", 0)) == 0, "forced high danger remains outside the actionable high-danger count")

	print("--- B) same-shanten safer alternative is actionable ---")
	var safer := {
		"tile": "E",
		"score": 1080.0,
		"shanten": 1,
		"ukeire": 10,
		"risk": 14.0,
		"feed_risk": 8.0,
	}
	scene.reset_ai_sim_stats()
	var actionable = scene._ai_sim_note_avoidable_danger_report(forced, [forced, safer])
	check(bool(actionable.get("avoidable_dangerous", false)), "same-shanten safer option is classified as avoidable")
	check(bool(actionable.get("avoidable_high_danger", false)), "same-shanten safer option clears the high-danger threshold")
	check(str(actionable.get("candidate_tile", "")) == "E", "telemetry identifies the safer candidate tile")
	check(float(actionable.get("pressure_gain", 0.0)) >= 8.0, "telemetry requires a material combined risk/feed reduction")
	check(int(scene.ai_sim_stats.get("avoidable_dangerous_discards", 0)) == 1 and int(scene.ai_sim_stats.get("avoidable_high_danger_discards", 0)) == 1, "actionable counters increment once per selected discard")

	print("--- C) hard guard removes a catastrophe candidate before selection ---")
	var catastrophe := {
		"tile": "5W",
		"score": 1240.0,
		"shanten": 1,
		"ukeire": 12,
		"risk": 60.0,
		"feed_risk": 40.0,
		"human_target_pressure": 30.0,
		"safety_label": "",
		"wait_best_points": 2,
		"wait_total_remaining": 3,
	}
	var guarded_safe := {
		"tile": "E",
		"score": 1100.0,
		"shanten": 1,
		"ukeire": 10,
		"risk": 14.0,
		"feed_risk": 6.0,
		"human_target_pressure": 8.0,
		"safety_label": "安",
	}
	var reports: Array = [catastrophe, guarded_safe]
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	scene.ai_benchmark_base_difficulty = -1
	scene.ai_sim_trace_enabled = true
	var before_guard = scene._ai_sim_avoidable_danger_report(reports[0], reports)
	scene.apply_hard_danger_push_guard(reports, -1)
	var selected_after: Dictionary = reports[0]
	var after_guard = scene._ai_sim_avoidable_danger_report(selected_after, reports)
	check(bool(before_guard.get("avoidable_high_danger", false)), "catastrophe fixture is avoidable before the hard guard")
	check(str(selected_after.get("tile", "")) == "E", "hard guard moves the safer same-shanten candidate to the front")
	check(bool(selected_after.get("hard_guard_moved", false)), "hard guard leaves an auditable moved marker")
	check(not bool(after_guard.get("avoidable_dangerous", false)), "post-guard selected report no longer carries avoidable danger")

	scene.ai_sim_trace_enabled = false
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
