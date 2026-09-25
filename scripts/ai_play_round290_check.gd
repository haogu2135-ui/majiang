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
	scene.reset_ai_sim_stats()
	scene.ai_sim_trace_enabled = true

	var quiet_reports: Array = scene.get_ai_discard_reports(1)
	print("    quiet reports=%d" % quiet_reports.size())
	for report in quiet_reports:
		print("    quiet %s sh=%d risk=%.1f feed=%.1f score=%.1f" % [
			str(report.get("tile", "")),
			int(report.get("shanten", -1)),
			float(report.get("risk", 0.0)),
			float(report.get("feed_risk", 0.0)),
			float(report.get("score", 0.0)),
		])

	scene.offline_sim_quiet = false
	scene.clear_ai_report_cache()
	var full_reports: Array = scene.get_ai_discard_reports(1)
	print("    full reports=%d" % full_reports.size())
	for report in full_reports:
		print("    full  %s sh=%d risk=%.1f feed=%.1f score=%.1f moved=%s" % [
			str(report.get("tile", "")),
			int(report.get("shanten", -1)),
			float(report.get("risk", 0.0)),
			float(report.get("feed_risk", 0.0)),
			float(report.get("score", 0.0)),
			str(report.get("hard_guard_moved", false)),
		])
		if str(report.get("tile", "")) == "4T":
			print("    full winner detail=%s" % report)
	check(not quiet_reports.is_empty() and not full_reports.is_empty(), "both evaluation paths produce discard candidates")

	scene.ai_sim_trace_enabled = false
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
