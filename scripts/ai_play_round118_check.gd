extends SceneTree
## Round 118: feed-risk weighting reuses the report difficulty snapshot.

var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if condition:
		print("  OK  | %s" % message)
	else:
		print("  FAIL| %s" % message)
		failed = true


func run() -> void:
	print("=== ai_play_round118 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD

	print("--- A) helper snapshot equivalence ---")
	var fallback_weight: float = scene.discard_feed_penalty_weight(1.20, 0)
	var hard_snapshot_weight: float = scene.discard_feed_penalty_weight(1.20, 0, scene.AI_DIFFICULTY_HARD)
	var easy_snapshot_weight: float = scene.discard_feed_penalty_weight(1.20, 0, scene.AI_DIFFICULTY_EASY)
	check(is_equal_approx(fallback_weight, hard_snapshot_weight), "explicit hard difficulty preserves the live fallback")
	check(not is_equal_approx(hard_snapshot_weight, easy_snapshot_weight), "feed penalty weighting honors the explicit difficulty")

	print("--- B) discard context carries the reusable input ---")
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = []
	var context: Dictionary = scene.make_ai_evaluation_context(0, scene.visible_tile_counts_shared())
	check(int(context.get("discard_report_difficulty", -1)) == scene.AI_DIFFICULTY_HARD, "discard context carries the normalized difficulty")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
