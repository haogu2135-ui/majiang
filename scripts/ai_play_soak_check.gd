extends SceneTree
## Longer offline AI soak: independent seeds, paired easy/hard hands, and durable telemetry.

const SEEDS: Array = [20260831, 20260917, 20261003, 20261019, 20261104]
const HANDS_PER_SEED := 2
const OUTPUT_DIR := "res://build/qa/ai_play_soak_evidence"
var failed := false

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if condition:
		print("  OK  | %s" % message)
	else:
		print("  FAIL| %s" % message)
		failed = true

func write_artifacts(scene: Node, summary: Dictionary, rows: Array, elapsed_ms: int) -> Dictionary:
	var absolute_dir := ProjectSettings.globalize_path(OUTPUT_DIR)
	var mkdir_error := DirAccess.make_dir_recursive_absolute(absolute_dir)
	if mkdir_error != OK and not DirAccess.dir_exists_absolute(absolute_dir):
		return {"ok": false, "error": "mkdir:%d" % mkdir_error}
	var payload := {
		"version": str(scene.APP_VERSION),
		"seed_bases": SEEDS,
		"hands_per_seed": HANDS_PER_SEED,
		"paired_probe_seat": 0,
		"paired_probe_difficulty": int(scene.AI_DIFFICULTY_NORMAL),
		"rows": rows,
		"aggregate": summary,
		"elapsed_ms": elapsed_ms,
		"commercial_strength_ok": bool(summary.get("commercial_strength_ok", false)) and rows.size() == SEEDS.size(),
	}
	var json_path := OUTPUT_DIR + "/AI_SOAK_LATEST.json"
	var md_path := OUTPUT_DIR + "/AI_SOAK_LATEST.md"
	var json_file := FileAccess.open(json_path, FileAccess.WRITE)
	if json_file == null:
		return {"ok": false, "error": "json_open"}
	json_file.store_string(JSON.stringify(payload, "\t"))
	json_file.close()
	var md_lines: Array[String] = []
	md_lines.append("# AI Long Soak Evidence Latest")
	md_lines.append("")
	md_lines.append("Version: `%s`" % str(scene.APP_VERSION))
	md_lines.append("Seeds: %d independent paired seeds; hands/seed: %d; total hands: %d" % [SEEDS.size(), HANDS_PER_SEED, SEEDS.size() * HANDS_PER_SEED * 2])
	md_lines.append("Probe: seat 0 fixed at normal while easy/hard opponents are compared")
	md_lines.append("Aggregate commercial gate: **%s**" % ("PASS" if bool(payload.get("commercial_strength_ok", false)) else "FAIL"))
	md_lines.append("Per-seed strength flags are diagnostics only; two hands are too sparse for an independent difficulty claim.")
	md_lines.append("Elapsed ms: %d" % elapsed_ms)
	md_lines.append("")
	md_lines.append("## Aggregate")
	md_lines.append("- rows=%d finished=%s integrity=%s score=%s paired=%s/%s" % [int(summary.get("rows", 0)), str(summary.get("finished_all", false)), str(summary.get("integrity_all", false)), str(summary.get("score_conservation_all", false)), str(summary.get("paired_wall_seed", false)), str(summary.get("paired_profile_seed", false))])
	md_lines.append("- high danger e/h=%.4f/%.4f; avoidable high danger e/h=%.4f/%.4f" % [float(summary.get("easy_high_danger", 1.0)), float(summary.get("hard_high_danger", 1.0)), float(summary.get("easy_avoidable_high_danger", 1.0)), float(summary.get("hard_avoidable_high_danger", 1.0))])
	md_lines.append("- fixed-player high danger e/h=%.4f/%.4f; deal-in to player e/h=%.3f/%.3f" % [float(summary.get("easy_human_high_danger", 1.0)), float(summary.get("hard_human_high_danger", 1.0)), float(summary.get("easy_deal_in_to_human", 1.0)), float(summary.get("hard_deal_in_to_human", 1.0))])
	md_lines.append("")
	md_lines.append("## Seed Rows")
	md_lines.append("| Seed | Strength diagnostic | Stability gate | Finished | Integrity | Score | Elapsed ms |")
	md_lines.append("|---:|:---:|:---:|:---:|:---:|:---:|---:|")
	for row_value in rows:
		var row: Dictionary = row_value
		md_lines.append("| %d | %s | %s | %s | %s | %s | %d |" % [int(row.get("seed_base", 0)), str(row.get("commercial_strength_ok", false)), str(row.get("stability_ok", false)), str(row.get("finished_all", false)), str(row.get("integrity_all", false)), str(row.get("score_conservation_all", false)), int(row.get("elapsed_ms", 0))])
	var md_file := FileAccess.open(md_path, FileAccess.WRITE)
	if md_file == null:
		return {"ok": false, "error": "md_open"}
	md_file.store_string("\n".join(md_lines) + "\n")
	md_file.close()
	return {"ok": true, "json_path": json_path, "md_path": md_path}

