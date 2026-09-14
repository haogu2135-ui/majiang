extends SceneTree
## Round 120: threat/readiness calculations reuse one wall snapshot.

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
	print("=== ai_play_round120 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.wall = scene.make_wall()
	scene.players[1]["discards"] = ["1W", "4W", "7W"]
	scene.players[1]["melds"] = [["E", "E", "E"]]

	print("--- A) threat cache key ---")
	var first_key: String = scene.threat_report_table_state_cache_key(0, scene.visible_tile_counts_shared())
	var repeated_key: String = scene.threat_report_table_state_cache_key(0, scene.visible_tile_counts_shared())
	check(first_key != "" and first_key == repeated_key, "threat cache key is stable across repeated reads")

	print("--- B) readiness score ---")
	var readiness: float = scene.opponent_readiness_score_from_plan(1, 12.0)
	check(readiness >= 0.0, "plan-based readiness remains valid with a wall snapshot")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
