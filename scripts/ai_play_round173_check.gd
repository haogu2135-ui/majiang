extends SceneTree
## Round 173: shop rendering consumes one viewport and content-size snapshot.

var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if condition:
		print("  OK  | %s" % message)
	else:
		print("  FAIL| %s" % message)
		failed = true


func run() -> void:
	print("=== ai_play_round173 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.currency = {"coins": 1200, "gems": 80}
	var expected_viewport: Vector2 = scene.effective_viewport_size()
	var expected_content_size: Vector2 = scene.safe_content_pixel_size()
	scene.show_shop_screen(true)

	var panel := scene.root_layer.get_node_or_null("ShopCabinetFrontPanel") as Control
	var content := panel.get_node_or_null("ShopItemsScroll/ShopItemsContent") as Control if panel != null else null
	var name_label := panel.find_child("ShopItemName_swap_card", true, false) as Label if panel != null else null
	check(panel != null and panel.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "商店面板发布本次绘制的 viewport 快照")
	check(panel != null and str(panel.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "商店面板声明每次绘制只读取一次 viewport")
	check(panel != null and panel.get_meta("content_size_snapshot", Vector2.ZERO) == expected_content_size, "商店面板发布本次绘制的 content-size 快照")
	check(panel != null and str(panel.get_meta("content_size_snapshot_policy", "")) == "one_content_size_snapshot_per_draw", "商店面板声明每次绘制只读取一次 content-size")
	check(content != null and content.find_child("ShopItemRow_swap_card", true, false) != null and content.find_child("ShopItemsBottomSpacer", true, false) != null, "商品行和底部间距仍完整构建")
	check(name_label != null and name_label.get_meta("shop_name_width_px", 0.0) == maxf(120.0, expected_content_size.x * 0.300), "商品名称仍使用原有的 content-size 宽度预算")

	scene.currency["gems"] = 0
	scene.mode = "menu"
	check(panel != null and panel.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport and panel.get_meta("content_size_snapshot", Vector2.ZERO) == expected_content_size, "后续状态变化不会改写已完成的商店快照")

	scene.clear_screen()
	scene.root_layer = null
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
