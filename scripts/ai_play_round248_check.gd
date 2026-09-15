extends SceneTree
## Round 248: tsumo continuation risk checks reuse the drawn tile index.

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
	print("=== ai_play_round248 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.current_seat = 3
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_last_draw = {"seat": 3, "tile": "2W", "source": "normal", "wall_empty": false, "serial": 248}
	scene.offline_self_draw_ready = {"seat": 3, "tile": "2W", "serial": 248}
	scene.players[3]["hand"] = ["2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W", "2T", "3T", "4T", "2W"]

	var source_248 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	check(source_248.contains("deal_in_risk_score(normalized_drawn_tile, seat, continue_eval_context, continue_visible_counts, drawn_index)"), "tsumo continuation forwards the normalized drawn index to deal-in risk")
	check(source_248.contains("discard_feed_risk_report(normalized_drawn_tile, seat, continue_visible_counts, continue_eval_context, drawn_index)"), "tsumo continuation forwards the normalized drawn index to feed risk")
	var decision_248: Dictionary = scene.ai_tsumo_decision_report(3, "2W")
	check(bool(decision_248.get("win_valid", false)) and decision_248.has("reason"), "tsumo continuation keeps a valid decision report")

	var visible_248: Array = scene.visible_tile_counts_shared()
	var context_248: Dictionary = scene.make_ai_evaluation_context(3, visible_248)
	var index_248: int = scene.tile_index_normalized("2W")
	var risk_248: float = scene.deal_in_risk_score("2W", 3, context_248, visible_248, index_248)
	var feed_248: Dictionary = scene.discard_feed_risk_report("2W", 3, visible_248, context_248, index_248)
	check(index_248 >= 0 and risk_248 >= 0.0 and typeof(feed_248) == TYPE_DICTIONARY, "explicit continuation index keeps bounded risk outputs")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
