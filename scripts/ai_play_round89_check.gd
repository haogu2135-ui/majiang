extends SceneTree
## Round 89: independent paired sample keeps the commercial AI gate stable.
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
	print("=== ai_play_round89 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.fast_mode_enabled = true
	scene.sfx_enabled = false
	scene.music_enabled = false
	scene.fx_enabled = false

	print("--- A) independent fixed-player probe samples ---")
	# Four unrelated base seeds with two paired hands each give the same 16
	# easy/hard simulations as the main pack, without relying on a one-hand
	# statistic that can be dominated by one forced tenpai discard.
	var seeds: Array = [20260701, 20260753, 20260805, 20260857]
	var hands_per_seed := 2
	var t0 = Time.get_ticks_msec()
	var aggregate = scene.empty_ai_strength_aggregate()
	var rows: Array = []
	for seed_base in seeds:
		# Keep seat 0 at normal difficulty so player-target risk is comparable;
		# only the three opponents change between easy and hard.
		var bench = scene.sample_ai_strength_benchmark(hands_per_seed, int(seed_base), false, false, 0, scene.AI_DIFFICULTY_NORMAL)
		rows.append(bench)
		scene.add_ai_strength_benchmark_to_aggregate(aggregate, bench)
	var elapsed = Time.get_ticks_msec() - t0
	var summary = scene.finalize_ai_strength_aggregate(aggregate)
	print("    elapsed=%d rows=%d ok=%s hd(raw/avoid)=%.3f/%.3f %.3f/%.3f humanHD(raw/avoid)=%.3f/%.3f %.3f/%.3f humanRon=%.2f/%.2f" % [
		elapsed,
		rows.size(),
		str(summary.get("commercial_strength_ok", false)),
		float(summary.get("easy_high_danger", 1.0)),
		float(summary.get("hard_high_danger", 1.0)),
		float(summary.get("easy_avoidable_high_danger", 1.0)),
		float(summary.get("hard_avoidable_high_danger", 1.0)),
		float(summary.get("easy_human_high_danger", 1.0)),
		float(summary.get("hard_human_high_danger", 1.0)),
		float(summary.get("easy_human_avoidable_high_danger", 1.0)),
		float(summary.get("hard_human_avoidable_high_danger", 1.0)),
		float(summary.get("easy_deal_in_to_human", 1.0)),
		float(summary.get("hard_deal_in_to_human", 1.0)),
	])
	check(rows.size() == seeds.size(), "all independent seeds produce a paired row")
	for row in rows:
		if typeof(row) != TYPE_DICTIONARY:
			check(false, "seed row has the expected dictionary shape")
			continue
		var seed_row: Dictionary = row
		print("    seed=%s probe=%s/%s ok=%s integrity=%s score=%s hd(raw/avoid)=%.3f/%.3f %.3f/%.3f" % [
			str(seed_row.get("seed_base", 0)),
			str(seed_row.get("fixed_probe_seat", -1)),
			str(seed_row.get("fixed_probe_difficulty", -1)),
			str(seed_row.get("commercial_strength_ok", false)),
			str(seed_row.get("integrity_all", false)),
			str(seed_row.get("score_conservation_all", false)),
			float(seed_row.get("easy_high_danger", 1.0)),
			float(seed_row.get("hard_high_danger", 1.0)),
			float(seed_row.get("easy_avoidable_high_danger", 1.0)),
			float(seed_row.get("hard_avoidable_high_danger", 1.0)),
		])
		check(int(seed_row.get("fixed_probe_seat", -1)) == 0 and int(seed_row.get("fixed_probe_difficulty", -1)) == scene.AI_DIFFICULTY_NORMAL, "seed %s keeps seat0 at the normal player probe" % str(seed_row.get("seed_base", 0)))
		check(bool(seed_row.get("paired_wall_seed", false)) and bool(seed_row.get("paired_profile_seed", false)), "seed %s keeps paired inputs" % str(seed_row.get("seed_base", 0)))
		check(bool(seed_row.get("integrity_all", false)), "seed %s preserves the physical tile ledger" % str(seed_row.get("seed_base", 0)))
		check(bool(seed_row.get("score_conservation_all", false)), "seed %s preserves the score ledger" % str(seed_row.get("seed_base", 0)))
	check(bool(summary.get("finished_all", false)), "independent aggregate reaches terminal hands")
	check(bool(summary.get("integrity_all", false)), "independent aggregate preserves the tile ledger")
	check(bool(summary.get("score_conservation_all", false)), "independent aggregate preserves the score ledger")
	check(bool(summary.get("hard_safer_human_avoidable_high_danger", false)), "hard avoids no fewer actionable player-pressure choices than easy")
	check(bool(summary.get("hard_safer_deal_in_to_human", false)), "hard does not deal in to the fixed player probe more often than easy")
	check(bool(summary.get("commercial_strength_ok", false)), "independent aggregate passes the commercial strength gate")
	check(elapsed < 180000, "independent sample stays inside the serial low-resource budget")

	scene.enable_offline_all_bot_mode(false, false)
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
