extends SceneTree
## Round 262: ron and tsumo alternate-wait probes reuse effective indexes.

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
	print("=== ai_play_round262 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var source_262 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var ron_start_262 := source_262.find("func ai_ron_decision_report")
	var ron_end_262 := source_262.find("func ai_tsumo_decision_report", ron_start_262)
	var ron_source_262 := source_262.substr(ron_start_262, ron_end_262 - ron_start_262)
	var tsumo_start_262 := source_262.find("func ai_tsumo_decision_report")
	var tsumo_end_262 := source_262.find("func ai_tsumo_continue_discard", tsumo_start_262)
	var tsumo_source_262 := source_262.substr(tsumo_start_262, tsumo_end_262 - tsumo_start_262)
	check(ron_source_262.contains("var wait_tile_indices: Dictionary = wait_metrics.get(\"tile_indices\", {})"), "ron captures effective-tile indexes")
	check(ron_source_262.contains("int(wait_tile_indices.get(wait_tile, -1))"), "ron alternate waits reuse captured indexes")
	check(tsumo_source_262.contains("var wait_tile_indices: Dictionary = wait_metrics.get(\"tile_indices\", {})"), "tsumo captures effective-tile indexes")
	check(tsumo_source_262.contains("int(wait_tile_indices.get(wait_tile, -1))"), "tsumo alternate waits reuse captured indexes")
	check(ron_source_262.contains("wait_index = tile_index_normalized(wait_tile)"), "ron keeps the direct-call fallback")
	check(tsumo_source_262.contains("wait_index = tile_index_normalized(wait_tile)"), "tsumo keeps the direct-call fallback")

	var tenpai_hand: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7B", "8B", "9B", "1T", "1T", "2T", "3T"]
	var hand_counts: Array = scene.tile_counts(tenpai_hand)
	var metrics: Dictionary = scene.effective_tile_metrics(tenpai_hand, 0, 1, 0, scene.make_empty_tile_counts(), hand_counts)
	var waits: Array = metrics.get("tiles", [])
	var indexes: Dictionary = metrics.get("tile_indices", {})
	check(waits.has("1T") and waits.has("4T"), "fixture exposes multiple alternate waits")
	check(int(indexes.get("1T", -1)) == scene.tile_index("1T") and int(indexes.get("4T", -1)) == scene.tile_index("4T"), "alternate waits carry canonical indexes")

	scene.offline_phase = "resolving"
	scene.players[1]["hand"] = tenpai_hand.duplicate()
	scene.players[1]["discards"] = []
	var ron_report: Dictionary = scene.ai_ron_decision_report(1, "4T")
	print("    ron=%s" % ron_report)
	check(int(ron_report.get("wait_variety", 0)) >= 2 and int(ron_report.get("points", 0)) > 0, "ron alternate-wait report remains valid")

	var tsumo_hand: Array = tenpai_hand.duplicate()
	tsumo_hand.append("1T")
	scene.current_seat = 3
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_last_draw = {"seat": 3, "tile": "1T", "source": "normal", "wall_empty": false, "serial": 262}
	scene.offline_self_draw_ready = {"seat": 3, "tile": "1T", "serial": 262}
	scene.players[3]["hand"] = tsumo_hand
	scene.players[3]["discards"] = []
	var tsumo_report: Dictionary = scene.ai_tsumo_decision_report(3, "1T")
	print("    tsumo=%s" % tsumo_report)
	check(bool(tsumo_report.get("win_valid", false)) and int(tsumo_report.get("wait_variety", 0)) >= 2, "tsumo alternate-wait report remains valid")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
