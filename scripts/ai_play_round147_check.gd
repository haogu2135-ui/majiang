extends SceneTree
## Round 147: route evaluation reuses one exposed-tile index snapshot.

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
	print("=== ai_play_round147 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("AI"), make_player("P2"), make_player("P3")]
	scene.wall = scene.make_wall()
	scene.players[1]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "1T", "3T", "5T", "E", "S", "R"]
	scene.players[1]["melds"] = [["1W", "2W", "3W"], ["E", "E", "E"]]

	var hand_counts: Array = scene.tile_counts(scene.players[1]["hand"])
	var meld_tile_indices: Array = scene.hand_plan_meld_tile_indices_for_seat(1)
	var live_eval: Dictionary = scene.hand_plan_eval_for_seat_from_counts(1, hand_counts, 14)
	var snapshot_eval: Dictionary = scene.hand_plan_eval_for_seat_from_counts(1, hand_counts, 14, meld_tile_indices)

	print("--- A) seat route evaluation ---")
	check(not meld_tile_indices.is_empty(), "副露牌索引快照已建立")
	check(live_eval == snapshot_eval, "显式副露快照保持路线评估结果")

	var live_extra: Dictionary = scene.plan_report_with_extra_melds(1, hand_counts, 14, ["9B", "9B", "9B"])
	var snapshot_extra: Dictionary = scene.plan_report_with_extra_melds(1, hand_counts, 14, ["9B", "9B", "9B"], meld_tile_indices)
	check(live_extra == snapshot_extra, "副露候选路线保持 live 回退结果")

	print("--- B) shared evaluation context ---")
	var visible_counts: Array = scene.visible_tile_counts_shared()
	var context: Dictionary = scene.make_ai_evaluation_context(1, visible_counts)
	check(context.get("meld_tile_indices", []) == meld_tile_indices, "评估上下文发布一次副露牌索引快照")

	scene.offline_phase = "await_discard"
	scene.current_seat = 1
	scene.offline_turn_needs_draw = false
	var context_output: Dictionary = {}
	var reports: Array = scene.get_ai_discard_reports(1, visible_counts, context_output)
	check(not reports.is_empty(), "弃牌报告仍能完成副露手路线评估")
	check(context_output.get("meld_tile_indices", []) == meld_tile_indices, "弃牌报告复用上下文副露快照")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
