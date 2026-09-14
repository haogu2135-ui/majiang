extends SceneTree
## Round 126: claim reports reuse the shared wall-count snapshot.

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
	print("=== ai_play_round126 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.wall = scene.make_wall()

	print("--- A) claim context carries the wall snapshot ---")
	var claim_context: Dictionary = scene.make_ai_claim_context(1, scene.visible_tile_counts_shared())
	var eval_context: Dictionary = claim_context.get("eval_context", {})
	var wall_count: int = scene.get_wall_count()
	check(int(eval_context.get("discard_report_wall_count", -1)) == wall_count, "claim context carries the current wall count")

	print("--- B) explicit wall input preserves claim discipline ---")
	var fallback_report: Dictionary = scene.wall_draw_claim_discipline_report(1, "chi", 3, 3, 0.0, 0)
	var snapshot_report: Dictionary = scene.wall_draw_claim_discipline_report(1, "chi", 3, 3, 0.0, 0, wall_count)
	check(fallback_report == snapshot_report, "claim discipline keeps the live fallback result with a wall snapshot")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
