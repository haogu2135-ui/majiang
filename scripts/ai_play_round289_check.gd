extends SceneTree

var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if condition:
		print("  OK  | %s" % message)
	else:
		print("  FAIL| %s" % message)
		failed = true


func run() -> void:
	print("=== ai_play_round289 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.fast_mode_enabled = true
	scene.sfx_enabled = false
	scene.music_enabled = false
	scene.fx_enabled = false
	scene.mode = "offline"
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	scene.ai_benchmark_base_difficulty = scene.AI_DIFFICULTY_HARD
	scene.ai_benchmark_probe_seat = -1
	scene.ai_benchmark_probe_difficulty = -1
	scene.ensure_ai_benchmark_players()
	scene.enable_offline_all_bot_mode(true, true)
	scene.reset_ai_profile_seat_map()
	scene.players[0]["score"] = 32000
	scene.players[1]["score"] = 38000
	scene.players[2]["score"] = 15000
	scene.players[3]["score"] = 15000
	scene.offline_hand_number = scene.MATCH_MAX_HANDS - 2
	scene.dealer_seat = 0
	scene.offline_skip_ai_profile_reshuffle = true
	scene.ai_sim_trace_enabled = true
	seed(20260924)
	scene.deal_offline_hand()
	var opening_context: Dictionary = scene.score_context_report(0)
	var opening_reports: Array = scene.get_ai_discard_reports(0)
	var opening_attack: float = float(opening_reports[0].get("ai_attack_multiplier", 1.0)) if not opening_reports.is_empty() else 1.0
	print("    opening hand=%d standings=%s context=%s attack=%.3f" % [scene.offline_hand_number, str(scene.players.map(func(player): return int(player.get("score", 0)))), str(opening_context), opening_attack])
	check(int(opening_context.get("rank", 0)) == 2 and int(opening_context.get("leader_gap", 0)) <= -1800, "late match starts with a second-place AI trailing the leader")
	check(str(opening_context.get("strategy", "")) == "追分" and opening_attack > 1.0, "live endgame discard reports receive chase weighting")
	check(not opening_reports.is_empty(), "dealer receives a ranked opening discard report")

	var completed_hands := 0
	var first_seat_zero_discard_confirmed := false
	while completed_hands < 12:
		var result: Dictionary = scene.simulate_offline_bot_hand_sync(700)
		completed_hands += 1
		check(bool(result.get("ended", false)), "endgame hand %d reaches a terminal result" % completed_hands)
		check(bool(result.get("integrity_ok", false)), "endgame hand %d conserves the tile ledger" % completed_hands)
		check(bool(result.get("score_conserved", false)), "endgame hand %d conserves table points" % completed_hands)
		if completed_hands == 1:
			var trace: Array = result.get("discard_trace", [])
			for entry in trace:
				if typeof(entry) != TYPE_DICTIONARY or int(entry.get("seat", -1)) != 0:
					continue
				first_seat_zero_discard_confirmed = str(entry.get("tile", "")) == str(opening_reports[0].get("tile", ""))
				break
			check(first_seat_zero_discard_confirmed, "first live seat-zero discard follows the chase-weighted report")
		if scene.is_offline_match_finished():
			break
		var previous_hand_number := int(scene.offline_hand_number)
		scene.start_next_offline_hand(false)
		check(scene.offline_phase == "await_discard", "match advances to the next dealt endgame hand")
		check(int(scene.offline_hand_number) == previous_hand_number or int(scene.offline_hand_number) == previous_hand_number + 1, "dealer repeat or hand progression preserves match numbering")
	check(completed_hands >= 3 and scene.is_offline_match_finished(), "cumulative match reaches its configured final hand")
	var final_score_total := 0
	for player in scene.players:
		final_score_total += int(player.get("score", 0))
	check(final_score_total == 100000, "cumulative endgame preserves the initial 100000-point table")
	check(not scene.last_match_summary.is_empty(), "final-hand settlement produces a match summary")

	scene.ai_sim_trace_enabled = false
	scene.enable_offline_all_bot_mode(false, false)
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
