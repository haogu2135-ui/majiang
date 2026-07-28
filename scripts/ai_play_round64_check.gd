extends SceneTree
## Round 64: low-resource commercial strength gate for AI danger discipline.
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


func fill_wall(scene, count: int) -> void:
	var wall: Array[String] = []
	for i in range(count):
		wall.append("1B")
	scene.wall = wall


func reset_pressure_table(scene) -> void:
	scene.players = [
		make_player("Human"),
		make_player("P1"),
		make_player("AI"),
		make_player("P3"),
	]
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.current_seat = 2
	scene.offline_turn_needs_draw = false
	scene.offline_all_bot_mode = false
	scene.offline_sim_quiet = false
	scene.dealer_seat = 0
	scene.offline_hand_number = scene.MATCH_MAX_HANDS
	fill_wall(scene, 18)
	scene.players[0]["melds"] = [["1T", "1T", "1T"], ["2T", "2T", "2T"], ["3T", "3T", "3T"]]
	scene.players[0]["discards"] = []
	for i in range(14):
		scene.players[0]["discards"].append("9B")
	scene.players[0]["score"] = 30000
	scene.players[2]["score"] = 33000
	scene.players[2]["melds"] = []
	scene.players[2]["hand"] = ["2W", "3W", "4W", "5W", "5W", "6W", "7W", "8W", "2B", "3B", "4B", "9B", "E", "S"]
	scene.clear_ai_report_cache()


func report_lookup(reports: Array, tile: String) -> Dictionary:
	for item in reports:
		if typeof(item) == TYPE_DICTIONARY and str(item.get("tile", "")) == tile:
			return item
	return {}


func score_gap(safe_report: Dictionary, danger_report: Dictionary) -> float:
	return float(safe_report.get("score", -999999.0)) - float(danger_report.get("score", -999999.0))


func run() -> void:
	print("=== ai_play_round64 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.fast_mode_enabled = true
	scene.sfx_enabled = false
	scene.music_enabled = false
	scene.fx_enabled = false
	scene.reset_ai_profile_seat_map()

	print("--- A) deterministic hard safety separation ---")
	reset_pressure_table(scene)
	var readiness = scene.human_readiness_for_defense()
	check(readiness >= 12.0, "pressure table exposes a hot human opponent")
	scene.ai_difficulty = scene.AI_DIFFICULTY_EASY
	var easy_reports = scene.get_ai_discard_reports(2)
	var easy_safe = report_lookup(easy_reports, "9B")
	var easy_danger = report_lookup(easy_reports, "5W")
	var easy_honor = report_lookup(easy_reports, "E")
	var easy_choice = scene.choose_ai_discard_for_seat(2)
	reset_pressure_table(scene)
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var hard_reports = scene.get_ai_discard_reports(2)
	var hard_safe = report_lookup(hard_reports, "9B")
	var hard_danger = report_lookup(hard_reports, "5W")
	var hard_honor = report_lookup(hard_reports, "E")
	var hard_choice = scene.choose_ai_discard_for_seat(2)
	print("    easy choice=%s safe_gap=%.1f honor_gap=%.1f human_pen=%.1f" % [
		easy_choice,
		score_gap(easy_safe, easy_danger),
		score_gap(easy_safe, easy_honor),
		float(easy_danger.get("human_target_penalty", 0.0)),
	])
	print("    hard choice=%s safe_gap=%.1f honor_gap=%.1f human_pen=%.1f" % [
		hard_choice,
		score_gap(hard_safe, hard_danger),
		score_gap(hard_safe, hard_honor),
		float(hard_danger.get("human_target_penalty", 0.0)),
	])
	check(str(hard_safe.get("safety_label", "")) == "现" and float(hard_safe.get("risk", 99.0)) < scene.AI_DANGER_RISK_SOFT, "safe tile is visible and below soft danger")
	check(float(hard_danger.get("risk", 0.0)) >= scene.AI_DANGER_RISK_HIGH, "danger tile is high-risk under human pressure")
	check(hard_choice == "9B", "hard AI chooses the visible safe tile")
	check(score_gap(hard_safe, hard_danger) > score_gap(easy_safe, easy_danger) + 250.0, "hard opens a larger safety gap than easy")
	check(score_gap(hard_safe, hard_honor) > score_gap(easy_safe, easy_honor) + 250.0, "hard also rejects risky honors harder")
	check(float(hard_danger.get("human_target_penalty", 0.0)) > float(easy_danger.get("human_target_penalty", 0.0)) * 2.0, "hard human-target penalty is materially stronger")
	check(float(hard_safe.get("fold_push", 0.0)) > float(easy_safe.get("fold_push", 0.0)) + 30.0, "hard rewards safe fold more in late pressure")

	print("--- B) fixed-seed low-resource strength sample ---")
	reset_pressure_table(scene)
	var bench = scene.sample_ai_strength_benchmark(2, 20260730)
	print("    bench high_danger e/h=%.3f/%.3f deal_in e/h=%.2f/%.2f human e/h=%.2f/%.2f ms_h=%.0f finished=%s/%s/%s" % [
		float(bench.get("easy_high_danger", 1.0)),
		float(bench.get("hard_high_danger", 1.0)),
		float(bench.get("easy_deal_in", 1.0)),
		float(bench.get("hard_deal_in", 1.0)),
		float(bench.get("easy_deal_in_to_human", 1.0)),
		float(bench.get("hard_deal_in_to_human", 1.0)),
		float(bench.get("avg_ms_hard", 0.0)),
		str(bench.get("easy_finished", 0)),
		str(bench.get("normal_finished", 0)),
		str(bench.get("hard_finished", 0)),
	])
	check(bool(bench.get("finished_all", false)), "fixed-seed sample finishes all hands")
	check(bool(bench.get("hard_safer_high_danger", false)), "hard high-danger rate is not worse than easy")
	check(bool(bench.get("hard_safer_deal_in", false)), "hard deal-in rate is not worse than easy")
	check(bool(bench.get("hard_safer_deal_in_to_human", false)), "hard human deal-in rate is not worse than easy")
	check(bool(bench.get("commercial_strength_ok", false)), "commercial strength aggregate flag is green")
	check(float(bench.get("avg_ms_hard", 999999.0)) < 30000.0, "hard benchmark remains low-resource")

	scene.enable_offline_all_bot_mode(false, false)
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
