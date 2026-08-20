extends SceneTree
## Round 95: exact-score discard ties preserve the commercial decision hierarchy.

var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(cond: bool, msg: String) -> void:
	if cond:
		print("  OK  | %s" % msg)
	else:
		print("  FAIL| %s" % msg)
		failed = true


func sorted_tiles(scene, reports: Array) -> Array[String]:
	var working: Array = reports.duplicate(true)
	scene.sort_ai_discard_reports(working)
	var tiles: Array[String] = []
	for report in working:
		tiles.append(str(report.get("tile", "")))
	return tiles


func run() -> void:
	print("=== ai_play_round95 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame

	print("--- A) primary score remains authoritative ---")
	var score_reports := [
		{"tile": "9W", "score": 101.0, "shanten": 4, "ukeire": 0, "risk": 99.0, "feed_risk": 99.0},
		{"tile": "1W", "score": 100.0, "shanten": 0, "ukeire": 20, "risk": 0.0, "feed_risk": 0.0},
	]
	check(sorted_tiles(scene, score_reports) == ["9W", "1W"], "higher score beats every exact-tie field")

	print("--- B) lower shanten wins an exact score tie ---")
	var shanten_reports := [
		{"tile": "2W", "score": 100.0, "shanten": 2, "ukeire": 20, "risk": 0.0, "feed_risk": 0.0},
		{"tile": "8W", "score": 100.0, "shanten": 1, "ukeire": 1, "risk": 99.0, "feed_risk": 99.0},
	]
	check(sorted_tiles(scene, shanten_reports) == ["8W", "2W"], "lower shanten beats ukeire, danger, and tile order")

	print("--- C) higher ukeire wins after score and shanten ---")
	var ukeire_reports := [
		{"tile": "2T", "score": 100.0, "shanten": 1, "ukeire": 4, "risk": 0.0, "feed_risk": 0.0},
		{"tile": "8T", "score": 100.0, "shanten": 1, "ukeire": 8, "risk": 99.0, "feed_risk": 99.0},
	]
	check(sorted_tiles(scene, ukeire_reports) == ["8T", "2T"], "higher ukeire beats danger and tile order")

	print("--- D) combined danger resolves the remaining strategic tie ---")
	var danger_reports := [
		{"tile": "2B", "score": 100.0, "shanten": 1, "ukeire": 8, "risk": 5.0, "feed_risk": 10.0},
		{"tile": "8B", "score": 100.0, "shanten": 1, "ukeire": 8, "risk": 7.0, "feed_risk": 4.0},
	]
	check(sorted_tiles(scene, danger_reports) == ["8B", "2B"], "lower risk plus weighted feed risk wins despite higher raw risk")

	print("--- E) tile order is the final deterministic fallback ---")
	var tile_reports := [
		{"tile": "3W", "score": 100.0, "shanten": 1, "ukeire": 8, "risk": 7.0, "feed_risk": 4.0},
		{"tile": "1W", "score": 100.0, "shanten": 1, "ukeire": 8, "risk": 7.0, "feed_risk": 4.0},
		{"tile": "2W", "score": 100.0, "shanten": 1, "ukeire": 8, "risk": 7.0, "feed_risk": 4.0},
	]
	var expected: Array[String] = ["1W", "2W", "3W"]
	check(sorted_tiles(scene, tile_reports) == expected, "equal reports use canonical tile order")
	check(sorted_tiles(scene, [tile_reports[1], tile_reports[2], tile_reports[0]]) == expected, "shuffled input produces the same complete order")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
