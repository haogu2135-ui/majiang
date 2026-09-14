extends SceneTree
## Round 183: settings overlay reuses its viewport snapshot.

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
	print("=== ai_play_round183 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.settings_panel_open = true
	scene.large_text_enabled = false

	var overlay_root := Control.new()
	overlay_root.name = "SettingsViewportSnapshotRoot"
	overlay_root.size = Vector2(1280.0, 720.0)
	root.add_child(overlay_root)
	scene.root_layer = overlay_root
	var expected_viewport: Vector2 = scene.effective_viewport_size()
	scene.draw_settings_overlay(overlay_root)
	var overlay := overlay_root.get_node_or_null("SettingsOverlay") as Control
	var rule_status := overlay.find_child("SettingsRuleVariantStatus", true, false) as Label if overlay != null else null
	check(overlay != null and overlay.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "设置蒙层发布本次绘制的 viewport 快照")
	check(overlay != null and str(overlay.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "设置蒙层声明每次绘制只读取一次 viewport")
	check(rule_status != null and rule_status.text != "", "地方规则状态标签仍完整构建")
	scene.large_text_enabled = true
	check(overlay != null and overlay.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "后续设置状态变化不会改写已完成的 viewport 快照")

	overlay_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
