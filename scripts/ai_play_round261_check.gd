extends SceneTree
## Round 261: wait valuation reuses effective-tile indexes.

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
	print("=== ai_play_round261 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var source_261 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var effective_start_261 := source_261.find("func effective_tile_metrics")
	var effective_end_261 := source_261.find("func touch_effective_tiles_cache_key", effective_start_261)
	var effective_source_261 := source_261.substr(effective_start_261, effective_end_261 - effective_start_261)
	var wait_start_261 := source_261.find("func wait_value_metrics")
	var wait_end_261 := source_261.find("func wait_quality_penalty", wait_start_261)
	var wait_source_261 := source_261.substr(wait_start_261, wait_end_261 - wait_start_261)
	check(effective_source_261.contains("var tile_indices_by_tile: Dictionary = {}"), "effective metrics capture tile indexes during the scan")
	check(effective_source_261.contains("\"tile_indices\": tile_indices_by_tile"), "effective metrics publish the index snapshot")
	check(wait_source_261.contains("effective_tile_indices_snapshot: Dictionary = {}"), "wait valuation accepts an optional index snapshot")
	check(wait_source_261.contains("effective_tile_indices_snapshot.get(tile, -1)"), "wait valuation reuses captured indexes")
	check(wait_source_261.contains("tile_index_value = tile_index_normalized(tile)"), "wait valuation keeps the direct-call fallback")

	var tenpai_hand: Array = [
		"1W", "2W", "3W",
		"4W", "5W", "6W",
		"7W", "8W", "9W",
		"1T", "1T", "1T", "4T",
	]
	scene.players[0]["hand"] = tenpai_hand.duplicate()
	var visible_counts_261: Array = scene.make_empty_tile_counts()
	var hand_counts_261: Array = scene.tile_counts(tenpai_hand)
	var metrics_261: Dictionary = scene.effective_tile_metrics(tenpai_hand, 0, 0, 0, visible_counts_261, hand_counts_261)
	var effective_tiles_261: Array = metrics_261.get("tiles", [])
	var remaining_261: Dictionary = metrics_261.get("remaining_by_tile", {})
	var indexes_261: Dictionary = metrics_261.get("tile_indices", {})
	check(effective_tiles_261.has("4T"), "tenpai metrics retain the expected winning tile")
	check(int(indexes_261.get("4T", -1)) == scene.tile_index("4T"), "captured index matches the canonical tile order")
	var snapshot_wait_261: Dictionary = scene.wait_value_metrics(0, tenpai_hand, 0, 0, effective_tiles_261, remaining_261, true, {}, 1.0, 1.0, hand_counts_261, 0, indexes_261)
	var fallback_wait_261: Dictionary = scene.wait_value_metrics(0, tenpai_hand, 0, 0, effective_tiles_261, remaining_261, true, {}, 1.0, 1.0, hand_counts_261, 0)
	check(is_equal_approx(float(snapshot_wait_261.get("score", 0.0)), float(fallback_wait_261.get("score", 0.0))), "index snapshot preserves wait score")
	check(str(snapshot_wait_261.get("best_tile", "")) == str(fallback_wait_261.get("best_tile", "")), "index snapshot preserves best wait")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
