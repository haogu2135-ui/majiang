extends SceneTree
## Round 67: late-wall self-gang decisions respect exhaustive-draw tenpai ba.
var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(cond: bool, msg: String) -> void:
	if cond:
		print("  OK  | %s" % msg)
	else:
		print("  FAIL| %s" % msg)
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


func fill_wall(scene, count: int) -> void:
	var wall: Array[String] = []
	for i in range(count):
		wall.append("9B")
	scene.wall = wall


func reset_table(scene) -> void:
	scene.players = [
		make_player("Self"),
		make_player("AI"),
		make_player("P2"),
		make_player("P3"),
	]
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 1
	scene.dealer_seat = 0
	scene.offline_sim_quiet = true
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	scene.offline_concealed_gang_tiles.clear()
	for seat in range(4):
		scene.players[seat]["hand"] = []
		scene.players[seat]["discards"] = []
		scene.players[seat]["melds"] = []
		scene.players[seat]["score"] = 25000
	scene.clear_ai_report_cache()


func dirty_concealed_hand() -> Array:
	# Four E plus scattered junk: concealed gang does not approach tenpai.
	return ["E", "E", "E", "E", "1W", "3W", "5W", "7W", "9W", "1T", "3T", "5T", "7T", "9T"]


func useful_tenpai_concealed_hand() -> Array:
	# Closed shape that stays tenpai after concealed gang of 5W.
	return ["5W", "5W", "5W", "5W", "1W", "2W", "3W", "7W", "8W", "9W", "2T", "3T", "4T", "E"]


func dirty_added_hand() -> Array:
	return ["E", "1W", "3W", "5W", "7W", "9W", "1T", "3T", "5T", "7T", "9T", "1B", "3B"]


