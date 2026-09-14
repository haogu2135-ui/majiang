extends SceneTree
## Round 229: claim route reports reuse extra-meld tile indexes.

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
	print("=== ai_play_round229 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var hand_counts: Array = scene.tile_counts(["1W", "2W", "3W", "4T", "5T", "6T", "7B", "8B", "9B", "E", "S"])
	var extra_tiles: Array = ["9B", "9B", "9B"]
	var extra_indexes: Array[int] = []
	for extra_tile in extra_tiles:
		extra_indexes.append(scene.tile_index(str(extra_tile)))
	var fallback_report: Dictionary = scene.plan_report_with_extra_melds(1, hand_counts, 11, extra_tiles)
	var explicit_report: Dictionary = scene.plan_report_with_extra_melds(1, hand_counts, 11, extra_tiles, [], extra_indexes)
	check(str(fallback_report.get("label", "")) == str(explicit_report.get("label", "")), "claim route labels preserve the explicit extra-meld indexes")
	check(is_equal_approx(float(fallback_report.get("score", 0.0)), float(explicit_report.get("score", 0.0))), "claim route scores preserve the explicit extra-meld indexes")
	check(is_equal_approx(float(fallback_report.get("score_bonus", 0.0)), float(explicit_report.get("score_bonus", 0.0))), "claim route bonuses preserve the explicit extra-meld indexes")

	var invalid_fallback: Dictionary = scene.plan_report_with_extra_melds(1, hand_counts, 11, ["ZZ"])
	var invalid_explicit: Dictionary = scene.plan_report_with_extra_melds(1, hand_counts, 11, ["ZZ"], [], [-1])
	check(str(invalid_fallback.get("label", "")) == str(invalid_explicit.get("label", "")), "invalid extra-meld tiles keep the legacy route fallback")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
