extends SceneTree
## Round 75: compact per-seed decision traces expose the terminal deal-in path without normal-play overhead.
var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(cond: bool, msg: String) -> void:
	if cond:
		print("  OK  | %s" % msg)
	else:
		print("  FAIL| %s" % msg)
		failed = true


func run_hand(scene, difficulty: int, seed_base: int, hand_index: int) -> Dictionary:
	scene.enable_offline_all_bot_mode(true, true)
	scene.ai_difficulty = difficulty
	scene.ai_benchmark_base_difficulty = difficulty
	scene.ai_benchmark_probe_seat = -1
	scene.ai_benchmark_probe_difficulty = -1
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
	return scene.simulate_offline_bot_hand_sync(700)


func run() -> void:
	print("=== ai_play_round75 check START ===")
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

	print("--- A) hard two-away emergency guard ---")
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var guard_reports: Array = [
		{"tile": "4W", "score": 900.0, "shanten": 2, "risk": 61.2, "feed_risk": 50.7, "human_target_pressure": 37.7, "safety_label": "现"},
		{"tile": "9T", "score": 287.5, "shanten": 2, "risk": 41.3, "feed_risk": 33.0, "human_target_pressure": 40.8, "safety_label": "壁"},
	]
	scene.apply_hard_danger_push_guard(guard_reports)
	check(str(guard_reports[0].get("tile", "")) == "9T", "hard catastrophic two-away state promotes a same-shanten safe fold")
	var thin_tenpai_reports: Array = [
		{"tile": "7W", "score": 900.0, "shanten": 0, "risk": 56.8, "feed_risk": 51.3, "human_target_pressure": 16.4, "wait_best_points": 400, "wait_total_remaining": 4, "safety_label": ""},
		{"tile": "S", "score": 224.2, "shanten": 1, "risk": 28.7, "feed_risk": 26.1, "human_target_pressure": 24.7, "wait_best_points": 0, "wait_total_remaining": 0, "safety_label": ""},
	]
	scene.apply_hard_danger_push_guard(thin_tenpai_reports)
	check(str(thin_tenpai_reports[0].get("tile", "")) == "S", "hard folds a thin low-value tenpai under catastrophic feed risk")

	print("--- B) seed-level terminal decision traces ---")
	var seed_base = 20260811
	var traced_deal_ins = 0
	var hard_guard_moves = 0
	for difficulty in [scene.AI_DIFFICULTY_EASY, scene.AI_DIFFICULTY_HARD]:
		for hand_index in range(2):
			var result = run_hand(scene, difficulty, seed_base, hand_index)
			var trace: Array = result.get("discard_trace", [])
			check(bool(result.get("ended", false)), "difficulty %d hand %d completes" % [difficulty, hand_index])
			check(not trace.is_empty(), "difficulty %d hand %d records compact choices" % [difficulty, hand_index])
			for item in trace:
				if difficulty == scene.AI_DIFFICULTY_HARD and typeof(item) == TYPE_DICTIONARY and bool(item.get("hard_guard_moved", false)):
					hard_guard_moves += 1
					print("    guard move hand=%d step=%d %s -> %s" % [
						hand_index,
						int(item.get("step", -1)),
						str(item.get("hard_guard_from_tile", "")),
						str(item.get("tile", "")),
					])
			if int(result.get("deal_ins", 0)) <= 0:
				continue
			traced_deal_ins += 1
			var terminal_step = int(result.get("terminal_trace_step", -1))
			var terminal_tile = str(result.get("terminal_tile", ""))
			var terminal_entry: Dictionary = {}
			for item in trace:
				if typeof(item) == TYPE_DICTIONARY and int(item.get("step", -2)) == terminal_step:
					terminal_entry = item
					break
			print("    base=%d decision=%d hand=%d dealin seat=%d -> winner=%d tile=%s source=%s rank=%d risk=%.1f feed=%.1f human=%.1f sh=%d wait=%d/%d/%.1f best=%s/%.1f safe=%s risk=%.1f feed=%.1f human=%.1f sh=%d gap=%.1f guard=%s/%s candidate=%s guard_gap=%.1f guard_gain=%.1f" % [
				difficulty,
				int(terminal_entry.get("difficulty", -1)),
				hand_index,
				int(result.get("deal_in_seat", -1)),
				int(result.get("terminal_winner", -1)),
				terminal_tile,
				str(terminal_entry.get("source", "")),
				int(terminal_entry.get("selected_rank", -1)),
				float(terminal_entry.get("risk", 0.0)),
				float(terminal_entry.get("feed", 0.0)),
				float(terminal_entry.get("human_pressure", 0.0)),
				int(terminal_entry.get("shanten", -1)),
				int(terminal_entry.get("wait_best_points", 0)),
				int(terminal_entry.get("wait_total_remaining", 0)),
				float(terminal_entry.get("wait_value", 0.0)),
				str(terminal_entry.get("best_tile", "")),
				float(terminal_entry.get("best_risk", 0.0)),
				str(terminal_entry.get("safest_tile", "")),
				float(terminal_entry.get("safest_risk", 0.0)),
				float(terminal_entry.get("safest_feed", 0.0)),
				float(terminal_entry.get("safest_human_pressure", 0.0)),
				int(terminal_entry.get("safest_shanten", -1)),
				float(terminal_entry.get("score", 0.0)) - float(terminal_entry.get("safest_score", 0.0)),
				str(terminal_entry.get("hard_guard_two_away", false)),
				str(terminal_entry.get("hard_guard_catastrophe_two_away", false)),
				str(terminal_entry.get("hard_guard_safe_tile", "")),
				float(terminal_entry.get("hard_guard_safe_score_gap", 0.0)),
				float(terminal_entry.get("hard_guard_safe_pressure_gain", 0.0)),
			])
			check(not terminal_entry.is_empty(), "terminal deal-in maps to a recorded discard")
			check(str(terminal_entry.get("tile", "")) == terminal_tile, "terminal trace retains the committed tile")

	check(traced_deal_ins > 0, "diagnostic seed exercises at least one terminal deal-in")
	check(hard_guard_moves > 0, "hard seed executes a catastrophic two-away safety reroute")
	scene.ai_sim_trace_enabled = false
	scene.enable_offline_all_bot_mode(false, false)
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
