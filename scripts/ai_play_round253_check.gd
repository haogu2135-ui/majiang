extends SceneTree
## Round 253: scoring-meld validation resolves the first tile once.

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
	print("=== ai_play_round253 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var source_253 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	check(source_253.contains("var first_index := -1"), "scoring-meld validation captures the first index in its single pass")
	check(not source_253.contains('var first_index = tile_index(str(meld[0]))'), "scoring-meld validation avoids the duplicate first-tile lookup")
	check(scene.is_valid_scoring_meld(["4W", "4W", "4W"]), "triplet validation preserves valid scoring melds")
	check(scene.is_valid_scoring_meld(["4M", "5M", "6M"]), "sequence validation preserves normalized aliases")
	check(not scene.is_valid_scoring_meld(["4W", "5W", "6T"]), "mixed-suit sequences remain invalid")
	check(not scene.is_valid_scoring_meld(["ZZ", "ZZ", "ZZ"]), "invalid scoring meld tiles remain rejected")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
