extends SceneTree
## Round 56: a forced preserve-tenpai discard must skip full report generation.
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
	print("=== ai_play_round56 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	scene.dealer_seat = 0
	scene.setup_tile_order()
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	# 2W is a low-value tsumo; returning it preserves the higher-value 1W wait.
	var tenpai: Array = ["2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W", "2T", "3T", "4T"]
	for seat in range(3):
		scene.players[seat]["hand"] = ["1B", "3B", "5B", "7B", "9B", "1T", "3T", "5T", "7T", "9T", "E", "S", "W"]
	scene.players[3]["hand"] = tenpai.duplicate()
	var test_wall: Array[String] = []
	for i in range(48):
		test_wall.append("2B")
	test_wall.append("2W")
	scene.wall = test_wall
	scene.current_seat = 3
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = true
	scene.offline_last_draw.clear()
	scene.offline_self_draw_ready.clear()
	scene.clear_ai_report_cache()

	print("--- A) forced tsumo-pass discard does not build a Top-K report ---")
	var result = scene.simulate_offline_bot_hand_sync(1)
	print("    result=%s misses=%d" % [str(result), int(scene.ai_report_cache_misses)])
	check(scene.players[3]["discards"].size() == 1 and str(scene.players[3]["discards"].back()) == "2W", "sync bot returns the low-value tsumo tile")
	check(scene.players[3]["hand"].size() == tenpai.size() and scene.can_win_for_seat(3, "1W"), "returning the tile preserves the original high-value tenpai")
	check(scene.ai_report_cache_misses == 0, "forced discard bypasses full discard-report generation")
	check(int(result.get("discards", 0)) == 1, "simulation still records the forced discard")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
