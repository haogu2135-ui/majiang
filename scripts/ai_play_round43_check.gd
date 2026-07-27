extends SceneTree
## Round 43: malformed open melds cannot complete or score a hand.
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


func structural_open_hand() -> Array:
	# Three concealed sets and a pair. It becomes a legal hand only with a valid open meld.
	return ["4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "3T", "E", "E"]


func run() -> void:
	print("=== ai_play_round43 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.setup_tile_order()
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.dealer_seat = 0

	print("--- A) malformed melds cannot inflate hand completion or score ---")
	var hand = structural_open_hand()
	scene.players[0]["hand"] = hand.duplicate()
	scene.players[0]["melds"] = [["1W", "1W", "2W"]]
	check(scene.is_complete_hand(hand, 1), "仅按数量的旧结构检查会误判夹具完整")
	check(not scene.has_valid_scoring_melds(0), "混杂三张不是有效副露")
	check(not scene.can_win_for_seat(0) and not scene.can_win_for_seat_from_counts(0, scene.tile_counts(hand)), "和牌入口拒绝畸形副露")
	check(zero_score(scene.calculate_win_score_from_tiles(0, hand, false)), "计分入口拒绝畸形副露")

	scene.players[0]["melds"] = [["1W", "2W", "3W", "4W"]]
	check(not scene.has_valid_scoring_melds(0), "四张顺子不是有效杠")
	check(not scene.can_win_for_seat_from_counts(0, scene.tile_counts(hand)), "四张混杂副露不能伪造和牌")

	scene.players[0]["melds"] = [["1W", "2T", "3T"]]
	check(not scene.has_valid_scoring_melds(0), "跨花色连续牌不是顺子")
	check(zero_score(scene.calculate_win_score_from_tiles(0, hand, false)), "跨花色副露不产生分数")

	print("--- B) legitimate chi, peng, and gang remain valid ---")
	scene.players[0]["melds"] = [["1W", "2W", "3W"]]
	check(scene.has_valid_scoring_melds(0), "同花色连续三张是有效吃")
	check(scene.can_win_for_seat_from_counts(0, scene.tile_counts(hand)), "合法吃牌仍可完成和牌")
	check(int(scene.calculate_win_score_from_tiles(0, hand, false).get("points", 0)) > 0, "合法吃牌仍可计分")

	scene.players[0]["melds"] = [["1W", "1W", "1W"]]
	check(scene.has_valid_scoring_melds(0), "相同三张是有效碰")
	scene.players[0]["melds"] = [["1W", "1W", "1W", "1W"]]
	check(scene.has_valid_scoring_melds(0), "相同四张是有效杠")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
