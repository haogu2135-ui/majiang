extends SceneTree
## Round 281: added-gang public risk reuses one normalized tile and index.

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
	print("=== ai_play_round281 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var source_281 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var start_281 := source_281.find("func added_gang_rob_threat_report")
	var end_281 := source_281.find("func touch_ai_rob_threat_cache_key", start_281)
	var function_281 := source_281.substr(start_281, end_281 - start_281)
	check(function_281.contains("var normalized_tile := normalize_tile_code(tile)"), "added-gang risk normalizes the tile once")
	check(function_281.contains("var tile_index_snapshot := tile_index_normalized(normalized_tile)"), "added-gang risk resolves the tile index once")
	check(function_281.contains("%d|%d|%s\" % [ai_state_revision, gang_seat, normalized_tile]"), "added-gang cache keys use the normalized tile")
	check(function_281.contains("visible_tile_count_from_counts(normalized_tile, visible_counts, tile_index_snapshot)"), "visible risk count consumes the captured index")
	check(function_281.contains("single_opponent_deal_in_risk_components(normalized_tile, gang_seat, seat, visible, visible_counts, eval_context, tile_index_snapshot)"), "opponent risk branches consume the normalized snapshot")
	check(not function_281.contains("visible_tile_count_from_counts(tile, visible_counts)"), "added-gang risk avoids the legacy tile lookup")

	scene.players[1]["melds"] = [["5W", "5W", "5W"], ["6W", "6W", "6W"], ["7W", "7W", "7W"]]
	scene.players[1]["discards"] = ["1W", "2W", "3W", "8W", "9W", "E", "S", "W", "N", "P", "F", "C"]
	scene.clear_threat_report_cache()
	var canonical_281: Dictionary = scene.added_gang_rob_threat_report(0, "4W")
	var cache_size_281: int = scene.ai_rob_threat_cache.size()
	var alias_281: Dictionary = scene.added_gang_rob_threat_report(0, "4M")
	check(canonical_281 == alias_281, "legacy tile aliases preserve the public risk report")
	check(cache_size_281 == 1 and scene.ai_rob_threat_cache.size() == cache_size_281, "canonical and legacy tiles share one threat cache entry")
	var invalid_281: Dictionary = scene.added_gang_rob_threat_report(0, "ZZ")
	var invalid_again_281: Dictionary = scene.added_gang_rob_threat_report(0, "ZZ")
	check(invalid_281.has("risk_score") and invalid_281.has("risk_details") and float(invalid_281.get("risk_score", -1.0)) >= 0.0 and invalid_281 == invalid_again_281, "invalid gang tiles retain a stable non-negative report")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
