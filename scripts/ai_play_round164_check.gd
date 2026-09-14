extends SceneTree
## Round 164: center wind compass reuses one current-seat snapshot.

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
	print("=== ai_play_round164 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.current_seat = 2
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var first_root := Control.new()
	first_root.name = "CenterWindSnapshotRoot"
	first_root.size = Vector2(1280.0, 720.0)
	root.add_child(first_root)
	scene.root_layer = first_root
	var first_compass := scene.draw_center_wind_compass(first_root) as Control
	var first_active_badge := first_compass.get_node_or_null("CenterWindCompass_西") as Control if first_compass != null else null
	check(first_compass != null and int(first_compass.get_meta("current_seat_snapshot", -1)) == 2, "中心风位罗盘发布当前座位快照")
	check(first_compass != null and str(first_compass.get_meta("current_seat_snapshot_policy", "")) == "one_current_seat_snapshot_per_draw", "中心风位罗盘声明每次绘制只读取一次当前座位")
	check(first_compass != null and first_compass.get_node_or_null("CenterWindSimpleMark_西") != null and first_active_badge != null and str(first_active_badge.get_meta("wind_state", "")) == "current", "简化标记和完整风位标记使用同一当前座位")
	check(first_active_badge != null and first_active_badge.find_child("CenterWindCurrentMarker", true, false) != null, "当前风位仍保留形状和文字标记")

	scene.current_seat = 0
	check(first_compass != null and int(first_compass.get_meta("current_seat_snapshot", -1)) == 2 and str(first_active_badge.get_meta("wind_state", "")) == "current", "后续状态变化不会改写已完成的罗盘快照")

	var second_root := Control.new()
	second_root.name = "CenterWindFreshSnapshotRoot"
	second_root.size = Vector2(1280.0, 720.0)
	root.add_child(second_root)
	scene.root_layer = second_root
	var second_compass := scene.draw_center_wind_compass(second_root) as Control
	var second_active_badge := second_compass.get_node_or_null("CenterWindCompass_东") as Control if second_compass != null else null
	check(second_compass != null and int(second_compass.get_meta("current_seat_snapshot", -1)) == 0 and second_active_badge != null and str(second_active_badge.get_meta("wind_state", "")) == "current", "下一次罗盘绘制重新获取实时当前座位")

	first_root.queue_free()
	second_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
