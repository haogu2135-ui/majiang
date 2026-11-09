extends "res://scripts/ui_interaction_smoke_test.gd"


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if condition:
		print("  OK  | %s" % message)
	else:
		print("  FAIL| %s" % message)
		failed = true


func make_player(seat: int) -> Dictionary:
	return {"name": "P%d" % seat, "hand": [], "hand_instance_serials": [], "discards": [], "melds": [], "flowers": 0, "flower_tiles": [], "score": 25000, "bot": seat != 0}


func prepare_conserved_table(scene: Node, public_copies: int, open_hand: bool = false) -> void:
	scene.cancel_offline_ai_run()
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.current_seat = 1
	scene.dealer_seat = 1
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	scene.ai_benchmark_base_difficulty = -1
	scene.ai_benchmark_probe_seat = -1
	scene.ai_benchmark_probe_difficulty = -1
	scene.active_round_id = "candidate-inventory-%d-%s" % [public_copies, open_hand]
	scene.offline_pending_claim.clear()
	scene.offline_passed_win_tiles.clear()
	scene.offline_claim_discard_bans.clear()
	scene.offline_concealed_gang_tiles.clear()
	scene.offline_claim_counts.clear()
	scene.offline_package_liability.clear()
	scene.players = [make_player(0), make_player(1), make_player(2), make_player(3)]
	scene.wall = scene.make_wall()
	var hand: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E", "E", "5B", "5B"]
	if open_hand:
		hand = ["E", "E", "E", "5B", "5B"]
		scene.players[1]["melds"] = [["1W", "2W", "3W"], ["4W", "5W", "6W"], ["7T", "8T", "9T"]]
		for meld in scene.players[1]["melds"]:
			for tile in meld:
				scene.wall.erase(str(tile))
	scene.players[1]["hand"] = hand
	for tile in hand:
		scene.wall.erase(str(tile))
	for copy_index in range(public_copies):
		scene.players[2]["discards"].append("5B")
		scene.wall.erase("5B")
	for seat in [0, 2, 3]:
		while scene.players[seat]["hand"].size() < 13:
			var tile: String = scene.wall.pop_back()
			if scene.is_flower_tile(tile):
				scene.players[seat]["flower_tiles"].append(tile)
				scene.players[seat]["flowers"] += 1
			else:
				scene.players[seat]["hand"].append(tile)
	scene.last_discard = "5B" if public_copies > 0 else ""
	scene.last_discard_seat = 2 if public_copies > 0 else -1
	scene.offline_last_draw = {"seat": 1, "tile": "5B", "source": "normal", "serial": 298, "wall_empty": false}
	scene.offline_self_draw_ready = {"seat": 1, "tile": "5B", "serial": 298}
	scene.round_event_history.clear()
	scene.round_event_sequence = 0
	scene.record_round_event("round_start", {"dealer": 1, "seed": 298, "rule_variant": scene.RULE_VARIANT_YANGZHOU})
	scene.clear_ai_report_cache()
	check(scene.offline_tile_ledger_report().get("ok", false), "the controlled candidate table conserves every physical tile and flower")


func candidate_report(scene: Node, tile: String, visible: Array, context: Dictionary) -> Dictionary:
	var hand: Array = scene.players[1]["hand"]
	var simulated: Array = hand.duplicate()
	simulated.erase(tile)
	return scene.build_ai_discard_report(1, tile, simulated, scene.players[1]["melds"].size(), visible, {}, context, scene.tile_counts(simulated), scene.tile_counts(hand))


func snapshot(scene: Node) -> Dictionary:
	return {"players": scene.players.duplicate(true), "wall": scene.wall.duplicate(), "phase": scene.offline_phase, "seat": scene.current_seat, "events": scene.round_event_history.duplicate(true), "last_draw": scene.offline_last_draw.duplicate(true)}


