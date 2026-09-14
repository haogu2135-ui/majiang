extends SceneTree
## Round 131: the assistance refresh reuses the discard evaluation context for threats.

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
	print("=== ai_play_round131 check START ===")
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
	scene.players[1]["discards"] = ["1W", "4W", "7W", "2T"]
	scene.players[2]["discards"] = ["2W", "5W", "8W"]
	scene.players[3]["melds"] = [["E", "E", "E"]]
	scene.wall.clear()
	for _i in range(60):
		scene.wall.append("1B")
	scene.clear_ai_report_cache()

	var visible_counts: Array = scene.visible_tile_counts_shared()
	var shared_context: Dictionary = {}
	var shared_reports: Array = scene.get_ai_discard_reports(0, visible_counts, shared_context)
	check(not shared_reports.is_empty(), "discard reports still evaluate with a context output sink")
	check(not shared_context.is_empty() and shared_context.has("pressure_context"), "a report miss exports its completed pressure context")
	check(shared_context.has("threat_cache_state_key") and shared_context.has("opponents"), "the exported context contains the threat snapshot inputs")
	var shared_threats: Dictionary = scene.render_seat_threat_reports(0, shared_context)

	scene.clear_ai_report_cache()
	var baseline_reports: Array = scene.get_ai_discard_reports(0, visible_counts)
	var baseline_context: Dictionary = scene.make_ai_evaluation_context(0, visible_counts)
	var baseline_threats: Dictionary = scene.render_seat_threat_reports(0, baseline_context)
	check(shared_reports == baseline_reports, "shared-context reports preserve the baseline ranking")
	check(shared_threats == baseline_threats, "shared-context threats preserve the baseline reports")

	var cache_hit_context: Dictionary = {}
	var cached_reports: Array = scene.get_ai_discard_reports(0, visible_counts, cache_hit_context)
	check(cached_reports == baseline_reports and cache_hit_context.is_empty(), "a report-cache hit keeps context creation lazy")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
