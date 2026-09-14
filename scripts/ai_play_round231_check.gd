extends SceneTree
## Round 231: targeted threat candidates derive route classes from one index.

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
	print("=== ai_play_round231 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["4W", "8W", "E", "5T"]
	scene.players[1]["discards"] = ["1W", "7W", "E"]

	var visible_counts: Array = scene.make_empty_tile_counts()
	var context: Dictionary = scene.make_ai_evaluation_context(0, visible_counts)
	var suit_safe_tiles: Array = scene.threat_safe_tile_labels(0, "suit", 0, 4, context, 1)
	var honor_safe_tiles: Array = scene.threat_safe_tile_labels(0, "honor", -1, 4, context, 1)
	check(suit_safe_tiles.size() <= 4, "suit threat candidates keep the requested bound")
	check(honor_safe_tiles.size() <= 4, "honor threat candidates keep the requested bound")
	check(suit_safe_tiles.has(scene.tile_label("4W")), "number candidates retain their suit classification")
	check(honor_safe_tiles.has(scene.tile_label("E")), "honor candidates retain their honor classification")

	var invalid_context: Dictionary = scene.make_ai_evaluation_context(0, visible_counts)
	var invalid_tiles: Array = scene.threat_safe_tile_labels(0, "honor", -1, 4, invalid_context, 1)
	check(invalid_tiles.size() <= 4, "targeted threat candidates preserve invalid-state bounds")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
