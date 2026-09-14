extends SceneTree
## Round 184: win-detail rendering reuses its viewport snapshot.

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
	print("=== ai_play_round184 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.mode = "offline"

	var detail_root := Control.new()
	detail_root.name = "WinDetailViewportSnapshotRoot"
	detail_root.size = Vector2(1280.0, 720.0)
	root.add_child(detail_root)
	scene.root_layer = detail_root
	var expected_viewport: Vector2 = scene.effective_viewport_size()
	scene.draw_win_detail_section(detail_root, {"winner": 0, "fan": 2, "points": 100, "reasons": ["立直"], "win_tile": "5W", "self_draw": false})
	var detail_panel := detail_root.get_node_or_null("WinDetailPanel") as Control
	var showcase := detail_panel.get_node_or_null("WinDetailShowcase") as Control if detail_panel != null else null
	var yaku_scroll := detail_panel.get_node_or_null("WinDetailYakuScroll") as Control if detail_panel != null else null
	check(detail_panel != null and detail_panel.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "胡牌详情发布本次绘制的 viewport 快照")
	check(detail_panel != null and showcase != null and showcase.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "胡牌详情 showcase 复用父绘制 viewport 快照")
	check(showcase != null and str(showcase.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "胡牌详情 showcase 声明只读取一次 viewport")
	check(yaku_scroll != null, "胡牌详情仍构建番种滚动区域")
	scene.large_text_enabled = true
	check(detail_panel != null and detail_panel.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport and showcase != null and showcase.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "后续结算状态不会改写已完成的 viewport 快照")

	var direct_showcase_root := Control.new()
	root.add_child(direct_showcase_root)
	var direct_showcase: Control = scene.draw_win_detail_showcase(direct_showcase_root, "5W", false, 2, 100)
	check(direct_showcase != null and direct_showcase.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "独立 showcase 调用保留实时 viewport 回退")
	direct_showcase_root.queue_free()
	detail_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
