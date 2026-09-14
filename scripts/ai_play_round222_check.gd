extends SceneTree
## Round 222: discard pressure reuses the candidate tile-index snapshot.

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


func legacy_same_suit_pressure(scene, seat: int, tile: String) -> bool:
	var index: int = scene.tile_index(tile)
	if index < 0 or index >= 27 or seat < 0 or seat >= scene.players.size():
		return false
	var suit := int(index / 9)
	var count := 0
	for discarded in scene.players[seat]["discards"]:
		var discarded_index: int = scene.tile_index(str(discarded))
		if discarded_index >= 0 and discarded_index < 27 and int(discarded_index / 9) == suit:
			count += 1
	return count >= 3


func run() -> void:
	print("=== ai_play_round222 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[1]["discards"] = ["1W", "2W", "3W", "E"]

	var candidate_index: int = scene.tile_index("4W")
	var expected: bool = legacy_same_suit_pressure(scene, 1, "4W")
	var fallback: bool = scene.same_suit_pressure(1, "4W")
	var explicit: bool = scene.same_suit_pressure(1, "4W", {}, candidate_index)
	check(fallback == expected, "same-suit pressure preserves its direct fallback result")
	check(explicit == expected, "same-suit pressure preserves its explicit tile-index result")
	check(scene.same_suit_pressure(1, "4M", {}, candidate_index) == expected, "same-suit pressure preserves normalized aliases")
	check(not scene.same_suit_pressure(1, "ZZ"), "same-suit pressure keeps invalid-tile behavior")

	var visible_counts: Array = scene.make_empty_tile_counts()
	var pressure: float = scene.discard_pressure_score("4W", 0, visible_counts)
	check(pressure >= 1.2, "discard pressure retains the same-suit contribution")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
