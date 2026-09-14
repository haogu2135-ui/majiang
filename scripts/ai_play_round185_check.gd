extends SceneTree
## Round 185: menu-card text budgets reuse their viewport snapshot.

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
	print("=== ai_play_round185 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "menu"

	var card_root := Control.new()
	card_root.name = "MenuCardViewportSnapshotRoot"
	card_root.size = Vector2(1280.0, 720.0)
	root.add_child(card_root)
	scene.root_layer = card_root
	var expected_viewport: Vector2 = scene.effective_viewport_size()
	var card: Button = scene.make_menu_card("联机对战\n局域网房间", Color(0.24, 0.42, 0.38), Callable(), "wifi", false)
	card_root.add_child(card)
	var title := card.get_node_or_null("MenuCardTitleLabel") as Label
	var subtitle := card.get_node_or_null("MenuCardSubtitleLabel") as Label
	check(card != null and card.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "菜单卡片发布本次绘制的 viewport 快照")
	check(card != null and str(card.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "菜单卡片声明每次绘制只读取一次 viewport")
	check(title != null and subtitle != null and title.text == "联机对战" and subtitle.text == "局域网房间", "菜单卡片标题和副标题仍完整构建")
	scene.large_text_enabled = true
	check(card != null and card.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "后续菜单状态变化不会改写已完成的 viewport 快照")

	card_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
