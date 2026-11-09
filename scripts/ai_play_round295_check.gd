extends SceneTree

var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if condition:
		print("  OK  | %s" % message)
	else:
		print("  FAIL| %s" % message)
		failed = true


func make_player() -> Dictionary:
	return {"name": "Fixture", "hand": [], "discards": [], "melds": [], "flowers": 0, "flower_tiles": [], "score": 25000, "bot": true}


func reset_fixture(scene: Node, discard_count: int, wall_count: int) -> void:
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.offline_ai_active = false
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.offline_phase = "await_discard"
	scene.current_seat = 1
	scene.offline_turn_needs_draw = false
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	scene.players = [make_player(), make_player(), make_player(), make_player()]
	scene.players[1]["hand"] = ["5W", "1B", "2B", "3B", "4B", "5B", "6B", "7B", "8B", "9B"]
	scene.players[1]["melds"] = [["5W", "5W", "5W"]]
	scene.players[0]["melds"] = [["1W", "2W", "3W"]]
	var discards: Array = ["1T", "2T", "3T", "4T", "5T", "6T", "7T", "8T"]
	scene.players[0]["discards"] = discards.slice(0, discard_count)
	scene.wall.resize(wall_count)
	scene.wall.fill("9B")
	scene.offline_passed_win_tiles.clear()
	scene.clear_ai_report_cache()


func fresh_report(scene: Node) -> Dictionary:
	scene.clear_ai_report_cache()
	return scene.added_gang_rob_threat_report(1, "5W")


