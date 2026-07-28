extends SceneTree
## Round 62: late-wall AI accounts for exhaustive-draw tenpai ba.
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


func empty_wall() -> Array[String]:
	var wall: Array[String] = []
	return wall


func tenpai_hand() -> Array:
	return ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W"]


func tsumo_complete_hand() -> Array:
	var hand = tenpai_hand()
	hand.append("5W")
	return hand


func reset_table(scene) -> void:
	scene.players = [
		make_player("Self"),
		make_player("AI"),
		make_player("P2"),
		make_player("P3"),
	]
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 1
	scene.dealer_seat = 0
	scene.offline_sim_quiet = true
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL
	scene.wall = empty_wall()
	for seat in range(4):
		scene.players[seat]["hand"] = []
		scene.players[seat]["discards"] = []
		scene.players[seat]["melds"] = []
		scene.players[seat]["score"] = 25000


func fill_wall(scene, count: int) -> void:
	var wall: Array[String] = []
	for i in range(count):
		wall.append("9B")
	scene.wall = wall


func run() -> void:
	print("=== ai_play_round62 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.clear_ai_report_cache()

	print("--- A) urgency and preservation helpers ---")
	reset_table(scene)
	fill_wall(scene, 40)
	check(is_equal_approx(scene.wall_draw_ba_urgency(), 0.0), "deep wall has no ba urgency")
	fill_wall(scene, 12)
	check(scene.wall_draw_ba_urgency() > 0.4, "short wall raises ba urgency")
	var tenpai_push = scene.wall_draw_tenpai_preservation_adjustment(1, 0, 6)
	var noten_push = scene.wall_draw_tenpai_preservation_adjustment(1, 3, 0)
	check(tenpai_push > 0.0, "tenpai preservation is positive near wall end")
	check(noten_push < 0.0, "deep noten is discouraged near wall end")
	check(tenpai_push > absf(noten_push), "keeping tenpai outweighs noten push magnitude")

	print("--- B) discard scoring keeps tenpai near wall end ---")
	reset_table(scene)
	fill_wall(scene, 10)
	# Tenpai closed hand + isolated honor draw.
	scene.players[1]["hand"] = ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W", "E"]
	scene.offline_phase = "await_discard"
	scene.current_seat = 1
	scene.offline_turn_needs_draw = false
	var tenpai_after: Array = ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W"]
	var tenpai_report = scene.build_ai_discard_report(1, "E", tenpai_after, 0)
	check(int(tenpai_report.get("shanten", 99)) == 0, "honor dump from complete shape stays tenpai")
	check(float(tenpai_report.get("wall_draw_push", 0.0)) > 0.0, "tenpai discard carries wall-draw push")
	# Deep noten hand + same honor dump.
	scene.players[1]["hand"] = ["1W", "3W", "5W", "7W", "9W", "1T", "3T", "5T", "7T", "9T", "1B", "3B", "5B", "E"]
	var noten_after: Array = ["1W", "3W", "5W", "7W", "9W", "1T", "3T", "5T", "7T", "9T", "1B", "3B", "5B"]
	var noten_report = scene.build_ai_discard_report(1, "E", noten_after, 0)
	check(int(noten_report.get("shanten", -1)) >= 2, "scattered hand remains far from tenpai")
	check(float(tenpai_report.get("wall_draw_push", 0.0)) > float(noten_report.get("wall_draw_push", 0.0)), "tenpai discard gets stronger wall-draw push than noten")
	check(float(tenpai_report.get("score", -999999.0)) > float(noten_report.get("score", -999999.0)), "overall score still prefers tenpai retention near wall end")

	print("--- C) low-value ron/tsumo force pocket near wall ba ---")
	reset_table(scene)
	fill_wall(scene, 8)
	scene.players[1]["hand"] = tenpai_hand()
	scene.players[2]["discards"] = ["5W"]
	scene.last_discard = "5W"
	scene.last_discard_seat = 2
	scene.offline_phase = "resolving"
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var ron = scene.ai_ron_decision_report(1, "5W")
	check(bool(ron.get("accept", false)), "late-wall ron accepts instead of gambling tenpai ba")
	check(str(ron.get("reason", "")).find("查听") >= 0 or str(ron.get("reason", "")).find("高压") >= 0 or str(ron.get("reason", "")).find("高价值") >= 0 or str(ron.get("reason", "")).find("必") >= 0, "late-wall ron reason is pocket-oriented")

	reset_table(scene)
	fill_wall(scene, 8)
	scene.players[1]["hand"] = tsumo_complete_hand()
	scene.current_seat = 1
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_last_draw = {"seat": 1, "tile": "5W", "source": "normal", "wall_empty": false, "serial": 91}
	scene.offline_self_draw_ready = {"seat": 1, "tile": "5W", "serial": 91}
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var tsumo = scene.ai_tsumo_decision_report(1, "5W")
	check(bool(tsumo.get("accept", false)), "late-wall tsumo accepts to secure ba-aware value")
	check(str(tsumo.get("reason", "")) != "留听高番自摸", "late-wall tsumo does not keep-tenpai pass")

	print("--- D) deep wall still allows keep-tenpai logic path ---")
	reset_table(scene)
	fill_wall(scene, 48)
	check(is_equal_approx(scene.wall_draw_ba_urgency(), 0.0), "deep wall disables ba urgency")
	check(not scene.should_force_accept_for_wall_draw_ba(1, 200, 48), "deep wall does not force ba pocket on flat one-fan")
	check(scene.should_force_accept_for_wall_draw_ba(1, 200, 8), "very short wall forces ba pocket on modest points")
	check(scene.should_force_accept_for_wall_draw_ba(1, 1000, 16), "mid-short wall forces ba pocket when points cover ba")
	check(not scene.should_force_accept_for_wall_draw_ba(1, 200, 20), "mid wall still allows keep-tenpai on flat one-fan")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
