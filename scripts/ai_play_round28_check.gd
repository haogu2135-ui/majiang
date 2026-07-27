extends SceneTree
## Round 28: score calculation must reject incomplete hands at its public boundary.
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


func zero_score(score: Dictionary) -> bool:
	return int(score.get("fan", -1)) == 0 and int(score.get("points", -1)) == 0 and (score.get("reasons", ["invalid"]) as Array).is_empty()


func run() -> void:
	print("=== ai_play_round28 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.setup_tile_order()
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.dealer_seat = 0

	print("--- A) malformed closed hand cannot become a paid win ---")
	# Fourteen tiles, but no legal 4-meld-plus-pair / special-hand decomposition.
	var invalid_closed: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "3T", "5T", "7T", "E"]
	scene.players[0]["flowers"] = 4
	check(not scene.is_complete_hand(invalid_closed, 0), "夹具不是合法闭门和牌")
	var invalid_closed_score = scene.calculate_win_score_from_tiles(0, invalid_closed, true)
	print("    invalid closed=%s" % str(invalid_closed_score))
	check(zero_score(invalid_closed_score), "非法闭门牌形不产生庄家、自摸或花牌分")

	print("--- B) malformed open hand is rejected too ---")
	scene.players[0]["flowers"] = 0
	scene.players[0]["melds"] = [["1W", "2W", "3W"]]
	var invalid_open: Array = ["4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "3T", "4T", "6T"]
	check(not scene.is_complete_hand(invalid_open, 1), "夹具不是合法副露和牌")
	check(zero_score(scene.calculate_win_score_from_tiles(0, invalid_open, false)), "非法副露牌形不产生基础分")

	print("--- C) legal scoring remains unchanged ---")
	scene.players[0]["melds"] = []
	var complete: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T", "E", "E"]
	check(scene.is_complete_hand(complete, 0), "合法一条龙夹具仍可和")
	var complete_score = scene.calculate_win_score_from_tiles(0, complete, false)
	print("    legal=%s" % str(complete_score))
	check(int(complete_score.get("points", 0)) > 0 and (complete_score.get("reasons", []) as Array).has("一条龙"), "合法牌形仍返回完整番种与分数")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
