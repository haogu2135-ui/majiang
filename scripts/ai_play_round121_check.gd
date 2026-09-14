extends SceneTree
## Round 121: evaluation contexts reuse their visible-count compact key.

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
	print("=== ai_play_round121 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.wall = scene.make_wall()

	print("--- A) threat-key override ---")
	var visible_counts: Array = scene.visible_tile_counts_shared()
	var visible_key: String = scene.counts_compact_key(visible_counts)
	var default_key: String = scene.threat_report_table_state_cache_key(0, visible_counts)
	var override_key: String = scene.threat_report_table_state_cache_key(0, visible_counts, visible_key)
	check(default_key != "" and default_key == override_key, "explicit visible-count key preserves the threat cache key")

	print("--- B) evaluation context reuse ---")
	var context: Dictionary = scene.make_ai_evaluation_context(0, visible_counts)
	check(str(context.get("visible_counts_key", "")) == visible_key, "evaluation context stores the compact visible-count key")
	check(str(context.get("threat_cache_state_key", "")) == override_key, "evaluation context passes the same key to threat caching")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
