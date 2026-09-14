extends SceneTree
## Round 188: local settings refresh reuses its viewport snapshot.

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
	print("=== ai_play_round188 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.settings_panel_open = true

	var refresh_root := Control.new()
	refresh_root.name = "SettingsLocalRefreshSnapshotRoot"
	refresh_root.size = Vector2(1280.0, 720.0)
	refresh_root.set_meta("ui_page_generation", scene.ui_page_generation)
	root.add_child(refresh_root)
	var settings_panel := Control.new()
	settings_panel.name = "SettingsPanel"
	refresh_root.add_child(settings_panel)
	scene.root_layer = refresh_root
	var setting_button := Button.new()
	scene.make_setting_row(settings_panel, "AI 节奏", "当前: 标准", setting_button)
	var expected_viewport: Vector2 = scene.effective_viewport_size()
	var refreshed: bool = scene.refresh_settings_local_row("AI 节奏")
	check(refreshed and settings_panel.get_meta("local_update_viewport_snapshot", Vector2.ZERO) == expected_viewport, "设置局部刷新发布本次更新的 viewport 快照")
	check(str(settings_panel.get_meta("local_update_viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_update", "设置局部刷新声明每次更新只读取一次 viewport")
	check(setting_button.text != "", "设置按钮局部刷新仍更新可见状态")
	scene.fast_mode_enabled = not scene.fast_mode_enabled
	check(settings_panel.get_meta("local_update_viewport_snapshot", Vector2.ZERO) == expected_viewport, "后续设置状态变化不会改写已完成的局部刷新快照")

	refresh_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
