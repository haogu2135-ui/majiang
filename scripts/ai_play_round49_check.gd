extends SceneTree
## Round 49: public win and score boundaries reject tile inventories with more than four copies.
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


func five_copy_closed_hand() -> Array:
	# Structurally this is a triplet plus a pair of 1W and three sequences, but five 1W are impossible.
	return ["1W", "1W", "1W", "1W", "1W", "2T", "3T", "4T", "5T", "6T", "7T", "7B", "8B", "9B"]


func overfull_open_hand() -> Array:
	# The open 1W quad plus this concealed pair would require six copies of 1W.
	return ["1W", "1W", "2T", "3T", "4T", "5T", "6T", "7T", "7B", "8B", "9B"]


func legal_hand() -> Array:
	return ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T", "E", "E"]


func run() -> void:
	print("=== ai_play_round49 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.setup_tile_order()
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.dealer_seat = 1

	print("--- A) five concealed copies cannot score a structurally complete hand ---")
	var closed = five_copy_closed_hand()
	scene.players[0]["hand"] = closed.duplicate()
	scene.players[0]["melds"] = []
	check(scene.is_complete_hand(closed, 0), "夹具只按面子拆分会被视为完整")
	check(not scene.has_valid_scoring_tile_inventory(0, closed), "五张同牌违反物理牌张上限")
	check(not scene.can_win_for_seat(0) and not scene.can_win_for_seat_from_counts(0, scene.tile_counts(closed)), "公开和牌入口拒绝五张同牌")
	check(zero_score(scene.calculate_win_score_from_tiles(0, closed, false)), "计分入口拒绝五张同牌")

	print("--- B) fixed melds participate in the same four-copy limit ---")
	var open_hand = overfull_open_hand()
	scene.players[0]["hand"] = open_hand.duplicate()
	scene.players[0]["melds"] = [["1W", "1W", "1W", "1W"]]
	check(scene.has_valid_scoring_melds(0) and scene.is_complete_hand(open_hand, 1), "夹具的固定杠和剩余结构分别合法")
	check(not scene.has_valid_scoring_tile_inventory(0, open_hand), "固定杠与暗手合计超过四张被拒绝")
	check(not scene.can_win_for_seat(0) and not scene.can_win_for_seat_from_counts(0, scene.tile_counts(open_hand)), "固定组超额不会进入和牌或计分")
	check(zero_score(scene.calculate_win_score_from_tiles(0, open_hand, false)), "固定组超额不产生分数")

	print("--- C) legal inventories keep existing scoring behavior ---")
	var legal = legal_hand()
	scene.players[0]["hand"] = legal.duplicate()
	scene.players[0]["melds"] = []
	check(scene.has_valid_scoring_tile_inventory(0, legal) and scene.can_win_for_seat(0), "正常四张上限内的牌形仍可和")
	var legal_score = scene.calculate_win_score_from_tiles(0, legal, false)
	check(int(legal_score.get("points", 0)) > 0 and (legal_score.get("reasons", []) as Array).has("一条龙"), "正常牌形保留原有番种与分数")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
