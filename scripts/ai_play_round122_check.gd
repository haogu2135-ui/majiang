extends SceneTree
## Round 122: claim contexts retain the shared visible-count key.

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
	print("=== ai_play_round122 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.wall = scene.make_wall()
	scene.players[1]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E", "S", "S"]

	print("--- A) snapshot-free claim context ---")
	var context: Dictionary = scene.make_ai_claim_context(1)
	var eval_context: Dictionary = context.get("eval_context", {})
	var visible_counts: Array = eval_context.get("visible_counts", [])
	check(not visible_counts.is_empty() and str(eval_context.get("visible_counts_key", "")) == scene.counts_compact_key(visible_counts), "claim context retains the live visible-count key")

	print("--- B) explicit snapshot claim context ---")
	var explicit_counts: Array = scene.visible_tile_counts_shared()
	var explicit_context: Dictionary = scene.make_ai_claim_context(1, explicit_counts)
	var explicit_eval: Dictionary = explicit_context.get("eval_context", {})
	check(str(explicit_eval.get("visible_counts_key", "")) == scene.counts_compact_key(explicit_counts), "claim context retains the supplied visible-count key")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
