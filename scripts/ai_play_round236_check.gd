extends SceneTree
## Round 236: self-gang reports reuse the open-meld snapshot.

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
	print("=== ai_play_round236 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["E", "E", "E", "E", "1W", "2W", "3W", "4T", "5T", "6T", "7B", "8B", "9B"]
	scene.players[0]["melds"] = [["1T", "1T", "1T"], ["2T", "2T", "2T"]]
	var visible_counts_236: Array = scene.make_empty_tile_counts()
	var context_236: Dictionary = scene.make_ai_evaluation_context(0, visible_counts_236)
	context_236["hand_counts"] = scene.tile_counts(scene.players[0]["hand"])
	context_236["self_gang_open_melds"] = scene.players[0]["melds"].size()
	var fallback_report_236: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed")
	var snapshot_report_236: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", context_236)
	check(int(context_236.get("self_gang_open_melds", -1)) == 2, "self-gang context publishes the open-meld snapshot")
	check(int(snapshot_report_236.get("before_shanten", 99)) == int(fallback_report_236.get("before_shanten", -1)) and int(snapshot_report_236.get("after_shanten", 99)) == int(fallback_report_236.get("after_shanten", -1)), "open-meld snapshot preserves self-gang shanten")
	check(bool(snapshot_report_236.get("allow", false)) == bool(fallback_report_236.get("allow", false)) and str(snapshot_report_236.get("reason", "")) == str(fallback_report_236.get("reason", "")), "open-meld snapshot preserves the decision")
	check(is_equal_approx(float(snapshot_report_236.get("score", 0.0)), float(fallback_report_236.get("score", 0.0))), "open-meld snapshot preserves the score")

	var no_snapshot_context_236: Dictionary = context_236.duplicate(true)
	no_snapshot_context_236.erase("self_gang_open_melds")
	var no_snapshot_report_236: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", no_snapshot_context_236)
	check(bool(no_snapshot_report_236.get("allow", false)) == bool(fallback_report_236.get("allow", false)) and int(no_snapshot_report_236.get("before_shanten", 99)) == int(fallback_report_236.get("before_shanten", -1)), "missing open-meld snapshot keeps the live fallback")

	var invalid_context_236: Dictionary = context_236.duplicate(true)
	invalid_context_236["self_gang_open_melds"] = 0
	var invalid_snapshot_report_236: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", invalid_context_236)
	check(int(invalid_snapshot_report_236.get("before_shanten", 99)) != int(snapshot_report_236.get("before_shanten", -1)) or int(invalid_snapshot_report_236.get("after_shanten", 99)) != int(snapshot_report_236.get("after_shanten", -1)), "explicit changed open-meld snapshot remains authoritative")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
