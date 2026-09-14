extends SceneTree
## Round 221: kabe safety reuses the candidate tile-index snapshot.

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


func legacy_kabe_safe(scene, tile: String, opponent: int, visible_counts: Array) -> bool:
	if not scene.is_number_tile(tile) or opponent < 0 or opponent >= scene.players.size():
		return false
	var index: int = scene.tile_index(tile)
	if index < 0 or index >= 27 or index >= visible_counts.size():
		return false
	var rank := index % 9
	if rank > 0 and int(visible_counts[index - 1]) >= 3:
		return true
	if rank < 8 and int(visible_counts[index + 1]) >= 3:
		return true
	return false


func run() -> void:
	print("=== ai_play_round221 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[1]["discards"] = ["E", "S", "W", "N", "P", "F"]

	var visible_counts: Array = scene.make_empty_tile_counts()
	var tile_index_221: int = scene.tile_index("4W")
	visible_counts[scene.tile_index("3W")] = 3
	var expected: bool = legacy_kabe_safe(scene, "4W", 1, visible_counts)
	var fallback: bool = scene.is_kabe_safe_against_opponent("4W", 1, visible_counts)
	var explicit: bool = scene.is_kabe_safe_against_opponent("4W", 1, visible_counts, {}, tile_index_221)
	check(fallback == expected, "kabe safety preserves its direct fallback result")
	check(explicit == expected, "kabe safety preserves its explicit tile-index result")
	check(scene.is_kabe_safe_tile("4M", 0, visible_counts, {}, tile_index_221) == expected, "table-level kabe safety preserves normalized aliases")
	check(not scene.is_kabe_safe_against_opponent("ZZ", 1, visible_counts), "invalid kabe tiles retain the legacy rejection")

	visible_counts[tile_index_221] = 3
	check(not scene.is_kabe_safe_tile("4W", 0, visible_counts, {}, tile_index_221), "visible candidate tiles retain the kabe rejection")
	check(not scene.is_kabe_safe_against_opponent("4W", -1, visible_counts, {}, tile_index_221), "kabe safety keeps invalid-opponent behavior")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
