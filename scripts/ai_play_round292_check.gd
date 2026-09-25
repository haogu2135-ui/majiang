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


func guard_fixture() -> Array:
	return [
		{
			"tile": "9T",
			"score": 271.0,
			"shanten": 2,
			"risk": 27.0,
			"feed_risk": 31.5,
			"human_target_pressure": 36.4,
			"human_target_exposure": 39.2,
			"safety_label": "",
		},
		{
			"tile": "5W",
			"score": 216.4,
			"shanten": 2,
			"risk": 32.7,
			"feed_risk": 28.5,
			"human_target_pressure": 24.4,
			"human_target_exposure": 26.5,
			"safety_label": "",
		},
	]


func run() -> void:
	print("=== ai_play_round292 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD

	var relief_reports: Array = guard_fixture()
	scene.apply_hard_danger_push_guard(relief_reports)
	check(str(relief_reports[0].get("tile", "")) == "5W", "hard two-away guard accepts a low-cost same-shanten player-exposure relief")

	var full_table_risk_reports: Array = guard_fixture()
	full_table_risk_reports[1]["risk"] = 39.0
	scene.apply_hard_danger_push_guard(full_table_risk_reports)
	check(str(full_table_risk_reports[0].get("tile", "")) == "9T", "targeted relief does not override worse combined risk")

	var shanten_loss_reports: Array = guard_fixture()
	shanten_loss_reports[1]["shanten"] = 3
	scene.apply_hard_danger_push_guard(shanten_loss_reports)
	check(str(shanten_loss_reports[0].get("tile", "")) == "9T", "targeted relief never pays an extra shanten")

	var expensive_reports: Array = guard_fixture()
	expensive_reports[1]["score"] = 0.0
	scene.apply_hard_danger_push_guard(expensive_reports)
	check(str(expensive_reports[0].get("tile", "")) == "9T", "targeted relief respects the score-gap cap")

	scene.fast_mode_enabled = true
	scene.sfx_enabled = false
	scene.music_enabled = false
	scene.fx_enabled = false
	scene.ensure_ai_benchmark_players()
	scene.ai_sim_trace_enabled = true
	scene.ai_benchmark_base_difficulty = scene.AI_DIFFICULTY_HARD
	scene.ai_benchmark_probe_seat = 0
	scene.ai_benchmark_probe_difficulty = scene.AI_DIFFICULTY_NORMAL
	scene.enable_offline_all_bot_mode(true, true)
	scene.reset_ai_profile_seat_map()
	seed(20261104)
	scene.offline_skip_ai_profile_reshuffle = true
	scene.mode = "offline"
	scene.offline_hand_number = 1
	scene.dealer_seat = 0
	for seat in range(4):
		scene.players[seat]["score"] = scene.MATCH_START_SCORE
	scene.deal_offline_hand()
	scene.reset_ai_profile_seat_map()
	var result: Dictionary = scene.simulate_offline_bot_hand_sync(700)
	check(bool(result.get("ended", false)), "regression seed reaches a terminal hand")
	check(bool(result.get("integrity_ok", false)) and bool(result.get("score_conserved", false)), "regression seed preserves tile and score ledgers")
	var improved_fixture_seen := false
	for item in result.get("discard_trace", []):
		if typeof(item) == TYPE_DICTIONARY and int(item.get("step", -1)) == 22 and int(item.get("seat", -1)) == 2:
			improved_fixture_seen = str(item.get("tile", "")) == "5W"
			break
	check(improved_fixture_seen, "seed 20261104 step 22 selects the safer same-shanten 5W discard")

	scene.ai_sim_trace_enabled = false
	scene.enable_offline_all_bot_mode(false, false)
	scene.shutdown_runtime()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
