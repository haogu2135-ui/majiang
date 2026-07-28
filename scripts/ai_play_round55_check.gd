extends SceneTree
## Round 55: threat reports must retain one evaluation context's table snapshot.
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
	print("=== ai_play_round55 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.offline_sim_quiet = true
	scene.setup_tile_order()
	scene.players = [make_player("Self"), make_player("Threat"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["5W", "9T", "E"]
	scene.players[1]["melds"] = [["1W", "2W", "3W"], ["6W", "7W", "8W"]]
	scene.players[1]["discards"] = ["5W", "1T", "2T", "3T", "4T", "5T", "6T"]

	print("--- A) the same evaluation context stays internally consistent ---")
	scene.clear_threat_report_cache()
	var context = scene.make_ai_evaluation_context(0, scene.visible_tile_counts())
	var initial = scene.opponent_seat_threat_report(0, 1, context)
	var initial_cache_size = scene.threat_report_cache.size()
	check(not initial.is_empty() and initial_cache_size == 1, "snapshot report enters one threat-cache slot")
	# Simulate a table update after the context is captured. Existing batch work
	# must retain its captured analysis rather than compute mixed-state guidance.
	scene.players[1]["discards"].append("9B")
	var replay = scene.opponent_seat_threat_report(0, 1, context)
	check(scene.threat_report_cache.size() == initial_cache_size, "same context reuses its captured threat-cache key")
	check(is_equal_approx(float(replay.get("score", -1.0)), float(initial.get("score", -2.0))) and replay.get("safe_tiles", []) == initial.get("safe_tiles", []), "same context returns unchanged threat guidance")

	print("--- B) a new live evaluation still receives a distinct cache key ---")
	var fresh = scene.opponent_seat_threat_report(0, 1)
	check(not fresh.is_empty() and scene.threat_report_cache.size() > initial_cache_size, "fresh live state does not reuse the earlier snapshot report")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
