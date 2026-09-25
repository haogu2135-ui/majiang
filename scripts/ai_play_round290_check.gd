extends SceneTree

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
	print("=== ai_play_round290 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_all_bot_mode = true
	scene.offline_sim_quiet = true
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	scene.ai_benchmark_base_difficulty = scene.AI_DIFFICULTY_HARD
	scene.ai_benchmark_probe_seat = -1
	scene.ai_benchmark_probe_difficulty = -1
	scene.players = [make_player("P0"), make_player("Actor"), make_player("Route"), make_player("P3")]
	scene.wall = scene.make_wall()
	scene.players[1]["hand"] = ["1B", "2B", "3B", "4B", "5B", "6B", "7B", "8B", "9B", "2T", "4T", "6T", "5W", "E"]
	scene.players[2]["melds"] = [["1W", "2W", "3W"], ["7W", "8W", "9W"]]
	scene.players[2]["discards"] = ["1T", "2T", "3T", "4T", "5T", "6T"]
	scene.offline_claim_counts[scene.claim_source_key(2, 1)] = 2

	var quiet_reports: Array = scene.get_ai_discard_reports(1)
	var quiet_choice := str(quiet_reports[0].get("tile", "")) if not quiet_reports.is_empty() else ""
	for report in quiet_reports:
		print("    quiet %s sh=%d risk=%.1f safety=%s ukeire=%d emergency=%.1f score=%.1f" % [
			str(report.get("tile", "")),
			int(report.get("shanten", -1)),
			float(report.get("risk", 0.0)),
			str(report.get("safety_label", "")),
			int(report.get("ukeire", 0)),
			float(report.get("emergency_defense", 0.0)),
			float(report.get("score", 0.0)),
		])
	scene.offline_sim_quiet = false
	scene.clear_ai_report_cache()
	var full_reports: Array = scene.get_ai_discard_reports(1)
	var full_choice := str(full_reports[0].get("tile", "")) if not full_reports.is_empty() else ""
	check(quiet_reports.size() <= scene.AI_FAST_EVAL_PRESSURE_TOP_K, "quiet evaluation remains bounded in a pressure state")
	check(not full_reports.is_empty() and full_choice == "4T", "full evaluation prefers the current-safe route-preserving discard")
	check(quiet_choice == full_choice, "hard quiet pre-ranking retains the full scorer's emergency-safe choice")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
