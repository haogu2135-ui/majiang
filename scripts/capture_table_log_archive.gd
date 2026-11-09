extends SceneTree

func _init() -> void:
	DisplayServer.window_set_size(Vector2i(960, 540))
	root.size = Vector2i(960, 540)
	var scene = load("res://Main.tscn").instantiate()
	root.add_child(scene)
	await create_timer(0.1).timeout
	scene.music_enabled = false
	scene.sfx_enabled = false
	scene.table_logs.append("对局开始，东风局")
	scene.table_logs.append("玩家摸入一万")
	scene.table_logs.append("对家打出中")
	scene.render_game()
	await create_timer(0.1).timeout
	var btn := scene.find_child("TableLogArchiveButton", true, false) as Button
	if btn != null:
		btn.pressed.emit()
	await create_timer(0.15).timeout
	var img := root.get_texture().get_image()
	DirAccess.make_dir_recursive_absolute("res://build/qa")
	img.save_png("res://build/qa/table_log_archive_raw.png")
	print("Saved res://build/qa/table_log_archive_raw.png")
	quit(0)
