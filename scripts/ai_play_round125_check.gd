extends SceneTree
## Round 125: discard report cache keys reuse the visible-count snapshot.

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
	print("=== ai_play_round125 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.wall = scene.make_wall()
	scene.players[1]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "E", "S"]

	var visible_counts: Array = scene.visible_tile_counts_shared()
	print("--- A) cache-key snapshot equivalence ---")
	var default_key: String = scene.ai_report_cache_key(1)
	var snapshot_key: String = scene.ai_report_cache_key(1, visible_counts)
	check(default_key != "" and default_key == snapshot_key, "discard cache key preserves the live visible-count result")

	print("--- B) report path keeps the supplied state ---")
	scene.offline_sim_quiet = false
	scene.clear_ai_report_cache()
	var reports: Array = scene.get_ai_discard_reports(1)
	check(not reports.is_empty(), "cache-miss discard evaluation still produces reports")
	var repeated_reports: Array = scene.get_ai_discard_reports(1)
	check(reports == repeated_reports and scene.ai_report_cache_hits >= 1, "cache-hit discard evaluation preserves the report result")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
