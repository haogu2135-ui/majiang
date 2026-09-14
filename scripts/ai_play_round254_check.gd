extends SceneTree
## Round 254: exposed full-straight grouping reuses the first tile index.

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
	print("=== ai_play_round254 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var source_254 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	check(source_254.contains("full_straight_open_meld_group(meld, meld_suit, meld_first_index)"), "full-straight detection forwards the existing first-tile index")
	check(source_254.contains("first_index_snapshot: int = -2"), "exposed-meld grouping keeps a direct-call fallback")
	var first_index_254: int = scene.tile_index("1W")
	var fallback_group_254: int = scene.full_straight_open_meld_group(["1W", "2W", "3W"], 0)
	var explicit_group_254: int = scene.full_straight_open_meld_group(["1M", "2M", "3M"], 0, first_index_254)
	check(fallback_group_254 == 0 and explicit_group_254 == fallback_group_254, "exposed sequence grouping preserves normalized aliases")
	check(scene.full_straight_open_meld_group(["4W", "4W", "4W"], 0, scene.tile_index("4W")) == -1, "triplet melds remain outside sequence groups")
	check(scene.full_straight_open_meld_group(["1W", "2W", "3T"], 0, first_index_254) == -1, "mixed-suit exposed melds remain rejected")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
