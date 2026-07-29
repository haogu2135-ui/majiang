extends SceneTree
## Round 76: compact hard-AI traces for the R68 20260827 fixed-seed outlier.
var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(cond: bool, msg: String) -> void:
	if cond:
		print("  OK  | %s" % msg)
	else:
		print("  FAIL| %s" % msg)
		failed = true


func run_hand(scene, seed_base: int, hand_index: int) -> Dictionary:
	scene.enable_offline_all_bot_mode(true, true)
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	scene.ai_benchmark_base_difficulty = scene.AI_DIFFICULTY_HARD
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


func print_high_risk_trace(scene, trace: Array) -> void:
	for item in trace:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var risk = float(item.get("risk", 0.0))
		var feed = float(item.get("feed", 0.0))
		var human = float(item.get("human_pressure", 0.0))
		if risk < scene.AI_DANGER_RISK_HIGH and human < 28.0:
			continue
		print("    step=%d seat=%d tile=%s risk=%.1f feed=%.1f human=%.1f sh=%d wait=%d/%d source=%s guard=%s thin=%s one=%s from=%s safe=%s gap=%.1f gain=%.1f" % [
			int(item.get("step", -1)),
			int(item.get("seat", -1)),
			str(item.get("tile", "")),
			risk,
			feed,
			human,
			int(item.get("shanten", -1)),
			int(item.get("wait_best_points", 0)),
			int(item.get("wait_total_remaining", 0)),
			str(item.get("source", "")),
			str(item.get("hard_guard_moved", false)),
			str(item.get("hard_guard_catastrophe_tenpai", false)),
			str(item.get("hard_guard_extreme_one_away", false)),
			str(item.get("hard_guard_from_tile", "")),
			str(item.get("hard_guard_safe_tile", "")),
			float(item.get("hard_guard_safe_score_gap", 0.0)),
			float(item.get("hard_guard_safe_pressure_gain", 0.0)),
		])


func run() -> void:
	print("=== ai_play_round76 check START ===")
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

	for seed_base in [20260827]:
		print("--- hard fixed seed %d ---" % seed_base)
		for hand_index in range(2):
			var result = run_hand(scene, seed_base, hand_index)
			var trace: Array = result.get("discard_trace", [])
			print("    hand=%d ended=%s integrity=%s high=%d humanHigh=%d dealin=%d humanRon=%d steps=%d" % [
				hand_index,
				str(result.get("ended", false)),
				str(result.get("integrity_ok", false)),
				int(result.get("high_danger_discards", 0)),
				int(result.get("human_high_danger_discards", 0)),
				int(result.get("deal_ins", 0)),
				int(result.get("deal_ins_to_human", 0)),
				int(result.get("steps", 0)),
			])
			check(bool(result.get("ended", false)), "seed %d hand %d completes" % [seed_base, hand_index])
			check(bool(result.get("integrity_ok", false)), "seed %d hand %d keeps 144-tile integrity" % [seed_base, hand_index])
			check(not trace.is_empty(), "seed %d hand %d produces a compact trace" % [seed_base, hand_index])
			print_high_risk_trace(scene, trace)

	scene.ai_sim_trace_enabled = false
	scene.enable_offline_all_bot_mode(false, false)
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