func run() -> void:
	print("=== ai long soak START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.fast_mode_enabled = true
	scene.sfx_enabled = false
	scene.music_enabled = false
	scene.fx_enabled = false

	var aggregate: Dictionary = scene.empty_ai_strength_aggregate()
	var rows: Array = []
	var started := Time.get_ticks_msec()
	for seed_base in SEEDS:
		var row_started := Time.get_ticks_msec()
		var bench: Dictionary = scene.sample_ai_strength_benchmark(HANDS_PER_SEED, int(seed_base), false, false, 0, scene.AI_DIFFICULTY_NORMAL)
		scene.add_ai_strength_benchmark_to_aggregate(aggregate, bench)
		var raw: Dictionary = bench.get("raw", {})
		var by: Dictionary = raw.get("by_diff", {})
		var easy: Dictionary = by.get(scene.AI_DIFFICULTY_EASY, {})
		var hard: Dictionary = by.get(scene.AI_DIFFICULTY_HARD, {})
		var row := {
			"seed_base": int(seed_base),
			"elapsed_ms": Time.get_ticks_msec() - row_started,
			"commercial_strength_ok": bool(bench.get("commercial_strength_ok", false)),
			"finished_all": bool(bench.get("finished_all", false)),
			"integrity_all": bool(bench.get("integrity_all", false)),
			"score_conservation_all": bool(bench.get("score_conservation_all", false)),
			"paired_wall_seed": bool(bench.get("paired_wall_seed", false)),
			"paired_profile_seed": bool(bench.get("paired_profile_seed", false)),
			"hard_safer_human_avoidable_high_danger": bool(bench.get("hard_safer_human_avoidable_high_danger", false)),
			"easy_high_danger": float(bench.get("easy_high_danger", 1.0)),
			"hard_high_danger": float(bench.get("hard_high_danger", 1.0)),
			"easy_avoidable_high_danger": float(bench.get("easy_avoidable_high_danger", 1.0)),
			"hard_avoidable_high_danger": float(bench.get("hard_avoidable_high_danger", 1.0)),
			"easy_deal_in_to_human": float(bench.get("easy_deal_in_to_human", 1.0)),
			"hard_deal_in_to_human": float(bench.get("hard_deal_in_to_human", 1.0)),
			"easy_finished": int(easy.get("ended", 0)),
			"hard_finished": int(hard.get("ended", 0)),
		}
		row["stability_ok"] = bool(row.get("finished_all", false)) \
			and bool(row.get("integrity_all", false)) \
			and bool(row.get("score_conservation_all", false)) \
			and bool(row.get("paired_wall_seed", false)) \
			and bool(row.get("paired_profile_seed", false))
		rows.append(row)
		print("    seed=%d pass=%s finished=%s integrity=%s score=%s hd=%.3f/%.3f elapsed=%dms" % [int(seed_base), str(row.get("commercial_strength_ok", false)), str(row.get("finished_all", false)), str(row.get("integrity_all", false)), str(row.get("score_conservation_all", false)), float(row.get("easy_high_danger", 1.0)), float(row.get("hard_high_danger", 1.0)), int(row.get("elapsed_ms", 0))])
		check(bool(row.get("stability_ok", false)), "seed %d finishes with physical and score integrity" % int(seed_base))
		check(bool(row.get("paired_wall_seed", false)) and bool(row.get("paired_profile_seed", false)), "seed %d keeps paired wall/profile inputs" % int(seed_base))

	var elapsed := Time.get_ticks_msec() - started
	var summary: Dictionary = scene.finalize_ai_strength_aggregate(aggregate)
	print("    aggregate rows=%d hands=%d/%d pass=%s finished=%s integrity=%s score=%s elapsed=%dms" % [int(summary.get("rows", 0)), int(summary.get("easy_hands", 0)), int(summary.get("hard_hands", 0)), str(summary.get("commercial_strength_ok", false)), str(summary.get("finished_all", false)), str(summary.get("integrity_all", false)), str(summary.get("score_conservation_all", false)), elapsed])
	check(rows.size() == SEEDS.size(), "all independent soak seeds produce rows")
	check(bool(summary.get("finished_all", false)), "soak aggregate reaches terminal hands")
	check(bool(summary.get("integrity_all", false)), "soak aggregate preserves the physical tile ledger")
	check(bool(summary.get("score_conservation_all", false)), "soak aggregate preserves the score ledger")
	check(bool(summary.get("hard_safer_human_avoidable_high_danger", false)), "hard remains no worse on actionable player pressure")
	check(bool(summary.get("hard_safer_deal_in_to_human", false)), "hard does not increase deal-in to the fixed player probe")
	check(bool(summary.get("commercial_strength_ok", false)), "soak aggregate passes the commercial strength gate")
	check(elapsed < 170000, "soak remains inside the serial 180-second budget")

	var written := write_artifacts(scene, summary, rows, elapsed)
	print("    artifacts ok=%s json=%s md=%s error=%s" % [str(written.get("ok", false)), str(written.get("json_path", "")), str(written.get("md_path", "")), str(written.get("error", ""))])
	check(bool(written.get("ok", false)), "soak writes durable JSON and Markdown evidence")

	scene.enable_offline_all_bot_mode(false, false)
	scene.shutdown_runtime()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
