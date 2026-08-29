extends SceneTree
## Runtime coverage for the six reading-assistance profiles and focus recovery.

const PROFILE_FIXTURES := [
	{"name": "01_standard", "label": "标准", "large": false, "contrast": false, "reduce_motion": false},
	{"name": "02_large_text", "label": "大字", "large": true, "contrast": false, "reduce_motion": false},
	{"name": "03_high_contrast", "label": "高对比", "large": false, "contrast": true, "reduce_motion": false},
	{"name": "04_reduce_motion", "label": "减动效", "large": false, "contrast": false, "reduce_motion": true},
	{"name": "05_focused", "label": "专注", "large": true, "contrast": true, "reduce_motion": true},
	{"name": "06_clear", "label": "清晰", "large": true, "contrast": true, "reduce_motion": false},
]

var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if condition:
		print("  OK  | %s" % message)
	else:
		print("  FAIL| %s" % message)
		failed = true


func settle(seconds: float = 0.0) -> void:
	await process_frame
	await process_frame
	if seconds > 0.0:
		await create_timer(seconds).timeout
		await process_frame


func send_key(keycode: Key, unicode_value: int = 0) -> void:
	var pressed_event := InputEventKey.new()
	pressed_event.keycode = keycode
	pressed_event.unicode = unicode_value
	pressed_event.pressed = true
	Input.parse_input_event(pressed_event)
	await process_frame
	var released_event := InputEventKey.new()
	released_event.keycode = keycode
	released_event.unicode = unicode_value
	released_event.pressed = false
	Input.parse_input_event(released_event)
	await process_frame


func requested_viewport_size() -> Vector2i:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--size="):
			var parts := argument.substr("--size=".length()).split("x")
			if parts.size() == 2:
				return Vector2i(maxi(320, int(parts[0])), maxi(240, int(parts[1])))
			printerr("invalid accessibility smoke size: %s" % argument)
			return Vector2i(1280, 720)
	return Vector2i(1280, 720)


func requested_output_dir(viewport_size: Vector2i) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output-dir="):
			return argument.substr("--output-dir=".length())
	if viewport_size == Vector2i(1280, 720):
		return "res://build/qa/accessibility_profiles"
	return "res://build/qa/accessibility_profiles_%dx%d" % [viewport_size.x, viewport_size.y]


func write_capture_metadata(output_dir_res: String, viewport_size: Vector2i) -> bool:
	var metadata := {
		"capture_revision": OS.get_environment("YUNZHUO_CAPTURE_REVISION"),
		"capture_batch_id": OS.get_environment("YUNZHUO_CAPTURE_BATCH_ID"),
		"worktree_state": OS.get_environment("YUNZHUO_CAPTURE_WORKTREE_STATE"),
		"runtime_source_state": OS.get_environment("YUNZHUO_CAPTURE_RUNTIME_SOURCE_STATE"),
		"worktree_diff_fingerprint": OS.get_environment("YUNZHUO_CAPTURE_WORKTREE_DIFF_FINGERPRINT"),
		"runtime_source_diff_fingerprint": OS.get_environment("YUNZHUO_CAPTURE_RUNTIME_SOURCE_DIFF_FINGERPRINT"),
		"capture_size": "%dx%d" % [viewport_size.x, viewport_size.y],
		"profile_names": PROFILE_FIXTURES.map(func(profile: Dictionary) -> String: return str(profile["name"])),
		"profile_labels": PROFILE_FIXTURES.map(func(profile: Dictionary) -> String: return str(profile["label"])),
		"focus_contract": {
			"profile_control": "SettingRowButton_阅读辅助",
			"profile_focus_after_rebuild": true,
			"return_control": "MenuSettingsButton",
			"cycle": "standard->large_text->high_contrast->reduce_motion->focused->clear->standard",
		},
		"capture_time_utc": Time.get_datetime_string_from_system(true),
	}
	var output_path := ProjectSettings.globalize_path("%s/accessibility_capture_metadata.json" % output_dir_res)
	var file := FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		printerr("failed to write accessibility capture metadata: %s" % output_path)
		return false
	file.store_string(JSON.stringify(metadata) + "\n")
	return true


func save_profile_screenshot(output_dir_res: String, profile_name: String) -> bool:
	var viewport_texture := root.get_texture()
	if viewport_texture == null:
		printerr("failed to capture accessibility profile %s: viewport texture unavailable" % profile_name)
		return false
	var image := viewport_texture.get_image()
	if image == null:
		printerr("failed to capture accessibility profile %s: viewport image unavailable" % profile_name)
		return false
	var output_path := ProjectSettings.globalize_path("%s/%s.png" % [output_dir_res, profile_name])
	var error := image.save_png(output_path)
	if error != OK:
		printerr("failed to save accessibility profile %s: %s" % [profile_name, error_string(error)])
		return false
	print("saved accessibility profile: %s" % output_path)
	return true


func profile_button(scene: Node) -> Button:
	return scene.find_child("SettingRowButton_阅读辅助", true, false) as Button


func profile_status(scene: Node) -> Label:
	return scene.find_child("SettingRowStatus_阅读辅助", true, false) as Label


