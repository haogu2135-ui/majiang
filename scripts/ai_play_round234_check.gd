extends SceneTree
## Round 234: self-gang selectors pass their existing tile index to reports.

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
	print("=== ai_play_round234 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["E", "E", "E", "E", "1W", "2W", "3W", "4T", "5T", "6T", "7B", "8B", "9B"]
	var visible_counts_234: Array = scene.make_empty_tile_counts()
	var context_234: Dictionary = scene.make_ai_evaluation_context(0, visible_counts_234)
	var honor_index_234: int = scene.tile_index("E")
	var honor_fallback_234: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", context_234)
	var honor_snapshot_234: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", context_234, honor_index_234)
	check(int(honor_snapshot_234.get("tile_index", -2)) == honor_index_234, "explicit self-gang index is retained in the report")
	check(bool(honor_snapshot_234.get("is_honor_tile", false)), "explicit honor index keeps classification")
	check(bool(honor_snapshot_234.get("allow", false)) == bool(honor_fallback_234.get("allow", false)) and str(honor_snapshot_234.get("reason", "")) == str(honor_fallback_234.get("reason", "")), "explicit concealed-gang index preserves the decision")
	check(is_equal_approx(float(honor_snapshot_234.get("score", 0.0)), float(honor_fallback_234.get("score", 0.0))), "explicit concealed-gang index preserves the score")

	scene.players[0]["hand"] = ["1W", "1W", "1W", "1W", "2W", "3W", "4W", "4T", "5T", "6T", "7B", "8B", "9B"]
	var terminal_index_234: int = scene.tile_index("1W")
	var terminal_fallback_234: Dictionary = scene.build_ai_self_gang_report(0, "1W", "concealed", context_234)
	var terminal_snapshot_234: Dictionary = scene.build_ai_self_gang_report(0, "1W", "concealed", context_234, terminal_index_234)
	check(int(terminal_snapshot_234.get("tile_index", -2)) == terminal_index_234 and bool(terminal_snapshot_234.get("is_terminal_or_honor", false)), "explicit terminal index keeps classification")
	check(bool(terminal_snapshot_234.get("allow", false)) == bool(terminal_fallback_234.get("allow", false)) and is_equal_approx(float(terminal_snapshot_234.get("score", 0.0)), float(terminal_fallback_234.get("score", 0.0))), "explicit terminal index preserves the legacy report")

	var invalid_fallback_234: Dictionary = scene.build_ai_self_gang_report(0, "ZZ", "concealed", context_234)
	var invalid_snapshot_234: Dictionary = scene.build_ai_self_gang_report(0, "ZZ", "concealed", context_234, -1)
	check(int(invalid_snapshot_234.get("tile_index", -2)) == -1 and bool(invalid_snapshot_234.get("allow", false)) == bool(invalid_fallback_234.get("allow", false)), "invalid explicit index keeps the legacy rejection")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
