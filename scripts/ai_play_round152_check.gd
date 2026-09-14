extends SceneTree
## Round 152: opponent pattern threat is memoized per opponent, tile, and visibility.

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
	print("=== ai_play_round152 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[1]["melds"] = [["1W", "2W", "3W"]]
	scene.players[1]["discards"] = ["9B"]

	var visible_counts: Array = scene.visible_tile_counts_shared()
	var context: Dictionary = scene.make_ai_evaluation_context(0, visible_counts)
	var visible_count: int = scene.visible_tile_count_from_counts("5W", visible_counts)
	var score: float = scene.opponent_pattern_threat_score(1, "5W", visible_count, context)
	var cached_score: float = scene.opponent_pattern_threat_score(1, "5W", visible_count, context)
	var fallback_score: float = scene.opponent_pattern_threat_score(1, "5W", visible_count)
	var cache = context.get("pattern_threats", {})

	print("--- A) pattern-threat context memo preserves the score ---")
	print("    score=%.1f cached=%.1f fallback=%.1f entries=%d" % [score, cached_score, fallback_score, cache.size() if typeof(cache) == TYPE_DICTIONARY else 0])
	check(score > 0.0 and is_equal_approx(score, cached_score) and is_equal_approx(score, fallback_score), "对手模式威胁重复调用保持评分")
	check(typeof(cache) == TYPE_DICTIONARY and cache.size() == 1, "同一对手/牌/可见数只建立一个上下文缓存条目")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
