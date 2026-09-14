extends SceneTree
## Round 212: added-gang selection reads canonical tile counts by slot.

var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if condition:
		print("  OK  | %s" % message)
	else:
		print("  FAIL| %s" % message)
		failed = true


func make_player(hand: Array, melds: Array) -> Dictionary:
	return {
		"name": "P0",
		"hand": hand,
		"discards": [],
		"melds": melds,
		"flowers": 0,
		"flower_tiles": [],
		"score": 25000,
		"bot": true,
	}


func legacy_first_added_gang_tile(scene, seat: int) -> String:
	if seat < 0 or seat >= scene.players.size():
		return ""
	var hand_counts: Array = scene.tile_counts(scene.players[seat].get("hand", []))
	var triplet_tiles: Dictionary = {}
	for meld_value in scene.players[seat].get("melds", []):
		if typeof(meld_value) != TYPE_ARRAY:
			continue
		var meld: Array = meld_value
		if meld.size() != 3:
			continue
		var normalized: String = scene.normalize_tile_code(str(meld[0]))
		if normalized == "":
			continue
		var is_triplet := true
		for meld_index in range(1, meld.size()):
			if scene.normalize_tile_code(str(meld[meld_index])) != normalized:
				is_triplet = false
				break
		if is_triplet:
			triplet_tiles[normalized] = true
	for tile in scene.TILE_CODES:
		var normalized_tile := str(tile)
		var index: int = scene.tile_index_normalized(normalized_tile)
		if index >= 0 and int(hand_counts[index]) > 0 and triplet_tiles.has(normalized_tile):
			return tile
	return ""


func run() -> void:
	print("=== ai_play_round212 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true

	var cases: Array = [
		{
			"label": "single added gang candidate",
			"hand": ["3W"],
			"melds": [["3W", "3W", "3W"]],
			"expected": "3W",
		},
		{
			"label": "earliest candidate follows TILE_CODES order",
			"hand": ["9W", "2W"],
			"melds": [["9W", "9W", "9W"], ["2W", "2W", "2W"]],
			"expected": "2W",
		},
		{
			"label": "normalized alias triplet",
			"hand": ["5W"],
			"melds": [["5M", "5M", "5M"]],
			"expected": "5W",
		},
		{
			"label": "non-triplet meld is ignored",
			"hand": ["4W"],
			"melds": [["4W", "4W", "5W"]],
			"expected": "",
		},
		{
			"label": "missing hand tile is ignored",
			"hand": [],
			"melds": [["6W", "6W", "6W"]],
			"expected": "",
		},
	]
	for case in cases:
		scene.players = [make_player(case.get("hand", []), case.get("melds", []))]
		var actual: String = scene.first_added_gang_tile(0)
		var legacy: String = legacy_first_added_gang_tile(scene, 0)
		var expected := str(case.get("expected", ""))
		var label := str(case.get("label", "case"))
		check(actual == expected, "%s returns the expected tile" % label)
		check(actual == legacy, "%s preserves the legacy result" % label)

	scene.players = [make_player(["3W"], [["3W", "3W", "3W"]])]
	check(scene.first_added_gang_tile(-1) == "", "negative seat returns no added gang")
	check(scene.first_added_gang_tile(1) == "", "out-of-range seat returns no added gang")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
