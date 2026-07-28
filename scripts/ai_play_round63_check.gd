extends SceneTree
## Round 63: late-wall claim decisions respect exhaustive-draw tenpai ba.
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


func empty_wall() -> Array[String]:
	var wall: Array[String] = []
	return wall


func reset_table(scene) -> void:
	scene.players = [
		make_player("Self"),
		make_player("AI"),
		make_player("P2"),
		make_player("P3"),
	]
	scene.mode = "offline"
	scene.offline_phase = "resolving"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 1
	scene.dealer_seat = 0
	scene.offline_sim_quiet = true
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL
	scene.wall = empty_wall()
	scene.offline_concealed_gang_tiles.clear()
	for seat in range(4):
		scene.players[seat]["hand"] = []
		scene.players[seat]["discards"] = []
		scene.players[seat]["melds"] = []
		scene.players[seat]["score"] = 25000


func fill_wall(scene, count: int) -> void:
	var wall: Array[String] = []
	for i in range(count):
		wall.append("9B")
	scene.wall = wall


func dirty_peng_hand() -> Array:
	# Pair of 5W plus scattered junk: peng does not approach tenpai.
	return ["5W", "5W", "1T", "3T", "5T", "7T", "9T", "1B", "3B", "5B", "7B", "9B", "E"]


func useful_one_away_peng_hand() -> Array:
	# Closed shape that becomes tenpai/near-tenpai after pung of 5W.
	return ["5W", "5W", "1W", "1W", "1W", "2W", "3W", "4W", "6W", "7W", "8W", "9W", "9W"]


