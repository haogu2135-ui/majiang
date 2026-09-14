extends SceneTree
## Round 223: discard reports reuse their candidate tile-index snapshot.

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
	print("=== ai_play_round223 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.ai_difficulty = 1

	var honor_counts: Array = scene.tile_counts(["E", "2W", "3W", "4W"])
	var honor_index: int = scene.tile_index("E")
	var opening_context: Dictionary = {
		"seat": 1,
		"discard_report_wall_count": 60,
		"discard_report_route_focus": 1.0,
		"discard_report_difficulty": 1,
	}
	var opening_fallback: float = scene.opening_efficiency_adjustment(1, "E", 4, honor_counts, 0, opening_context)
	var opening_explicit: float = scene.opening_efficiency_adjustment(1, "E", 4, honor_counts, 0, opening_context, honor_index)
	check(is_equal_approx(opening_fallback, opening_explicit), "opening efficiency preserves its explicit tile-index result")

	var post_context: Dictionary = {
		"seat": 1,
		"discard_report_route_focus": 1.0,
		"discard_report_difficulty": 1,
	}
	var post_fallback: float = scene.post_meld_route_adjustment(1, "E", 1, honor_counts, "标准", -1, 2, post_context)
	var post_explicit: float = scene.post_meld_route_adjustment(1, "E", 1, honor_counts, "标准", -1, 2, post_context, honor_index)
	check(is_equal_approx(post_fallback, post_explicit), "post-meld route preserves its explicit tile-index result")
	check(is_equal_approx(scene.opening_efficiency_adjustment(1, "ZZ", 4, honor_counts, 0, opening_context), 0.0), "opening efficiency keeps invalid-tile behavior")
	check(is_equal_approx(scene.post_meld_route_adjustment(1, "ZZ", 1, honor_counts, "标准", -1, 2, post_context), 0.0), "post-meld route keeps invalid-tile behavior")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
