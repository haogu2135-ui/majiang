extends SceneTree
## Round 214: shape scans reuse the already computed neighbor state.

var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if condition:
		print("  OK  | %s" % message)
	else:
		print("  FAIL| %s" % message)
		failed = true


func legacy_isolated_total(scene, counts: Array) -> int:
	var total := 0
	for index in range(scene.TILE_CODES.size()):
		var amount := int(counts[index])
		if scene.is_isolated_shape_tile(counts, index):
			total += amount
	return total


func run() -> void:
	print("=== ai_play_round214 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true

	var cases: Array = []
	var dense_counts: Array = scene.make_empty_tile_counts()
	for index in range(scene.TILE_CODES.size()):
		dense_counts[index] = (index % 4) + 1
	cases.append(dense_counts)
	var sparse_counts: Array = scene.make_empty_tile_counts()
	sparse_counts[0] = 1
	sparse_counts[4] = 1
	sparse_counts[9] = 2
	sparse_counts[18] = 1
	sparse_counts[27] = 1
	sparse_counts[31] = 2
	cases.append(sparse_counts)

	for case_index in range(cases.size()):
		var counts: Array = cases[case_index]
		var expected_isolated := legacy_isolated_total(scene, counts)
		var shape_report: Dictionary = scene.ai_hand_shape_metrics_from_counts(counts)
		var quality_report: Dictionary = shape_report.get("quality_report", {})
		var feature_total := 0
		for amount in counts:
			feature_total += int(amount)
		var features: Dictionary = scene.hand_plan_features_from_counts(counts, feature_total, true)
		check(int(quality_report.get("isolated", -1)) == expected_isolated, "shape metrics preserve isolated count for fixture %d" % case_index)
		check(int(features.get("shape_isolated", -1)) == expected_isolated, "fused plan features preserve isolated count for fixture %d" % case_index)

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
