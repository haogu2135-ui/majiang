extends SceneTree
## Round 259: fallback opponent threat scoring reuses its captured tile index.

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
	print("=== ai_play_round259 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[1]["melds"] = [["4W", "5W", "6W"]]
	scene.players[1]["discards"] = ["9B"]
	var visible_counts_259: Array = scene.make_empty_tile_counts()
	var source_259 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var threat_start_259 := source_259.find("func opponent_tile_threat_score")
	var threat_end_259 := source_259.find("func opponent_pattern_threat_score", threat_start_259)
	var threat_source_259 := source_259.substr(threat_start_259, threat_end_259 - threat_start_259)
	check(threat_source_259.contains("var tile_index_snapshot := tile_index(tile)"), "fallback threat scoring captures the tile index once")
	check(threat_source_259.contains("visible_tile_count_from_counts(tile, known_counts, tile_index_snapshot)"), "fallback threat scoring forwards the captured index")
	check(threat_source_259.contains("if not risk_vector.is_empty():"), "precomputed risk vectors keep their early return")

	var canonical_context_259: Dictionary = scene.make_ai_evaluation_context(0, visible_counts_259)
	var alias_context_259: Dictionary = scene.make_ai_evaluation_context(0, visible_counts_259)
	var canonical_threat_259: float = scene.opponent_tile_threat_score("4W", 0, visible_counts_259, {}, canonical_context_259)
	var alias_threat_259: float = scene.opponent_tile_threat_score("4M", 0, visible_counts_259, {}, alias_context_259)
	check(is_equal_approx(alias_threat_259, canonical_threat_259), "normalized aliases preserve fallback threat scoring")
	var invalid_threat_259: float = scene.opponent_tile_threat_score("ZZ", 0, visible_counts_259, {}, {})
	check(is_equal_approx(invalid_threat_259, 0.0), "invalid fallback threat tiles retain the zero result")
	var cached_threat_259: float = scene.opponent_tile_threat_score("4W", 0, visible_counts_259, {"threat": 17.5}, {})
	check(is_equal_approx(cached_threat_259, 17.5), "precomputed risk vectors retain the threat fast path")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
