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


func run_hand(scene, difficulty: int, seed_base: int, hand_index: int) -> Dictionary:
	scene.enable_offline_all_bot_mode(true, true)
	scene.ai_difficulty = difficulty
	scene.ai_benchmark_base_difficulty = difficulty
	scene.ai_benchmark_probe_seat = 0
	scene.ai_benchmark_probe_difficulty = scene.AI_DIFFICULTY_NORMAL
	scene.reset_ai_profile_seat_map()
	seed(seed_base + hand_index * 17)
	scene.offline_skip_ai_profile_reshuffle = true
	scene.mode = "offline"
	scene.offline_hand_number = 1
	scene.dealer_seat = hand_index % 4
	for seat in range(4):
		scene.players[seat]["score"] = scene.MATCH_START_SCORE
	scene.deal_offline_hand()
	scene.reset_ai_profile_seat_map()
	var result: Dictionary = scene.simulate_offline_bot_hand_sync(700)
	result["probe_score_delta"] = int(scene.players[0].get("score", scene.MATCH_START_SCORE)) - scene.MATCH_START_SCORE
	return result


func print_terminal_window(seed_base: int, difficulty: int, hand_index: int, result: Dictionary) -> void:
	var trace: Array = result.get("discard_trace", [])
	var terminal_step := int(result.get("terminal_trace_step", -1))
	var terminal_tile := str(result.get("terminal_tile", ""))
	var window: Array = []
	for item in trace:
		if typeof(item) == TYPE_DICTIONARY and int(item.get("step", -2)) >= terminal_step - 3 and int(item.get("step", -2)) <= terminal_step:
			window.append(item)
	print("    seed=%d diff=%d hand=%d deal_in=%d winner=%d tile=%s terminal_step=%d" % [
		seed_base,
		difficulty,
		hand_index,
		int(result.get("deal_in_seat", -1)),
		int(result.get("terminal_winner", -1)),
		terminal_tile,
		terminal_step,
	])
	for item in window:
		print("      step=%d seat=%d tile=%s risk=%.1f feed=%.1f human=%.1f humanRisk=%.1f sh=%d wait=%d/%d/%.1f thin_guard=%s safety=%s score=%.1f best=%s/%.1f/%.1f/sh%d safest=%s/%.1f/%.1f/h%.1f/r%.1f/sh%d score=%.1f avoid=%s gain=%.1f hard2=%s safe=%s gap=%.1f gain=%.1f moved=%s fast_safe=%s" % [
			int(item.get("step", -1)),
			int(item.get("seat", -1)),
			str(item.get("tile", "")),
			float(item.get("risk", 0.0)),
			float(item.get("feed", 0.0)),
			float(item.get("human_pressure", 0.0)),
			float(item.get("human_risk", 0.0)),
			int(item.get("shanten", -1)),
			int(item.get("wait_best_points", 0)),
			int(item.get("wait_total_remaining", 0)),
			float(item.get("wait_value", 0.0)),
			str(item.get("hard_guard_catastrophe_tenpai", false)),
			str(item.get("safety", "")),
			float(item.get("score", 0.0)),
			str(item.get("best_tile", "")),
			float(item.get("best_risk", 0.0)),
			float(item.get("best_feed", 0.0)),
			int(item.get("best_shanten", -1)),
			str(item.get("safest_tile", "")),
			float(item.get("safest_risk", 0.0)),
			float(item.get("safest_feed", 0.0)),
			float(item.get("safest_human_pressure", 0.0)),
			float(item.get("safest_human_risk", 0.0)),
			int(item.get("safest_shanten", -1)),
			float(item.get("safest_score", 0.0)),
			str(item.get("avoidable_candidate_tile", "")),
			float(item.get("avoidable_pressure_gain", 0.0)),
			str(item.get("hard_guard_two_away", false)),
			str(item.get("hard_guard_safe_tile", "")),
			float(item.get("hard_guard_safe_score_gap", 0.0)),
			float(item.get("hard_guard_safe_pressure_gain", 0.0)),
			str(item.get("hard_guard_moved", false)),
			str(item.get("fast_safety_preserved", false)),
		])
		for guard_candidate in item.get("hard_guard_candidates", []):
			if typeof(guard_candidate) != TYPE_DICTIONARY:
				continue
			print("        guard_candidate=%s sh_delta=%d risk=%.1f feed=%.1f human=%.1f humanRisk=%.1f safety=%s gap=%.1f/%.1f gain=%.1f/%.1f reject=%s" % [
				str(guard_candidate.get("tile", "")),
				int(guard_candidate.get("shanten_delta", 0)),
				float(guard_candidate.get("risk", 0.0)),
				float(guard_candidate.get("feed_risk", 0.0)),
				float(guard_candidate.get("human_target_pressure", 0.0)),
				float(guard_candidate.get("human_target_risk", 0.0)),
				str(guard_candidate.get("safety_label", "")),
				float(guard_candidate.get("score_gap", 0.0)),
				float(guard_candidate.get("max_score_gap", 0.0)),
				float(guard_candidate.get("pressure_gain", 0.0)),
				float(guard_candidate.get("minimum_pressure_gain", 0.0)),
				str(guard_candidate.get("rejection_reason", "")),
			])
		for fast_candidate in item.get("fast_candidates", []):
			if typeof(fast_candidate) != TYPE_DICTIONARY:
				continue
			print("        fast_candidate=%s sh=%d risk=%.1f human=%.1f humanRisk=%.1f feed=%.1f human_feed=%.1f safety=%s rank=%.1f cheap=%.1f retained=%s safest=%s" % [
				str(fast_candidate.get("tile", "")),
				int(fast_candidate.get("shanten", 8)),
				float(fast_candidate.get("risk", 0.0)),
				float(fast_candidate.get("human_pressure", 0.0)),
				float(fast_candidate.get("human_risk", 0.0)),
				float(fast_candidate.get("feed_score", 0.0)),
				float(fast_candidate.get("human_feed", 0.0)),
				str(fast_candidate.get("safety", "")),
				float(fast_candidate.get("safety_rank", 0.0)),
				float(fast_candidate.get("cheap_score", 0.0)),
				str(fast_candidate.get("retained_for_full_eval", false)),
				str(fast_candidate.get("safest_fast_candidate", false)),
			])
		for report_candidate in item.get("report_candidates", []):
			if typeof(report_candidate) != TYPE_DICTIONARY:
				continue
			print("        report_candidate=%s sh=%d score=%.1f risk=%.1f feed=%.1f human=%.1f humanRisk=%.1f exposure=%.1f safety=%s wait=%d/%d" % [
				str(report_candidate.get("tile", "")),
				int(report_candidate.get("shanten", -1)),
				float(report_candidate.get("score", 0.0)),
				float(report_candidate.get("risk", 0.0)),
				float(report_candidate.get("feed", 0.0)),
				float(report_candidate.get("human_pressure", 0.0)),
				float(report_candidate.get("human_risk", 0.0)),
				float(report_candidate.get("human_exposure", 0.0)),
				str(report_candidate.get("safety", "")),
				int(report_candidate.get("wait_best_points", 0)),
				int(report_candidate.get("wait_total_remaining", 0)),
			])
	check(not window.is_empty(), "seed %d diff %d hand %d records its terminal discard window" % [seed_base, difficulty, hand_index])