func run() -> void:
	print("=== ai_play_round295 check START ===")
	var settings_path := "user://settings.cfg"
	var settings_existed := FileAccess.file_exists(settings_path)
	var settings_bytes := FileAccess.get_file_as_bytes(settings_path) if settings_existed else PackedByteArray()
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	reset_fixture(scene, 4, 30)
	var initial_revision: int = scene.ai_state_revision
	var hard_report: Dictionary = scene.added_gang_rob_threat_report(1, "5W")
	check(bool(hard_report["can_rob"]) and float(hard_report["max_risk"]) >= 25.0 and float(hard_report["max_risk"]) < 30.0, "public fixture lies between the normal and easy chankan thresholds")
	scene.cycle_ai_difficulty_setting()
	var easy_report: Dictionary = scene.added_gang_rob_threat_report(1, "5W")
	check(scene.ai_difficulty == scene.AI_DIFFICULTY_EASY and scene.ai_state_revision == initial_revision, "the actual difficulty setter can update without a table revision")
	check(is_equal_approx(float(easy_report["risk_threshold"]), 30.0) and not bool(easy_report["can_rob"]), "easy difficulty immediately uses its own gate instead of a cached hard gate")
	check(easy_report["risk_details"] == hard_report["risk_details"], "difficulty changes the decision gate without changing public evidence")
	check(easy_report == fresh_report(scene), "difficulty-switched cached evaluation agrees with a fresh evaluation")
	scene.cycle_ai_difficulty_setting()
	var normal_report: Dictionary = scene.added_gang_rob_threat_report(1, "5W")
	check(is_equal_approx(float(normal_report["risk_threshold"]), 25.0) and bool(normal_report["can_rob"]), "normal difficulty also takes effect before any new public tile")
	check(normal_report == fresh_report(scene), "normal difficulty does not reuse the easy decision")
	reset_fixture(scene, 0, 100)
	var early_report: Dictionary = scene.added_gang_rob_threat_report(1, "5W")
	check(not bool(early_report["can_rob"]), "early one-meld fixture has no credible public chankan signal")
	scene.wall.resize(16)
	var late_report: Dictionary = scene.added_gang_rob_threat_report(1, "5W")
	var fresh_late: Dictionary = fresh_report(scene)
	check(bool(fresh_late["can_rob"]) and float(fresh_late["max_risk"]) > float(early_report["max_risk"]), "wall exhaustion makes the unchanged public hand cross the risk gate")
	check(late_report == fresh_late, "remaining wall changes invalidate the cached readiness and risk")
	scene.record_passed_win_tile(0, "6W")
	var passed_report: Dictionary = scene.added_gang_rob_threat_report(1, "5W")
	var fresh_passed: Dictionary = fresh_report(scene)
	check(scene.is_passed_win_tile(0, "5W") and not bool(fresh_passed["can_rob"]), "temporary furiten excludes every ron wait after a passed win")
	check(passed_report == fresh_passed and not passed_report["robbers"].has(0), "a passed win immediately removes that opponent from the cached rob risk")
	scene.clear_passed_win_tiles(0)
	var cleared_report: Dictionary = scene.added_gang_rob_threat_report(1, "5W")
	check(cleared_report == fresh_report(scene) and bool(cleared_report["can_rob"]), "clearing temporary furiten restores risk without requiring a new river tile")
	var returned_report: Dictionary = scene.added_gang_rob_threat_report(1, "5W")
	var unchanged_report: Dictionary = returned_report.duplicate(true)
	returned_report["risk_details"][0]["risk"] = -100.0
	returned_report["robbers"].clear()
	check(scene.added_gang_rob_threat_report(1, "5W") == unchanged_report, "mutating nested return data cannot corrupt the cached report")
	var cache_entries: int = scene.ai_rob_threat_cache.size()
	scene.players[0]["hand"] = ["4W", "6W", "9W", "9W", "9W", "E", "E", "E", "R", "R"]
	var hidden_report: Dictionary = scene.added_gang_rob_threat_report(1, "5W")
	check(hidden_report == unchanged_report and scene.ai_rob_threat_cache.size() == cache_entries, "concealed opponent tiles never enter the memo key or change the declaration risk")
	check(bool(hidden_report["public_only"]) and int(hidden_report["winner_seat"]) == -1 and not bool(hidden_report["human_robber"]) and not bool(hidden_report["ai_robber"]), "cached reports retain the public-information contract")
	reset_fixture(scene, 0, 16)
	var first_report: Dictionary = scene.added_gang_rob_threat_report(1, "5W")
	var first_key: String = scene.ai_rob_threat_lru_head
	for wall_count in range(17, 81):
		scene.wall.resize(wall_count)
		scene.added_gang_rob_threat_report(1, "5W")
	check(scene.ai_rob_threat_cache.size() == 64 and scene.ai_rob_threat_lru_prev.size() == 64 and scene.ai_rob_threat_lru_next.size() == 64, "changing policy inputs retains the bounded sixty-four-entry memo and LRU links")
	check(not scene.ai_rob_threat_cache.has(first_key), "the oldest policy state is evicted when the memo reaches its limit")
	scene.wall.resize(17)
	scene.added_gang_rob_threat_report(1, "5W")
	var protected_key: String = scene.ai_rob_threat_lru_head
	scene.wall.resize(81)
	scene.added_gang_rob_threat_report(1, "5W")
	check(scene.ai_rob_threat_cache.has(protected_key) and scene.ai_rob_threat_cache.size() == 64, "revisiting a policy state promotes it before the next bounded eviction")
	scene.wall.resize(16)
	check(scene.added_gang_rob_threat_report(1, "5W") == first_report, "an evicted policy state recomputes the same public-information decision")
	scene.queue_free()
	await process_frame
	if settings_existed:
		var settings_file := FileAccess.open(settings_path, FileAccess.WRITE)
		check(settings_file != null, "the difficulty test can restore the previous settings file")
		if settings_file != null:
			settings_file.store_buffer(settings_bytes)
			settings_file.close()
	else:
		check(DirAccess.remove_absolute(ProjectSettings.globalize_path(settings_path)) == OK, "the difficulty test removes its temporary settings file")
	print("=== RESULT: %s ===" % ("FAIL" if failed else "OK"))
	quit(1 if failed else 0)
