extends SceneTree
## Round 165: score strip reuses one current-seat snapshot.

var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if condition:
		print("  OK  | %s" % message)
	else:
		print("  FAIL| %s" % message)
		failed = true


func make_player(name: String, score: int) -> Dictionary:
	return {
		"name": name,
		"hand": [],
		"discards": [],
		"melds": [],
		"flowers": 0,
		"flower_tiles": [],
		"score": score,
		"bot": true,
	}


func run() -> void:
	print("=== ai_play_round165 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.current_seat = 1
	scene.players = [
		make_player("P0", 25000),
		make_player("P1", 26000),
		make_player("P2", 24000),
		make_player("P3", 25000),
	]

	var first_root := Control.new()
	first_root.name = "ScoreStripSnapshotRoot"
	first_root.size = Vector2(1280.0, 720.0)
	root.add_child(first_root)
	scene.root_layer = first_root
	scene.draw_score_strip(first_root, Rect2(0.0, 0.0, 1.0, 1.0))
	var first_strip := first_root.get_node_or_null("ScoreStrip") as Control
	var first_active_chip := first_strip.get_node_or_null("ScoreStripChip_1") as Control if first_strip != null else null
	var first_inactive_chip := first_strip.get_node_or_null("ScoreStripChip_0") as Control if first_strip != null else null
	check(first_strip != null and int(first_strip.get_meta("current_seat_snapshot", -1)) == 1, "分数条发布当前座位快照")
	check(first_strip != null and str(first_strip.get_meta("current_seat_snapshot_policy", "")) == "one_current_seat_snapshot_per_draw", "分数条声明每次绘制只读取一次当前座位")
	check(first_active_chip != null and bool(first_active_chip.get_meta("active_snapshot", false)) and first_inactive_chip != null and not bool(first_inactive_chip.get_meta("active_snapshot", true)), "四个分数 chip 复用同一活动座位快照")

	scene.current_seat = 3
	check(first_strip != null and int(first_strip.get_meta("current_seat_snapshot", -1)) == 1 and bool(first_active_chip.get_meta("active_snapshot", false)), "后续状态变化不会改写已完成的分数条快照")

	var second_root := Control.new()
	second_root.name = "ScoreStripFreshSnapshotRoot"
	second_root.size = Vector2(1280.0, 720.0)
	root.add_child(second_root)
	scene.root_layer = second_root
	scene.draw_score_strip(second_root, Rect2(0.0, 0.0, 1.0, 1.0))
	var second_strip := second_root.get_node_or_null("ScoreStrip") as Control
	var second_active_chip := second_strip.get_node_or_null("ScoreStripChip_3") as Control if second_strip != null else null
	check(second_strip != null and int(second_strip.get_meta("current_seat_snapshot", -1)) == 3 and second_active_chip != null and bool(second_active_chip.get_meta("active_snapshot", false)), "下一次分数条绘制重新获取实时当前座位")

	first_root.queue_free()
	second_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
