extends SceneTree
## Round 210: single-opponent risk reuses one tile classification snapshot.

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


func legacy_risk_components(scene, tile: String, seat: int, opponent: int, visible_override: int, visible_counts_snapshot: Array, eval_context: Dictionary) -> Dictionary:
	var result: Dictionary = {"risk": 0.0, "pattern_threat": 0.0}
	if tile == "" or seat < 0 or seat >= scene.players.size() or opponent < 0 or opponent >= scene.players.size() or opponent == seat:
		return result
	if scene.opponent_discard_tile_count(opponent, tile, eval_context) > 0:
		return result
	var visible = visible_override if visible_override >= 0 else scene.visible_tile_count_from_counts(tile, visible_counts_snapshot)
	var opponent_state = scene.ai_context_opponent_state(eval_context, opponent)
	var meld_count = scene.ai_opponent_state_count(opponent_state, opponent, "melds")
	var discard_count = scene.ai_opponent_state_count(opponent_state, opponent, "discards")
	var pressure = 2.0 + float(meld_count) * 3.2
	var readiness = scene.opponent_readiness_score(opponent, eval_context)
	if visible == 0:
		pressure += 4.8
	elif visible == 1:
		pressure += 2.2
	elif visible >= 3:
		pressure -= 4.0
	if scene.is_middle_number_tile(tile):
		pressure += 3.0
	elif scene.is_terminal_or_honor(tile):
		pressure -= 1.4
	if scene.is_honor_tile(tile) and visible == 0:
		pressure += 2.0
	if opponent == (seat + 1) % 4 and scene.can_feed_chi(tile):
		pressure += 1.8
	if discard_count >= 12 or meld_count >= 3:
		pressure += 2.8
	if readiness >= 7.0:
		pressure += readiness * (0.32 if scene.is_terminal_or_honor(tile) else 0.52)
		if scene.is_middle_number_tile(tile):
			pressure += readiness * 0.18
	if scene.is_suji_safe_against_opponent(tile, opponent, eval_context):
		pressure -= 8.6
	elif scene.is_kabe_safe_against_opponent(tile, opponent, visible_counts_snapshot, eval_context):
		pressure -= 5.4
	var pattern_threat = scene.opponent_pattern_threat_score(opponent, tile, visible, eval_context)
	pressure += pattern_threat
	result["risk"] = max(0.0, pressure)
	result["pattern_threat"] = pattern_threat
	return result


func run() -> void:
	print("=== ai_play_round210 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	var visible_counts: Array = scene.make_empty_tile_counts()
	var cases: Array = [
		{"tile": "5W", "visible": 0, "label": "middle number"},
		{"tile": "1W", "visible": 1, "label": "terminal number"},
		{"tile": "E", "visible": 0, "label": "honor"},
		{"tile": "ZZ", "visible": 0, "label": "invalid tile"},
	]
	for case in cases:
		var tile := str(case.get("tile", ""))
		var visible := int(case.get("visible", 0))
		var expected_context: Dictionary = scene.make_ai_evaluation_context(0, visible_counts)
		var actual_context: Dictionary = scene.make_ai_evaluation_context(0, visible_counts)
		var expected: Dictionary = legacy_risk_components(scene, tile, 0, 1, visible, visible_counts, expected_context)
		var actual: Dictionary = scene.single_opponent_deal_in_risk_components(tile, 0, 1, visible, visible_counts, actual_context)
		check(is_equal_approx(float(actual.get("risk", 0.0)), float(expected.get("risk", 0.0))), "%s risk matches the legacy formula" % str(case.get("label", tile)))
		check(is_equal_approx(float(actual.get("pattern_threat", 0.0)), float(expected.get("pattern_threat", 0.0))), "%s pattern threat matches the legacy formula" % str(case.get("label", tile)))

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
