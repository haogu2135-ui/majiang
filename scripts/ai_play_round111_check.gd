extends SceneTree
## Round 111: count-based completion probes reuse caller-owned vectors safely.

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
	print("=== ai_play_round111 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.wall = scene.make_wall()

	var tenpai: Array = ["2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W", "2T", "3T", "4T"]
	var metrics: Dictionary = scene.effective_tile_metrics(tenpai, 0, 1, 0)
	var tenpai_counts: Array = scene.tile_counts(tenpai)

	print("--- A) count-based scoring leaves the supplied vector intact ---")
	var winning_counts: Array = tenpai_counts.duplicate()
	winning_counts[scene.tile_index_normalized("2W")] += 1
	var counts_key_before: String = scene.counts_compact_key(winning_counts)
	var checked_score: Dictionary = scene.calculate_win_score_from_tiles(1, [], false, "", false, winning_counts, 14)
	var assumed_score: Dictionary = scene.calculate_win_score_from_tiles(1, [], false, "", true, winning_counts, 14)
	check(checked_score == assumed_score, "count scoring preserves the validated hand result")
	check(scene.counts_compact_key(winning_counts) == counts_key_before, "count scoring restores the supplied vector")

	print("--- B) wait valuation keeps array and count paths equivalent ---")
	var wait_tiles: Array = metrics.get("tiles", [])
	var remaining_by_tile: Dictionary = metrics.get("remaining_by_tile", {})
	var array_key_before: String = scene.counts_compact_key(tenpai_counts)
	var array_wait: Dictionary = scene.wait_value_metrics(1, tenpai, 0, 0, wait_tiles, remaining_by_tile)
	var count_wait: Dictionary = scene.wait_value_metrics(1, tenpai, 0, 0, wait_tiles, remaining_by_tile, false, {}, -1.0, -1.0, tenpai_counts)
	check(array_wait == count_wait, "count wait valuation matches the array path")
	check(scene.counts_compact_key(tenpai_counts) == array_key_before, "wait valuation restores the reusable vector")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
