extends SceneTree
## Round 66: AI strength evidence helpers are self-contained from fresh scenes.
var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(cond: bool, msg: String) -> void:
	if cond:
		print("  OK  | %s" % msg)
	else:
		print("  FAIL| %s" % msg)
		failed = true


func array_sum(values: Array) -> int:
	var total = 0
	for value in values:
		total += int(value)
	return total


func run() -> void:
	print("=== ai_play_round66 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.fast_mode_enabled = true
	scene.sfx_enabled = false
	scene.music_enabled = false
	scene.fx_enabled = false

	print("--- A) sample_ai_strength_benchmark builds a fresh table ---")
	scene.players.clear()
	var t0 = Time.get_ticks_msec()
	var bench = scene.sample_ai_strength_benchmark(1, 20260730)
	var bench_ms = Time.get_ticks_msec() - t0
	print("    bench ms=%d ok=%s high_danger e/h=%.3f/%.3f deal_in e/h=%.2f/%.2f finished=%s/%s/%s" % [
		bench_ms,
		str(bench.get("commercial_strength_ok", false)),
		float(bench.get("easy_high_danger", 1.0)),
		float(bench.get("hard_high_danger", 1.0)),
		float(bench.get("easy_deal_in", 1.0)),
		float(bench.get("hard_deal_in", 1.0)),
		str(bench.get("easy_finished", 0)),
		str(bench.get("normal_finished", 0)),
		str(bench.get("hard_finished", 0)),
	])
	check(scene.players.size() == 4, "strength benchmark creates four benchmark players")
	check(bool(bench.get("finished_all", false)), "fresh strength benchmark finishes every sampled hand")
	check(bool(bench.get("commercial_strength_ok", false)), "fresh strength benchmark reports commercial gate green")
	check(float(bench.get("hard_high_danger", 1.0)) < float(bench.get("easy_high_danger", 0.0)), "hard high-danger rate is lower in fresh benchmark")
	check(float(bench.get("hard_deal_in", 1.0)) <= float(bench.get("easy_deal_in", 0.0)), "hard deal-in rate is not higher in fresh benchmark")
	check(float(bench.get("avg_ms_hard", 999999.0)) < 15000.0, "fresh hard sample stays low-resource")
	check(bench_ms < 45000, "fresh strength benchmark stays within serial smoke budget")

	print("--- B) match winrate sample also self-initializes ---")
	scene.players.clear()
	var t1 = Time.get_ticks_msec()
	var match = scene.sample_bot_match_winrates(2, 20260726)
	var match_ms = Time.get_ticks_msec() - t1
	var wins: Array = match.get("win_counts", [])
	var deal_ins: Array = match.get("deal_ins", [])
	print("    match ms=%d finished=%s wins=%s deal_ins=%s" % [match_ms, str(match.get("finished", 0)), str(wins), str(deal_ins)])
	check(scene.players.size() == 4, "match sample creates four benchmark players")
	check(int(match.get("finished", 0)) == 2, "fresh match sample finishes requested hands")
	check(wins.size() == 4 and array_sum(wins) <= 2, "match sample reports four-seat win counts")
	check(deal_ins.size() == 4, "match sample reports four-seat deal-in counts")
	check(match_ms < 30000, "fresh match sample stays within low-resource budget")

	scene.enable_offline_all_bot_mode(false, false)
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
