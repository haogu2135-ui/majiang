extends SceneTree
## Round 211: pattern-threat scoring reuses the caller's tile index snapshot.

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


func legacy_opponent_tile_threat_score(scene, tile: String, seat: int, visible_counts_snapshot: Array, eval_context: Dictionary) -> float:
	if seat < 0 or seat >= scene.players.size():
		return 0.0
	var total := 0.0
	var known_counts = scene.ai_context_known_counts(eval_context, seat, visible_counts_snapshot)
	var visible = scene.visible_tile_count_from_counts(tile, known_counts)
	for other in range(scene.players.size()):
		if other == seat:
			continue
		if scene.opponent_discard_tile_count(other, tile, eval_context) > 0:
			continue
		total += scene.opponent_pattern_threat_score(other, tile, visible, eval_context)
	return total


func run() -> void:
	print("=== ai_play_round211 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[1]["melds"] = [["1W", "2W", "3W"]]
	scene.players[1]["discards"] = ["9B"]
	var visible_counts: Array = scene.make_empty_tile_counts()
	var cases: Array = [
		{"tile": "5W", "label": "middle number"},
		{"tile": "1W", "label": "terminal number"},
		{"tile": "E", "label": "honor"},
		{"tile": "ZZ", "label": "invalid tile"},
	]
	for case in cases:
		var tile := str(case.get("tile", ""))
		var label := str(case.get("label", tile))
		var visible: int = scene.visible_tile_count_from_counts(tile, visible_counts)
		var explicit_context: Dictionary = scene.make_ai_evaluation_context(0, visible_counts)
		var fallback_context: Dictionary = scene.make_ai_evaluation_context(0, visible_counts)
		var explicit_index: int = scene.tile_index(tile)
		var explicit: float = scene.opponent_pattern_threat_score(1, tile, visible, explicit_context, explicit_index)
		var fallback: float = scene.opponent_pattern_threat_score(1, tile, visible, fallback_context)
		check(is_equal_approx(explicit, fallback), "%s explicit index preserves pattern threat" % label)

	var aggregate_context: Dictionary = scene.make_ai_evaluation_context(0, visible_counts)
	var legacy_context: Dictionary = scene.make_ai_evaluation_context(0, visible_counts)
	var aggregate: float = scene.opponent_tile_threat_score("5W", 0, visible_counts, {}, aggregate_context)
	var legacy: float = legacy_opponent_tile_threat_score(scene, "5W", 0, visible_counts, legacy_context)
	check(is_equal_approx(aggregate, legacy), "aggregate opponent threat preserves the legacy loop result")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
