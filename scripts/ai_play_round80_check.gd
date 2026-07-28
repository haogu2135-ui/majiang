extends SceneTree
## Round 80: quiet all-bot discard reports must not retain unusable cache copies.
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


func setup_table(scene) -> void:
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 1
	scene.dealer_seat = 0
	scene.offline_hand_number = 1
	scene.wall = scene.make_wall()
	scene.players[1]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "3T", "5T", "E", "E"]
	scene.players[0]["discards"] = ["9B", "9T"]
	scene.players[2]["melds"] = [["1B", "1B", "1B"]]
	scene.players[3]["discards"] = ["S", "R"]
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD


func run() -> void:
	print("=== ai_play_round80 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	setup_table(scene)

	print("--- A) quiet simulation skips one-shot report cache ---")
	scene.enable_offline_all_bot_mode(true, true)
	scene.clear_ai_report_cache()
	var quiet_reports = scene.get_ai_discard_reports(1)
	check(not quiet_reports.is_empty(), "quiet simulation still returns discard candidates")
	check(scene.ai_report_cache.is_empty() and scene.ai_report_cache_order.is_empty(), "quiet simulation retains no state-unique report copies")
	check(scene.ai_report_cache_hits == 0 and scene.ai_report_cache_misses == 0, "quiet simulation skips cache-key accounting")

	print("--- B) interactive report cache remains available ---")
	scene.enable_offline_all_bot_mode(false, false)
	scene.clear_ai_report_cache()
	var first_reports = scene.get_ai_discard_reports(1)
	var second_reports = scene.get_ai_discard_reports(1)
	check(not first_reports.is_empty() and first_reports.size() == second_reports.size(), "interactive calls preserve report availability")
	check(scene.ai_report_cache.size() == 1 and scene.ai_report_cache_order.size() == 1, "interactive state stores one reusable report entry")
	check(scene.ai_report_cache_misses == 1 and scene.ai_report_cache_hits == 1, "second interactive call hits the existing report cache")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
