extends SceneTree
## Round 119: targeted threat cards skip redundant all-opponent reports.

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
	print("=== ai_play_round119 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.wall = scene.make_wall()
	scene.players[0]["hand"] = ["1W", "2W", "3W", "5W", "7W", "9W", "E", "S"]
	scene.players[1]["discards"] = ["1W", "4W", "7W"]

	print("--- A) targeted and general paths ---")
	var context: Dictionary = scene.make_ai_evaluation_context(0, scene.visible_tile_counts_shared())
	var targeted_labels: Array = scene.threat_safe_tile_labels(0, "suit", 0, 3, context, 1)
	var general_labels: Array = scene.threat_safe_tile_labels(0, "suit", 0, 3, context)
	check(targeted_labels.size() <= 3 and general_labels.size() <= 3, "targeted and general threat cards remain bounded")
	check(targeted_labels == scene.threat_safe_tile_labels(0, "suit", 0, 3, context, 1), "targeted threat-card results are deterministic")
	var invalid_target_labels: Array = scene.threat_safe_tile_labels(0, "suit", 0, 3, context, 0)
	check(invalid_target_labels == general_labels, "self-targeted cards retain the general threat path")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
