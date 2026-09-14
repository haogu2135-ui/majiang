extends SceneTree
## Round 123: tsumo decisions reuse their normalized difficulty snapshot.

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
	print("=== ai_play_round123 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.wall = scene.make_wall()
	scene.current_seat = 3
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_last_draw = {"seat": 3, "tile": "2W", "source": "normal", "wall_empty": false, "serial": 123}
	scene.offline_self_draw_ready = {"seat": 3, "tile": "2W", "serial": 123}
	scene.players[3]["hand"] = ["2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W", "2T", "3T", "4T", "2W"]

	print("--- A) normalized difficulty remains decision-stable ---")
	scene.ai_difficulty = scene.AI_DIFFICULTY_EASY
	var easy_decision: Dictionary = scene.ai_tsumo_decision_report(3, "2W")
	scene.ai_difficulty = -100
	var clamped_easy_decision: Dictionary = scene.ai_tsumo_decision_report(3, "2W")
	check(easy_decision == clamped_easy_decision, "an out-of-range easy value keeps the same tsumo decision")

	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var hard_decision: Dictionary = scene.ai_tsumo_decision_report(3, "2W")
	scene.ai_difficulty = 100
	var clamped_hard_decision: Dictionary = scene.ai_tsumo_decision_report(3, "2W")
	check(hard_decision == clamped_hard_decision, "an out-of-range hard value keeps the same tsumo decision")
	check(int(hard_decision.get("fan", -1)) >= 0 and int(hard_decision.get("points", -1)) >= 0, "tsumo report remains valid after difficulty reuse")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
