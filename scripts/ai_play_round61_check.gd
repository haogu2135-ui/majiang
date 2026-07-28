extends SceneTree
## Round 61: exhaustive draw settles tenpai/noten ba without fabricating a winner.
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


func tenpai_hand() -> Array:
	# 13-tile ryanmen/kanchan style complete-on-5W hand.
	return ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W"]


func noten_hand() -> Array:
	return ["1W", "3W", "5W", "7W", "9W", "1T", "3T", "5T", "7T", "9T", "1B", "3B", "5B"]


func reset_table(scene) -> void:
	scene.players = [
		make_player("P0"),
		make_player("P1"),
		make_player("P2"),
		make_player("P3"),
	]
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = true
	scene.current_seat = 0
	scene.dealer_seat = 1
	scene.offline_sim_quiet = true
	scene.offline_last_winner = 2
	scene.last_win_score = {"fan": 6, "points": 6400, "winner": 2, "win_tile": "5W", "self_draw": true}
	var stale_deltas: Array[int] = [100, -100, 0, 0]
	scene.last_score_deltas = stale_deltas
	scene.round_summary = ""
	var empty_wall: Array[String] = []
	scene.wall = empty_wall
	for seat in range(4):
		scene.players[seat]["score"] = 25000
		scene.players[seat]["melds"] = []
		scene.players[seat]["discards"] = []


func score_total(scene) -> int:
	var total = 0
	for player in scene.players:
		total += int(player.get("score", 0))
	return total


func delta_total(scene) -> int:
	var total = 0
	for delta in scene.last_score_deltas:
		total += int(delta)
	return total


func run() -> void:
	print("=== ai_play_round61 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()

	print("--- A) mixed tenpai/noten pays ba to tenpai seats ---")
	reset_table(scene)
	scene.players[0]["hand"] = tenpai_hand()
	scene.players[1]["hand"] = tenpai_hand()
	scene.players[2]["hand"] = noten_hand()
	scene.players[3]["hand"] = noten_hand()
	check(scene.is_seat_tenpai_for_wall_draw(0) and scene.is_seat_tenpai_for_wall_draw(1), "fixture marks two tenpai seats")
	check(not scene.is_seat_tenpai_for_wall_draw(2) and not scene.is_seat_tenpai_for_wall_draw(3), "fixture marks two noten seats")
	scene.finish_wall_draw()
	var ba = int(scene.WALL_DRAW_NOTEN_BA)
	check(scene.offline_phase == "ended" and scene.offline_last_winner == -1, "wall draw ends without a winner seat")
	check(bool(scene.offline_dealer_repeat), "wall draw keeps dealer repeat")
	check(score_total(scene) == 100000, "mixed wall draw conserves table score")
	check(delta_total(scene) == 0, "mixed wall draw deltas sum to zero")
	check(int(scene.players[2]["score"]) == 25000 - ba and int(scene.players[3]["score"]) == 25000 - ba, "each noten seat pays ba")
	check(int(scene.players[0]["score"]) == 25000 + ba and int(scene.players[1]["score"]) == 25000 + ba, "two tenpai seats split the noten pool evenly")
	check(bool(scene.last_win_score.get("wall_draw", false)) and int(scene.last_win_score.get("fan", -1)) == 0, "wall draw stores tenpai summary instead of a win")
	check(scene.round_summary.find("听牌") >= 0 and scene.round_summary.find("未听") >= 0, "summary names tenpai and noten seats")

	print("--- B) all tenpai and all noten charge nothing ---")
	reset_table(scene)
	for seat in range(4):
		scene.players[seat]["hand"] = tenpai_hand()
	scene.finish_wall_draw()
	check(scene.players[0]["score"] == 25000 and scene.players[1]["score"] == 25000 and scene.players[2]["score"] == 25000 and scene.players[3]["score"] == 25000, "all-tenpai wall draw has no ba")
	check(scene.round_summary.find("四家听牌") >= 0, "all-tenpai summary explains no ba")

	reset_table(scene)
	for seat in range(4):
		scene.players[seat]["hand"] = noten_hand()
	scene.finish_wall_draw()
	check(scene.players[0]["score"] == 25000 and scene.players[1]["score"] == 25000 and scene.players[2]["score"] == 25000 and scene.players[3]["score"] == 25000, "all-noten wall draw has no ba")
	check(scene.round_summary.find("四家未听") >= 0, "all-noten summary explains no ba")

	print("--- C) one tenpai collects every noten payment ---")
	reset_table(scene)
	scene.players[0]["hand"] = tenpai_hand()
	scene.players[1]["hand"] = noten_hand()
	scene.players[2]["hand"] = noten_hand()
	scene.players[3]["hand"] = noten_hand()
	scene.finish_wall_draw()
	check(int(scene.players[0]["score"]) == 25000 + ba * 3, "single tenpai collects full pool")
	check(int(scene.players[1]["score"]) == 25000 - ba and int(scene.players[2]["score"]) == 25000 - ba and int(scene.players[3]["score"]) == 25000 - ba, "three noten seats each pay ba")
	check(score_total(scene) == 100000 and delta_total(scene) == 0, "single-tenpai wall draw remains conservative")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
