extends SceneTree
## Round 133: advisor cards reuse one threat summary for both defense texts.

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


func reset_scene_state(scene) -> void:
	scene.ai_assist_enabled = true
	scene.offline_sim_quiet = false
	scene.current_human_advice = []
	scene.clear_ai_report_cache()


func run() -> void:
	print("=== ai_play_round133 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.current_seat = 1
	scene.last_discard = "3B"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[1]["melds"] = [["5W", "5W", "5W"]]
	scene.players[2]["discards"] = ["1W", "4W", "7W"]
	scene.wall.clear()
	for _i in range(60):
		scene.wall.append("1B")

	print("--- A) pending-claim advisor card ---")
	scene.offline_phase = "pending_claim"
	scene.offline_pending_claim = {"tile": "5W", "options": ["pass"], "chi_choices": []}
	reset_scene_state(scene)
	var pending_summary: String = scene.opponent_threat_summary(0)
	var pending_baseline: String = scene.advisor_defense_text(0)
	scene.clear_ai_report_cache()
	var pending_payloads: Array = scene.advisor_panel_card_payloads()
	var pending_defense: Dictionary = pending_payloads[2] if pending_payloads.size() > 2 else {}
	check(pending_summary != "" and str(pending_defense.get("sub", "")) == pending_summary, "pending-claim defense card keeps the threat summary")
	check(str(pending_defense.get("main", "")) == pending_baseline, "pending-claim defense text remains unchanged")
	check(scene.threat_report_cache_misses > 0 and scene.threat_report_cache_hits == 0, "pending-claim card performs one threat lookup pass")

	print("--- B) waiting advisor card ---")
	scene.offline_phase = "resolving"
	scene.offline_pending_claim = {}
	reset_scene_state(scene)
	var waiting_baseline: String = scene.advisor_defense_text(0)
	scene.clear_ai_report_cache()
	var waiting_payloads: Array = scene.advisor_panel_card_payloads()
	var waiting_defense: Dictionary = waiting_payloads[2] if waiting_payloads.size() > 2 else {}
	check(str(waiting_defense.get("main", "")) == waiting_baseline, "waiting defense text remains unchanged")
	check(scene.threat_report_cache_misses > 0 and scene.threat_report_cache_hits == 0, "waiting card performs one threat lookup pass")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
