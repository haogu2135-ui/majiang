extends SceneTree

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
	return {"name": name, "hand": [], "discards": [], "melds": [], "flowers": 0, "flower_tiles": [], "score": 25000, "bot": name != "Human"}


func reset_pending_fixture(scene: Node, expired: bool = true) -> void:
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.offline_all_bot_mode = false
	scene.offline_ai_active = true
	scene.offline_phase = "pending_claim"
	scene.current_seat = 0
	scene.offline_turn_needs_draw = false
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.players = [make_player("Human"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["1W", "2W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E", "E", "1T", "1T"]
	scene.players[2]["discards"] = ["3W"]
	scene.wall = scene.make_wall()
	scene.last_discard = "3W"
	scene.last_discard_seat = 2
	scene.offline_pending_claim = {"from_seat": 2, "tile": "3W", "options": ["hu"], "deadline_msec": Time.get_ticks_msec() + (-1 if expired else 60000)}
	scene.offline_passed_win_tiles.clear()
	scene.offline_claim_discard_bans.clear()
	scene.last_win_score.clear()
	scene.table_logs.clear()
	scene.pending_claim_auto_pass_feedback = ""
	scene.clear_pending_danger_discard()


func check_pass_resolved(scene: Node, hand: Array, label: String) -> void:
	check(scene.offline_pending_claim.is_empty() and scene.offline_phase != "pending_claim", "%s releases the response window" % label)
	check(scene.players[0]["hand"] == hand and scene.players[0]["melds"].is_empty(), "%s cannot accept a stale win or meld" % label)
	check(scene.players[2]["discards"] == ["3W"] and scene.last_win_score.is_empty(), "%s preserves the discarded tile instead of settling" % label)
	check(scene.is_passed_win_tile(0, "3W"), "%s preserves the local passed-win contract" % label)
	var score_total := 0
	for player in scene.players:
		score_total += int(player.get("score", 0))
	check(score_total == 100000, "%s keeps table score conserved" % label)


func run() -> void:
	print("=== ai_play_round294 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	for claim in ["pass", "hu", "peng", "gang", "chi"]:
		reset_pending_fixture(scene)
		check(scene.pending_claim_remaining_seconds() == 0 and scene.can_win_for_seat(0, "3W"), "expired %s fixture has a genuine winning hand" % claim)
		var hand: Array = scene.players[0]["hand"].duplicate()
		scene.human_claim(claim)
		check_pass_resolved(scene, hand, "expired %s" % claim)
		var logs: Array = scene.table_logs.duplicate()
		scene.human_claim(claim)
		check(scene.table_logs == logs, "expired %s cannot resolve twice" % claim)

	reset_pending_fixture(scene)
	var timeout_hand: Array = scene.players[0]["hand"].duplicate()
	scene.update_pending_claim_live_state()
	check_pass_resolved(scene, timeout_hand, "automatic timeout")
	check(scene.pending_claim_auto_pass_feedback.contains("已自动过"), "automatic timeout retains its visible feedback")
	var timeout_logs: Array = scene.table_logs.duplicate()
	scene.update_pending_claim_live_state()
	check(scene.table_logs == timeout_logs, "the next deadline poll cannot repeat the timeout")

	reset_pending_fixture(scene, false)
	check(scene.pending_claim_remaining_seconds() > 0, "unexpired winning fixture remains available")
	scene.human_claim("hu")
	check(scene.offline_phase == "ended" and not scene.last_win_score.is_empty(), "unexpired legal hu still settles normally")

	reset_pending_fixture(scene, false)
	scene.current_seat = 2
	scene.players[2]["hand"] = ["3W"]
	scene.players[2]["melds"] = [["3W", "3W", "3W"]]
	scene.players[2]["discards"] = []
	scene.wall.clear()
	scene.wall.append("8B")
	scene.offline_pending_claim["rob_gang"] = true
	check(scene.can_finish_offline_round(0, "3W", false, 2, "rob_gang"), "the unexpired rob-gang window authenticates a legal human win")
	scene.human_claim("pass")
	check(scene.offline_phase == "await_discard" and scene.current_seat == 2 and not scene.offline_turn_needs_draw and scene.offline_pending_claim.is_empty(), "an authenticated rob-gang pass returns after completion without reentering resolving")
	check(scene.players[2]["melds"] == [["3W", "3W", "3W", "3W"]] and scene.players[2]["hand"] == ["8B"] and str(scene.offline_last_draw.get("source", "")) == "gang", "a rob-gang pass completes one added gang and one replacement draw")
	var completed: Dictionary = scene.players[2].duplicate(true)
	var completed_events: Array = scene.round_event_history.duplicate(true)
	scene.human_claim("pass")
	check(scene.players[2] == completed and scene.round_event_history == completed_events and scene.offline_phase == "await_discard", "a consumed rob-gang pass cannot replay completion or change its live phase")

	scene.queue_free()
	await process_frame
	print("=== RESULT: %s ===" % ("FAIL" if failed else "OK"))
	quit(1 if failed else 0)
