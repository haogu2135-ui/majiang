extends SceneTree
## Round 271: scoring reuses the cached meld state for menzen and gang count.

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
	print("=== ai_play_round271 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var source_271 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	var exposed_start_271 := source_271.find("func exposed_meld_count_for_seat")
	var exposed_end_271 := source_271.find("func is_menzen_hand", exposed_start_271)
	var exposed_source_271 := source_271.substr(exposed_start_271, exposed_end_271 - exposed_start_271)
	check(exposed_source_271.count("for item in melds") == 1, "meld state uses one exposed-meld scan")
	check(exposed_source_271.contains("var gang_count = 0"), "meld state captures gang count during the scan")
	check(exposed_source_271.contains("\"gang_count\": gang_count"), "meld cache publishes the paired gang count")
	var score_start_271 := source_271.find("func calculate_win_score_from_tiles")
	var score_end_271 := source_271.find("func is_last_draw_context", score_start_271)
	var score_source_271 := source_271.substr(score_start_271, score_end_271 - score_start_271)
	check(score_source_271.contains("var scoring_meld_state := scoring_meld_state_for_seat(seat)"), "scoring captures one meld state")
	check(not score_source_271.contains("is_menzen_hand(seat)"), "scoring avoids a second menzen lookup")
	check(not score_source_271.contains("count_gang_melds(seat)"), "scoring avoids a second gang scan")
	var gang_start_271 := source_271.find("func count_gang_melds")
	var gang_source_271 := source_271.substr(gang_start_271, source_271.find("func add_clickable_tile_press_art", gang_start_271) - gang_start_271)
	check(gang_source_271.contains("scoring_meld_state_for_seat(seat)"), "public gang helper keeps the cached fallback")

	var closed_hand_271: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7T", "8T", "9T", "E", "E", "E", "S", "S"]
	scene.players[1]["hand"] = closed_hand_271.duplicate()
	scene.players[1]["melds"] = []
	scene.exposed_meld_count_cache.clear()
	var closed_state_271: Dictionary = scene.scoring_meld_state_for_seat(1)
	var closed_score_271: Dictionary = scene.calculate_win_score_from_tiles(1, closed_hand_271, false)
	check(int(closed_state_271.get("value", -1)) == 0 and int(closed_state_271.get("gang_count", -1)) == 0, "closed meld state keeps menzen and gang values")
	check(scene.is_menzen_hand(1) and scene.count_gang_melds(1) == 0, "public closed helpers preserve their results")
	check(closed_score_271.get("reasons", []).has("门清"), "closed scoring keeps the menzen fan")

	var open_hand_271: Array = ["4W", "5W", "6W", "7B", "8B", "9B", "1T", "2T", "3T", "E", "E"]
	scene.players[1]["hand"] = open_hand_271.duplicate()
	scene.players[1]["melds"] = [["1W", "2W", "3W"]]
	scene.exposed_meld_count_cache.clear()
	var open_state_271: Dictionary = scene.scoring_meld_state_for_seat(1)
	var open_score_271: Dictionary = scene.calculate_win_score_from_tiles(1, open_hand_271, false)
	check(int(open_state_271.get("value", -1)) == 1 and int(open_state_271.get("gang_count", -1)) == 0, "open sequence state keeps exposed and gang values")
	check(not scene.is_menzen_hand(1) and scene.count_gang_melds(1) == 0, "public open helpers preserve their results")
	check(int(open_score_271.get("points", 0)) > 0 and not open_score_271.get("reasons", []).has("门清"), "open scoring keeps paid result without menzen fan")

	scene.players[1]["melds"] = [["1W", "1W", "1W", "1W"]]
	scene.exposed_meld_count_cache.clear()
	var gang_state_271: Dictionary = scene.scoring_meld_state_for_seat(1)
	var gang_score_271: Dictionary = scene.calculate_win_score_from_tiles(1, open_hand_271, false)
	check(int(gang_state_271.get("value", -1)) == 1 and int(gang_state_271.get("gang_count", -1)) == 1, "gang state keeps one exposed meld and one gang")
	check(not scene.is_menzen_hand(1) and scene.count_gang_melds(1) == 1, "public gang helper keeps the cached count")
	check(gang_score_271.get("reasons", []).has("杠") and int(gang_score_271.get("points", 0)) > int(open_score_271.get("points", 0)), "gang scoring keeps its extra fan")

	var cached_state_271: Dictionary = scene.scoring_meld_state_for_seat(1)
	check(cached_state_271 == gang_state_271, "repeated scoring state reuses the same cache entry")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
