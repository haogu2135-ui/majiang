extends SceneTree
## Round 257: scoring inventory meld tiles normalize and resolve their index once.

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
	print("=== ai_play_round257 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var source_257 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	var inventory_start_257 := source_257.find("func has_valid_scoring_tile_inventory_from_counts")
	var inventory_end_257 := source_257.find("func is_valid_scoring_meld", inventory_start_257)
	var inventory_source_257 := source_257.substr(inventory_start_257, inventory_end_257 - inventory_start_257)
	check(source_257.contains("var normalized_code := normalize_tile_code(str(item))"), "scoring inventory normalizes each meld tile once")
	check(source_257.contains("var index := int(tile_order.get(normalized_code, -1))"), "scoring inventory resolves the normalized index directly")
	check(not inventory_source_257.contains("is_tile_enabled_for_rule("), "scoring inventory avoids the duplicate rule normalization")

	var hand_counts_257: Array = scene.tile_counts(["1W", "2W"])
	scene.players[0]["melds"] = [["4M", "5M", "6M"]]
	check(scene.has_valid_scoring_tile_inventory_from_counts(0, hand_counts_257, 2), "legacy suit aliases remain accepted for enabled meld tiles")
	var repeated_result_257: bool = scene.has_valid_scoring_tile_inventory_from_counts(0, hand_counts_257, 2)
	check(repeated_result_257, "normalized inventory validation remains stable across repeated calls")

	scene.players[0]["melds"] = [["H1", "H1", "H1"]]
	check(not scene.has_valid_scoring_tile_inventory_from_counts(0, hand_counts_257, 2), "flower meld tiles remain outside the scoring inventory")
	scene.players[0]["melds"] = [["4W", "5W", "6W"]]
	scene.offline_active_rule_variant = scene.RULE_VARIANT_SICHUAN
	check(scene.has_valid_scoring_tile_inventory_from_counts(0, hand_counts_257, 2), "enabled suited melds remain valid under a restricted rule")
	scene.players[0]["melds"] = [["E", "E", "E"]]
	check(not scene.has_valid_scoring_tile_inventory_from_counts(0, hand_counts_257, 2), "rule-disabled honor melds remain rejected")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
