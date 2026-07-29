extends SceneTree
## Round 34: quiet Top-K keeps one material fold candidate under table pressure.
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


func report_for_tile(reports: Array, tile: String) -> Dictionary:
	for report in reports:
		if typeof(report) == TYPE_DICTIONARY and str(report.get("tile", "")) == tile:
			return report
	return {}


func run() -> void:
	print("=== ai_play_round34 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.setup_tile_order()
	scene.players = [make_player("Threat"), make_player("AI"), make_player("P2"), make_player("P3")]
	scene.wall = scene.make_wall()
	# Seat 0 is a late, open W-suit threat. It has discarded E, making E the
	# only clear fold tile in seat 1's hand, even though breaking the pair costs
	# efficiency and would normally fall behind the quiet Top-K cut.
	scene.players[0]["melds"] = [["1W", "2W", "3W"], ["4W", "5W", "6W"], ["7W", "8W", "9W"]]
	scene.players[0]["discards"] = ["E", "1T", "2T", "3T", "4T", "5T", "6T", "7T", "8T", "9T", "1B", "2B", "3B", "4B"]
	scene.players[1]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "2T", "3T", "E", "E", "5B"]
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	scene.clear_ai_report_cache()

	print("--- A) high-pressure quiet evaluation retains the fold option ---")
	var context = scene.make_ai_evaluation_context(1, scene.visible_tile_counts())
	var pressure = scene.ai_pressure_context(1, context)
	print("    readiness=%.1f rank=%d" % [float(pressure.get("readiness_pressure", 0.0)), int(pressure.get("threat_rank", 0))])
	check(float(pressure.get("readiness_pressure", 0.0)) >= 9.5 or int(pressure.get("threat_rank", 0)) >= 2, "夹具触发高压候选保留")
	var reports = scene.get_ai_discard_reports(1)
	var fold_report = report_for_tile(reports, "E")
	print("    candidates=%d fold=%s" % [reports.size(), str(fold_report)])
	check(reports.size() == scene.AI_FAST_EVAL_PRESSURE_TOP_K, "高压静默模式保留攻击与折返的完整评估槽位")
	check(not fold_report.is_empty(), "高压下完整评估包含安全折返牌")
	check(str(fold_report.get("safety_label", "")) == "现", "折返牌是主威胁现物")
	var min_shanten = 99
	for report in reports:
		min_shanten = min(min_shanten, int(report.get("shanten", 99)))
	check(int(fold_report.get("shanten", 99)) > min_shanten, "安全折返牌保留在低效率候选之外")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
