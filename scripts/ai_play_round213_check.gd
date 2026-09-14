extends SceneTree
## Round 213: hand-plan features classify canonical tile slots directly.

var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if condition:
		print("  OK  | %s" % message)
	else:
		print("  FAIL| %s" % message)
		failed = true


func legacy_feature_classification(scene, counts: Array) -> Dictionary:
	var expected := {
		"simple_tiles": 0,
		"terminal_honor_tiles": 0,
		"orphan_unique": 0,
		"orphan_tiles": 0,
		"orphan_pair": false,
	}
	for index in range(scene.TILE_CODES.size()):
		var amount := int(counts[index])
		if amount <= 0:
			continue
		var tile: String = str(scene.TILE_CODES[index])
		if scene.is_simple_number_tile(tile):
			expected["simple_tiles"] = int(expected["simple_tiles"]) + amount
		else:
			expected["terminal_honor_tiles"] = int(expected["terminal_honor_tiles"]) + amount
		if scene.is_thirteen_orphans_tile(tile):
			expected["orphan_unique"] = int(expected["orphan_unique"]) + 1
			expected["orphan_tiles"] = int(expected["orphan_tiles"]) + amount
			if amount >= 2:
				expected["orphan_pair"] = true
	return expected


func run() -> void:
	print("=== ai_play_round213 check START ===")
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
	var expected: Dictionary = legacy_feature_classification(scene, counts)
	var actual: Dictionary = scene.hand_plan_features_from_counts(counts, tile_total, false)
	check(int(actual.get("simple_tiles", -1)) == int(expected.get("simple_tiles", -2)), "simple-number feature total preserves the legacy classification")
	check(int(actual.get("terminal_honor_tiles", -1)) == int(expected.get("terminal_honor_tiles", -2)), "terminal/honor feature total preserves the legacy classification")
	check(int(actual.get("orphan_unique", -1)) == int(expected.get("orphan_unique", -2)), "thirteen-orphans unique count preserves the legacy classification")
	check(int(actual.get("orphan_tiles", -1)) == int(expected.get("orphan_tiles", -2)), "thirteen-orphans tile total preserves the legacy classification")
	check(bool(actual.get("orphan_pair", false)) == bool(expected.get("orphan_pair", true)), "thirteen-orphans pair flag preserves the legacy classification")

	var shaped: Dictionary = scene.hand_plan_features_from_counts(counts, tile_total, true)
	check(int(shaped.get("simple_tiles", -1)) == int(expected.get("simple_tiles", -2)), "shape-enabled feature scan keeps canonical simple-number totals")
	check(int(shaped.get("orphan_tiles", -1)) == int(expected.get("orphan_tiles", -2)), "shape-enabled feature scan keeps canonical orphan totals")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
