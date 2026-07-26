extends SceneTree
## Round 25: a full straight must be an actual 123 + 456 + 789 decomposition.
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


func run() -> void:
	print("=== ai_play_round25 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.setup_tile_order()
	scene.dealer_seat = 1
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	print("--- A) all ranks present is not sufficient ---")
	# 111W / 234W / 567W / 789W / 22W is a valid hand with every W rank,
	# but it cannot simultaneously contain 123W + 456W + 789W.
	var false_positive: Array = ["1W", "1W", "1W", "2W", "2W", "2W", "3W", "4W", "5W", "6W", "7W", "7W", "8W", "9W"]
	scene.players[0]["melds"] = []
	check(scene.is_complete_hand(false_positive, 0), "反例本身是合法和牌")
	check(not scene.is_full_straight_hand(0, false_positive), "仅有同花色 1-9 不误判一条龙")
	var false_score = scene.calculate_win_score_from_tiles(0, false_positive, false)
	print("    false reasons=%s" % str(false_score.get("reasons", [])))
	check(not (false_score.get("reasons", []) as Array).has("一条龙"), "反例结算不加一条龙番")

	print("--- B) concealed and exposed full straights score correctly ---")
	var concealed: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T", "E", "E"]
	check(scene.is_complete_hand(concealed, 0), "暗手一条龙夹具是合法和牌")
	check(scene.full_straight_suit(0, concealed) == 0, "暗手 123/456/789 正确识别万子一条龙")
	var concealed_score = scene.calculate_win_score_from_tiles(0, concealed, false)
	check((concealed_score.get("reasons", []) as Array).has("一条龙"), "暗手一条龙进入结算番种")

	scene.players[0]["melds"] = [["1W", "2W", "3W"]]
	var exposed: Array = ["4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T", "E", "E"]
	check(scene.is_complete_hand(exposed, 1), "明牌一条龙夹具是合法和牌")
	check(scene.full_straight_suit(0, exposed) == 0, "明牌 123 与暗手 456/789 正确组合")
	var exposed_score = scene.calculate_win_score_from_tiles(0, exposed, false)
	check((exposed_score.get("reasons", []) as Array).has("一条龙"), "明牌一条龙进入结算番种")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
