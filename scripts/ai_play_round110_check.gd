extends SceneTree
## Round 110: validated AI wins skip duplicate scoring validation.

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
	print("=== ai_play_round110 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_hand_number = 1
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.wall = scene.make_wall()
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL

	var tenpai: Array = ["2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W", "2T", "3T", "4T"]
	var win_hand: Array = tenpai.duplicate()
	win_hand.append("2W")

	print("--- A) ron scoring reuses the already validated count state ---")
	scene.players[1]["hand"] = tenpai.duplicate()
	scene.players[0]["discards"] = ["2W"]
	scene.last_discard = "2W"
	scene.last_discard_seat = 0
	scene.offline_phase = "pending_claim"
	var ron_counts: Array = scene.tile_counts(tenpai)
	var ron_winning_counts: Array = ron_counts.duplicate()
	ron_winning_counts[scene.tile_index_normalized("2W")] += 1
	var ron_valid: bool = scene.can_win_for_seat_from_counts(1, ron_counts, "2W")
	check(ron_valid, "fixture provides a legal ron state")
	var ron_checked: Dictionary = scene.calculate_win_score_from_tiles(1, [], false, "", false, ron_winning_counts, win_hand.size())
	var ron_assumed: Dictionary = scene.calculate_win_score_from_tiles(1, [], false, "", true, ron_winning_counts, win_hand.size())
	check(ron_checked == ron_assumed, "assumed-complete ron scoring matches validated scoring")
	var ron_key_before: String = scene.counts_compact_key(ron_counts)
	var ron_report: Dictionary = scene.ai_ron_decision_report(1, "2W")
	check(int(ron_report.get("fan", -1)) == int(ron_checked.get("fan", -2)) and int(ron_report.get("points", -1)) == int(ron_checked.get("points", -2)), "ron report preserves validated score")
	check(scene.counts_compact_key(ron_counts) == ron_key_before, "ron report leaves the source count vector unchanged")

	print("--- B) tsumo scoring reuses the already validated count state ---")
	scene.current_seat = 2
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_last_draw = {"seat": 2, "tile": "2W", "source": "normal", "wall_empty": false, "serial": 110}
	scene.offline_self_draw_ready = {"seat": 2, "tile": "2W", "serial": 110}
	scene.players[2]["hand"] = win_hand.duplicate()
	var tsumo_counts: Array = scene.tile_counts(win_hand)
	var tsumo_valid: bool = scene.can_win_for_seat_from_counts(2, tsumo_counts, "", true)
	check(tsumo_valid, "fixture provides a legal tsumo state")
	var tsumo_checked: Dictionary = scene.calculate_win_score_from_tiles(2, [], true, "", false, tsumo_counts, win_hand.size())
	var tsumo_assumed: Dictionary = scene.calculate_win_score_from_tiles(2, [], true, "", true, tsumo_counts, win_hand.size())
	check(tsumo_checked == tsumo_assumed, "assumed-complete tsumo scoring matches validated scoring")
	var tsumo_report: Dictionary = scene.ai_tsumo_decision_report(2, "2W")
	check(bool(tsumo_report.get("win_valid", false)) and int(tsumo_report.get("fan", -1)) == int(tsumo_checked.get("fan", -2)) and int(tsumo_report.get("points", -1)) == int(tsumo_checked.get("points", -2)), "tsumo report preserves validated score")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
