extends SceneTree
## Round 230: discard reason text reuses the candidate tile index.

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
	print("=== ai_play_round230 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var original_counts: Array = scene.tile_counts(["1W", "2W", "3W", "4T", "5T", "6T", "E"])
	var candidate_index: int = scene.tile_index("4W")
	var fallback_isolated: bool = scene.is_discard_isolated("4W", [], original_counts)
	var explicit_isolated: bool = scene.is_discard_isolated("4W", [], original_counts, candidate_index)
	check(fallback_isolated == explicit_isolated, "isolated-discard detection preserves the explicit tile index")

	var report: Dictionary = {
		"safety_label": "",
		"plan_label": "标准",
		"shanten": 3,
		"shape_label": "",
		"wait_value": 0.0,
	}
	var reason_fallback: String = scene.discard_reason_label("4W", [], report, original_counts)
	var reason_explicit: String = scene.discard_reason_label("4W", [], report, original_counts, candidate_index)
	check(reason_fallback == reason_explicit, "discard reason text preserves the explicit tile index")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
