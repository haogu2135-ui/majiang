extends SceneTree
## Round 78: bounded fixed-human probe for the remaining R69 outlier seed.
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
	print("=== ai_play_round78 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.fast_mode_enabled = true
	scene.sfx_enabled = false
	scene.music_enabled = false
	scene.fx_enabled = false

	var t0 = Time.get_ticks_msec()
	var bench = scene.sample_ai_strength_benchmark(2, 20260827, false, false, 0, scene.AI_DIFFICULTY_NORMAL)
	var elapsed = Time.get_ticks_msec() - t0
	print("    probe=%s/%s finished=%s integrity=%s hd=%.3f/%.3f humanHD=%.3f/%.3f dealin=%.2f/%.2f humanRon=%.2f/%.2f ms=%d" % [
		str(bench.get("fixed_probe_seat", -1)),
		str(bench.get("fixed_probe_difficulty", -1)),
		str(bench.get("finished_all", false)),
		str(bench.get("integrity_all", false)),
		float(bench.get("easy_high_danger", 1.0)),
		float(bench.get("hard_high_danger", 1.0)),
		float(bench.get("easy_human_high_danger", 1.0)),
		float(bench.get("hard_human_high_danger", 1.0)),
		float(bench.get("easy_deal_in", 1.0)),
		float(bench.get("hard_deal_in", 1.0)),
		float(bench.get("easy_deal_in_to_human", 1.0)),
		float(bench.get("hard_deal_in_to_human", 1.0)),
		elapsed,
	])
	check(int(bench.get("fixed_probe_seat", -1)) == 0, "seat0 remains the human probe")
	check(int(bench.get("fixed_probe_difficulty", -1)) == scene.AI_DIFFICULTY_NORMAL, "human probe uses normal difficulty")
	check(bool(bench.get("finished_all", false)), "paired probe hands finish")
	check(bool(bench.get("integrity_all", false)), "paired probe hands retain inventory integrity")
	check(bench.has("hard_safer_high_danger"), "overall high danger remains available for diagnostics")
	check(bool(bench.get("hard_safer_human_high_danger", false)), "hard player-target high danger is no worse")
	check(float(bench.get("hard_deal_in_to_human", 1.0)) <= float(bench.get("easy_deal_in_to_human", 0.0)) + 0.001, "hard actual human ron is no worse")
	check(elapsed < 110000, "single-seed human probe stays within serial low-resource budget")

	scene.enable_offline_all_bot_mode(false, false)
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
