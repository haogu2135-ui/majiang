extends SceneTree
## Round 46: concealed gangs preserve menzen, while open calls still break it.
var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(cond: bool, msg: String) -> void:
	if cond:
		print("  OK  | %s" % msg)
	else:
		print("  FAIL| %s" % msg)
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


func concealed_quad_complete_hand() -> Array:
	# Three concealed sequences plus a pair; the fourth set is a 1T concealed quad.
	return ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E"]


func open_chi_complete_hand() -> Array:
	# Two concealed sequences plus a pair; fixed melds are a concealed quad and an open chi.
	return ["4W", "5W", "6W", "7W", "8W", "9W", "E", "E"]


func reset_round(scene) -> void:
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 0
	scene.dealer_seat = 1
	scene.wall.clear()
	scene.offline_concealed_gang_tiles.clear()
	scene.offline_last_draw.clear()


func has_reason(score: Dictionary, reason: String) -> bool:
	return (score.get("reasons", []) as Array).has(reason)


func run() -> void:
	print("=== ai_play_round46 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.offline_sim_quiet = true
	scene.setup_tile_order()

	print("--- A) registered concealed quad preserves menzen scoring ---")
	reset_round(scene)
	scene.players[0]["hand"] = concealed_quad_complete_hand()
	scene.players[0]["melds"] = [["1T", "1T", "1T", "1T"]]
	scene.record_concealed_gang_meld(0, "1T")
	var concealed_score = scene.calculate_win_score_from_tiles(0, scene.players[0]["hand"], false)
	check(scene.is_concealed_gang_meld(0, scene.players[0]["melds"][0]) and scene.exposed_meld_count_for_seat(0) == 0 and scene.is_menzen_hand(0), "登记暗杠不计入明副露")
	check(scene.can_win_for_seat(0) and int(concealed_score.get("points", 0)) > 0 and has_reason(concealed_score, "门清"), "合法暗杠和牌入口与计分均保留门清")

	print("--- B) unmarked imported quad remains non-menzen ---")
	scene.offline_concealed_gang_tiles.clear()
	var legacy_score = scene.calculate_win_score_from_tiles(0, scene.players[0]["hand"], false)
	check(not scene.is_concealed_gang_meld(0, scene.players[0]["melds"][0]) and scene.exposed_meld_count_for_seat(0) == 1 and not scene.is_menzen_hand(0), "未标记四张组保守按明杠处理")
	check(int(legacy_score.get("points", 0)) > 0 and not has_reason(legacy_score, "门清"), "旧状态不虚增门清")

	print("--- C) a real open chi still breaks menzen after a concealed quad ---")
	reset_round(scene)
	scene.players[0]["hand"] = open_chi_complete_hand()
	scene.players[0]["melds"] = [["1T", "1T", "1T", "1T"], ["1B", "2B", "3B"]]
	scene.record_concealed_gang_meld(0, "1T")
	var open_score = scene.calculate_win_score_from_tiles(0, scene.players[0]["hand"], false)
	check(scene.exposed_meld_count_for_seat(0) == 1 and not scene.is_menzen_hand(0), "暗杠之外的吃牌计为明副露")
	check(int(open_score.get("points", 0)) > 0 and not has_reason(open_score, "门清"), "暗杠与明吃共存时不计门清")

	print("--- D) live concealed-gang transition records provenance ---")
	reset_round(scene)
	scene.players[0]["hand"] = ["5W", "5W", "5W", "5W"]
	scene.wall.append("9B")
	check(scene.perform_concealed_gang(0, "5W"), "实战暗杠可执行")
	check(scene.is_concealed_gang_meld(0, scene.players[0]["melds"][0]) and scene.exposed_meld_count_for_seat(0) == 0, "实战暗杠登记门清来源")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
