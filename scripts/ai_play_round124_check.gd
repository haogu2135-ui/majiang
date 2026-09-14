extends SceneTree
## Round 124: effective-tile metrics reuse the hand compact key.

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
	print("=== ai_play_round124 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.wall = scene.make_wall()

	var hand: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "E", "S"]
	var counts: Array = scene.tile_counts(hand)
	var source_key: String = scene.counts_compact_key(counts)

	print("--- A) unknown shanten path ---")
	scene.clear_ai_report_cache()
	var metrics_without_snapshot: Dictionary = scene.effective_tile_metrics(hand, 0, 1)
	var computed_shanten: int = scene.calculate_min_shanten_from_counts(counts)
	check(computed_shanten >= 0 and int(metrics_without_snapshot.get("count", -1)) >= 0, "effective-tile metrics still computes an unknown shanten")
	check(scene.counts_compact_key(counts) == source_key, "unknown shanten path preserves the source count vector")

	print("--- B) explicit key-compatible path ---")
	var metrics_with_snapshot: Dictionary = scene.effective_tile_metrics(hand, 0, 1, computed_shanten, [], counts)
	check(metrics_without_snapshot.get("tiles", []) == metrics_with_snapshot.get("tiles", []) and metrics_without_snapshot.get("remaining_by_tile", {}) == metrics_with_snapshot.get("remaining_by_tile", {}), "reused hand key preserves effective-tile results")
	var explicit_key_result: int = scene.calculate_min_shanten_from_counts(counts, 0, source_key)
	check(explicit_key_result == computed_shanten, "explicit hand key preserves the shanten cache result")
	check(scene.counts_compact_key(counts) == source_key, "explicit hand key path preserves the source count vector")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
