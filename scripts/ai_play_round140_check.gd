extends SceneTree
## Round 140: concealed self-gang wait comparisons reuse public tile counts.

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
	print("=== ai_play_round140 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("AI"), make_player("P2"), make_player("P3")]
	scene.current_seat = 1
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.wall.clear()
	for _i in range(40):
		scene.wall.append("9B")
	scene.players[1]["hand"] = ["5W", "5W", "5W", "5W", "1W", "2W", "3W", "7W", "8W", "9W", "2T", "3T", "4T", "E"]

	var hand: Array = scene.players[1]["hand"]
	var hand_counts: Array = scene.tile_counts(hand)
	var before_shanten: int = scene.calculate_min_shanten_from_counts(hand_counts, 0)
	var after_hand: Array = hand.duplicate()
	for _i in range(4):
		after_hand.erase("5W")
	var after_counts: Array = hand_counts.duplicate()
	var gang_index: int = scene.tile_index_normalized("5W")
	after_counts[gang_index] = int(after_counts[gang_index]) - 4
	var after_shanten: int = scene.calculate_min_shanten_from_counts(after_counts, 1)
	var visible_counts: Array = scene.visible_tile_counts_shared()

	print("--- A) explicit public snapshot matches legacy effective counts ---")
	var before_legacy: int = scene.effective_tile_count(hand, 0, 1, before_shanten, [], hand_counts)
	var before_snapshot: int = scene.effective_tile_count(hand, 0, 1, before_shanten, visible_counts, hand_counts)
	var after_legacy: int = scene.effective_tile_count(after_hand, 1, 1, after_shanten, [], after_counts)
	var after_snapshot: int = scene.effective_tile_count(after_hand, 1, 1, after_shanten, visible_counts, after_counts)
	check(before_legacy == before_snapshot and after_legacy == after_snapshot, "杠前杠后有效进张复用可见牌快照且保持旧结果")
	check(before_shanten == 0 and after_shanten == 0, "夹具进入暗杠前后同向听比较分支")

	print("--- B) self-gang report consumes the shared snapshot ---")
	var context: Dictionary = scene.make_ai_evaluation_context(1, visible_counts)
	context["hand_counts"] = hand_counts
	context["self_gang_attack_multiplier"] = scene.ai_total_attack_multiplier(1)
	context["self_gang_gang_aggression"] = scene.ai_gang_aggression(1)
	context["self_gang_wait_focus"] = scene.ai_wait_value_focus(1)
	context["self_gang_difficulty"] = scene.AI_DIFFICULTY_NORMAL
	var snapshot_report: Dictionary = scene.build_ai_self_gang_report(1, "5W", "concealed", context)
	var legacy_report: Dictionary = scene.build_ai_self_gang_report(1, "5W", "concealed")
	check(int(snapshot_report.get("before_ukeire", -1)) == before_snapshot and int(snapshot_report.get("after_ukeire", -1)) == after_snapshot, "暗杠报告使用同一可见牌快照计算杠前杠后有效进张")
	check(int(snapshot_report.get("before_ukeire", -1)) == int(legacy_report.get("before_ukeire", -2)) and int(snapshot_report.get("after_ukeire", -1)) == int(legacy_report.get("after_ukeire", -2)) and bool(snapshot_report.get("wait_narrowed", false)) == bool(legacy_report.get("wait_narrowed", true)), "带上下文与旧报告保持等待收窄判断一致")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
