extends SceneTree
## Round 246: claim discipline reuses the feed score already collected for the target.

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
	print("=== ai_play_round246 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["melds"] = [["4W", "4W", "4W"]]
	scene.players[0]["discards"] = ["1W", "7W"]
	var visible_counts_246: Array = scene.make_empty_tile_counts()
	var tile_index_246: int = scene.tile_index("4W")
	visible_counts_246[tile_index_246] = 2
	var context_246: Dictionary = scene.make_ai_evaluation_context(1, visible_counts_246)
	var feed_report_246: Dictionary = {"details": [
		{"opponent": 0, "score": 14.0},
		{"opponent": 2, "score": 31.0},
	]}
	var pressure_fallback_246: float = scene.human_target_discard_pressure(1, "4W", 24.0, feed_report_246, 2, context_246)
	var pressure_snapshot_246: float = scene.human_target_discard_pressure(1, "4M", 24.0, feed_report_246, 2, context_246, tile_index_246, 14.0)
	check(is_equal_approx(pressure_snapshot_246, pressure_fallback_246), "feed-score snapshot preserves human-target pressure")

	var pressure_report_246: Dictionary = {
		"discard": "4M",
		"tile_index": tile_index_246,
		"risk": 24.0,
		"safety": "筋",
		"feed_report": feed_report_246,
	}
	var difficulty_246: int = int(context_246.get("discard_report_difficulty", -1))
	var expected_feed_246: float = max(14.0, scene.human_target_discard_penalty_from_pressure(pressure_fallback_246, difficulty_246) * 0.55)
	var discipline_246: Dictionary = scene.human_claim_discipline_report(1, "chi", 0, 2, 2, 0.0, pressure_report_246, 0, context_246)
	check(is_equal_approx(float(discipline_246.get("feed_human", -1.0)), expected_feed_246), "claim discipline keeps the single pressure result")
	check(str(discipline_246.get("reason", "")) != "", "claim discipline still publishes a decision reason")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
