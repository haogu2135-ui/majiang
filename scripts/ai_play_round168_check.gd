extends SceneTree
## Round 168: center wind labels reuse one content-size snapshot.

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
	print("=== ai_play_round168 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.current_seat = 0
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.wall.clear()
	for _i in range(60):
		scene.wall.append("1B")

	var center_root := Control.new()
	center_root.name = "CenterWindContentSnapshotRoot"
	center_root.size = Vector2(1280.0, 720.0)
	root.add_child(center_root)
	scene.root_layer = center_root
	var expected_content_size: Vector2 = scene.safe_content_pixel_size()
	scene.draw_center(center_root)
	var center := center_root.get_node_or_null("CenterConsole3DShell") as Control
	check(center != null and center.get_meta("wind_label_content_size_snapshot", Vector2.ZERO) == expected_content_size, "中心面板发布风位标签使用的 content-size 快照")
	check(center != null and str(center.get_meta("wind_label_content_size_snapshot_policy", "")) == "one_content_size_snapshot_per_wind_label_pass", "中心面板声明风位标签循环只读取一次 content-size")

	scene.current_seat = 2
	check(center != null and center.get_meta("wind_label_content_size_snapshot", Vector2.ZERO) == expected_content_size, "后续状态变化不会改写已完成的风位尺寸快照")

	center_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
