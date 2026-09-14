extends SceneTree
## Round 139: quiet post-claim reports reuse the visible-count snapshot.

var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if condition:
		print("  OK  | %s" % message)
	else:
		print("  FAIL| %s" % message)
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
	print("=== ai_play_round139 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("Probe"), make_player("Caller"), make_player("Route"), make_player("Third")]
	scene.wall = scene.make_wall()
	scene.players[1]["hand"] = ["1B", "2B", "3B", "4B", "5B", "6B", "7B", "8B", "9B", "2T", "4T", "6T", "5W"]
	scene.players[2]["melds"] = [["1W", "2W", "3W"], ["7W", "8W", "9W"]]
	scene.players[2]["discards"] = ["1T", "2T", "3T", "4T", "5T", "6T"]
	scene.offline_claim_counts[scene.claim_source_key(2, 1)] = 2

	var visible_counts: Array = scene.visible_tile_counts_shared()
	var simulated_counts = scene.tile_counts(scene.players[1]["hand"])
	var candidate_index = scene.tile_index("5W")
	simulated_counts[candidate_index] = int(simulated_counts[candidate_index]) - 1
	var explicit_context: Dictionary = scene.make_ai_evaluation_context(1, visible_counts)
	var explicit_pressure: Dictionary = scene.ai_pressure_context(1, explicit_context)
	var explicit_report: Dictionary = scene.build_ai_fast_post_claim_discard_report(1, "5W", 1, explicit_pressure, explicit_context, simulated_counts, visible_counts)

	var legacy_context: Dictionary = scene.make_ai_evaluation_context(1, visible_counts)
	var legacy_pressure: Dictionary = scene.ai_pressure_context(1, legacy_context)
	var legacy_report: Dictionary = scene.build_ai_fast_post_claim_discard_report(1, "5W", 1, legacy_pressure, legacy_context, simulated_counts)
	print("    explicit safety=%s feed=%.1f score=%.1f" % [str(explicit_report.get("safety_label", "")), float(explicit_report.get("feed_risk", 0.0)), float(explicit_report.get("score", 0.0))])
	print("    legacy   safety=%s feed=%.1f score=%.1f" % [str(legacy_report.get("safety_label", "")), float(legacy_report.get("feed_risk", 0.0)), float(legacy_report.get("score", 0.0))])
	check(str(explicit_report.get("safety_label", "")) == str(legacy_report.get("safety_label", "")), "显式可见牌快照保持安全标签一致")
	check(explicit_report.get("feed_report", {}) == legacy_report.get("feed_report", {}), "显式可见牌快照保持喂牌报告一致")
	check(is_equal_approx(float(explicit_report.get("score", 0.0)), float(legacy_report.get("score", 0.0))) and is_equal_approx(float(explicit_report.get("risk", 0.0)), float(legacy_report.get("risk", 0.0))), "显式可见牌快照保持快速评估分数一致")
	check(bool(explicit_report.get("fast_post_claim", false)) and bool(legacy_report.get("fast_post_claim", false)), "新旧调用都保留快速副露后弃牌标记")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
