extends SceneTree
## Round 58: post-claim kuikae bans block immediate swap discards for players and AI.
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


func reset_table(scene) -> void:
	scene.players = [
		make_player("Self"),
		make_player("Left"),
		make_player("Across"),
		make_player("Right"),
	]
	scene.mode = "offline"
	scene.offline_phase = "resolving"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 1
	scene.dealer_seat = 0
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
	for seat in range(4):
		scene.players[seat]["hand"] = []
		scene.players[seat]["discards"] = []
		scene.players[seat]["melds"] = []


func run() -> void:
	print("=== ai_play_round58 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()

	print("--- A) helper: peng bans same tile, edge chi bans swap tile ---")
	check(scene.claim_discard_ban_tiles("peng", "5W") == ["5W"], "peng only bans claimed tile")
	var chi_low = scene.claim_discard_ban_tiles("chi", "2W", ["2W", "3W", "4W"])
	check(chi_low.has("2W") and chi_low.has("5W") and chi_low.size() == 2, "chi low-end 234 bans 2 and 5")
	var chi_high = scene.claim_discard_ban_tiles("chi", "4W", ["2W", "3W", "4W"])
	check(chi_high.has("4W") and chi_high.has("1W") and chi_high.size() == 2, "chi high-end 234 bans 4 and 1")
	var chi_mid = scene.claim_discard_ban_tiles("chi", "3W", ["2W", "3W", "4W"])
	check(chi_mid == ["3W"], "chi middle only bans claimed tile")
	check(scene.claim_discard_ban_tiles("gang", "5W", ["5W", "5W", "5W", "5W"]).is_empty(), "open gang has no immediate kuikae ban")

	print("--- B) peng claim hard-blocks immediate same-tile discard ---")
	reset_table(scene)
	# Seat 0 holds two 5W plus fillers; seat 1 discards 5W for peng.
	scene.players[0]["hand"] = ["5W", "5W", "1T", "2T", "3T", "4T", "6T", "7T", "8T", "9T", "1B", "2B", "3B"]
	scene.players[1]["discards"] = ["5W"]
	scene.last_discard = "5W"
	scene.last_discard_seat = 1
	scene.offline_phase = "resolving"
	check(scene.is_valid_offline_claim(0, 1, "5W", "peng"), "peng claim is legal before apply")
	scene.apply_offline_claim(0, 1, "5W", "peng")
	check(scene.offline_phase == "await_discard" and scene.current_seat == 0, "peng moves seat 0 into discard window")
	check(scene.is_claim_discard_banned(0, "5W"), "peng marks claimed tile as banned")
	check(not scene.is_valid_offline_discard(0, "5W"), "hard rule rejects banned same-tile discard")
	check(scene.is_valid_offline_discard(0, "1T"), "non-banned tile remains discardable")
	var before_hand = scene.players[0]["hand"].duplicate()
	check(scene.discard_tile_by_value(0, "5W") == "", "commit path refuses banned peng swap")
	check(scene.players[0]["hand"] == before_hand, "refused discard leaves hand unchanged")
	check(scene.discard_tile_by_value(0, "1T") == "1T", "legal discard after peng still works")
	check(not scene.is_claim_discard_banned(0, "5W"), "successful discard clears kuikae bans")

	print("--- C) edge chi bans swap tile for AI reports ---")
	reset_table(scene)
	# After chi 4W into 2W3W4W, hand keeps another 4W and a 1W swap candidate.
	# Chi is only legal from the previous seat, so source must be seat 3.
	scene.players[0]["hand"] = ["2W", "3W", "4W", "1W", "6W", "7W", "8W", "1T", "2T", "3T", "4T", "5T", "6T"]
	scene.players[0]["bot"] = true
	scene.players[3]["discards"] = ["4W"]
	scene.last_discard = "4W"
	scene.last_discard_seat = 3
	scene.offline_phase = "resolving"
	var chi_choice = {"needed": ["2W", "3W"], "meld": ["2W", "3W", "4W"]}
	check(scene.is_valid_offline_claim(0, 3, "4W", "chi", chi_choice), "edge chi claim is legal")
	scene.apply_offline_claim(0, 3, "4W", "chi", chi_choice)
	check(scene.is_claim_discard_banned(0, "4W") and scene.is_claim_discard_banned(0, "1W"), "edge chi bans claimed tile and swap tile")
	var reports = scene.get_ai_discard_reports(0)
	var reported_tiles: Array = []
	for report in reports:
		if typeof(report) == TYPE_DICTIONARY:
			reported_tiles.append(str(report.get("tile", "")))
	check(not reported_tiles.has("4W") and not reported_tiles.has("1W"), "AI discard reports omit kuikae-banned tiles")
	var ai_tile = scene.choose_ai_discard_for_seat(0)
	check(ai_tile != "" and ai_tile != "4W" and ai_tile != "1W", "AI choose_ai_discard avoids kuikae bans")
	check(scene.is_valid_offline_discard(0, ai_tile), "AI selected tile remains legally discardable")

	print("--- D) real draw clears leftover bans ---")
	reset_table(scene)
	scene.players[0]["hand"] = ["1T", "2T", "3T", "4T", "5T", "6T", "7T", "8T", "9T", "1B", "2B", "3B"]
	scene.set_claim_discard_bans(0, ["5W", "1W"])
	check(scene.is_claim_discard_banned(0, "5W"), "fixture installed bans")
	var draw_wall: Array[String] = ["9B"]
	scene.wall = draw_wall
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.offline_turn_needs_draw = true
	check(scene.draw_tile_for(0, false) == "9B", "fixture draws a real tile")
	check(not scene.is_claim_discard_banned(0, "5W") and not scene.is_claim_discard_banned(0, "1W"), "draw clears claim discard bans")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
