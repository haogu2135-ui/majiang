extends SceneTree
## Round 239: self-gang selectors reuse the before-shanten snapshot.

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
	print("=== ai_play_round239 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["E", "E", "E", "E", "1W", "2W", "3W", "4T", "5T", "6T", "7B", "8B", "9B"]
	var visible_counts_239: Array = scene.make_empty_tile_counts()
	var hand_counts_239: Array = scene.tile_counts(scene.players[0]["hand"])
	var expected_before_239: int = scene.calculate_min_shanten_from_counts(hand_counts_239, 0)
	var context_239: Dictionary = scene.make_ai_evaluation_context(0, visible_counts_239)
	context_239["hand_counts"] = hand_counts_239
	context_239["self_gang_open_melds"] = 0
	context_239["self_gang_before_shanten"] = expected_before_239
	var fallback_report_239: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed")
	var snapshot_report_239: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", context_239, scene.tile_index("E"))
	check(expected_before_239 >= -1, "self-gang selector captures a valid before-shanten value")
	check(int(snapshot_report_239.get("before_shanten", 99)) == expected_before_239, "before-shanten snapshot is consumed by self-gang reports")
	check(int(snapshot_report_239.get("before_shanten", 99)) == int(fallback_report_239.get("before_shanten", -1)) and int(snapshot_report_239.get("after_shanten", 99)) == int(fallback_report_239.get("after_shanten", -1)), "before-shanten snapshot preserves before/after shanten")
	check(bool(snapshot_report_239.get("allow", false)) == bool(fallback_report_239.get("allow", false)) and str(snapshot_report_239.get("reason", "")) == str(fallback_report_239.get("reason", "")), "before-shanten snapshot preserves the decision")

	var no_snapshot_context_239: Dictionary = context_239.duplicate(true)
	no_snapshot_context_239.erase("self_gang_before_shanten")
	var no_snapshot_report_239: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", no_snapshot_context_239, scene.tile_index("E"))
	check(int(no_snapshot_report_239.get("before_shanten", 99)) == int(fallback_report_239.get("before_shanten", -1)), "missing before-shanten snapshot keeps the live fallback")

	var changed_context_239: Dictionary = context_239.duplicate(true)
	changed_context_239["self_gang_before_shanten"] = expected_before_239 + 1
	var changed_report_239: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", changed_context_239, scene.tile_index("E"))
	check(int(changed_report_239.get("before_shanten", 99)) == expected_before_239 + 1, "explicit before-shanten snapshot remains authoritative")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
