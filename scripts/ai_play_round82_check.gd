extends SceneTree
## Round 82: quiet commercial simulations must retain the four-seat score ledger.
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
	print("=== ai_play_round82 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.fast_mode_enabled = true
	scene.sfx_enabled = false
	scene.music_enabled = false
	scene.fx_enabled = false

	print("--- A) direct score ledger detects a non-zero-sum mutation ---")
	scene.ensure_ai_benchmark_players()
	var clean = scene.offline_score_ledger_report()
	print("    clean total=%d expected=%d delta=%d" % [
		int(clean.get("total", 0)),
		int(clean.get("expected_total", 0)),
		int(clean.get("delta", 0)),
	])
	check(bool(clean.get("ok", false)), "fresh four-seat table has a valid score ledger")
	check(int(clean.get("total", 0)) == scene.MATCH_START_SCORE * 4, "fresh table starts at the four-seat total")
	var baseline = int(clean.get("total", 0))
	scene.players[0]["score"] = int(scene.players[0].get("score", 0)) + 1
	var inflated = scene.offline_score_ledger_report(baseline)
	check(not bool(inflated.get("ok", true)) and int(inflated.get("delta", 0)) == 1, "ledger rejects a one-point score creation")
	scene.players[0]["score"] = int(scene.players[0].get("score", 0)) - 1

	print("--- B) paired difficulty samples keep both physical tiles and total score ---")
	var bench = scene.sample_ai_strength_benchmark(1, 20260730, false, true)
	var raw: Dictionary = bench.get("raw", {})
	var by_diff: Dictionary = raw.get("by_diff", {})
	for diff in [scene.AI_DIFFICULTY_EASY, scene.AI_DIFFICULTY_NORMAL, scene.AI_DIFFICULTY_HARD]:
		var row: Dictionary = by_diff.get(diff, {})
		print("    diff=%d ended=%d tile=%s score=%s" % [
			diff,
			int(row.get("ended", 0)),
			str(row.get("integrity_ok", false)),
			str(row.get("score_conserved", false)),
		])
		check(int(row.get("ended", 0)) == 1, "difficulty %d reaches a terminal hand" % diff)
		check(bool(row.get("integrity_ok", false)), "difficulty %d keeps the physical tile ledger" % diff)
		check(int(row.get("score_conserved_passed", 0)) == 1 and bool(row.get("score_conserved", false)), "difficulty %d keeps the score ledger" % diff)

	print("--- C) score conservation is mandatory for the commercial benchmark gate ---")
	print("    benchmark score e/n/h=%s/%s/%s aggregate=%s commercial=%s" % [
		str(bench.get("easy_score_conserved", false)),
		str(bench.get("normal_score_conserved", false)),
		str(bench.get("hard_score_conserved", false)),
		str(bench.get("score_conservation_all", false)),
		str(bench.get("commercial_strength_ok", false)),
	])
	check(bool(bench.get("score_conservation_all", false)), "commercial benchmark requires all sampled score ledgers")
	check(bool(bench.get("commercial_strength_ok", false)), "commercial benchmark remains green with the score gate")

	scene.enable_offline_all_bot_mode(false, false)
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
