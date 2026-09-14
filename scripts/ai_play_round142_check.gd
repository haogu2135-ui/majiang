extends SceneTree
## Round 142: deal-in risk scoring reuses an existing visible-count snapshot.

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
	print("=== ai_play_round142 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.offline_all_bot_mode = true
	scene.players = [make_player("P0"), make_player("AI"), make_player("P2"), make_player("P3")]
	scene.current_seat = 1
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.wall = scene.make_wall()
	scene.players[1]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "3T", "5T", "E", "S"]
	scene.players[2]["melds"] = [["1W", "2W", "3W"], ["7W", "8W", "9W"]]
	scene.players[2]["discards"] = ["1T", "2T", "3T", "4T", "5T", "6T"]

	var visible_counts: Array = scene.visible_tile_counts_shared()
	var explicit_context: Dictionary = scene.make_ai_evaluation_context(1, visible_counts)
	var legacy_context: Dictionary = scene.make_ai_evaluation_context(1, visible_counts)
	var explicit_score: float = scene.deal_in_risk_score("1W", 1, explicit_context, visible_counts)
	var legacy_score: float = scene.deal_in_risk_score("1W", 1, legacy_context)

	print("--- A) explicit snapshot preserves the legacy risk score ---")
	print("    explicit=%.1f legacy=%.1f" % [explicit_score, legacy_score])
	check(is_equal_approx(explicit_score, legacy_score), "显式可见牌快照保持风险评分一致")

	print("--- B) quiet post-claim report forwards the snapshot ---")
	scene.players[1]["hand"] = ["1B", "2B", "3B", "4B", "5B", "6B", "7B", "8B", "9B", "2T", "4T", "6T", "5W"]
	var simulated_counts: Array = scene.tile_counts(scene.players[1]["hand"])
	var candidate_index: int = scene.tile_index_normalized("5W")
	simulated_counts[candidate_index] = int(simulated_counts[candidate_index]) - 1
	var report_context: Dictionary = scene.make_ai_evaluation_context(1, visible_counts)
	var pressure_context: Dictionary = scene.ai_pressure_context(1, report_context)
	var report: Dictionary = scene.build_ai_fast_post_claim_discard_report(1, "5W", 1, pressure_context, report_context, simulated_counts, visible_counts)
	var expected_score: float = scene.deal_in_risk_score("5W", 1, report_context, visible_counts)
	check(is_equal_approx(float(report.get("risk", 0.0)), expected_score), "快速副露报告沿用风险评分快照")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
