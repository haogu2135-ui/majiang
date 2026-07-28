extends SceneTree
## Round 77: public special-hand scoring contract for advertised local rules.
var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(cond: bool, msg: String) -> void:
	if cond:
		print("  OK  | %s" % msg)
	else:
		print("  FAIL| %s" % msg)
		failed = true


func make_players(scene) -> void:
	scene.players = []
	for seat in range(4):
		scene.players.append({
			"name": "P%d" % seat,
			"hand": [],
			"discards": [],
			"melds": [],
			"flowers": 0,
			"flower_tiles": [],
			"score": scene.MATCH_START_SCORE,
			"bot": true,
		})


func score_fixture(scene, tiles: Array, melds: Array = [], flowers: int = 0) -> Dictionary:
	make_players(scene)
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.dealer_seat = 1
	scene.players[0]["melds"] = melds.duplicate(true)
	scene.players[0]["flowers"] = flowers
	var flower_tiles: Array = []
	for index in range(flowers):
		flower_tiles.append(str(scene.FLOWER_CODES[index]))
	scene.players[0]["flower_tiles"] = flower_tiles
	return scene.calculate_win_score_from_tiles(0, tiles, false)


func has_reason(score_data: Dictionary, reason: String) -> bool:
	var reasons = score_data.get("reasons", [])
	return typeof(reasons) == TYPE_ARRAY and (reasons as Array).has(reason)


func check_scored(score_data: Dictionary, reason: String, name: String) -> void:
	check(int(score_data.get("points", 0)) > 0, "%s fixture produces a paid result" % name)
	check(has_reason(score_data, reason), "%s fixture includes %s" % [name, reason])


func run() -> void:
	print("=== ai_play_round77 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()

	print("--- A) closed special hands ---")
	var seven_pairs: Array = ["1W", "1W", "2W", "2W", "3W", "3W", "4W", "4W", "5B", "5B", "6B", "6B", "E", "E"]
	var seven_score = score_fixture(scene, seven_pairs)
	check_scored(seven_score, "七对", "seven pairs")

	var orphans: Array = ["1W", "9W", "1B", "9B", "1T", "9T", "E", "S", "N", "R", "Z", "F", "P", "1W"]
	var orphan_score = score_fixture(scene, orphans)
	check_scored(orphan_score, "十三幺", "thirteen orphans")

	var pure_one_suit: Array = ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "8W", "8W", "9W", "9W"]
	var pure_score = score_fixture(scene, pure_one_suit)
	check_scored(pure_score, "清一色", "pure one suit")
	check(not has_reason(pure_score, "混一色"), "pure one suit does not also score mixed one suit")

	var mixed_one_suit: Array = ["1B", "1B", "1B", "2B", "3B", "4B", "5B", "6B", "7B", "E", "E", "E", "S", "S"]
	var mixed_score = score_fixture(scene, mixed_one_suit)
	check_scored(mixed_score, "混一色", "mixed one suit")
	check(not has_reason(mixed_score, "清一色"), "mixed one suit does not score pure one suit")

	var all_honors: Array = ["E", "E", "E", "S", "S", "S", "N", "N", "N", "R", "R", "R", "Z", "Z"]
	var honor_score = score_fixture(scene, all_honors)
	check_scored(honor_score, "字一色", "all honors")
	check_scored(honor_score, "碰碰胡", "all honors triplets")

	print("--- B) dragon and wind hierarchy ---")
	var big_dragons: Array = ["Z", "Z", "Z", "F", "F", "F", "P", "P", "P", "1W", "2W", "3W", "5T", "5T"]
	var big_dragon_score = score_fixture(scene, big_dragons)
	check_scored(big_dragon_score, "大三元", "big three dragons")
	check(not has_reason(big_dragon_score, "小三元"), "big three dragons excludes small three dragons")

	var small_dragons: Array = ["Z", "Z", "Z", "F", "F", "F", "P", "P", "1W", "2W", "3W", "7T", "8T", "9T"]
	var small_dragon_score = score_fixture(scene, small_dragons)
	check_scored(small_dragon_score, "小三元", "small three dragons")
	check(not has_reason(small_dragon_score, "大三元"), "small three dragons excludes big three dragons")

	var big_winds: Array = ["E", "E", "E", "S", "S", "S", "N", "N", "N", "R", "R", "R", "5T", "5T"]
	var big_wind_score = score_fixture(scene, big_winds)
	check_scored(big_wind_score, "大四喜", "big four winds")
	check(not has_reason(big_wind_score, "小四喜"), "big four winds excludes small four winds")

	var small_winds: Array = ["E", "E", "E", "S", "S", "S", "N", "N", "N", "R", "R", "1T", "2T", "3T"]
	var small_wind_score = score_fixture(scene, small_winds)
	check_scored(small_wind_score, "小四喜", "small four winds")
	check(not has_reason(small_wind_score, "大四喜"), "small four winds excludes big four winds")

	print("--- C) composition bonuses ---")
	var all_simples: Array = ["2W", "2W", "2W", "3W", "4W", "5W", "4B", "5B", "6B", "7T", "7T", "7T", "8T", "8T"]
	var simple_score = score_fixture(scene, all_simples)
	check_scored(simple_score, "断幺九", "all simples")

	var all_triplets: Array = ["1W", "1W", "1W", "2W", "2W", "2W", "3B", "3B", "3B", "E", "E", "E", "R", "R"]
	var triplet_score = score_fixture(scene, all_triplets)
	check_scored(triplet_score, "碰碰胡", "all triplets")

	var big_hanging: Array = ["5T", "5T"]
	var hanging_melds: Array = [["1W", "1W", "1W"], ["2W", "2W", "2W"], ["3B", "3B", "3B"], ["E", "E", "E"]]
	var hanging_score = score_fixture(scene, big_hanging, hanging_melds)
	check_scored(hanging_score, "大吊车", "four-open-meld hand")

	print("--- D) flowers are additive but not a hand substitute ---")
	var flower_base = score_fixture(scene, seven_pairs)
	var flower_score = score_fixture(scene, seven_pairs, [], 2)
	check_scored(flower_score, "花牌", "two flowers")
	check(int(flower_score.get("fan", 0)) == int(flower_base.get("fan", 0)) + 2, "two flowers add exactly two fan")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
