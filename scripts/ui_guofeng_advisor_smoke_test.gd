extends "res://scripts/ui_battle_reading_evidence_smoke_test.gd"


func run() -> void:
	print("=== guofeng advisor UI smoke START ===")
	if DisplayServer.get_name().to_lower() == "headless":
		quit(1)
		return
	OS.set_environment("YUNZHUO_UI_CAPTURE", "1")
	var viewport_size := Vector2i(1280, 720)
	var arguments := OS.get_cmdline_user_args()
	if not arguments.is_empty():
		var dimensions := arguments[0].split("x")
		if dimensions.size() == 2:
			viewport_size = Vector2i(int(dimensions[0]), int(dimensions[1]))
	var large_contrast := arguments.size() > 1 and arguments[1] == "large_contrast"
	DisplayServer.window_set_size(viewport_size)
	root.size = viewport_size
	root.content_scale_size = viewport_size
	var capture_root := OS.get_environment("YUNZHUO_GUOFENG_ADVISOR_CAPTURE_DIR")
	if capture_root.is_empty():
		capture_root = "res://build/qa/guofeng_advisor"
	var output_dir := ProjectSettings.globalize_path("%s/%dx%d%s" % [capture_root, viewport_size.x, viewport_size.y, "_large_contrast" if large_contrast else ""])
	check(DirAccess.make_dir_recursive_absolute(output_dir) == OK, "advisor evidence directory is writable")
	var scene = load("res://Main.tscn").instantiate()
	if scene.get_script() == null:
		check(false, "runtime script must compile before advisor evidence")
		scene.free()
		quit(1)
		return
	root.add_child(scene)
	await settle()
	var user_state := capture_smoke_state(scene)
	scene.set_process(false)
	scene.music_enabled = false
	scene.sfx_enabled = false
	scene.voice_enabled = false
	scene.tts_enabled = false
	scene.fx_enabled = false
	scene.reduce_motion_enabled = true
	scene.large_text_enabled = large_contrast
	scene.high_contrast_enabled = large_contrast
	scene.tutorial_step = scene.TUTORIAL_STEP_COMPLETE
	await check_advisor_reading(scene, output_dir)
	scene.shutdown_runtime()
	restore_smoke_state(scene, user_state)
	scene.queue_free()
	await process_frame
	print("=== RESULT: %s ===" % ("FAIL" if failed else "OK"))
	quit(1 if failed else 0)
