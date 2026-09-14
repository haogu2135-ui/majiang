extends SceneTree
## Round 265: full-straight checks reuse one temporary count vector.

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
	print("=== ai_play_round265 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var source_265 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	var start_265 := source_265.find("func full_straight_suit_from_counts")
	var end_265 := source_265.find("func full_straight_open_meld_group", start_265)
	var function_265 := source_265.substr(start_265, end_265 - start_265)
	check(function_265.contains("var concealed_counts: Array = concealed_counts_source.duplicate()"), "full-straight scoring allocates one work vector")
	check(function_265.contains("var consumed_indices: Array[int] = []"), "full-straight scoring tracks temporary decrements")
	check(function_265.contains("consumed_indices.append(index)"), "full-straight scoring records consumed slots")
	check(function_265.contains("for consumed_index in consumed_indices:"), "full-straight scoring restores the work vector")
	check(function_265.count("concealed_counts_source.duplicate()") == 1, "full-straight scoring avoids per-suit vector copies")

	var concealed_265: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T", "E", "E"]
	var concealed_counts_265: Array = scene.tile_counts(concealed_265)
	var concealed_key_265: String = scene.counts_compact_key(concealed_counts_265)
	check(scene.full_straight_suit_from_counts(0, concealed_counts_265) == 0, "concealed 123/456/789 remains recognized")
	check(scene.counts_compact_key(concealed_counts_265) == concealed_key_265, "full-straight probes restore caller counts")

	var false_positive_265: Array = ["1W", "1W", "1W", "2W", "2W", "2W", "3W", "4W", "5W", "6W", "7W", "7W", "8W", "9W"]
	var false_counts_265: Array = scene.tile_counts(false_positive_265)
	check(scene.full_straight_suit_from_counts(0, false_counts_265) == -1, "non-decomposable all-rank hand remains rejected")

	scene.players[0]["melds"] = [["1W", "2W", "3W"]]
	var exposed_265: Array = ["4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T", "E", "E"]
	var exposed_counts_265: Array = scene.tile_counts(exposed_265)
	check(scene.full_straight_suit_from_counts(0, exposed_counts_265) == 0, "exposed 123 plus concealed 456/789 remains recognized")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
