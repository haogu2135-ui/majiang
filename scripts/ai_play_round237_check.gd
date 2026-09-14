extends SceneTree
## Round 237: self-gang selectors reuse the added-candidate snapshot.

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
	print("=== ai_play_round237 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["4M", "1W", "2W", "3W", "5W", "6W", "7W", "8W", "9W", "E", "S", "W", "N"]
	scene.players[0]["melds"] = [["4M", "4M", "4M"]]
	var visible_counts_237: Array = scene.make_empty_tile_counts()
	var context_237: Dictionary = scene.make_ai_evaluation_context(0, visible_counts_237)
	context_237["hand_counts"] = scene.tile_counts(scene.players[0]["hand"])
	context_237["self_gang_open_melds"] = scene.players[0]["melds"].size()
	context_237["self_gang_added_candidates"] = {"4W": true}
	var fallback_report_237: Dictionary = scene.build_ai_self_gang_report(0, "4M", "added")
	var snapshot_report_237: Dictionary = scene.build_ai_self_gang_report(0, "4M", "added", context_237, scene.tile_index("4M"))
	check(str(scene.TILE_CODES[scene.tile_index("4M")]) == "4W", "added-gang fixture uses the canonical alias key")
	check(bool(snapshot_report_237.get("allow", false)) == bool(fallback_report_237.get("allow", false)) and str(snapshot_report_237.get("reason", "")) == str(fallback_report_237.get("reason", "")), "added-candidate snapshot preserves the decision")
	check(is_equal_approx(float(snapshot_report_237.get("score", 0.0)), float(fallback_report_237.get("score", 0.0))), "added-candidate snapshot preserves the score")

	var no_snapshot_context_237: Dictionary = context_237.duplicate(true)
	no_snapshot_context_237.erase("self_gang_added_candidates")
	var no_snapshot_report_237: Dictionary = scene.build_ai_self_gang_report(0, "4M", "added", no_snapshot_context_237, scene.tile_index("4M"))
	check(bool(no_snapshot_report_237.get("allow", false)) == bool(fallback_report_237.get("allow", false)), "missing added-candidate snapshot keeps the live fallback")

	var stale_context_237: Dictionary = context_237.duplicate(true)
	stale_context_237["self_gang_added_candidates"] = {}
	var stale_report_237: Dictionary = scene.build_ai_self_gang_report(0, "4M", "added", stale_context_237, scene.tile_index("4M"))
	check(not bool(stale_report_237.get("allow", false)) and str(stale_report_237.get("reason", "")) == "非法杠", "empty added-candidate snapshot remains authoritative")

	var invalid_report_237: Dictionary = scene.build_ai_self_gang_report(0, "ZZ", "added", context_237, -1)
	check(not bool(invalid_report_237.get("allow", false)) and str(invalid_report_237.get("reason", "")) == "非法杠", "invalid added-gang candidates keep the guarded rejection")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