func run() -> void:
	print("=== ai_play_round291 check START ===")
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
	var seeds: Array[int] = [20260701, 20260753, 20260805, 20260819, 20260843]
	var requested_seed_arguments := OS.get_cmdline_user_args()
	if not requested_seed_arguments.is_empty():
		seeds.clear()
		for seed_argument in requested_seed_arguments:
			seeds.append(int(seed_argument))
	var probe_rons := {scene.AI_DIFFICULTY_EASY: 0, scene.AI_DIFFICULTY_HARD: 0}
	var probe_wins := {scene.AI_DIFFICULTY_EASY: 0, scene.AI_DIFFICULTY_HARD: 0}
	var probe_score_delta := {scene.AI_DIFFICULTY_EASY: 0, scene.AI_DIFFICULTY_HARD: 0}
	for seed_base in seeds:
		for difficulty in [scene.AI_DIFFICULTY_EASY, scene.AI_DIFFICULTY_HARD]:
			for hand_index in range(2):
				var result: Dictionary = run_hand(scene, difficulty, seed_base, hand_index)
				check(bool(result.get("ended", false)), "seed %d diff %d hand %d terminates" % [seed_base, difficulty, hand_index])
				var result_winner := int(result.get("winner", -1))
				if result_winner == 0:
					probe_wins[difficulty] = int(probe_wins.get(difficulty, 0)) + 1
				probe_score_delta[difficulty] = int(probe_score_delta.get(difficulty, 0)) + int(result.get("probe_score_delta", 0))
				for trace_item in result.get("discard_trace", []):
					if typeof(trace_item) != TYPE_DICTIONARY or not bool(trace_item.get("hard_guard_catastrophe_tenpai", false)):
						continue
					print("    guard_event seed=%d diff=%d hand=%d step=%d tile=%s moved=%s from=%s risk=%.1f feed=%.1f human=%.1f wait=%d/%d" % [
						seed_base,
						difficulty,
						hand_index,
						int(trace_item.get("step", -1)),
						str(trace_item.get("tile", "")),
						str(trace_item.get("hard_guard_moved", false)),
						str(trace_item.get("hard_guard_from_tile", "")),
						float(trace_item.get("risk", 0.0)),
						float(trace_item.get("feed", 0.0)),
						float(trace_item.get("human_pressure", 0.0)),
						int(trace_item.get("wait_best_points", 0)),
						int(trace_item.get("wait_total_remaining", 0)),
					])
				if int(result.get("deal_ins_to_human", 0)) > 0:
					probe_rons[difficulty] = int(probe_rons.get(difficulty, 0)) + 1
					print_terminal_window(seed_base, difficulty, hand_index, result)
				print("    outcome seed=%d diff=%d hand=%d winner=%d probe_score=%+d ron_to_probe=%d" % [
					seed_base,
					difficulty,
					hand_index,
					result_winner,
					int(result.get("probe_score_delta", 0)),
					int(result.get("deal_ins_to_human", 0)),
				])
	print("    replayed fixed-player rons easy/hard=%d/%d" % [
		int(probe_rons.get(scene.AI_DIFFICULTY_EASY, 0)),
		int(probe_rons.get(scene.AI_DIFFICULTY_HARD, 0)),
	])
	print("    fixed-player outcomes easy/hard wins=%d/%d score_delta=%+d/%+d (%d paired hands each)" % [
		int(probe_wins.get(scene.AI_DIFFICULTY_EASY, 0)),
		int(probe_wins.get(scene.AI_DIFFICULTY_HARD, 0)),
		int(probe_score_delta.get(scene.AI_DIFFICULTY_EASY, 0)),
		int(probe_score_delta.get(scene.AI_DIFFICULTY_HARD, 0)),
		seeds.size() * 2,
	])
	scene.ai_sim_trace_enabled = false
	scene.enable_offline_all_bot_mode(false, false)
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
