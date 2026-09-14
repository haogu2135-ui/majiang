extends SceneTree
## Round 127: ron decisions reuse their normalized difficulty snapshot.

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
	print("=== ai_play_round127 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.offline_phase = "resolving"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[1]["hand"] = ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W"]

	print("--- A) normalized difficulty remains ron-stable ---")
	scene.ai_difficulty = scene.AI_DIFFICULTY_EASY
	var easy_report: Dictionary = scene.ai_ron_decision_report(1, "5W")
	scene.ai_difficulty = -100
	var clamped_easy_report: Dictionary = scene.ai_ron_decision_report(1, "5W")
	check(easy_report == clamped_easy_report, "an out-of-range easy value keeps the same ron decision")

	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var hard_report: Dictionary = scene.ai_ron_decision_report(1, "5W")
	scene.ai_difficulty = 100
	var clamped_hard_report: Dictionary = scene.ai_ron_decision_report(1, "5W")
	check(hard_report == clamped_hard_report, "an out-of-range hard value keeps the same ron decision")
	check(int(hard_report.get("fan", -1)) >= 0 and int(hard_report.get("points", -1)) >= 0, "ron report remains valid after difficulty reuse")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
