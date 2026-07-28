extends SceneTree
## Round 79: trace the R78 fixed-human probe high-danger outlier decisions.
var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(cond: bool, msg: String) -> void:
	if cond:
		print("  OK  | %s" % msg)
	else:
		print("  FAIL| %s" % msg)
		failed = true


func run_hand(scene, hand_index: int) -> Dictionary:
	scene.enable_offline_all_bot_mode(true, true)
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	scene.ai_benchmark_base_difficulty = scene.AI_DIFFICULTY_HARD
	scene.ai_benchmark_probe_seat = 0
	scene.ai_benchmark_probe_difficulty = scene.AI_DIFFICULTY_NORMAL
	scene.reset_ai_profile_seat_map()
	seed(20260827 + hand_index * 17)
	scene.offline_skip_ai_profile_reshuffle = true
	scene.mode = "offline"
	scene.offline_hand_number = 1
	scene.dealer_seat = hand_index % 4
	for seat in range(4):
		scene.players[seat]["score"] = scene.MATCH_START_SCORE
	scene.deal_offline_hand()
	scene.reset_ai_profile_seat_map()
	return scene.simulate_offline_bot_hand_sync(700)


func print_high_trace(scene, trace: Array) -> void:
	for item in trace:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var risk = float(item.get("risk", 0.0))
		var human = float(item.get("human_pressure", 0.0))
		if risk < scene.AI_DANGER_RISK_HIGH and human < 28.0:
			continue
		print("    step=%d seat=%d diff=%d tile=%s risk=%.1f feed=%.1f human=%.1f sh=%d guard=%s from=%s safe=%s gap=%.1f gain=%.1f" % [
			int(item.get("step", -1)),
			int(item.get("seat", -1)),
			int(item.get("difficulty", -1)),
			str(item.get("tile", "")),
			risk,
			float(item.get("feed", 0.0)),
			human,
			int(item.get("shanten", -1)),
			str(item.get("hard_guard_moved", false)),
			str(item.get("hard_guard_from_tile", "")),
			str(item.get("hard_guard_safe_tile", "")),
			float(item.get("hard_guard_safe_score_gap", 0.0)),
			float(item.get("hard_guard_safe_pressure_gain", 0.0)),
		])


func run() -> void:
	print("=== ai_play_round79 check START ===")
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

	for hand_index in range(2):
		var result = run_hand(scene, hand_index)
		var trace: Array = result.get("discard_trace", [])
		print("--- hand %d ended=%s integrity=%s high=%d humanHigh=%d dealin=%d humanRon=%d seat=%d winner=%d ---" % [
			hand_index,
			str(result.get("ended", false)),
			str(result.get("integrity_ok", false)),
			int(result.get("high_danger_discards", 0)),
			int(result.get("human_high_danger_discards", 0)),
			int(result.get("deal_ins", 0)),
			int(result.get("deal_ins_to_human", 0)),
			int(result.get("deal_in_seat", -1)),
			int(result.get("winner", -1)),
		])
		check(bool(result.get("ended", false)), "hand %d completes" % hand_index)
		check(bool(result.get("integrity_ok", false)), "hand %d keeps inventory integrity" % hand_index)
		check(not trace.is_empty(), "hand %d records a compact trace" % hand_index)
		print_high_trace(scene, trace)

	scene.ai_sim_trace_enabled = false
	scene.enable_offline_all_bot_mode(false, false)
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
