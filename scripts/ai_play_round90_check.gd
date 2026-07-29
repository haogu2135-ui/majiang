extends SceneTree
## Round 90: player-pressure telemetry counts only actionable safe alternatives.
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
	print("=== ai_play_round90 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame

	print("--- A) same-shanten safe alternative is actionable ---")
	var dangerous := {
		"tile": "5W",
		"score": 1240.0,
		"shanten": 1,
		"ukeire": 12,
		"human_target_pressure": 34.0,
	}
	var safer := {
		"tile": "E",
		"score": 1070.0,
		"shanten": 1,
		"ukeire": 10,
		"human_target_pressure": 12.0,
	}
	scene.reset_ai_sim_stats()
	scene._ai_sim_note_human_target_pressure_report(dangerous, [dangerous, safer])
	check(int(scene.ai_sim_stats.get("human_high_danger_discards", 0)) == 1, "raw high player pressure remains visible for diagnosis")
	check(int(scene.ai_sim_stats.get("human_avoidable_high_danger_discards", 0)) == 1, "same-shanten low-loss safer option is counted as avoidable")

	print("--- B) worsening or materially weaker alternatives are not actionable ---")
	var worse_shanten := safer.duplicate(true)
	worse_shanten["tile"] = "9B"
	worse_shanten["shanten"] = 2
	worse_shanten["score"] = 900.0
	var weak_same_shanten := safer.duplicate(true)
	weak_same_shanten["tile"] = "N"
	weak_same_shanten["score"] = 900.0
	weak_same_shanten["ukeire"] = 4
	scene.reset_ai_sim_stats()
	scene._ai_sim_note_human_target_pressure_report(dangerous, [dangerous, worse_shanten, weak_same_shanten])
	check(int(scene.ai_sim_stats.get("human_high_danger_discards", 0)) == 1, "forced high pressure is still retained in the raw series")
	check(int(scene.ai_sim_stats.get("human_avoidable_high_danger_discards", 0)) == 0, "worse shanten or material efficiency loss does not count as avoidable")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
