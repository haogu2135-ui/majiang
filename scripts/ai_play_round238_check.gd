extends SceneTree
## Round 238: self-gang selectors reuse the before-plan label snapshot.

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
	print("=== ai_play_round238 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["E", "E", "E", "E", "1W", "2W", "3W", "4T", "5T", "6T", "7B", "8B", "9B"]
	var visible_counts_238: Array = scene.make_empty_tile_counts()
	var context_238: Dictionary = scene.make_ai_evaluation_context(0, visible_counts_238)
	context_238["hand_counts"] = scene.tile_counts(scene.players[0]["hand"])
	var expected_label_238: String = str(scene.hand_plan_report_for_seat_from_counts(0, context_238["hand_counts"], scene.players[0]["hand"].size()).get("label", ""))
	context_238["self_gang_before_plan_label"] = expected_label_238
	var fallback_report_238: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed")
	var snapshot_report_238: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", context_238, scene.tile_index("E"))
	check(expected_label_238 != "", "self-gang context captures the current before-plan label")
	check(str(snapshot_report_238.get("before_plan_label", "")) == expected_label_238, "before-plan snapshot is consumed by self-gang reports")
	check(str(snapshot_report_238.get("before_plan_label", "")) == str(fallback_report_238.get("before_plan_label", "")), "before-plan snapshot preserves the route label")
	check(bool(snapshot_report_238.get("allow", false)) == bool(fallback_report_238.get("allow", false)) and str(snapshot_report_238.get("reason", "")) == str(fallback_report_238.get("reason", "")), "before-plan snapshot preserves the decision")

	var no_snapshot_context_238: Dictionary = context_238.duplicate(true)
	no_snapshot_context_238.erase("self_gang_before_plan_label")
	var no_snapshot_report_238: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", no_snapshot_context_238, scene.tile_index("E"))
	check(str(no_snapshot_report_238.get("before_plan_label", "")) == str(fallback_report_238.get("before_plan_label", "")), "missing before-plan snapshot keeps the live fallback")

	var changed_context_238: Dictionary = context_238.duplicate(true)
	changed_context_238["self_gang_before_plan_label"] = "七对"
	var changed_report_238: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", changed_context_238, scene.tile_index("E"))
	check(str(changed_report_238.get("before_plan_label", "")) == "七对", "explicit before-plan snapshot remains authoritative")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
