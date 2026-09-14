extends SceneTree
## Round 244: honor route reports reuse one computed statistics snapshot.

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
	print("=== ai_play_round244 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var dragon_counts_244: Array = scene.tile_counts(["Z", "Z", "Z", "F", "F", "F", "P", "P", "1W", "2W"])
	var dragon_stats_244: Dictionary = scene.honor_group_stats_from_counts(dragon_counts_244, scene.DRAGON_CODES)
	var dragon_score_244: float = scene.honor_route_score_from_counts(dragon_counts_244, scene.DRAGON_CODES)
	var dragon_stats_score_244: float = scene.honor_route_score_from_stats(dragon_stats_244, scene.DRAGON_CODES.size())
	check(is_equal_approx(dragon_score_244, dragon_stats_score_244), "honor route score preserves the count-based result")
	var dragon_report_244: Dictionary = scene.honor_group_plan_report_from_counts(dragon_counts_244, scene.DRAGON_CODES, "Big dragons", "Small dragons")
	check(str(dragon_report_244.get("label", "")) == "Small dragons", "dragon route report keeps its family label")
	check(int(dragon_report_244.get("progress", 0)) == 5 and is_equal_approx(float(dragon_report_244.get("score", 0.0)), dragon_score_244), "dragon route report reuses the same statistics")

	var wind_counts_244: Array = scene.tile_counts(["E", "E", "E", "S", "S", "S", "N", "N", "N", "R", "R"])
	var wind_stats_244: Dictionary = scene.honor_group_stats_from_counts(wind_counts_244, scene.WIND_CODES)
	var wind_report_244: Dictionary = scene.honor_group_plan_report_from_counts(wind_counts_244, scene.WIND_CODES, "Big winds", "Small winds")
	check(is_equal_approx(scene.honor_route_score_from_counts(wind_counts_244, scene.WIND_CODES), scene.honor_route_score_from_stats(wind_stats_244, scene.WIND_CODES.size())), "wind route score preserves the statistics helper result")
	check(str(wind_report_244.get("label", "")) == "Small winds" and int(wind_report_244.get("progress", 0)) == 7, "wind route report keeps its progress")

	var low_counts_244: Array = scene.tile_counts(["Z", "F", "P"])
	check(scene.honor_group_plan_report_from_counts(low_counts_244, scene.DRAGON_CODES, "Big dragons", "Small dragons").is_empty(), "insufficient honor progress keeps the empty report")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
