extends SceneTree
## Round 267: effective-tile probes share one short-lived shanten memo.

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


func independent_effective_tile_metrics(scene, hand: Array, open_melds: int, known_shanten: int, visible_counts: Array, hand_counts: Array) -> Dictionary:
	var working_counts: Array = hand_counts.duplicate()
	var current_shanten := known_shanten
	if current_shanten == 99:
		current_shanten = scene.calculate_min_shanten_from_counts(working_counts, open_melds)
	var next_tile_count := hand.size() + 1
	var total := 0
	var variety := 0
	var tiles: Array[String] = []
	var remaining_by_tile: Dictionary = {}
	var tile_indices: Dictionary = {}
	for index in range(scene.TILE_CODES.size()):
		var remaining: int = scene.remaining_tile_count_from_counts(index, visible_counts, working_counts)
		if remaining <= 0:
			continue
		working_counts[index] = int(working_counts[index]) + 1
		var improves := false
		if current_shanten <= 0:
			improves = scene.is_complete_hand_from_counts(working_counts, next_tile_count, open_melds)
		else:
			# Force each candidate through a clean final-result cache so this is an
			# independent probe rather than a warmed copy of the batch scan.
			scene.clear_shanten_cache()
			improves = scene.calculate_min_shanten_from_counts(working_counts, open_melds) < current_shanten
		working_counts[index] = int(working_counts[index]) - 1
		if improves:
			var tile := str(scene.TILE_CODES[index])
			total += remaining
			variety += 1
			tiles.append(tile)
			remaining_by_tile[tile] = remaining
			tile_indices[tile] = index
	scene.sort_effective_tiles_by_remaining(tiles, remaining_by_tile)
	return {
		"count": total,
		"variety": variety,
		"tiles": tiles,
		"remaining_by_tile": remaining_by_tile,
		"tile_indices": tile_indices,
	}


func run() -> void:
	print("=== ai_play_round267 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var source_267 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var shanten_start_267 := source_267.find("func calculate_min_shanten_from_counts")
	var shanten_end_267 := source_267.find("func effective_tile_count", shanten_start_267)
	var shanten_source_267 := source_267.substr(shanten_start_267, shanten_end_267 - shanten_start_267)
	check(shanten_source_267.contains("func calculate_min_shanten_from_counts_with_memo"), "shanten exposes a shared-memo entry point")
	var effective_start_267 := source_267.find("func effective_tile_metrics")
	var effective_end_267 := source_267.find("func touch_effective_tiles_cache_key", effective_start_267)
	var effective_source_267 := source_267.substr(effective_start_267, effective_end_267 - effective_start_267)
	check(effective_source_267.contains("var effective_tile_search_memo: Dictionary = {}"), "effective-tile scan allocates one batch memo")
	check(effective_source_267.contains("calculate_min_shanten_from_counts_with_memo(hand_counts, open_melds, \"\", effective_tile_search_memo)"), "candidate probes reuse the batch memo")

	var hand_267: Array = ["1W", "2W", "4W", "5W", "7W", "8W", "2T", "3T", "5T", "6T", "8T", "9T", "E", "S"]
	var counts_267: Array = scene.tile_counts(hand_267)
	var key_267: String = scene.counts_compact_key(counts_267)
	var normal_267: int = scene.calculate_min_shanten_from_counts(counts_267.duplicate(), 0)
	scene.clear_shanten_cache()
	var shared_memo_267: Dictionary = {}
	var shared_267: int = scene.calculate_min_shanten_from_counts_with_memo(counts_267.duplicate(), 0, "", shared_memo_267)
	check(shared_267 == normal_267 and not shared_memo_267.is_empty(), "shared and standalone shanten results remain equal")

	scene.clear_ai_report_cache()
	var metrics_267: Dictionary = scene.effective_tile_metrics(hand_267, 0, 1, 99, scene.make_empty_tile_counts(), counts_267)
	check(int(metrics_267.get("count", 0)) >= 0 and int(metrics_267.get("variety", 0)) >= 0, "effective-tile scan completes with shared memo")
	check(scene.counts_compact_key(counts_267) == key_267, "effective-tile scan leaves caller counts unchanged")
	var independent_metrics_267: Dictionary = independent_effective_tile_metrics(scene, hand_267, 0, 99, scene.make_empty_tile_counts(), counts_267)
	check(metrics_267 == independent_metrics_267, "shared batch probes equal independent per-candidate results")
	var metrics_repeat_267: Dictionary = scene.effective_tile_metrics(hand_267, 0, 1, 99, scene.make_empty_tile_counts(), counts_267)
	check(metrics_repeat_267 == metrics_267, "effective-tile cache preserves the batch result")

	scene.players[1]["melds"] = [["1W", "1W", "1W"]]
	var open_hand_267: Array = ["2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "2T", "3T", "4T", "E", "S"]
	var open_counts_267: Array = scene.tile_counts(open_hand_267)
	var open_normal_267: int = scene.calculate_min_shanten_from_counts(open_counts_267.duplicate(), 1)
	scene.clear_shanten_cache()
	var open_memo_267: Dictionary = {}
	var open_shared_267: int = scene.calculate_min_shanten_from_counts_with_memo(open_counts_267.duplicate(), 1, "", open_memo_267)
	check(open_shared_267 == open_normal_267 and not open_memo_267.is_empty(), "open-hand shanten also preserves shared-memo equivalence")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
