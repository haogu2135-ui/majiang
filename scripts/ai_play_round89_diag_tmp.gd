extends SceneTree

func _initialize() -> void:
	call_deferred("run")


func simulate_hand(scene, wall_seed: int, hand_index: int, difficulty: int) -> Dictionary:
	scene.ai_difficulty = difficulty
	scene.ai_benchmark_base_difficulty = difficulty
	scene.ai_benchmark_probe_seat = 0
	scene.ai_benchmark_probe_difficulty = scene.AI_DIFFICULTY_NORMAL
	scene.enable_offline_all_bot_mode(true, true)
	scene.reset_ai_profile_seat_map()
	seed(wall_seed)
	scene.offline_skip_ai_profile_reshuffle = true
	scene.mode = "offline"
	scene.offline_hand_number = 1
	scene.dealer_seat = hand_index % 4
	for seat in range(4):
		scene.players[seat]["score"] = scene.MATCH_START_SCORE
	scene.deal_offline_hand()
	scene.reset_ai_profile_seat_map()
	return scene.simulate_offline_bot_hand_sync(700)


func print_loss_trace(label: String, result: Dictionary) -> void:
	print("%s winner=%d self_draw=%s actor=%d terminal_step=%d tile=%s" % [label, int(result.get("winner", -1)), str(result.get("self_draw", false)), int(result.get("deal_in_seat", -1)), int(result.get("terminal_trace_step", -1)), str(result.get("terminal_tile", ""))])
	var trace: Array = result.get("discard_trace", [])
	var terminal_step := int(result.get("terminal_trace_step", -1))
	for index in range(trace.size() - 1, -1, -1):
		if typeof(trace[index]) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = trace[index]
		if int(entry.get("step", -1)) != terminal_step:
			continue
		print("  selected tile=%s seat=%d risk=%.1f feed=%.1f pressure=%.1f exposure=%.1f shanten=%d score=%.1f rank=%d best=%s(%.1f/%.1f) safest=%s(%.1f/%.1f sh=%d) guard=%s human_emergency=%s wait=%d/%d" % [str(entry.get("tile", "")), int(entry.get("seat", -1)), float(entry.get("risk", 0.0)), float(entry.get("feed", 0.0)), float(entry.get("human_pressure", 0.0)), float(entry.get("human_exposure", 0.0)), int(entry.get("shanten", -1)), float(entry.get("score", 0.0)), int(entry.get("selected_rank", -1)), str(entry.get("best_tile", "")), float(entry.get("best_risk", 0.0)), float(entry.get("best_feed", 0.0)), str(entry.get("safest_tile", "")), float(entry.get("safest_risk", 0.0)), float(entry.get("safest_feed", 0.0)), int(entry.get("safest_shanten", -1)), str(entry.get("hard_guard_moved", false)), str(entry.get("hard_guard_human_exposure_tenpai", false)), int(entry.get("wait_best_points", 0)), int(entry.get("wait_total_remaining", 0))])
		var fast_candidates: Array = entry.get("fast_candidates", [])
		for candidate in fast_candidates:
			if typeof(candidate) != TYPE_DICTIONARY:
				continue
			print("    fast tile=%s retained=%s safest=%s sh=%d risk=%.1f feed=%.1f pressure=%.1f" % [str(candidate.get("tile", "")), str(candidate.get("retained_for_full_eval", false)), str(candidate.get("safest_fast_candidate", false)), int(candidate.get("shanten", -1)), float(candidate.get("risk", 0.0)), float(candidate.get("feed_score", 0.0)), float(candidate.get("human_pressure", 0.0))])
		for candidate in entry.get("hard_guard_candidates", []):
			if typeof(candidate) != TYPE_DICTIONARY:
				continue
			print("    guard tile=%s delta=%d risk=%.1f feed=%.1f exposure=%.1f gap=%.1f gain=%.1f rejected=%s" % [str(candidate.get("tile", "")), int(candidate.get("shanten_delta", -1)), float(candidate.get("risk", 0.0)), float(candidate.get("feed_risk", 0.0)), float(candidate.get("human_target_exposure", 0.0)), float(candidate.get("score_gap", 0.0)), float(candidate.get("pressure_gain", 0.0)), str(candidate.get("rejection_reason", ""))])
		break


func run() -> void:
	print("=== Round 89 ron-loss diagnostics ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.fast_mode_enabled = true
	scene.sfx_enabled = false
	scene.music_enabled = false
	scene.fx_enabled = false
	scene.ensure_ai_benchmark_players()
	scene.ai_sim_trace_enabled = true
	var replay_cases: Array = [[20260753, 0], [20260753, 1]]
	var losses := 0
	for replay_case in replay_cases:
		var seed_base := int(replay_case[0])
		var hand_index := int(replay_case[1])
		var wall_seed := seed_base + hand_index * 17
		var hard_result := simulate_hand(scene, wall_seed, hand_index, scene.AI_DIFFICULTY_HARD)
		if int(hard_result.get("winner", -1)) != 0 or bool(hard_result.get("self_draw", false)):
			continue
		losses += 1
		print_loss_trace("HARD seed=%d hand=%d" % [seed_base, hand_index], hard_result)
		var easy_result := simulate_hand(scene, wall_seed, hand_index, scene.AI_DIFFICULTY_EASY)
		print_loss_trace("EASY seed=%d hand=%d" % [seed_base, hand_index], easy_result)
	print("=== ron losses traced: %d ===" % losses)
	scene.ai_sim_trace_enabled = false
	scene.enable_offline_all_bot_mode(false, false)
	scene.queue_free()
	quit(0)
