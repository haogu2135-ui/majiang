extends SceneTree
## Round 116: discard pressure and wait reports reuse fixed seat snapshots.

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
	print("=== ai_play_round116 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.wall = scene.make_wall()
	scene.players[0]["melds"] = [["E", "E", "E"]]
	scene.players[0]["discards"] = ["1W", "9W", "E"]
	scene.players[1]["melds"] = [["1W", "1W", "1W"]]

	print("--- A) discard evaluation snapshots ---")
	var context: Dictionary = scene.make_ai_evaluation_context(1, scene.visible_tile_counts_shared())
	check(context.has("discard_report_human_readiness") and context.has("discard_report_exposed_melds"), "discard context carries human readiness and exposed-meld snapshots")
	check(is_equal_approx(float(context.get("discard_report_human_readiness", -1.0)), scene.human_readiness_for_defense()), "human readiness snapshot matches the live value")
	check(int(context.get("discard_report_exposed_melds", -1)) == scene.exposed_meld_count_for_seat(1), "exposed-meld snapshot matches the live value")
	var fallback_context: Dictionary = context.duplicate(true)
	fallback_context.erase("discard_report_human_readiness")
	var snapshot_pressure: float = scene.human_target_discard_pressure(1, "5W", 24.0, {}, 2, context)
	var fallback_pressure: float = scene.human_target_discard_pressure(1, "5W", 24.0, {}, 2, fallback_context)
	check(is_equal_approx(snapshot_pressure, fallback_pressure), "human pressure snapshot preserves the fallback result")

	print("--- B) exposed-meld wait valuation ---")
	var open_wait_hand: Array = ["2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W"]
	var wait_metrics: Dictionary = scene.effective_tile_metrics(open_wait_hand, 1, 1, 0)
	var hand_counts: Array = scene.tile_counts(open_wait_hand)
	var array_wait: Dictionary = scene.wait_value_metrics(1, open_wait_hand, 1, 0, wait_metrics.get("tiles", []), wait_metrics.get("remaining_by_tile", {}), true)
	var snapshot_wait: Dictionary = scene.wait_value_metrics(1, open_wait_hand, 1, 0, wait_metrics.get("tiles", []), wait_metrics.get("remaining_by_tile", {}), true, {}, -1.0, -1.0, hand_counts, 1)
	check(array_wait == snapshot_wait, "exposed-meld snapshot preserves wait valuation")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
