extends SceneTree
## Round 250: claim feed-report fallback forwards the forced tile index.

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
	print("=== ai_play_round250 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_all_bot_mode = true
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["melds"] = [["4W", "4W", "4W"]]
	scene.players[0]["discards"] = ["1W", "7W"]

	var source_250 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	check(source_250.contains("discard_feed_risk_report(forced_tile, seat, claim_visible_counts, eval_context, forced_tile_index)"), "claim discipline forwards the forced tile index on feed-report fallback")
	var visible_250: Array = scene.make_empty_tile_counts()
	var index_250: int = scene.tile_index("4W")
	visible_250[index_250] = 2
	var context_250: Dictionary = scene.make_ai_evaluation_context(1, visible_250)
	var fallback_pressure_250: Dictionary = {"discard": "4W", "tile_index": index_250, "risk": 24.0, "safety": "筋", "feed_report": {}}
	var explicit_feed_250: Dictionary = scene.discard_feed_risk_report("4W", 1, visible_250, context_250, index_250)
	var snapshot_pressure_250: Dictionary = fallback_pressure_250.duplicate(true)
	snapshot_pressure_250["feed_report"] = explicit_feed_250
	var fallback_report_250: Dictionary = scene.human_claim_discipline_report(1, "chi", 0, 2, 2, 0.0, fallback_pressure_250, 0, context_250)
	var snapshot_report_250: Dictionary = scene.human_claim_discipline_report(1, "chi", 0, 2, 2, 0.0, snapshot_pressure_250, 0, context_250)
	check(is_equal_approx(float(fallback_report_250.get("feed_human", -1.0)), float(snapshot_report_250.get("feed_human", -2.0))), "claim feed fallback preserves the feed-human score")
	check(bool(fallback_report_250.get("decline", false)) == bool(snapshot_report_250.get("decline", true)) and str(fallback_report_250.get("reason", "")) == str(snapshot_report_250.get("reason", "")), "claim feed fallback preserves the decision")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