func run() -> void:
	print("=== ai_play_round67 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.clear_ai_report_cache()

	print("--- A) wall-draw self-gang helper gates ---")
	reset_table(scene)
	fill_wall(scene, 40)
	var deep = scene.wall_draw_self_gang_discipline_report(1, "concealed", 3, 3, 40)
	check(not bool(deep.get("decline", true)), "deep wall does not decline ordinary self-gang")
	check(is_equal_approx(float(deep.get("penalty", -1.0)), 0.0), "deep wall self-gang penalty is zero")
	var short_dirty = scene.wall_draw_self_gang_discipline_report(1, "concealed", 3, 3, 8)
	check(bool(short_dirty.get("decline", false)), "very short wall declines no-improve deep noten self-gang")
	check(str(short_dirty.get("reason", "")).find("查听") >= 0, "short dirty self-gang reason mentions 查听")
	var short_tenpai = scene.wall_draw_self_gang_discipline_report(1, "concealed", 1, 0, 8)
	check(not bool(short_tenpai.get("decline", true)), "self-gang into tenpai still allowed near wall end")
	var short_one_away = scene.wall_draw_self_gang_discipline_report(1, "added", 2, 1, 10)
	check(not bool(short_one_away.get("decline", true)), "self-gang that reaches one-away stays allowed")

	print("--- B) dirty late-wall concealed gang is blocked ---")
	reset_table(scene)
	fill_wall(scene, 8)
	scene.players[1]["hand"] = dirty_concealed_hand()
	var dirty_report = scene.build_ai_self_gang_report(1, "E", "concealed")
	print("    dirty concealed allow=%s reason=%s after=%s pen=%.1f" % [
		str(dirty_report.get("allow", false)),
		str(dirty_report.get("reason", "")),
		str(dirty_report.get("after_shanten", -1)),
		float(dirty_report.get("wall_draw_gang_penalty", 0.0)),
	])
	check(int(dirty_report.get("after_shanten", -1)) >= 2, "dirty concealed gang remains far from tenpai")
	check(not bool(dirty_report.get("allow", true)), "late-wall dirty concealed gang is disallowed")
	check(bool(dirty_report.get("declined_by_wall_draw", false)) or str(dirty_report.get("reason", "")).find("查听") >= 0, "dirty concealed gang decline is wall-draw ba aware")
	check(float(dirty_report.get("wall_draw_gang_penalty", 0.0)) > 0.0, "dirty concealed gang stores wall-draw penalty")
	check(scene.choose_ai_concealed_gang(1) == "", "choose_ai_concealed_gang skips late dirty gang")

	print("--- C) useful late-wall concealed gang still allowed ---")
	reset_table(scene)
	fill_wall(scene, 8)
	scene.players[1]["hand"] = useful_tenpai_concealed_hand()
	var useful_report = scene.build_ai_self_gang_report(1, "5W", "concealed")
	print("    useful concealed allow=%s reason=%s after=%s before=%s" % [
		str(useful_report.get("allow", false)),
		str(useful_report.get("reason", "")),
		str(useful_report.get("after_shanten", -1)),
		str(useful_report.get("before_shanten", -1)),
	])
	check(int(useful_report.get("after_shanten", 99)) <= 0, "useful concealed gang stays tenpai")
	check(bool(useful_report.get("allow", false)), "useful late-wall concealed gang remains allowed")
	check(not bool(useful_report.get("declined_by_wall_draw", false)), "useful concealed gang is not declined by wall-draw discipline")
	check(scene.choose_ai_concealed_gang(1) == "5W", "choose_ai_concealed_gang still takes useful late gang")

	print("--- D) dirty late-wall added gang is blocked ---")
	reset_table(scene)
	fill_wall(scene, 8)
	scene.players[1]["hand"] = dirty_added_hand()
	scene.players[1]["melds"] = [["E", "E", "E"]]
	var dirty_added = scene.build_ai_self_gang_report(1, "E", "added")
	print("    dirty added allow=%s reason=%s after=%s" % [
		str(dirty_added.get("allow", false)),
		str(dirty_added.get("reason", "")),
		str(dirty_added.get("after_shanten", -1)),
	])
	check(int(dirty_added.get("after_shanten", -1)) >= 2, "dirty added gang remains far from tenpai")
	check(not bool(dirty_added.get("allow", true)), "late-wall dirty added gang is disallowed")
	check(bool(dirty_added.get("declined_by_wall_draw", false)) or str(dirty_added.get("reason", "")).find("查听") >= 0, "dirty added gang decline is wall-draw ba aware")
	check(scene.choose_ai_added_gang(1) == "", "choose_ai_added_gang skips late dirty gang")

	print("--- E) deep wall does not mark wall-draw gang decline ---")
	reset_table(scene)
	fill_wall(scene, 48)
	scene.players[1]["hand"] = dirty_concealed_hand()
	var deep_report = scene.build_ai_self_gang_report(1, "E", "concealed")
	check(not bool(deep_report.get("declined_by_wall_draw", false)), "deep wall does not mark wall-draw gang decline")
	check(is_equal_approx(float(deep_report.get("wall_draw_gang_penalty", -1.0)), 0.0), "deep wall gang penalty stays zero")

	print("--- F) score path subtracts wall-draw gang penalty ---")
	var scored = scene.ai_self_gang_action_score({
		"gang_kind": "concealed",
		"tile": "E",
		"before_shanten": 3,
		"after_shanten": 3,
		"pressure": 0.0,
		"defense": 1.0,
		"seat": 1,
		"wait_narrowed": false,
		"rob_risk": false,
		"declined_by_plan": false,
		"wall_draw_gang_penalty": 25.0,
	})
	var scored_clean = scene.ai_self_gang_action_score({
		"gang_kind": "concealed",
		"tile": "E",
		"before_shanten": 3,
		"after_shanten": 3,
		"pressure": 0.0,
		"defense": 1.0,
		"seat": 1,
		"wait_narrowed": false,
		"rob_risk": false,
		"declined_by_plan": false,
		"wall_draw_gang_penalty": 0.0,
	})
	check(scored < scored_clean, "wall-draw gang penalty lowers self-gang score")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
