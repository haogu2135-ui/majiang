extends SceneTree
## Round 59: kuikae bans must not softlock when every hand tile is banned.
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
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 0
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
	print("=== ai_play_round59 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()

	print("--- A) installing all-hand bans auto-releases deadlock ---")
	reset_table(scene)
	scene.players[0]["hand"] = ["5W", "1W"]
	scene.set_claim_discard_bans(0, ["5W", "1W"])
	check(not scene.is_claim_discard_banned(0, "5W"), "all-hand ban set releases immediately")
	check(scene.is_valid_offline_discard(0, "5W"), "after auto-release the tile is discardable")

	print("--- B) choose_legal recovers after residual deadlock state ---")
	reset_table(scene)
	scene.players[1]["hand"] = ["4W", "1W"]
	scene.current_seat = 1
	# Force residual bans without going through set_claim_discard_bans auto-release.
	scene.offline_claim_discard_bans[1] = {"4W": true, "1W": true}
	check(scene.is_claim_discard_banned(1, "4W"), "fixture keeps residual bans")
	check(not scene.seat_has_unbanned_hand_tile(1), "fixture has no unbanned tile")
	var legal = scene.choose_legal_offline_discard_tile(1)
	check(legal == "4W" or legal == "1W", "legal chooser releases deadlock and returns a hand tile")
	check(not scene.is_claim_discard_banned(1, legal), "returned tile is no longer banned")
	check(scene.is_valid_offline_discard(1, legal), "returned tile is a valid offline discard")

	print("--- C) AI and bot-sim paths no longer pick banned hand[0] ---")
	reset_table(scene)
	scene.players[2]["hand"] = ["5W", "9B", "1T"]
	scene.current_seat = 2
	scene.set_claim_discard_bans(2, ["5W"])
	check(scene.is_claim_discard_banned(2, "5W"), "ordinary ban remains while alternatives exist")
	var ai_tile = scene.choose_ai_discard_for_seat(2)
	check(ai_tile != "" and ai_tile != "5W", "AI avoids banned tile when alternatives exist")
	check(scene.is_valid_offline_discard(2, ai_tile), "AI tile is legal")
	# Residual all-banned state must not fall back to illegal hand[0] in the chooser.
	scene.offline_claim_discard_bans[2] = {"5W": true, "9B": true, "1T": true}
	var recovered = scene.choose_ai_discard_for_seat(2)
	check(recovered != "", "AI recovers from all-banned residual state")
	check(scene.is_valid_offline_discard(2, recovered), "recovered AI discard is legal")
	check(scene.discard_tile_by_value(2, recovered) == recovered, "recovered discard commits")

	print("--- D) normal kuikae still blocks when a free tile remains ---")
	reset_table(scene)
	scene.players[0]["hand"] = ["5W", "5W", "1T", "2T", "3T"]
	scene.players[1]["discards"] = ["5W"]
	scene.last_discard = "5W"
	scene.last_discard_seat = 1
	scene.offline_phase = "resolving"
	scene.apply_offline_claim(0, 1, "5W", "peng")
	check(scene.is_claim_discard_banned(0, "5W"), "peng still bans claimed tile")
	check(not scene.is_valid_offline_discard(0, "5W"), "claimed tile remains blocked while free tiles exist")
	check(scene.is_valid_offline_discard(0, "1T"), "free tile remains available")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
