extends SceneTree
## Round 132: helper text reuses the discard reports it already resolved.

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


func reset_scene_state(scene) -> void:
	scene.current_human_advice = []
	scene.ai_assist_enabled = true
	scene.offline_sim_quiet = false
	scene.clear_ai_report_cache()


func run() -> void:
	print("=== ai_play_round132 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.offline_turn_needs_draw = false
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "2T", "3T", "5B", "E"]
	scene.wall.clear()
	for _i in range(60):
		scene.wall.append("1B")

	print("--- A) human hint report snapshot ---")
	reset_scene_state(scene)
	var hint_text: String = scene.human_hint_text()
	check(hint_text != "" and scene.ai_report_cache_misses == 1 and scene.ai_report_cache_hits == 0, "human hint does not refetch reports for its safest hint")

	print("--- B) hand tray report snapshot ---")
	reset_scene_state(scene)
	var tray_text: String = scene.hand_tray_text()
	check(tray_text != "" and scene.ai_report_cache_misses == 1 and scene.ai_report_cache_hits == 0, "hand tray does not refetch reports for its compact safety summary")

	print("--- C) advice summary report snapshot ---")
	reset_scene_state(scene)
	var advice_text: String = scene.ai_advice_summary(0)
	check(advice_text != "" and scene.ai_report_cache_misses == 1 and scene.ai_report_cache_hits == 0, "advice summary does not refetch reports for its safest hint")

	print("--- D) detailed defense report snapshot ---")
	reset_scene_state(scene)
	var detail_reports: Array = scene.get_ai_discard_reports(0)
	var detail_best: Dictionary = detail_reports[0] if not detail_reports.is_empty() else {}
	var detail_text: String = scene.advisor_defense_text(0, detail_best, detail_reports)
	check(detail_text != "" and scene.ai_report_cache_hits == 0, "detailed defense text consumes its supplied report snapshot")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
