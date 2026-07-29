extends SceneTree
## Round 87: a pure-suit plan receives its exclusivity bonus exactly once.
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
	print("=== ai_play_round87 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()

	print("--- A) pure-suit route bonus is not double-counted ---")
	var empty_counts = scene.tile_counts([])
	var pure_features := {
		"total": 8,
		"suit_counts": [8, 0, 0],
		"suit_rank_masks": [0, 0, 0],
		"honor_count": 0,
		"pair_count": 0,
		"triplet_count": 0,
		"orphan_unique": 0,
		"orphan_tiles": 0,
		"orphan_pair": false,
		"simple_tiles": 0,
		"terminal_honor_tiles": 0,
	}
	var pure_score = scene.hand_plan_score_from_features(empty_counts, pure_features)
	print("    pure score=%.1f" % pure_score)
	check(is_equal_approx(pure_score, 94.4), "eight-tile pure-suit baseline includes one 72-point exclusivity bonus")

	print("--- B) normal route discrimination remains intact ---")
	var almost_pure_features = pure_features.duplicate(true)
	almost_pure_features["suit_counts"] = [7, 1, 0]
	var almost_pure_score = scene.hand_plan_score_from_features(empty_counts, almost_pure_features)
	print("    almost-pure score=%.1f" % almost_pure_score)
	check(pure_score > almost_pure_score, "pure-suit route still outranks an off-suit alternative")
	check(is_equal_approx(pure_score - almost_pure_score, 38.8), "pure-versus-near-pure gap uses the intended single bonus")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
