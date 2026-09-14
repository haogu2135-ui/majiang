extends SceneTree
## Round 258: scoring validation returns the combined count snapshot in one meld pass.

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
	print("=== ai_play_round258 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var source_258 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	var score_start_258 := source_258.find("func calculate_win_score_from_tiles")
	var score_end_258 := source_258.find("func is_last_draw_context", score_start_258)
	var score_source_258 := source_258.substr(score_start_258, score_end_258 - score_start_258)
	check(source_258.contains("func validated_scoring_tile_counts_from_counts"), "scoring validation exposes a combined count snapshot helper")
	check(score_source_258.contains("scoring_counts = validated_scoring_tile_counts_from_counts(seat, hand_counts, canonical_tile_count)"), "normal scoring uses the combined validation pass")
	check(not score_source_258.contains("has_valid_scoring_melds(seat) or not has_valid_scoring_tile_inventory_from_counts"), "normal scoring avoids separate meld and inventory scans")

	var concealed_258: Array = ["1W", "2W", "3W", "7W", "8W", "9W", "1T", "2T", "3T", "E", "E"]
	var concealed_counts_258: Array = scene.tile_counts(concealed_258)
	scene.players[0]["hand"] = concealed_258.duplicate()
	scene.players[0]["melds"] = [["4M", "5M", "6M"]]
	var validated_counts_258: Array = scene.validated_scoring_tile_counts_from_counts(0, concealed_counts_258, concealed_258.size())
	var legacy_counts_258: Array = scene.scoring_tile_counts_from_counts(0, concealed_counts_258)
	check(validated_counts_258 == legacy_counts_258, "combined scoring counts preserve normalized meld aliases")
	var score_258: Dictionary = scene.calculate_win_score_from_tiles(0, concealed_258, false)
	check(int(score_258.get("points", 0)) > 0 and int(score_258.get("fan", 0)) > 0, "valid open hand still receives a paid score")

	scene.players[0]["melds"] = [["4W", "5W", "7W"]]
	var malformed_counts_258: Array = scene.validated_scoring_tile_counts_from_counts(0, concealed_counts_258, concealed_258.size())
	check(malformed_counts_258.is_empty(), "malformed sequence melds remain rejected by the combined pass")
	var malformed_score_258: Dictionary = scene.calculate_win_score_from_tiles(0, concealed_258, false)
	check(int(malformed_score_258.get("points", 0)) == 0, "malformed melds cannot produce a paid score")

	scene.players[0]["melds"] = [["4W", "4W", "4W", "4W"]]
	var over_limit_counts_258: Array = concealed_counts_258.duplicate()
	over_limit_counts_258[scene.tile_index("4W")] = 1
	over_limit_counts_258[scene.tile_index("1W")] = 0
	check(scene.validated_scoring_tile_counts_from_counts(0, over_limit_counts_258, concealed_258.size()).is_empty(), "combined inventory still enforces the four-copy limit")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
