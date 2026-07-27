extends SceneTree
## Round 27: quiet post-claim previews keep feed and package-liability discipline.
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


func run() -> void:
	print("=== ai_play_round27 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.enable_offline_all_bot_mode(true, true)
	scene.setup_tile_order()
	scene.players = [make_player("Probe"), make_player("Caller"), make_player("Route"), make_player("Third")]
	scene.wall = scene.make_wall()
	# Seat 1 has already fed seat 2 twice. 5W is a low-level risk candidate,
	# but it advances seat 2's open W route and would create package liability.
	scene.players[1]["hand"] = ["1B", "2B", "3B", "4B", "5B", "6B", "7B", "8B", "9B", "2T", "4T", "6T", "5W"]
	scene.players[2]["melds"] = [["1W", "2W", "3W"], ["7W", "8W", "9W"]]
	scene.players[2]["discards"] = ["1T", "2T", "3T", "4T", "5T", "6T"]
	scene.offline_claim_counts[scene.claim_source_key(2, 1)] = 2

	print("--- A) quiet post-claim preview applies bounded feed discipline ---")
	var simulated_counts = scene.tile_counts(scene.players[1]["hand"])
	var candidate_index = scene.tile_index("5W")
	simulated_counts[candidate_index] = int(simulated_counts[candidate_index]) - 1
	var context = scene.make_ai_evaluation_context(1, scene.visible_tile_counts())
	var pressure = scene.ai_pressure_context(1, context)
	var t0 = Time.get_ticks_msec()
	var report = scene.build_ai_fast_post_claim_discard_report(1, "5W", 1, pressure, context, simulated_counts)
	var elapsed = Time.get_ticks_msec() - t0
	var unpenalized = -float(report.get("shanten", 8)) * 760.0
	unpenalized -= float(report.get("risk", 0.0)) * float(report.get("defense", scene.ai_defense_weight(1, int(report.get("shanten", 8)), pressure))) * scene.ai_risk_factor(1)
	unpenalized += scene.ai_safety_bonus(str(report.get("safety_label", "")), scene.ai_defense_weight(1, int(report.get("shanten", 8)), pressure), int(report.get("shanten", 8)))
	print("    feed=%.1f package=%.1f ms=%d" % [float(report.get("feed_risk", 0.0)), float(report.get("package_feed_penalty", 0.0)), elapsed])
	check(bool(report.get("fast_post_claim", false)), "静默路径仍使用轻量副露后弃牌评估")
	check(float(report.get("feed_risk", 0.0)) > 0.0 and report.has("feed_report"), "静默路径保留喂吃碰风险")
	check(bool(report.get("package_feed_pending", false)) and float(report.get("package_feed_penalty", 0.0)) > 0.0, "静默路径识别包三搭责任")
	check(float(report.get("score", 0.0)) < unpenalized, "喂牌与包赔风险实际压低静默候选分")
	check((context.get("feed_reports", {}) as Dictionary).size() == 1, "同一候选复用共享喂牌缓存")
	check(elapsed < 300, "静默副露预演保持低开销")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
