extends SceneTree
## Round 69: fair human-probe strength sample for actual seat0 ron diagnostics.
var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(cond: bool, msg: String) -> void:
	if cond:
		print("  OK  | %s" % msg)
	else:
		print("  FAIL| %s" % msg)
		failed = true


func run() -> void:
	print("=== ai_play_round69 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.fast_mode_enabled = true
	scene.sfx_enabled = false
	scene.music_enabled = false
	scene.fx_enabled = false

	print("--- A) fixed seat0 human-probe benchmark ---")
	# Keep this under one minute on typical dev hardware: 2 hands/diff × easy/hard × 2 seeds.
	var seeds: Array = [20260811, 20260827]
	var aggregate = scene.empty_ai_strength_aggregate()
	var rows: Array = []
	var t0 = Time.get_ticks_msec()
	for seed_base in seeds:
		var bench = scene.sample_ai_strength_benchmark(2, int(seed_base), false, false, 0, scene.AI_DIFFICULTY_NORMAL)
		scene.add_ai_strength_benchmark_to_aggregate(aggregate, bench)
		rows.append(bench)
		print("    seed=%s probe=%s/%s ok=%s hd=%.3f/%.3f humanHD=%.3f/%.3f humanRon=%.2f/%.2f" % [
			str(seed_base),
			str(bench.get("fixed_probe_seat", -1)),
			str(bench.get("fixed_probe_difficulty", -1)),
			str(bench.get("commercial_strength_ok", false)),
			float(bench.get("easy_high_danger", 1.0)),
			float(bench.get("hard_high_danger", 1.0)),
			float(bench.get("easy_human_high_danger", 1.0)),
			float(bench.get("hard_human_high_danger", 1.0)),
			float(bench.get("easy_deal_in_to_human", 1.0)),
			float(bench.get("hard_deal_in_to_human", 1.0)),
		])
	var elapsed = Time.get_ticks_msec() - t0
	var summary = scene.finalize_ai_strength_aggregate(aggregate)
	print("    aggregate ok=%s hd=%.3f/%.3f humanHD=%.3f/%.3f humanRon=%.2f/%.2f ms=%d" % [
		str(summary.get("commercial_strength_ok", false)),
		float(summary.get("easy_high_danger", 1.0)),
		float(summary.get("hard_high_danger", 1.0)),
		float(summary.get("easy_human_high_danger", 1.0)),
		float(summary.get("hard_human_high_danger", 1.0)),
		float(summary.get("easy_deal_in_to_human", 1.0)),
		float(summary.get("hard_deal_in_to_human", 1.0)),
		elapsed,
	])
	check(rows.size() == 2, "two fixed-probe seeds sampled")
	for bench in rows:
		check(int(bench.get("fixed_probe_seat", -1)) == 0, "seat0 is fixed as the human probe")
		check(int(bench.get("fixed_probe_difficulty", -1)) == scene.AI_DIFFICULTY_NORMAL, "human probe uses normal difficulty")
		check(bool(bench.get("paired_wall_seed", false)), "row uses paired wall seeds")
		check(bool(bench.get("paired_profile_seed", false)), "row uses paired profile maps")
	check(bool(summary.get("finished_all", false)), "fixed-probe aggregate finishes all hands")
	check(bool(summary.get("hard_safer_high_danger", false)), "hard keeps overall high danger no worse than easy")
	check(bool(summary.get("hard_safer_human_high_danger", false)), "hard keeps player-target high danger no worse than easy")
	check(bool(summary.get("hard_safer_deal_in", false)), "hard total deal-in is no worse than easy")
	check(float(summary.get("hard_deal_in_to_human", 1.0)) <= float(summary.get("easy_deal_in_to_human", 0.0)) + 0.001, "hard actual human ron is strictly no worse with fixed seat0 probe")
	check(elapsed < 90000, "fixed-probe sample stays low-resource")

	scene.enable_offline_all_bot_mode(false, false)
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
