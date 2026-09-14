extends SceneTree
## Round 247: quiet discard evaluation forwards the captured candidate index.

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
	print("=== ai_play_round247 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.enable_offline_all_bot_mode(true, true)
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[1]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "3T", "E"]

	var source_247 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	check(source_247.contains("tile_risk_vector(cand, seat, visible_counts_snapshot, eval_context, idx)"), "quiet discard evaluation forwards its captured candidate index")
	var context_output_247: Dictionary = {}
	var reports_247: Array = scene.get_ai_discard_reports(1, [], context_output_247)
	check(reports_247.size() > 0, "quiet discard evaluation still produces candidate reports")
	if not reports_247.is_empty():
		var report_247: Dictionary = reports_247[0]
		var tile_247 := str(report_247.get("tile", ""))
		var index_247 := int(report_247.get("tile_index", -1))
		var visible_247: Array = scene.ai_context_visible_counts(context_output_247)
		var explicit_risk_247: Dictionary = scene.tile_risk_vector(tile_247, 1, visible_247, context_output_247, index_247)
		check(index_247 >= 0 and is_equal_approx(float(report_247.get("risk", -1.0)), float(explicit_risk_247.get("score", -2.0))), "quiet report risk remains aligned with the forwarded index")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
