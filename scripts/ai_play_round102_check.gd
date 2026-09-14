extends SceneTree
## Round 102: self-gang effective-count evaluation reuses prepared snapshots.

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
	print("=== ai_play_round102 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("AI"), make_player("P2"), make_player("P3")]
	scene.current_seat = 1
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.wall.clear()
	for _i in range(40):
		scene.wall.append("9B")
	scene.players[1]["hand"] = ["5W", "5W", "5W", "5W", "1W", "2W", "3W", "7W", "8W", "9W", "2T", "3T", "4T", "E"]

	var gang_hand: Array = scene.players[1]["hand"]
	var before_counts: Array = scene.tile_counts(gang_hand)
	var before_shanten: int = scene.calculate_min_shanten_from_counts(before_counts, 0)
	var after_hand: Array = gang_hand.duplicate()
	for _i in range(4):
		after_hand.erase("5W")
	var tile_index: int = scene.tile_index_normalized("5W")
	var after_counts: Array = before_counts.duplicate()
	after_counts[tile_index] = int(after_counts[tile_index]) - 4
	var after_shanten: int = scene.calculate_min_shanten_from_counts(after_counts, 1)

	print("--- A) helper accepts prepared count state ---")
	var before_array: int = scene.effective_tile_count(gang_hand, 0, 1)
	var before_snapshot: int = scene.effective_tile_count(gang_hand, 0, 1, before_shanten, [], before_counts)
	var after_array: int = scene.effective_tile_count(after_hand, 1, 1)
	var after_snapshot: int = scene.effective_tile_count(after_hand, 1, 1, after_shanten, [], after_counts)
	check(before_array == before_snapshot and after_array == after_snapshot, "prepared count path matches legacy effective counts")
	check(before_shanten == 0 and after_shanten == 0, "fixture enters the comparable concealed-gang branch")

	print("--- B) self-gang report consumes the same branch ---")
	var report: Dictionary = scene.build_ai_self_gang_report(1, "5W", "concealed")
	print("    report=%s" % report)
	check(int(report.get("before_ukeire", -1)) == before_snapshot, "report keeps the prepared before effective count")
	check(int(report.get("after_ukeire", -1)) == after_snapshot, "report keeps the prepared after effective count")
	check(bool(report.get("wait_narrowed", false)) == (after_snapshot < before_snapshot), "wait narrowing decision remains unchanged")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
