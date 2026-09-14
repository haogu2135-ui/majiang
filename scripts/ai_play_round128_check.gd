extends SceneTree
## Round 128: AI assistance reuses its visible-count evaluation snapshot.

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
	print("=== ai_play_round128 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = false
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[1]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "E", "S"]

	var visible_counts: Array = scene.visible_tile_counts_shared()
	print("--- A) assistance snapshot equivalence ---")
	scene.clear_ai_report_cache()
	var default_reports: Array = scene.get_ai_discard_reports(1)
	scene.clear_ai_report_cache()
	var snapshot_reports: Array = scene.get_ai_discard_reports(1, visible_counts)
	check(not default_reports.is_empty() and default_reports == snapshot_reports, "discard reports preserve results with the assistance snapshot")

	print("--- B) quiet path remains lazy ---")
	scene.offline_sim_quiet = true
	var quiet_reports: Array = scene.get_ai_discard_reports(1)
	check(not quiet_reports.is_empty(), "quiet discard callers still evaluate without a prebuilt snapshot")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
