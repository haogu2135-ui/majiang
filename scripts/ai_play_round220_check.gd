extends SceneTree
## Round 220: suji safety reuses the candidate tile-index snapshot.

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


func legacy_suji_safe(scene, tile: String, opponent: int) -> bool:
	if not scene.is_number_tile(tile) or opponent < 0 or opponent >= scene.players.size():
		return false
	var index: int = scene.tile_index(tile)
	if index < 0 or index >= 27:
		return false
	var rank := index % 9
	if rank <= 2:
		return scene.opponent_discard_tile_count(opponent, scene.TILE_CODES[index + 3]) > 0
	if rank >= 6:
		return scene.opponent_discard_tile_count(opponent, scene.TILE_CODES[index - 3]) > 0
	return scene.opponent_discard_tile_count(opponent, scene.TILE_CODES[index - 3]) > 0 and scene.opponent_discard_tile_count(opponent, scene.TILE_CODES[index + 3]) > 0


func run() -> void:
	print("=== ai_play_round220 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var cases: Array = [
		{"tile": "1W", "discards": ["4W"]},
		{"tile": "4W", "discards": ["1W", "7W"]},
		{"tile": "7W", "discards": ["4W"]},
		{"tile": "9W", "discards": ["6W"]},
		{"tile": "E", "discards": ["4W"]},
		{"tile": "ZZ", "discards": ["4W"]},
	]
	for case in cases:
		scene.players[1]["discards"] = case.get("discards", [])
		var tile: String = str(case.get("tile", ""))
		var expected: bool = legacy_suji_safe(scene, tile, 1)
		var actual: bool = scene.is_suji_safe_against_opponent(tile, 1)
		check(actual == expected, "%s preserves the legacy suji result" % tile)

	scene.players[1]["discards"] = ["1W", "7W", "2W", "8W", "3W", "9W"]
	check(scene.is_suji_safe_tile("4M", 0) == scene.is_suji_safe_against_opponent("4W", 1), "table-level suji safety preserves normalized aliases")
	check(not scene.is_suji_safe_against_opponent("4W", -1), "suji safety keeps invalid-opponent behavior")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
