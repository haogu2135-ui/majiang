extends SceneTree
## Round 106: AI tsumo validation is performed by the decision report once.

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


func set_draw_window(scene, seat: int, tile: String, serial: int) -> void:
	scene.current_seat = seat
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_last_draw = {"seat": seat, "tile": tile, "source": "normal", "wall_empty": false, "serial": serial}
	scene.offline_self_draw_ready = {"seat": seat, "tile": tile, "serial": serial}


func run() -> void:
	print("=== ai_play_round106 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.dealer_seat = 0

	print("--- A) report owns the valid self-draw decision ---")
	var complete_hand: Array = ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W", "5W"]
	scene.players[1]["hand"] = complete_hand.duplicate()
	set_draw_window(scene, 1, "5W", 106)
	var valid_report: Dictionary = scene.ai_tsumo_decision_report(1, "5W")
	check(bool(valid_report.get("win_valid", false)), "valid self-draw report exposes win_valid")
	check(str(valid_report.get("reason", "")) != "未成和", "valid self-draw is not rejected by the report")

	print("--- B) stale draw stays invalid without an outer win probe ---")
	var stale_report: Dictionary = scene.ai_tsumo_decision_report(1, "1W")
	check(not bool(stale_report.get("win_valid", true)) and str(stale_report.get("reason", "")) == "非当前摸牌", "stale tile remains explicitly invalid")

	print("--- C) self-draw minimum uses self-draw scoring ---")
	scene.offline_active_rule_variant = scene.RULE_VARIANT_GUANGDONG
	scene.dealer_seat = 1
	scene.players[1]["melds"] = [["1W", "2W", "3W"]]
	scene.players[1]["hand"] = ["4W", "5W", "6W", "7W", "8W", "9W", "2T", "3T", "4T", "E", "E"]
	set_draw_window(scene, 1, "E", 107)
	var counts: Array = scene.tile_counts(scene.players[1]["hand"])
	check(scene.can_win_for_seat(1), "dealer self-draw meets the Guangdong three-fan minimum")
	check(scene.can_win_for_seat_from_counts(1, counts, "", true), "count-based self-draw check keeps the self-draw fan")
	var guangdong_report: Dictionary = scene.ai_tsumo_decision_report(1, "E")
	check(bool(guangdong_report.get("win_valid", false)), "tsumo report applies the self-draw minimum")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
