extends SceneTree
## Round 218: incremental hand-plan features classify canonical tile slots directly.

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
	print("=== ai_play_round218 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true

	var counts: Array = scene.make_empty_tile_counts()
	var tile_total := 0
	for index in range(scene.TILE_CODES.size()):
		var amount := (index % 4) + 1
		counts[index] = amount
		tile_total += amount
	var expected: Dictionary = scene.hand_plan_features_from_counts(counts, tile_total, false)
	var incremental: Dictionary = {}
	for index in range(scene.TILE_CODES.size()):
		var amount := int(counts[index])
		for previous_amount in range(amount):
			scene.hand_plan_features_add_tile(incremental, index, previous_amount)

	check(int(incremental.get("total", -1)) == int(expected.get("total", -2)), "incremental feature total preserves the complete scan")
	check(int(incremental.get("simple_tiles", -1)) == int(expected.get("simple_tiles", -2)), "incremental simple-number classification preserves the complete scan")
	check(int(incremental.get("terminal_honor_tiles", -1)) == int(expected.get("terminal_honor_tiles", -2)), "incremental terminal/honor classification preserves the complete scan")
	check(int(incremental.get("orphan_unique", -1)) == int(expected.get("orphan_unique", -2)), "incremental orphan unique classification preserves the complete scan")
	check(int(incremental.get("orphan_tiles", -1)) == int(expected.get("orphan_tiles", -2)), "incremental orphan tile totals preserve the complete scan")
	check(bool(incremental.get("orphan_pair", false)) == bool(expected.get("orphan_pair", true)), "incremental orphan pair state preserves the complete scan")

	var before_invalid := incremental.duplicate(true)
	scene.hand_plan_features_add_tile(incremental, -1, 0)
	scene.hand_plan_features_add_tile(incremental, scene.TILE_CODES.size(), 0)
	check(incremental == before_invalid, "incremental feature updates keep invalid-slot behavior")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
