extends SceneTree
## Round 269: wait scoring reuses the exposed-meld index snapshot.

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
	print("=== ai_play_round269 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var core_source_269 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	var scoring_start_269 := core_source_269.find("func scoring_tile_counts_from_counts")
	var scoring_end_269 := core_source_269.find("func is_pure_one_suit_from_counts", scoring_start_269)
	var scoring_source_269 := core_source_269.substr(scoring_start_269, scoring_end_269 - scoring_start_269)
	check(scoring_source_269.contains("meld_tile_indices_snapshot: Array = []"), "scoring count helper accepts a meld-index snapshot")
	check(scoring_source_269.contains("if not meld_tile_indices_snapshot.is_empty()"), "scoring count helper has the snapshot fast path")
	check(scoring_source_269.contains("for raw_index in meld_tile_indices_snapshot"), "scoring count helper consumes normalized indexes directly")

	var ai_source_269 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var wait_start_269 := ai_source_269.find("func wait_value_metrics")
	var wait_end_269 := ai_source_269.find("func wait_quality_penalty", wait_start_269)
	var wait_source_269 := ai_source_269.substr(wait_start_269, wait_end_269 - wait_start_269)
	check(wait_source_269.contains("meld_tile_indices_snapshot: Array = []"), "wait valuation accepts a meld-index snapshot")
	check(wait_source_269.contains("scoring_tile_counts_from_counts(seat, hand_counts_snapshot, meld_tile_indices_snapshot)"), "wait valuation forwards the snapshot to scoring counts")
	var report_start_269 := ai_source_269.find("func build_ai_discard_report")
	var report_end_269 := ai_source_269.find("func wait_value_metrics", report_start_269)
	var report_source_269 := ai_source_269.substr(report_start_269, report_end_269 - report_start_269)
	check(report_source_269.contains("effective_tile_indices, meld_tile_indices_snapshot)"), "discard reports forward their shared meld indexes")

	var hand_269: Array = ["4W", "5W", "6W", "7B", "8B", "9B", "1T", "1T", "2T", "3T"]
	scene.players[1]["hand"] = hand_269.duplicate()
	scene.players[1]["melds"] = [["1W", "2W", "3W"]]
	var hand_counts_269: Array = scene.tile_counts(hand_269)
	var meld_indices_269: Array = scene.hand_plan_meld_tile_indices_for_seat(1)
	check(meld_indices_269 == [scene.tile_index("1W"), scene.tile_index("2W"), scene.tile_index("3W")], "context snapshot contains every exposed tile index")
	var legacy_counts_269: Array = scene.scoring_tile_counts_from_counts(1, hand_counts_269)
	var snapshot_counts_269: Array = scene.scoring_tile_counts_from_counts(1, hand_counts_269, meld_indices_269)
	check(snapshot_counts_269 == legacy_counts_269, "snapshot scoring counts equal the legacy meld scan")

	var visible_counts_269: Array = scene.make_empty_tile_counts()
	var metrics_269: Dictionary = scene.effective_tile_metrics(hand_269, 1, 1, 0, visible_counts_269, hand_counts_269)
	var waits_269: Array = metrics_269.get("tiles", [])
	var remaining_269: Dictionary = metrics_269.get("remaining_by_tile", {})
	var wait_indices_269: Dictionary = metrics_269.get("tile_indices", {})
	var legacy_wait_269: Dictionary = scene.wait_value_metrics(1, hand_269, 1, 0, waits_269, remaining_269, true, {}, -1.0, -1.0, hand_counts_269, 1, wait_indices_269)
	var snapshot_wait_269: Dictionary = scene.wait_value_metrics(1, hand_269, 1, 0, waits_269, remaining_269, true, {}, -1.0, -1.0, hand_counts_269, 1, wait_indices_269, meld_indices_269)
	check(legacy_wait_269 == snapshot_wait_269, "snapshot wait valuation preserves all open-hand metrics")
	check(scene.counts_compact_key(hand_counts_269) == scene.counts_compact_key(scene.tile_counts(hand_269)), "wait probes leave concealed counts unchanged")

	scene.players[1]["melds"] = []
	var closed_wait_269: Dictionary = scene.wait_value_metrics(1, hand_269, 0, 0, waits_269, remaining_269, true, {}, -1.0, -1.0, hand_counts_269, 0, wait_indices_269)
	check(not closed_wait_269.is_empty(), "legacy wait valuation remains available without exposed melds")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
