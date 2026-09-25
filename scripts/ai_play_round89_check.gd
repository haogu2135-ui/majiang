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
	# Eight independent base seeds with two paired hands each provide 16 hands
	# per difficulty without relying on one seed's forced tenpai discard.
	var seeds: Array = [20260701, 20260714, 20260742, 20260753, 20260805, 20260819, 20260843, 20260857]
	var requested_seed_arguments := OS.get_cmdline_user_args()
	if not requested_seed_arguments.is_empty():
		seeds.clear()
		for seed_argument in requested_seed_arguments:
			seeds.append(int(seed_argument))
	var hands_per_seed := 2
	var t0 = Time.get_ticks_msec()
	var aggregate = scene.empty_ai_strength_aggregate()
	var rows: Array = []
	var easy_probe_wins := 0
	var hard_probe_wins := 0
	var easy_probe_score_delta := 0
	var hard_probe_score_delta := 0
	for seed_base in seeds:
		# Keep seat 0 at normal difficulty so player-target risk is comparable;
		# only the three opponents change between easy and hard.
		var bench = scene.sample_ai_strength_benchmark(hands_per_seed, int(seed_base), false, false, 0, scene.AI_DIFFICULTY_NORMAL)
		rows.append(bench)
		scene.add_ai_strength_benchmark_to_aggregate(aggregate, bench)
		var raw: Dictionary = bench.get("raw", {})
		var by_diff: Dictionary = raw.get("by_diff", {})
		var easy_stats: Dictionary = by_diff.get(scene.AI_DIFFICULTY_EASY, {})
		var hard_stats: Dictionary = by_diff.get(scene.AI_DIFFICULTY_HARD, {})
		var easy_wins: Array = easy_stats.get("wins_by_seat", [])
		var hard_wins: Array = hard_stats.get("wins_by_seat", [])
		var easy_score_delta: Array = easy_stats.get("score_delta_by_seat", [])
		var hard_score_delta: Array = hard_stats.get("score_delta_by_seat", [])
		if easy_wins.size() == 4 and hard_wins.size() == 4 and easy_score_delta.size() == 4 and hard_score_delta.size() == 4:
			easy_probe_wins += int(easy_wins[0])
			hard_probe_wins += int(hard_wins[0])
			easy_probe_score_delta += int(easy_score_delta[0])
			hard_probe_score_delta += int(hard_score_delta[0])
	var elapsed = Time.get_ticks_msec() - t0
	var summary = scene.finalize_ai_strength_aggregate(aggregate)
	print("    elapsed=%d rows=%d ok=%s hd(raw/avoid)=%.3f/%.3f %.3f/%.3f humanHD(raw/avoid)=%.3f/%.3f %.3f/%.3f humanRon=%.2f/%.2f (%d/%d hands)" % [
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
		int(summary.get("easy_deal_ins_to_human", 0)),
		int(summary.get("hard_deal_ins_to_human", 0)),
	])
	print("    fixed probe seat0 wins easy/hard=%d/%d score_delta easy/hard=%+d/%+d (%d paired hands each; telemetry only)" % [
		easy_probe_wins,
		hard_probe_wins,
		easy_probe_score_delta,
		hard_probe_score_delta,
		seeds.size() * hands_per_seed,
	])
	check(rows.size() == seeds.size(), "all independent seeds produce a paired row")
	for row in rows:
		if typeof(row) != TYPE_DICTIONARY:
			check(false, "seed row has the expected dictionary shape")
			continue
		var seed_row: Dictionary = row
		var raw: Dictionary = seed_row.get("raw", {})
		var by_diff: Dictionary = raw.get("by_diff", {})
		var easy_stats: Dictionary = by_diff.get(scene.AI_DIFFICULTY_EASY, {})
		var hard_stats: Dictionary = by_diff.get(scene.AI_DIFFICULTY_HARD, {})
		var easy_wins: Array = easy_stats.get("wins_by_seat", [])
		var hard_wins: Array = hard_stats.get("wins_by_seat", [])
		var easy_score_delta: Array = easy_stats.get("score_delta_by_seat", [])
		var hard_score_delta: Array = hard_stats.get("score_delta_by_seat", [])
		print("    seed=%s probe=%s/%s ok=%s integrity=%s score=%s hd(raw/avoid)=%.3f/%.3f %.3f/%.3f humanHD=%.3f/%.3f humanRon=%.2f/%.2f probeWins=%d/%d probeScore=%+d/%+d humanClaimDeclines=%d/%d" % [
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
			float(seed_row.get("easy_human_high_danger", 1.0)),
			float(seed_row.get("hard_human_high_danger", 1.0)),
			float(seed_row.get("easy_deal_in_to_human", 1.0)),
			float(seed_row.get("hard_deal_in_to_human", 1.0)),
			int(easy_wins[0]) if easy_wins.size() == 4 else -1,
			int(hard_wins[0]) if hard_wins.size() == 4 else -1,
			int(easy_score_delta[0]) if easy_score_delta.size() == 4 else 0,
			int(hard_score_delta[0]) if hard_score_delta.size() == 4 else 0,
			int(seed_row.get("easy_human_claim_declines", 0)),
			int(seed_row.get("hard_human_claim_declines", 0)),
		])
		check(int(seed_row.get("fixed_probe_seat", -1)) == 0 and int(seed_row.get("fixed_probe_difficulty", -1)) == scene.AI_DIFFICULTY_NORMAL, "seed %s keeps seat0 at the normal player probe" % str(seed_row.get("seed_base", 0)))
		check(bool(seed_row.get("paired_wall_seed", false)) and bool(seed_row.get("paired_profile_seed", false)), "seed %s keeps paired inputs" % str(seed_row.get("seed_base", 0)))
		check(bool(seed_row.get("integrity_all", false)), "seed %s preserves the physical tile ledger" % str(seed_row.get("seed_base", 0)))
		check(bool(seed_row.get("score_conservation_all", false)), "seed %s preserves the score ledger" % str(seed_row.get("seed_base", 0)))
		for diff in [scene.AI_DIFFICULTY_EASY, scene.AI_DIFFICULTY_HARD]:
			var diff_stats: Dictionary = by_diff.get(diff, {})
			var wins_by_seat: Array = diff_stats.get("wins_by_seat", [])
			var score_delta_by_seat: Array = diff_stats.get("score_delta_by_seat", [])
			check(wins_by_seat.size() == 4, "seed %s difficulty %s reports wins by seat" % [str(seed_row.get("seed_base", 0)), str(diff)])
			check(score_delta_by_seat.size() == 4, "seed %s difficulty %s reports score deltas by seat" % [str(seed_row.get("seed_base", 0)), str(diff)])
			if wins_by_seat.size() == 4 and score_delta_by_seat.size() == 4:
				var total_wins := 0
				var total_score_delta := 0
				for seat in range(4):
					total_wins += int(wins_by_seat[seat])
					total_score_delta += int(score_delta_by_seat[seat])
				check(total_wins == int(diff_stats.get("wins", -1)), "seed %s difficulty %s seat wins reconcile" % [str(seed_row.get("seed_base", 0)), str(diff)])
				check(total_score_delta == 0, "seed %s difficulty %s score deltas conserve" % [str(seed_row.get("seed_base", 0)), str(diff)])
	check(bool(summary.get("finished_all", false)), "independent aggregate reaches terminal hands")
	check(bool(summary.get("integrity_all", false)), "independent aggregate preserves the tile ledger")
	check(bool(summary.get("score_conservation_all", false)), "independent aggregate preserves the score ledger")
	check(bool(summary.get("hard_safer_human_avoidable_high_danger", false)), "hard avoids no fewer actionable player-pressure choices than easy")
	var easy_human_ron_hands := int(summary.get("easy_deal_ins_to_human", 0))
	var hard_human_ron_hands := int(summary.get("hard_deal_ins_to_human", 0))
	check(hard_human_ron_hands <= easy_human_ron_hands + 1, "hard allows at most one additional ron against the fixed player probe")
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