func check_profile_state(scene: Node, profile: Dictionary) -> void:
	var expected_label := str(profile["label"])
	var button := profile_button(scene)
	var status := profile_status(scene)
	var focus_owner := scene.get_viewport().gui_get_focus_owner()
	check(button != null and button.text == expected_label, "profile button shows %s" % expected_label)
	check(status != null and status.text == "当前: %s" % expected_label, "profile status line shows %s" % expected_label)
	check(bool(scene.large_text_enabled) == bool(profile["large"]), "%s large-text state matches" % expected_label)
	check(bool(scene.high_contrast_enabled) == bool(profile["contrast"]), "%s contrast state matches" % expected_label)
	check(bool(scene.reduce_motion_enabled) == bool(profile["reduce_motion"]), "%s reduced-motion state matches" % expected_label)
	check(scene.accessibility_font_size(15) == (19 if bool(profile["large"]) else 15), "%s shared label size matches" % expected_label)
	check(button != null and button.has_focus() and focus_owner == button, "%s restores keyboard focus to the profile control" % expected_label)
	var focus_plate := button.find_child("ButtonFocusPlate", true, false) as CanvasItem if button != null else null
	check(focus_plate != null and focus_plate.modulate.a >= 0.50, "%s exposes visible focus feedback" % expected_label)


func run() -> void:
	print("=== ui accessibility smoke START ===")
	if DisplayServer.get_name().to_lower() == "headless":
		printerr("UI accessibility smoke requires a non-headless display driver")
		quit(1)
		return
	OS.set_environment("YUNZHUO_UI_CAPTURE", "1")

	var viewport_size := requested_viewport_size()
	DisplayServer.window_set_size(viewport_size)
	root.size = viewport_size
	root.content_scale_size = viewport_size
	await settle()

	var output_dir_res := requested_output_dir(viewport_size)
	var output_dir := ProjectSettings.globalize_path(output_dir_res)
	DirAccess.make_dir_recursive_absolute(output_dir)
	if not write_capture_metadata(output_dir_res, viewport_size):
		quit(1)
		return

	var scene = load("res://Main.tscn").instantiate()
	root.add_child(scene)
	await settle(0.10)
	# Main loads persisted preferences from _ready, so snapshot and override them
	# only after the scene has entered the tree.
	var original_settings := {
		"large_text_enabled": bool(scene.large_text_enabled),
		"high_contrast_enabled": bool(scene.high_contrast_enabled),
		"reduce_motion_enabled": bool(scene.reduce_motion_enabled),
		"fx_enabled": bool(scene.fx_enabled),
		"music_enabled": bool(scene.music_enabled),
		"sfx_enabled": bool(scene.sfx_enabled),
		"tts_enabled": bool(scene.tts_enabled),
		"voice_enabled": bool(scene.voice_enabled),
	}
	scene.music_enabled = false
	scene.sfx_enabled = false
	scene.tts_enabled = false
	scene.voice_enabled = false
	scene.fx_enabled = false
	scene.large_text_enabled = false
	scene.high_contrast_enabled = false
	scene.reduce_motion_enabled = false
	scene.save_settings()
	scene.show_menu(true)
	await settle(0.10)
	scene.settings_panel_open = true
	scene.refresh_current_screen()
	await settle(0.10)

	var initial_button := profile_button(scene)
	check(initial_button != null, "settings exposes the reading-assistance selector")
	if initial_button != null:
		initial_button.grab_focus()
		await settle(0.05)
	check_profile_state(scene, PROFILE_FIXTURES[0])
	if not save_profile_screenshot(output_dir_res, str(PROFILE_FIXTURES[0]["name"])):
		failed = true

	for profile_index in range(1, PROFILE_FIXTURES.size()):
		var selector := profile_button(scene)
		check(selector != null, "profile selector remains available before %s" % PROFILE_FIXTURES[profile_index]["label"])
		if selector == null:
			continue
		selector.grab_focus()
		await send_key(KEY_ENTER)
		await settle(0.10)
		check_profile_state(scene, PROFILE_FIXTURES[profile_index])
		if not save_profile_screenshot(output_dir_res, str(PROFILE_FIXTURES[profile_index]["name"])):
			failed = true

	var final_selector := profile_button(scene)
	check(final_selector != null and final_selector.text == "清晰", "six-profile sequence reaches the final clear profile")
	if final_selector != null:
		final_selector.grab_focus()
		await send_key(KEY_ENTER)
		await settle(0.10)
		check_profile_state(scene, PROFILE_FIXTURES[0])
		check(scene.accessibility_profile_label() == "标准", "profile cycle wraps back to standard")

	await send_key(KEY_ESCAPE)
	await settle(0.10)
	var menu_settings := scene.find_child("MenuSettingsButton", true, false) as Button
	check(not scene.settings_panel_open and scene.find_child("SettingsOverlay", true, false) == null, "Escape returns from settings to the menu")
	check(menu_settings != null and menu_settings.has_focus(), "return from settings restores menu keyboard focus")

	# Restore the caller's persisted preferences before ending this QA process.
	scene.large_text_enabled = bool(original_settings["large_text_enabled"])
	scene.high_contrast_enabled = bool(original_settings["high_contrast_enabled"])
	scene.reduce_motion_enabled = bool(original_settings["reduce_motion_enabled"])
	scene.fx_enabled = bool(original_settings["fx_enabled"])
	scene.music_enabled = bool(original_settings["music_enabled"])
	scene.sfx_enabled = bool(original_settings["sfx_enabled"])
	scene.tts_enabled = bool(original_settings["tts_enabled"])
	scene.voice_enabled = bool(original_settings["voice_enabled"])
	scene.save_settings()
	if scene.has_method("clear_fx_overlays"):
		scene.clear_fx_overlays()
	if scene.has_method("shutdown_runtime"):
		scene.shutdown_runtime()
	scene.queue_free()
	await settle(0.05)
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
