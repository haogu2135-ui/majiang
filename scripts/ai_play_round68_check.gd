extends SceneTree
## Round 68: multi-seed commercial strength evidence pack under low resources.
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
	print("=== ai_play_round68 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.fast_mode_enabled = true
	scene.sfx_enabled = false
	scene.music_enabled = false
	scene.fx_enabled = false

	print("--- A) multi-seed commercial strength pack ---")
	# Keep resource use low: 2 hands/diff × easy/hard × 3 fixed seeds + 1 shuffled sample.
	var seeds: Array = [20260730, 20260811, 20260827]
	var t0 = Time.get_ticks_msec()
	var pack = scene.sample_ai_commercial_strength_pack(2, seeds, true)
	var elapsed = Time.get_ticks_msec() - t0
	print("    elapsed=%d ok=%s fixed_pass=%s/%s total_ms=%s" % [
		elapsed,
		str(pack.get("commercial_strength_ok", false)),
		str(pack.get("fixed_pass_count", 0)),
		str((pack.get("fixed_rows", []) as Array).size()),
		str(pack.get("total_elapsed_ms", 0)),
	])
	for row in pack.get("fixed_rows", []):
		if typeof(row) != TYPE_DICTIONARY:
			continue
		print("    fixed seed=%s ok=%s hd(raw/avoid)=%.3f/%.3f %.3f/%.3f humanHD=%.3f/%.3f di=%.2f/%.2f ms_h=%.0f" % [
			str(row.get("seed_base", 0)),
			str(row.get("commercial_strength_ok", false)),
			float(row.get("easy_high_danger", 1.0)),
			float(row.get("hard_high_danger", 1.0)),
			float(row.get("easy_avoidable_high_danger", 1.0)),
			float(row.get("hard_avoidable_high_danger", 1.0)),
			float(row.get("easy_human_high_danger", 1.0)),
			float(row.get("hard_human_high_danger", 1.0)),
			float(row.get("easy_deal_in", 1.0)),
			float(row.get("hard_deal_in", 1.0)),
			float(row.get("avg_ms_hard", 0.0)),
		])
	var aggregate: Dictionary = pack.get("aggregate", {})
	var fixed_aggregate: Dictionary = pack.get("fixed_aggregate", {})
	print("    aggregate ok=%s fixed_ok=%s hd(raw/avoid)=%.3f/%.3f %.3f/%.3f humanHD=%.3f/%.3f di=%.2f/%.2f humanRon=%.2f/%.2f paired=%s/%s" % [
		str(aggregate.get("commercial_strength_ok", false)),
		str(fixed_aggregate.get("commercial_strength_ok", false)),
		float(aggregate.get("easy_high_danger", 1.0)),
		float(aggregate.get("hard_high_danger", 1.0)),
		float(aggregate.get("easy_avoidable_high_danger", 1.0)),
		float(aggregate.get("hard_avoidable_high_danger", 1.0)),
		float(aggregate.get("easy_human_high_danger", 1.0)),
		float(aggregate.get("hard_human_high_danger", 1.0)),
		float(aggregate.get("easy_deal_in", 1.0)),
		float(aggregate.get("hard_deal_in", 1.0)),
		float(aggregate.get("easy_deal_in_to_human", 1.0)),
		float(aggregate.get("hard_deal_in_to_human", 1.0)),
		str(pack.get("paired_wall_seed", false)),
		str(pack.get("paired_profile_seed", false)),
	])
	var shuffled: Dictionary = pack.get("shuffled_row", {})
	if not shuffled.is_empty():
		print("    shuffled seed=%s ok=%s hd(raw/avoid)=%.3f/%.3f %.3f/%.3f humanHD=%.3f/%.3f di=%.2f/%.2f ms_h=%.0f" % [
			str(shuffled.get("seed_base", 0)),
			str(shuffled.get("commercial_strength_ok", false)),
			float(shuffled.get("easy_high_danger", 1.0)),
			float(shuffled.get("hard_high_danger", 1.0)),
			float(shuffled.get("easy_avoidable_high_danger", 1.0)),
			float(shuffled.get("hard_avoidable_high_danger", 1.0)),
			float(shuffled.get("easy_human_high_danger", 1.0)),
			float(shuffled.get("hard_human_high_danger", 1.0)),
			float(shuffled.get("easy_deal_in", 1.0)),
			float(shuffled.get("hard_deal_in", 1.0)),
			float(shuffled.get("avg_ms_hard", 0.0)),
		])
	check((pack.get("fixed_rows", []) as Array).size() == 3, "pack contains three fixed-profile seeds")
	check(bool(pack.get("paired_wall_seed", false)), "pack compares difficulties on paired wall seeds")
	check(bool(pack.get("paired_profile_seed", false)), "pack compares difficulties on paired profile maps")
	check(bool(fixed_aggregate.get("score_conservation_all", false)), "fixed-profile aggregate retains total table score")
	check(bool(fixed_aggregate.get("commercial_strength_ok", false)), "fixed-profile aggregate passes commercial gate")
	check(not shuffled.is_empty(), "pack includes shuffled-profile sample")
	check(str(shuffled.get("profile_policy", "")) == "paired_full_shuffle", "shuffled sample uses paired full profile maps")
	check(bool(aggregate.get("score_conservation_all", false)), "combined aggregate retains total table score")
	check(bool(aggregate.get("commercial_strength_ok", false)), "aggregate including shuffled sample passes commercial gate")
	check(bool(pack.get("commercial_strength_ok", false)), "aggregate commercial strength pack is green")
	check(elapsed < 180000, "multi-seed pack stays within low-resource serial budget")
	check(float(pack.get("total_elapsed_ms", 999999.0)) < 180000.0, "reported pack runtime stays low-resource")

	print("--- B) durable evidence artifacts ---")
	var written = scene.write_ai_commercial_strength_evidence_pack(pack)
	print("    write ok=%s json=%s md=%s err=%s" % [
		str(written.get("ok", false)),
		str(written.get("json_path", "")),
		str(written.get("md_path", "")),
		str(written.get("error", "")),
	])
	check(bool(written.get("ok", false)), "strength pack writes durable artifacts")
	var json_path = str(written.get("json_path", ""))
	var md_path = str(written.get("md_path", ""))
	check(FileAccess.file_exists(json_path), "STRENGTH_PACK_LATEST.json exists")
	check(FileAccess.file_exists(md_path), "STRENGTH_PACK_LATEST.md exists")
	var json_text = FileAccess.get_file_as_string(json_path)
	var md_text = FileAccess.get_file_as_string(md_path)
	check(json_text.find("commercial_strength_ok") >= 0, "json evidence contains commercial gate field")
	check(json_text.find("score_conservation_all") >= 0, "json evidence contains score-conservation field")
	check(json_text.find("avoidable_high_danger") >= 0, "json evidence contains actionable all-opponent danger telemetry")
	check(md_text.find("AI Commercial Strength Pack Latest") >= 0, "markdown evidence has title")
	check(md_text.find("PASS") >= 0 or md_text.find("FAIL") >= 0, "markdown evidence reports gate result")
	check(md_text.find("hd raw e/h=") >= 0 and md_text.find("avoid e/h=") >= 0, "markdown evidence reports raw and actionable all-opponent danger")

	scene.enable_offline_all_bot_mode(false, false)
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
