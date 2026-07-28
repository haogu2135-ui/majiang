extends SceneTree
## Round 81: hard AI takes a near-free same-shanten fold under extreme pressure.
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
	print("=== ai_play_round81 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD

	print("--- A) extreme same-shanten danger accepts a small safety gain ---")
	var extreme_reports: Array = [
		{"tile": "5W", "score": 900.0, "shanten": 1, "risk": 59.0, "feed_risk": 38.0, "human_target_pressure": 24.0, "safety_label": ""},
		{"tile": "2W", "score": 888.0, "shanten": 1, "risk": 58.0, "feed_risk": 37.0, "human_target_pressure": 23.0, "safety_label": ""},
	]
	scene.apply_hard_danger_push_guard(extreme_reports)
	check(str(extreme_reports[0].get("tile", "")) == "2W", "hard promotes the near-free safer same-shanten discard")

	print("--- B) the exception does not broaden to ordinary pressure or shanten loss ---")
	var ordinary_reports: Array = [
		{"tile": "5W", "score": 900.0, "shanten": 1, "risk": 54.0, "feed_risk": 38.0, "human_target_pressure": 24.0, "safety_label": ""},
		{"tile": "2W", "score": 888.0, "shanten": 1, "risk": 53.0, "feed_risk": 37.0, "human_target_pressure": 23.0, "safety_label": ""},
	]
	scene.apply_hard_danger_push_guard(ordinary_reports)
	check(str(ordinary_reports[0].get("tile", "")) == "5W", "ordinary one-away pressure keeps the existing guard threshold")
	var shanten_loss_reports: Array = [
		{"tile": "5W", "score": 900.0, "shanten": 1, "risk": 59.0, "feed_risk": 38.0, "human_target_pressure": 24.0, "safety_label": ""},
		{"tile": "2W", "score": 888.0, "shanten": 2, "risk": 58.0, "feed_risk": 37.0, "human_target_pressure": 18.0, "safety_label": ""},
	]
	scene.apply_hard_danger_push_guard(shanten_loss_reports)
	check(str(shanten_loss_reports[0].get("tile", "")) == "5W", "extreme one-away exception never promotes a shanten loss")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
