extends SceneTree
## Round 233: self-gang reports reuse their captured tile classification.

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
	print("=== ai_play_round233 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["E", "E", "E", "E", "1W", "2W", "3W", "4T", "5T", "6T", "7B", "8B", "9B"]
	var visible_counts_233: Array = scene.make_empty_tile_counts()
	var context_233: Dictionary = scene.make_ai_evaluation_context(0, visible_counts_233)
	var honor_report_233: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", context_233)
	check(int(honor_report_233.get("tile_index", -2)) == scene.tile_index("E"), "self-gang reports publish the canonical tile index")
	check(bool(honor_report_233.get("is_honor_tile", false)), "self-gang reports retain honor classification")
	check(bool(honor_report_233.get("is_terminal_or_honor", false)), "self-gang reports retain terminal/honor classification")
	var honor_fallback_report_233: Dictionary = honor_report_233.duplicate(true)
	honor_fallback_report_233.erase("tile_index")
	honor_fallback_report_233.erase("is_honor_tile")
	honor_fallback_report_233.erase("is_terminal_or_honor")
	var honor_snapshot_score_233: float = scene.ai_self_gang_action_score(honor_report_233)
	var honor_fallback_score_233: float = scene.ai_self_gang_action_score(honor_fallback_report_233)
	check(is_equal_approx(honor_snapshot_score_233, honor_fallback_score_233), "honor self-gang score preserves the legacy fallback")

	var terminal_report_233: Dictionary = honor_report_233.duplicate(true)
	terminal_report_233["tile"] = "1W"
	terminal_report_233["tile_index"] = scene.tile_index("1W")
	terminal_report_233["is_honor_tile"] = false
	terminal_report_233["is_terminal_or_honor"] = true
	var terminal_fallback_report_233: Dictionary = terminal_report_233.duplicate(true)
	terminal_fallback_report_233.erase("tile_index")
	terminal_fallback_report_233.erase("is_honor_tile")
	terminal_fallback_report_233.erase("is_terminal_or_honor")
	check(is_equal_approx(scene.ai_self_gang_action_score(terminal_report_233), scene.ai_self_gang_action_score(terminal_fallback_report_233)), "terminal self-gang score preserves the legacy fallback")

	var invalid_report_233: Dictionary = {"tile": "ZZ", "gang_kind": "concealed"}
	var invalid_snapshot_report_233: Dictionary = invalid_report_233.duplicate(true)
	invalid_snapshot_report_233["tile_index"] = -1
	invalid_snapshot_report_233["is_honor_tile"] = false
	invalid_snapshot_report_233["is_terminal_or_honor"] = false
	check(is_equal_approx(scene.ai_self_gang_action_score(invalid_report_233), scene.ai_self_gang_action_score(invalid_snapshot_report_233)), "invalid self-gang tiles retain the fallback score")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
