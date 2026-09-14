extends SceneTree
## Round 216: deferred AI assistance reuses one enable-state snapshot.

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
	print("=== ai_play_round216 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 0
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "2T", "3T", "5B", "E"]
	scene.wall.clear()
	for _i in range(60):
		scene.wall.append("1B")

	scene.ai_assist_enabled = true
	scene.current_human_advice = []
	scene.current_seat_threat_reports = {}
	scene.update_ai_assistance_async()
	check(not scene.current_human_advice.is_empty(), "enabled assistance still commits the deferred discard advice")

	scene.ai_assist_enabled = false
	scene.current_human_advice = []
	scene.current_seat_threat_reports = {"sentinel": true}
	scene.update_ai_assistance_async()
	check(not scene.current_human_advice.is_empty(), "disabled assistance keeps the existing deferred report calculation")
	check(bool(scene.current_seat_threat_reports.get("sentinel", false)), "disabled assistance preserves the existing threat display")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
