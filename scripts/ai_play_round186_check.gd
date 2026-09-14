extends SceneTree
## Round 186: menu-card motion reuses the card viewport snapshot.

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
	print("=== ai_play_round186 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame

	var motion_root := Control.new()
	motion_root.name = "MenuMotionViewportSnapshotRoot"
	motion_root.size = Vector2(1280.0, 720.0)
	root.add_child(motion_root)
	var expected_viewport := Vector2(1136.0, 640.0)
	var button := Button.new()
	button.name = "MenuMotionSnapshotButton"
	motion_root.add_child(button)
	scene.configure_menu_button_motion(button, 0.0, 1.0, 0.0, expected_viewport)
	check(button.get_meta("motion_viewport_snapshot", Vector2.ZERO) == expected_viewport, "菜单按钮动画消费显式 viewport 快照")
	check(str(button.get_meta("motion_viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "菜单按钮动画声明复用卡片 viewport 快照")
	check(bool(button.get_meta("menu_motion_configured", false)), "菜单按钮动画仍完成配置登记")

	motion_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
