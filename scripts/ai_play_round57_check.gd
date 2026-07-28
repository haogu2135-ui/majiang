extends SceneTree
## Round 57: discard and temporary furiten must cover every current ron wait.
var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(cond: bool, msg: String) -> void:
	if cond:
		print("  OK  | %s" % msg)
	else:
		print("  FAIL| %s" % msg)
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


func two_sided_wait_hand() -> Array:
	# 1W completes 123/234/567/888/EE, while 4W completes 234/234/567/888/EE.
	return ["2W", "3W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "8W", "8W", "E", "E"]


func reset_round(scene) -> void:
	scene.players = [make_player("Self"), make_player("Source"), make_player("P2"), make_player("P3")]
	scene.mode = "offline"
	scene.offline_phase = "resolving"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 1
	scene.offline_passed_win_tiles.clear()
	scene.players[0]["hand"] = two_sided_wait_hand()


func run() -> void:
	print("=== ai_play_round57 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.offline_sim_quiet = true
	scene.setup_tile_order()

	print("--- A) a river tile in one wait blocks every ron wait ---")
	reset_round(scene)
	scene.players[0]["discards"] = ["1W"]
	check(scene.can_win_for_seat(0, "1W") and scene.can_win_for_seat(0, "4W"), "fixture has two structural ron waits")
	check(scene.is_discard_furiten(0, "4W"), "discarded 1W marks the alternate 4W wait as furiten")
	check(not scene.can_ron_for_seat(0, "1W") and not scene.can_ron_for_seat(0, "4W"), "discard furiten rejects every ron wait")
	check(not scene.get_claim_options(0, 1, "4W").has("hu"), "claim options hide alternate-wait ron during discard furiten")

	print("--- B) passing one win temporarily blocks the alternate wait too ---")
	reset_round(scene)
	check(scene.can_ron_for_seat(0, "1W") and scene.can_ron_for_seat(0, "4W"), "both waits are ron-eligible before a pass")
	scene.record_passed_win_tile(0, "1W")
	check(scene.is_passed_win_tile(0, "4W"), "temporary furiten applies across the current waits")
	check(not scene.can_ron_for_seat(0, "4W"), "passed 1W blocks alternate 4W ron")
	var ai_report = scene.ai_ron_decision_report(0, "4W")
	check(not bool(ai_report.get("accept", true)) and str(ai_report.get("reason", "")) == "过水", "AI report labels alternate-wait temporary furiten")
	var reset_wall: Array[String] = ["9B"]
	scene.wall = reset_wall
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.offline_turn_needs_draw = true
	check(scene.draw_tile_for(0, false) == "9B", "fixture advances through a real self draw")
	scene.players[0]["hand"].erase("9B")
	check(not scene.is_passed_win_tile(0, "4W") and scene.can_ron_for_seat(0, "4W"), "next self draw clears temporary furiten for all waits")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