func check_projection(scene: Node, public_copies: int, quiet: bool, open_hand: bool = false) -> void:
	scene.offline_sim_quiet = quiet
	prepare_conserved_table(scene, public_copies, open_hand)
	var visible: Array = scene.visible_tile_counts_shared()
	var context: Dictionary = scene.make_ai_evaluation_context(1, visible)
	var self_discards: Dictionary = scene.ai_context_self_discard_lookup(context, 1)
	var visible_before: Array = visible.duplicate()
	var context_inputs := {"visible": context.get("visible_counts", []).duplicate(), "known": context.get("known_counts", []).duplicate(), "river": self_discards.duplicate()}
	var before := snapshot(scene)
	var risk_before: Dictionary = scene.deal_in_risk_summary("5B", 1, visible, {}, context, scene.tile_index_normalized("5B"))
	var feed_before: Dictionary = scene.discard_feed_risk_report("5B", 1, visible, context, scene.tile_index_normalized("5B"))
	var simulated: Array = scene.players[1]["hand"].duplicate()
	simulated.erase("5B")
	var cached_before: Dictionary = scene.effective_tile_metrics(simulated, scene.players[1]["melds"].size(), 1, 0, visible).duplicate(true)
	var report := candidate_report(scene, "5B", visible, context)
	var expected_remaining := 2 - public_copies
	check(int(cached_before.get("remaining_by_tile", {}).get("5B", 0)) == expected_remaining + 1, "the pre-discard metric cache is explicitly warmed with a distinct inventory snapshot")
	check(int(report.get("effective_remaining", {}).get("5B", 0)) == expected_remaining, "a %s %s candidate excludes its own discarded copy from remaining waits" % ["quiet" if quiet else "visible", "open" if open_hand else "closed"])
	check(int(report.get("ukeire", -1)) == expected_remaining and int(report.get("wait_total_remaining", -1)) == expected_remaining, "candidate ukeire and valued waits agree with physical unseen inventory")
	if expected_remaining > 0:
		check(report.get("wait_self_discarded", []).has("5B"), "the planned discard marks its own winning face as self-discarded")
		check(is_equal_approx(float(report.get("wait_adjusted_remaining", -1.0)), float(expected_remaining) * 0.62), "candidate wait quality applies the existing self-discard penalty")
	else:
		check(not report.get("effective_tiles", []).has("5B") and int(report.get("variety", -1)) == 0, "a fourth known copy cannot create a phantom live wait")
	check(snapshot(scene) == before and visible == visible_before and context.get("visible_counts", []) == context_inputs["visible"] and context.get("known_counts", []) == context_inputs["known"] and self_discards == context_inputs["river"], "candidate projection leaves the live table and shared evaluation snapshots unchanged")
	check(is_equal_approx(float(report.get("risk", -1.0)), float(risk_before.get("score", -2.0))) and is_equal_approx(float(report.get("feed_risk", -1.0)), float(feed_before.get("score", -2.0))), "discard risk and meld-feed risk retain their pre-commit visibility boundary")
	check(scene.effective_tile_metrics(simulated, scene.players[1]["melds"].size(), 1, 0, visible) == cached_before, "projected wait metrics do not overwrite the unprojected cache entry")
	var reports: Array = scene.get_ai_discard_reports(1)
	check(not reports.is_empty(), "the production candidate list still provides legal evaluated choices")
	var found := false
	var counts: Array = scene.tile_counts(scene.players[1]["hand"])
	var inventory_ok := true
	for candidate in reports:
		for wait_tile in candidate.get("effective_remaining", {}):
			var wait_index: int = scene.tile_index_normalized(str(wait_tile))
			inventory_ok = inventory_ok and int(candidate["effective_remaining"][wait_tile]) == maxi(0, 4 - int(visible[wait_index]) - int(counts[wait_index]))
		if str(candidate.get("tile", "")) == "5B":
			found = true
			check(int(candidate.get("effective_remaining", {}).get("5B", 0)) == expected_remaining and int(candidate.get("ukeire", -1)) == expected_remaining, "the production candidate list exposes the corrected physical wait count")
	check(inventory_ok, "every retained production candidate respects public plus original-hand copy counts")
	if not quiet or open_hand:
		check(found, "unpruned production evaluation retains the legal planned pair discard")
	check(scene.commit_discard(1, "5B"), "the conserved candidate commits through the real discard boundary")
	var committed_hand: Array = scene.players[1]["hand"]
	var committed_visible: Array = scene.visible_tile_counts_shared()
	var actual: Dictionary = scene.effective_tile_metrics(committed_hand, scene.players[1]["melds"].size(), 1, 0, committed_visible)
	check(report.get("effective_remaining", {}) == actual.get("remaining_by_tile", {}) and int(report.get("ukeire", -1)) == int(actual.get("count", -2)), "pre-commit candidate inventory matches independently measured post-commit inventory")
	var committed_counts: Array = scene.tile_counts(committed_hand)
	var committed_report: Dictionary = scene.build_ai_discard_report(1, "5B", committed_hand, scene.players[1]["melds"].size(), committed_visible, {}, {}, committed_counts, committed_counts)
	check(int(committed_report.get("ukeire", -1)) == expected_remaining, "already-committed diagnostics do not count the same river copy twice")
	check(scene.offline_tile_ledger_report().get("ok", false), "projected and actual discard paths preserve the complete tile ledger")


func check_hidden_information(scene: Node) -> void:
	scene.offline_sim_quiet = false
	prepare_conserved_table(scene, 0)
	var original := candidate_report(scene, "5B", scene.visible_tile_counts_shared(), {})
	var hidden_tile: String = scene.players[3]["hand"][0]
	var wall_tile: String = scene.wall[0]
	scene.players[3]["hand"][0] = wall_tile
	scene.wall[0] = hidden_tile
	scene.clear_ai_report_cache()
	var swapped := candidate_report(scene, "5B", scene.visible_tile_counts_shared(), {})
	check(scene.offline_tile_ledger_report().get("ok", false), "the hidden-information swap preserves all four-copy counts")
	check(original.get("effective_remaining", {}) == swapped.get("effective_remaining", {}) and is_equal_approx(float(original.get("wait_value", -1.0)), float(swapped.get("wait_value", -2.0))), "candidate wait projection does not inspect concealed opponents or wall order")


func run() -> void:
	print("=== ai_play_round298 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	var user_state := capture_smoke_state(scene)
	scene.set_process(false)
	scene.music_enabled = false
	scene.sfx_enabled = false
	scene.tts_enabled = false
	scene.fx_enabled = false
	scene.ai_assist_enabled = false
	scene.setup_tile_order()
	for quiet in [true, false]:
		for public_copies in [0, 1, 2]:
			check_projection(scene, public_copies, quiet)
		check_projection(scene, 0, quiet, true)
	check_hidden_information(scene)
	scene.shutdown_runtime()
	restore_smoke_state(scene, user_state)
	scene.queue_free()
	await process_frame
	print("=== RESULT: %s ===" % ("FAIL" if failed else "OK"))
	quit(1 if failed else 0)
