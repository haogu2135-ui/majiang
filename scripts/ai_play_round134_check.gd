extends SceneTree
## Round 134: advisor helper text reuses one threat report.

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
	print("=== ai_play_round134 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.offline_turn_needs_draw = false
	scene.ai_assist_enabled = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["1W", "2W"]
	scene.players[1]["melds"] = [["5W", "5W", "5W"], ["6W", "6W", "6W"]]
	scene.wall.clear()
	for _i in range(60):
		scene.wall.append("1B")

	var recommended := {"tile": "1W", "risk": 12.0, "risk_label": "中", "safety_label": "", "stance": "均衡"}
	var safest := {"tile": "2W", "risk": 1.0, "risk_label": "低", "safety_label": "安", "stance": "均衡", "score": 0.0, "ukeire": 0}
	var reports: Array = [recommended, safest]

	print("--- A) explicit safest-hint threat snapshot ---")
	scene.clear_ai_report_cache()
	var threat_snapshot: Dictionary = scene.opponent_threat_report(0)
	scene.clear_ai_report_cache()
	var fallback_hint: String = scene.safest_discard_hint_text(recommended, safest)
	scene.clear_ai_report_cache()
	var snapshot_hint: String = scene.safest_discard_hint_text(recommended, safest, threat_snapshot)
	check(not threat_snapshot.is_empty() and fallback_hint == snapshot_hint, "safest-discard hint preserves its threat-gated result")
	check(scene.threat_report_cache_hits == 0 and scene.threat_report_cache_misses == 0, "safest-discard hint consumes the supplied threat report without lookup")

	print("--- B) detailed defense threat snapshot ---")
	scene.clear_ai_report_cache()
	var defense_text: String = scene.advisor_defense_text(0, recommended, reports)
	check(defense_text != "" and scene.threat_report_cache_misses > 0 and scene.threat_report_cache_hits == 0, "detailed defense text reuses its first threat report")

	print("--- C) public hint and summary threat snapshot ---")
	scene.current_human_advice = reports
	scene.clear_ai_report_cache()
	var hint_text: String = scene.human_hint_text()
	check(hint_text != "" and scene.threat_report_cache_misses > 0 and scene.threat_report_cache_hits == 0, "human hint formats one threat report")
	scene.clear_ai_report_cache()
	var advice_text: String = scene.ai_advice_summary(0)
	check(advice_text != "" and scene.threat_report_cache_misses > 0 and scene.threat_report_cache_hits == 0, "advice summary formats one threat report")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
