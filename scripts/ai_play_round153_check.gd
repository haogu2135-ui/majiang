extends SceneTree
## Round 153: discard reports can fuse shape and route feature scans.

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
	print("=== ai_play_round153 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var tiles: Array = ["1W", "2W", "3W", "4W", "5W", "5W", "7W", "8W", "1T", "1T", "3T", "E", "E", "R"]
	var counts: Array = scene.tile_counts(tiles)
	var regular_shape: Dictionary = scene.ai_hand_shape_metrics_from_counts(counts)
	var fused_features: Dictionary = scene.hand_plan_features_from_counts(counts, tiles.size(), true)
	var fused_shape: Dictionary = scene.ai_hand_shape_metrics_from_counts(counts, fused_features)
	var regular_plan: Dictionary = scene.hand_plan_eval_for_seat_from_counts(0, counts, tiles.size())
	var fused_plan: Dictionary = scene.hand_plan_eval_for_seat_from_counts(0, counts, tiles.size(), [], fused_features)

	print("--- A) fused candidate metrics preserve both outputs ---")
	check(fused_features.has("shape_value"), "融合特征包含按需牌型字段")
	check(regular_shape == fused_shape, "融合特征保持牌型形状结果")
	check(regular_plan == fused_plan, "融合特征保持路线评估结果")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
