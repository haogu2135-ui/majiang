extends SceneTree
## Round 130: report and threat cache keys reuse one wall-count snapshot.

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
	print("=== ai_play_round130 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.wall.clear()
	for _i in range(60):
		scene.wall.append("1B")

	var visible_counts: Array = scene.visible_tile_counts_shared()
	var wall_snapshot: int = scene.get_wall_count()
	print("--- A) threat table key snapshot ---")
	var default_threat_key: String = scene.threat_report_table_state_cache_key(0, visible_counts)
	var snapshot_threat_key: String = scene.threat_report_table_state_cache_key(0, visible_counts, "", wall_snapshot)
	check(default_threat_key != "" and default_threat_key == snapshot_threat_key, "threat table key is unchanged with the explicit wall snapshot")

	print("--- B) evaluation context reuses the same key input ---")
	var eval_context: Dictionary = scene.make_ai_evaluation_context(0, visible_counts)
	check(int(eval_context.get("discard_report_wall_count", -1)) == wall_snapshot, "evaluation context captures the wall before key construction")
	check(str(eval_context.get("threat_cache_state_key", "")) == snapshot_threat_key, "evaluation context threat key reuses its wall snapshot")

	print("--- C) discard report key snapshot ---")
	var default_report_key: String = scene.ai_report_cache_key(1, visible_counts)
	var snapshot_report_key: String = scene.ai_report_cache_key(1, visible_counts, wall_snapshot)
	check(default_report_key != "" and default_report_key == snapshot_report_key, "discard report key is unchanged with the explicit wall snapshot")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