func run() -> void:
	print("=== ai_play_round63 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.clear_ai_report_cache()

	print("--- A) wall-draw claim helper gates ---")
	reset_table(scene)
	fill_wall(scene, 40)
	var deep = scene.wall_draw_claim_discipline_report(1, "peng", 3, 3, 40.0, 0, 40)
	check(not bool(deep.get("decline", true)), "deep wall does not decline ordinary claim")
	check(is_equal_approx(float(deep.get("penalty", -1.0)), 0.0), "deep wall claim penalty is zero")
	check(is_equal_approx(float(deep.get("urgency", -1.0)), 0.0), "deep wall claim urgency is zero")

	var short_dirty = scene.wall_draw_claim_discipline_report(1, "peng", 3, 3, 12.0, 0, 8)
	check(bool(short_dirty.get("decline", false)), "very short wall declines no-improve deep noten claim")
	check(str(short_dirty.get("reason", "")).find("查听") >= 0, "short dirty claim reason mentions 查听")
	check(float(short_dirty.get("penalty", 0.0)) > 0.0, "short dirty claim carries penalty")

	var short_tenpai = scene.wall_draw_claim_discipline_report(1, "peng", 1, 0, 8.0, 0, 8)
	check(not bool(short_tenpai.get("decline", true)), "claim into tenpai still allowed near wall end")
	check(is_equal_approx(float(short_tenpai.get("penalty", -1.0)), 0.0), "claim into tenpai has no wall-draw claim penalty")

	var short_one_away = scene.wall_draw_claim_discipline_report(1, "peng", 2, 1, 10.0, 0, 10)
	check(not bool(short_one_away.get("decline", true)), "claim that reaches one-away stays allowed")

	print("--- B) dirty late-wall peng is blocked ---")
	reset_table(scene)
	fill_wall(scene, 8)
	scene.players[1]["hand"] = dirty_peng_hand()
	scene.players[0]["discards"] = ["5W"]
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var dirty_ctx = scene.make_ai_claim_context(1, [], [], 0)
	var dirty_report = scene.build_ai_claim_report(1, "peng", "5W", {}, dirty_ctx)
	print("    dirty late peng allow=%s reason=%s after=%s pen=%.1f" % [
		str(dirty_report.get("allow", false)),
		str(dirty_report.get("reason", "")),
		str(dirty_report.get("after_shanten", -1)),
		float(dirty_report.get("wall_draw_claim_penalty", 0.0)),
	])
	check(int(dirty_report.get("after_shanten", -1)) >= 2, "dirty peng remains far from tenpai")
	check(not bool(dirty_report.get("allow", true)), "late-wall dirty peng is disallowed")
	check(bool(dirty_report.get("declined_by_wall_draw", false)) or str(dirty_report.get("reason", "")).find("查听") >= 0, "dirty peng decline is wall-draw ba aware")
	check(float(dirty_report.get("wall_draw_claim_penalty", 0.0)) > 0.0, "dirty peng report stores wall-draw claim penalty")
	var dirty_claim = scene.choose_ai_claim(0, "5W")
	check(dirty_claim.is_empty() or str(dirty_claim.get("claim", "")) != "peng", "choose_ai_claim skips late dirty peng")

	print("--- C) useful late-wall peng still allowed ---")
	reset_table(scene)
	fill_wall(scene, 8)
	scene.players[1]["hand"] = useful_one_away_peng_hand()
	scene.players[0]["discards"] = ["5W"]
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var useful_ctx = scene.make_ai_claim_context(1, [], [], 0)
	var useful_report = scene.build_ai_claim_report(1, "peng", "5W", {}, useful_ctx)
	print("    useful late peng allow=%s reason=%s after=%s before=%s" % [
		str(useful_report.get("allow", false)),
		str(useful_report.get("reason", "")),
		str(useful_report.get("after_shanten", -1)),
		str(useful_report.get("before_shanten", -1)),
	])
	check(int(useful_report.get("after_shanten", 99)) <= 1, "useful peng reaches tenpai or one-away")
	check(bool(useful_report.get("allow", false)), "useful late-wall peng remains allowed")
	check(not bool(useful_report.get("declined_by_wall_draw", false)), "useful peng is not declined by wall-draw discipline")
	var useful_claim = scene.choose_ai_claim(0, "5W")
	check(str(useful_claim.get("claim", "")) == "peng" or str(useful_claim.get("claim", "")) == "hu", "choose_ai_claim still takes useful late claim")

	print("--- D) deep wall still allows shape-gain dirty path ---")
	reset_table(scene)
	fill_wall(scene, 48)
	scene.players[1]["hand"] = dirty_peng_hand()
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL
	var deep_ctx = scene.make_ai_claim_context(1, [], [], 0)
	var deep_report = scene.build_ai_claim_report(1, "peng", "5W", {}, deep_ctx)
	print("    deep dirty peng allow=%s reason=%s declined_wall=%s" % [
		str(deep_report.get("allow", false)),
		str(deep_report.get("reason", "")),
		str(deep_report.get("declined_by_wall_draw", false)),
	])
	check(not bool(deep_report.get("declined_by_wall_draw", false)), "deep wall does not mark wall-draw claim decline")
	check(is_equal_approx(float(deep_report.get("wall_draw_claim_penalty", -1.0)), 0.0), "deep wall claim penalty stays zero")

	print("--- E) score path subtracts wall-draw claim penalty ---")
	var fake_report = {
		"claim": "peng",
		"before_shanten": 3,
		"after_shanten": 3,
		"shape_gain": 20.0,
		"forced_discard_risk": 0.0,
		"seat": 1,
		"human_claim_penalty": 0.0,
		"wall_draw_claim_penalty": 25.0,
		"plan_label": "标准",
		"after_plan_label": "标准",
		"plan_bonus": 0.0,
		"after_plan_bonus": 0.0,
	}
	var scored = scene.ai_claim_action_score(fake_report, 1)
	var scored_clean = scene.ai_claim_action_score({
		"claim": "peng",
		"before_shanten": 3,
		"after_shanten": 3,
		"shape_gain": 20.0,
		"forced_discard_risk": 0.0,
		"seat": 1,
		"human_claim_penalty": 0.0,
		"wall_draw_claim_penalty": 0.0,
		"plan_label": "标准",
		"after_plan_label": "标准",
		"plan_bonus": 0.0,
		"after_plan_bonus": 0.0,
	}, 1)
	check(scored < scored_clean, "wall-draw claim penalty lowers action score")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
