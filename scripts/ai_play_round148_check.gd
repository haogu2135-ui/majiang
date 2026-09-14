extends SceneTree
## Round 148: discard pressure resolves each opponent's discard presence once.

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
	print("=== ai_play_round148 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[1]["discards"] = ["5W", "1W", "2W", "3W"]
	scene.players[2]["discards"] = ["5W", "4W", "6W"]
	scene.players[3]["discards"] = ["9B"]

	var visible_counts: Array = scene.visible_tile_counts_shared()
	var context: Dictionary = scene.make_ai_evaluation_context(0, visible_counts)
	var contextual_score: float = scene.discard_pressure_score("5W", 0, visible_counts, context)
	var visible_count: int = scene.visible_tile_count_from_counts("5W", visible_counts)
	var expected_score: float = float(visible_count) * 3.4 + 3.5 + 5.0 + 3.5 + 1.2 + 1.2

	print("--- A) one opponent lookup preserves pressure score ---")
	print("    visible=%d score=%.1f expected=%.1f" % [visible_count, contextual_score, expected_score])
	check(is_equal_approx(contextual_score, expected_score), "下家额外权重与其他对手压力保持单次计分")
	var fallback_score: float = scene.discard_pressure_score("5W", 0, visible_counts)
	check(is_equal_approx(fallback_score, contextual_score), "无上下文调用保持实时回退结果")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
