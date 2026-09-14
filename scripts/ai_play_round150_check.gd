extends SceneTree
## Round 150: all-opponent safety results are memoized per evaluation context.

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
	print("=== ai_play_round150 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[1]["discards"] = ["5W"]
	scene.players[2]["discards"] = ["5W"]
	scene.players[3]["discards"] = ["5W"]

	var visible_counts: Array = scene.visible_tile_counts_shared()
	var context: Dictionary = scene.make_ai_evaluation_context(0, visible_counts)
	var safe: bool = scene.is_tile_safe_against_all("5W", 0, context)
	var safe_cached: bool = scene.is_tile_safe_against_all("5W", 0, context)
	var unsafe: bool = scene.is_tile_safe_against_all("6W", 0, context)
	var safety_cache = context.get("all_safe_tiles", {})

	print("--- A) context safety memo preserves both outcomes ---")
	print("    safe=%s cached=%s unsafe=%s entries=%d" % [str(safe), str(safe_cached), str(unsafe), safety_cache.size() if typeof(safety_cache) == TYPE_DICTIONARY else 0])
	check(safe and safe_cached and not unsafe, "全桌现物结果在重复调用中保持正确")
	check(typeof(safety_cache) == TYPE_DICTIONARY and safety_cache.size() == 2, "真假安全结果均进入一次评估上下文缓存")
	check(not scene.is_tile_safe_against_all("6W", 0), "无上下文调用保持实时扫描回退")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
