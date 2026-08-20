extends SceneTree
## Round 92: catastrophic thin-tenpai pressure must expose the hard guard.
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


func run() -> void:
	print("=== ai_play_round92 check START ===")
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

	var result = run_hand(scene, 20260827, 1)
	var trace: Array = result.get("discard_trace", [])
	var thin_pressure_cases := 0
	var guarded_cases := 0
	for item in trace:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var risk := float(item.get("risk", 0.0))
		var feed := float(item.get("feed", 0.0))
		var shanten := int(item.get("shanten", 8))
		var wait_points := int(item.get("wait_best_points", 0))
		var wait_remaining := int(item.get("wait_total_remaining", 0))
		var thin_pressure: bool = shanten <= 0 \
			and risk >= scene.AI_DANGER_RISK_HIGH + 22.0 \
			and feed >= scene.AI_DANGER_FEED_SOFT + 32.0 \
			and wait_points > 0 and wait_points <= scene.score_points_for_fan(2) \
			and wait_remaining > 0 and wait_remaining <= 4
		if not thin_pressure:
			continue
		thin_pressure_cases += 1
		var guarded := bool(item.get("hard_guard_catastrophe_tenpai", false)) or bool(item.get("hard_guard_moved", false))
		if guarded:
			guarded_cases += 1
		else:
			print("    uncovered step=%d seat=%d tile=%s risk=%.1f feed=%.1f sh=%d wait=%d/%d" % [
				int(item.get("step", -1)),
				int(item.get("seat", -1)),
				str(item.get("tile", "")),
				risk,
				feed,
				shanten,
				wait_points,
				wait_remaining,
			])
	check(bool(result.get("ended", false)), "diagnostic hard hand completes")
	check(guarded_cases == thin_pressure_cases, "every naturally sampled catastrophic thin-tenpai case carries the hard guard")

	print("--- B) deterministic catastrophic thin-tenpai contract ---")
	var catastrophe := {
		"tile": "5W",
		"score": 1240.0,
		"shanten": 0,
		"ukeire": 3,
		"risk": scene.AI_DANGER_RISK_HIGH + 24.0,
		"feed_risk": scene.AI_DANGER_FEED_SOFT + 34.0,
		"human_target_pressure": 24.0,
		"safety_label": "",
		"wait_best_points": scene.score_points_for_fan(2),
		"wait_total_remaining": 3,
	}
	var guarded_safe := {
		"tile": "E",
		"score": 1090.0,
		"shanten": 1,
		"ukeire": 6,
		"risk": 8.0,
		"feed_risk": 4.0,
		"human_target_pressure": 6.0,
		"safety_label": "安",
		"wait_best_points": 0,
		"wait_total_remaining": 0,
	}
	var reports: Array = [catastrophe, guarded_safe]
	scene.apply_hard_danger_push_guard(reports, -1)
	check(bool(catastrophe.get("hard_guard_catastrophe_tenpai", false)), "catastrophic thin tenpai activates the dedicated hard guard")
	check(str(reports[0].get("tile", "")) == "E" and bool(reports[0].get("hard_guard_moved", false)), "hard guard moves the quality-bounded safer discard to the front")

	scene.ai_sim_trace_enabled = false
	scene.enable_offline_all_bot_mode(false, false)
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
