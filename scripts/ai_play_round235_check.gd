extends SceneTree
## Round 235: self-gang reports reuse the selector hand-count snapshot.

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
	print("=== ai_play_round235 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["E", "E", "E", "E", "1W", "2W", "3W", "4T", "5T", "6T", "7B", "8B", "9B"]
	var visible_counts_235: Array = scene.make_empty_tile_counts()
	var context_235: Dictionary = scene.make_ai_evaluation_context(0, visible_counts_235)
	context_235["hand_counts"] = scene.tile_counts(scene.players[0]["hand"])
	var fallback_report_235: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed")
	var snapshot_report_235: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", context_235)
	check(int(snapshot_report_235.get("tile_index", -2)) == scene.tile_index("E"), "hand-count snapshot report retains the tile index")
	check(bool(snapshot_report_235.get("allow", false)) == bool(fallback_report_235.get("allow", false)) and str(snapshot_report_235.get("reason", "")) == str(fallback_report_235.get("reason", "")), "hand-count snapshot preserves the concealed-gang decision")
	check(is_equal_approx(float(snapshot_report_235.get("score", 0.0)), float(fallback_report_235.get("score", 0.0))), "hand-count snapshot preserves the concealed-gang score")

	var invalid_context_235: Dictionary = context_235.duplicate(true)
	invalid_context_235["hand_counts"] = scene.make_empty_tile_counts()
	var invalid_snapshot_report_235: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", invalid_context_235)
	check(not bool(invalid_snapshot_report_235.get("allow", false)) and str(invalid_snapshot_report_235.get("reason", "")) == "非法杠", "stale hand-count snapshot keeps the guarded rejection")
	var no_snapshot_context_235: Dictionary = context_235.duplicate(true)
	no_snapshot_context_235.erase("hand_counts")
	var no_snapshot_report_235: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", no_snapshot_context_235)
	check(bool(no_snapshot_report_235.get("allow", false)) == bool(fallback_report_235.get("allow", false)), "missing hand-count snapshot keeps the live fallback")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
