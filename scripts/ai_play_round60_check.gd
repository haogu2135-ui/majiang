extends SceneTree
## Round 60: package liability pays the full win on ron and rob-gang, not only tsumo.
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


func complete_hand() -> Array:
	# 13-tile tenpai form that completes on 5W.
	return ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W"]


func tsumo_hand() -> Array:
	return ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W", "5W"]


func reset_table(scene) -> void:
	scene.players = [
		make_player("Packager"),
		make_player("Winner"),
		make_player("P2"),
		make_player("P3"),
	]
	scene.mode = "offline"
	scene.offline_phase = "resolving"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 1
	scene.dealer_seat = 2
	scene.last_discard = ""
	scene.last_discard_seat = -1
	scene.offline_pending_claim.clear()
	scene.offline_claim_counts.clear()
	scene.offline_package_liability.clear()
	scene.offline_passed_win_tiles.clear()
	scene.offline_claim_discard_bans.clear()
	scene.offline_concealed_gang_tiles.clear()
	scene.offline_last_draw.clear()
	scene.offline_self_draw_ready.clear()
	scene.offline_sim_quiet = true
	scene.wall = empty_wall()
	scene.last_win_score.clear()
	scene.last_score_deltas.clear()
	scene.offline_last_winner = -1
	scene.round_summary = ""
	for seat in range(4):
		scene.players[seat]["hand"] = []
		scene.players[seat]["discards"] = []
		scene.players[seat]["melds"] = []
		scene.players[seat]["score"] = 25000
		scene.last_score_deltas.append(0)


func run() -> void:
	print("=== ai_play_round60 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()

	print("--- A) package tsumo still charges the packager triple ---")
	reset_table(scene)
	scene.players[1]["hand"] = tsumo_hand()
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 1
	scene.offline_last_draw = {"seat": 1, "tile": "5W", "source": "normal", "wall_empty": false, "serial": 88}
	scene.offline_self_draw_ready = {"seat": 1, "tile": "5W", "serial": 88}
	scene.offline_package_liability[1] = 0
	var tsumo_points = int(scene.calculate_win_score(1, "5W", true).get("points", 0))
	check(scene.can_finish_offline_round(1, "5W", true, -1), "package tsumo remains finishable")
	scene.finish_offline_round(1, "5W", true, -1)
	check(int(scene.players[1]["score"]) == 25000 + tsumo_points * 3, "package tsumo winner receives triple")
	check(int(scene.players[0]["score"]) == 25000 - tsumo_points * 3, "package tsumo packager pays triple")
	check(int(scene.players[2]["score"]) == 25000 and int(scene.players[3]["score"]) == 25000, "package tsumo spares unrelated seats")
	check(bool(scene.last_win_score.get("package_payment", false)) and int(scene.last_win_score.get("package_payer", -1)) == 0, "tsumo records package payment metadata")
	check(scene.round_summary.find("包三搭") >= 0, "tsumo summary mentions package liability")

	print("--- B) package ron charges packager, not only the discarder ---")
	reset_table(scene)
	scene.players[1]["hand"] = complete_hand()
	scene.players[2]["discards"] = ["5W"]
	scene.last_discard = "5W"
	scene.last_discard_seat = 2
	scene.offline_phase = "resolving"
	scene.offline_package_liability[1] = 0
	var ron_points = int(scene.calculate_win_score(1, "5W", false).get("points", 0))
	check(scene.can_finish_offline_round(1, "5W", false, 2), "package ron remains finishable")
	scene.finish_offline_round(1, "5W", false, 2)
	check(int(scene.players[1]["score"]) == 25000 + ron_points * 3, "package ron winner receives triple")
	check(int(scene.players[0]["score"]) == 25000 - ron_points * 3, "package ron packager pays triple")
	check(int(scene.players[2]["score"]) == 25000, "discarder is spared when packager is liable")
	check(int(scene.players[3]["score"]) == 25000, "unrelated seat is spared on package ron")
	check(bool(scene.last_win_score.get("package_payment", false)) and int(scene.last_win_score.get("package_payer", -1)) == 0, "ron records package payment metadata")
	check(scene.round_summary.find("包三搭") >= 0, "ron summary mentions package liability")

	print("--- C) package rob-gang also charges the packager ---")
	reset_table(scene)
	scene.players[1]["hand"] = complete_hand()
	# Seat 3 is mid added-gang: open triplet plus the matching hand tile.
	scene.players[3]["melds"] = [["5W", "5W", "5W"]]
	scene.players[3]["hand"] = ["5W", "1T", "2T", "3T", "4T", "6T", "7T", "8T", "9T", "1B", "2B"]
	scene.current_seat = 3
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_package_liability[1] = 0
	var rob_points = int(scene.calculate_win_score(1, "5W", false, "rob_gang").get("points", 0))
	check(scene.can_finish_offline_round(1, "5W", false, 3, "rob_gang"), "package rob-gang remains finishable for AI path")
	scene.finish_offline_round(1, "5W", false, 3, "rob_gang")
	check(int(scene.players[1]["score"]) == 25000 + rob_points * 3, "package rob-gang winner receives triple")
	check(int(scene.players[0]["score"]) == 25000 - rob_points * 3, "package rob-gang packager pays triple")
	check(int(scene.players[3]["score"]) == 25000, "gang source is spared under package liability")
	check(bool(scene.last_win_score.get("package_payment", false)), "rob-gang records package payment")

	print("--- D) without package liability, ordinary ron still bills the discarder ---")
	reset_table(scene)
	scene.players[1]["hand"] = complete_hand()
	scene.players[2]["discards"] = ["5W"]
	scene.last_discard = "5W"
	scene.last_discard_seat = 2
	scene.offline_phase = "resolving"
	var plain_points = int(scene.calculate_win_score(1, "5W", false).get("points", 0))
	scene.finish_offline_round(1, "5W", false, 2)
	check(int(scene.players[1]["score"]) == 25000 + plain_points * 3, "plain ron winner receives triple")
	check(int(scene.players[2]["score"]) == 25000 - plain_points * 3, "plain ron discarder pays triple")
	check(int(scene.players[0]["score"]) == 25000 and int(scene.players[3]["score"]) == 25000, "plain ron spares non-dealers")
	check(not bool(scene.last_win_score.get("package_payment", false)), "plain ron does not mark package payment")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
