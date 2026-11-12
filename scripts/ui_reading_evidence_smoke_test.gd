extends "res://scripts/ui_interaction_smoke_test.gd"


func save_reading_capture(scene: Node, output_dir: String, name: String, state: Dictionary) -> void:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	check(image != null and image.save_png("%s/%s.png" % [output_dir, name]) == OK, "%s screenshot saves the current reading position" % name)
	var metadata := state.duplicate(true)
	metadata["runtime_source_diff_fingerprint"] = OS.get_environment("YUNZHUO_CAPTURE_RUNTIME_SOURCE_DIFF_FINGERPRINT")
	metadata["capture_batch_id"] = OS.get_environment("YUNZHUO_CAPTURE_BATCH_ID")
	metadata["capture_revision"] = OS.get_environment("YUNZHUO_CAPTURE_REVISION")
	metadata["source_manifest_sha256"] = OS.get_environment("YUNZHUO_CAPTURE_SOURCE_MANIFEST_SHA256")
	metadata["capture_time_utc"] = Time.get_datetime_string_from_system(true)
	metadata["viewport_size"] = [root.size.x, root.size.y]
	metadata["game_version"] = scene.APP_VERSION
	metadata["large_text_enabled"] = scene.large_text_enabled
	metadata["high_contrast_enabled"] = scene.high_contrast_enabled
	var file := FileAccess.open("%s/%s.json" % [output_dir, name], FileAccess.WRITE)
	check(file != null, "%s evidence metadata is writable" % name)
	if file != null:
		file.store_string(JSON.stringify(metadata, "\t"))


func check_rules_reading(scene: Node, output_dir: String) -> void:
	scene._show_rules_screen_impl()
	await settle(0.20)
	var scroll := scene.find_child("RulesContentScroll", true, false) as ScrollContainer
	var scrollbar := scene.find_child("RulesContentScrollBar", true, false) as VScrollBar
	var thumb := scene.find_child("RulesContentScrollThumb", true, false) as TextureRect
	var hit_target := scene.find_child("RulesContentScrollHitTarget", true, false) as Control
	var status := scene.find_child("RulesReadingStatus", true, false) as Label
	check(scroll != null and scrollbar != null and thumb != null and hit_target != null and status != null, "rules exposes the reading state and custom scrollbar controls")
	if scroll == null or scrollbar == null or thumb == null or hit_target == null or status == null:
		return
	var back := scene.find_child("RulesBackButton", true, false) as Button
	check(back != null and back.get_global_rect().end.y + 6.0 <= status.get_global_rect().position.y + 0.5, "rules reading position clears the complete native return button by six pixels")
	check(status.get_global_rect().end.y + 1.0 <= scroll.get_global_rect().position.y, "rules reading position stays above the body viewport")
	var source := scene.optional_gpt_illustration_texture("menu_ink_primary") as Texture2D
	check(thumb.texture is AtlasTexture and (thumb.texture as AtlasTexture).atlas == source, "rules thumb uses the authored signal artwork rather than the quiet dark scrim")
	check(hit_target.size.x >= 44.0 and hit_target.get_global_rect().position.x >= scroll.get_global_rect().end.x, "scrollbar retains its independent forty-four-pixel hit lane outside the last text column")
	var scroll_range := maxf(0.0, scrollbar.max_value - scrollbar.page)
	check(scroll_range > 0.0, "rules has an actual scroll range")
	if scroll_range <= 0.0:
		return
	var page_title: Label = null
	for candidate in scene.find_children("*", "Label", true, false):
		if (candidate as Label).text.begins_with("麻将玩法指南"):
			page_title = candidate as Label
			break
	check(page_title != null, "rules has a measurable page title")
	for chapter in range(6):
		var chapter_step := scene.find_child("RulesGuideStep_%d" % chapter, true, false) as Control
		var name_label := scene.find_child("RulesGuideStepLabel_%d" % chapter, true, false) as Label
		var state_label := scene.find_child("RulesGuideStepState_%d" % chapter, true, false) as Label
		if name_label == null or state_label == null:
			check(false, "rules chapter %d has both text rows" % (chapter + 1))
			continue
		check(name_label.get_theme_font_size("font_size") >= scene.accessibility_font_size(12) and label_text_width(name_label, name_label.text) <= name_label.size.x + 1.0, "rules chapter %d shows its complete name without reducing the requested font" % (chapter + 1))
		check(page_title != null and page_title.get_global_rect().end.y + 6.0 <= chapter_step.get_global_rect().position.y + 0.5, "rules chapter %d clears the page title" % (chapter + 1))
		check(chapter_step.get_global_rect().end.y + 12.0 <= scroll.get_global_rect().position.y + 0.5, "rules chapter %d clears the body text" % (chapter + 1))
		check(chapter_step != null and chapter_step.get_global_rect().encloses(name_label.get_global_rect()) and chapter_step.get_global_rect().encloses(state_label.get_global_rect()), "rules chapter %d keeps both complete rows inside its authored step" % (chapter + 1))
		if chapter > 0 and chapter_step != null:
			var preceding_step := scene.find_child("RulesGuideStep_%d" % (chapter - 1), true, false) as Control
			check(preceding_step != null and preceding_step.get_global_rect().end.x + 4.0 <= chapter_step.get_global_rect().position.x, "rules chapter %d remains separate from the preceding chapter" % (chapter + 1))
	await save_reading_capture(scene, output_dir, "rules_top", {"status": status.text, "scroll_value": scrollbar.value, "progress": thumb.get_meta("scroll_progress", -1.0)})
	for chapter in [2, 5]:
		var chapter_button := scene.find_child("RulesGuideStepButton_%d" % chapter, true, false) as Button
		check(chapter_button != null, "chapter %d exposes a native navigation target" % (chapter + 1))
		if chapter_button == null:
			continue
		await activate_button(chapter_button, "mouse" if chapter == 2 else "touch")
		await settle()
		check(status.text.begins_with("第%d/6 · " % (chapter + 1)), "chapter %d updates the named reading position" % (chapter + 1))
		var chapter_label := scene.find_child("RulesGuideStepLabel_%d" % chapter, true, false) as Label
		var chapter_state := scene.find_child("RulesGuideStepState_%d" % chapter, true, false) as Label
		var focus_marker := scene.find_child("RulesGuideStepFocusMarker_%d" % chapter, true, false) as Label
		check(chapter_button.has_focus() and focus_marker != null and focus_marker.visible, "chapter %d retains real native focus and its ink marker" % (chapter + 1))
		check(chapter_label != null and chapter_state != null and chapter_button.get_node_or_null("ButtonFocusPlate") == null, "chapter %d keeps the native name and state unobstructed by a second focus surface" % (chapter + 1))
		if chapter_label != null and chapter_state != null:
			check(chapter_label.get_global_rect().end.y + 1.0 <= chapter_state.get_global_rect().position.y and chapter_label.size.y >= chapter_label.get_minimum_size().y and chapter_state.size.y >= chapter_state.get_minimum_size().y, "chapter %d reserves separate complete font-height rows for name and current state" % (chapter + 1))
			var chapter_icon := scene.find_child("RulesGuideStepIcon_%d" % chapter, true, false) as Control
			check(chapter_icon == null or chapter_icon.get_global_rect().end.x <= chapter_state.get_global_rect().position.x, "chapter %d keeps any existing optional icon outside the state text row" % (chapter + 1))
		var progress := 0.0 if scroll_range <= 0.0 else scrollbar.value / scroll_range
		check(absf(float(thumb.get_meta("scroll_progress", -1.0)) - progress) <= 0.01, "chapter %d keeps the visual thumb synchronized" % (chapter + 1))
		await save_reading_capture(scene, output_dir, "rules_chapter_%d" % (chapter + 1), {"status": status.text, "scroll_value": scrollbar.value, "progress": progress})
		var before_tab_scroll := scrollbar.value
		var previous_button := scene.find_child("RulesGuideStepButton_%d" % (chapter - 1), true, false) as Button
		check(previous_button != null, "chapter %d has a preceding keyboard focus target" % (chapter + 1))
		if previous_button != null:
			previous_button.grab_focus()
			await send_key(KEY_TAB, 0)
			var tab_button := scene.get_viewport().gui_get_focus_owner() as Button
			check(tab_button == chapter_button and absf(scrollbar.value - before_tab_scroll) <= 1.0, "Tab reaches chapter %d without jumping the reading position" % (chapter + 1))
			await save_reading_capture(scene, output_dir, "rules_tab_chapter_%d" % (chapter + 1), {"status": status.text, "focused_control": tab_button.name if tab_button != null else "", "scroll_value": scrollbar.value})
	hit_target.grab_focus()
	await send_key(KEY_HOME, 0)
	check(scrollbar.value <= 1.0 and status.text.begins_with("第1/6"), "focused scrollbar Home returns to the first chapter")
	await send_key(KEY_PAGEDOWN, 0)
	check(scrollbar.value > 0.0, "focused scrollbar PageDown advances the reading position")
	await send_key(KEY_END, 0)
	check(scrollbar.value >= scroll_range - 1.0 and status.text.begins_with("第6/6"), "focused scrollbar End reaches the final chapter")
	await send_key(KEY_HOME, 0)
	var start := thumb.get_global_rect().get_center()
	var finish := Vector2(start.x, hit_target.get_global_rect().position.y + hit_target.size.y * 0.55)
	await send_left_button(start, true)
	var initial_mouse_value := scrollbar.value
	var motion := InputEventMouseMotion.new()
	motion.position = finish
	motion.global_position = finish
	motion.relative = finish - start
	motion.button_mask = MOUSE_BUTTON_MASK_LEFT
	Input.parse_input_event(motion)
	await process_frame
	await send_left_button(finish, false)
	check(scrollbar.value > initial_mouse_value + 1.0, "mouse drag moves the native reading range")
	hit_target.grab_focus()
	await send_key(KEY_HOME, 0)
	start = thumb.get_global_rect().get_center()
	finish = Vector2(start.x, hit_target.get_global_rect().position.y + hit_target.size.y * 0.70)
	await send_screen_touch(start, true)
	var initial_touch_value := scrollbar.value
	await send_screen_drag(start, finish)
	await send_screen_touch(finish, false)
	check(scrollbar.value > initial_touch_value + 1.0, "synthetic touch drag moves the reading range without losing ownership to mouse emulation")
	var before_wheel := scrollbar.value
	await send_wheel_down(hit_target.get_global_rect().get_center())
	check(scrollbar.value > before_wheel or scrollbar.value >= scroll_range - 1.0, "wheel input over the custom lane advances or remains at the final boundary")
	check(absf(float(thumb.get_meta("scroll_progress", -1.0)) - scrollbar.value / scroll_range) <= 0.01, "all custom inputs leave the thumb synchronized with native scroll")


func check_compact_lobby_feedback(scene: Node, output_dir: String) -> void:
	scene.tcp = ConnectedLobbyTransport.new()
	scene.tcp_status = StreamPeerTCP.STATUS_CONNECTED
	scene.selected_room = "ROOM7"
	scene.online_room = connected_room_fixture()
	scene.online_room.erase("canStart")
	scene.online_room["hostSeat"] = 0
	scene.online_room["youSeat"] = 0
	scene.online_room["players"].append({"seat": 3, "name": "丁", "ready": false})
	scene.online_feedback = "房间同步完成，等待房主开始。"
	scene.online_waiting_for_server = false
	scene._show_online_lobby_impl()
	await settle(0.20)
	var feedback := scene.find_child("OnlineLobbyFormFeedbackLabel", true, false) as Label
	var button_row := scene.find_child("OnlineLobbyActionButtonRow", true, false) as Control
	check(feedback != null and button_row != null, "lobby exposes separate feedback and action lanes")
	if feedback == null or button_row == null:
		return
	check(feedback.text.contains("准备") and not feedback.text.contains("等待房主"), "full unready room presents its actual start gate")
	check(feedback.get_theme_font_size("font_size") >= scene.accessibility_font_size(12), "full unready room respects the accessible feedback size")
	var form_panel := scene.find_child("OnlineLobbyFormPanel", true, false) as Control
	var start_row := scene.find_child("OnlineLobbyStartButtonRow", true, false) as Control
	check(feedback.size.y + 0.01 >= feedback.get_minimum_size().y and scene.online_room_edit.get_global_rect().end.y + 8.0 <= feedback.get_global_rect().position.y + 0.01, "feedback has a complete font-height row below the room input")
	check(start_row != null and button_row.get_global_rect().end.y + 8.0 <= start_row.get_global_rect().position.y + 0.01, "lobby action rows retain separate eight-pixel gaps")
	check(form_panel != null and start_row != null and form_panel.get_global_rect().encloses(start_row.get_global_rect()), "lobby keeps both bottom actions inside the form panel")
	var log_title := scene.find_child("OnlineLobbyLogListTitle", true, false) as Label
	var log_range := scene.find_child("OnlineLobbyLogRangeLabel", true, false) as Label
	var log_scroll := scene.find_child("OnlineLobbyLogScroll", true, false) as Control
	var log_latest := scene.find_child("OnlineLobbyLogLatestButton", true, false) as Button
	check(log_title != null and log_range != null and log_title.size.y >= log_title.get_minimum_size().y and log_range.size.y >= log_range.get_minimum_size().y and log_title.get_global_rect().end.y + 2.0 <= log_range.get_global_rect().position.y, "room log title and range occupy complete independent rows")
	check(log_range != null and log_scroll != null and log_range.get_global_rect().end.y + 8.0 <= log_scroll.get_global_rect().position.y, "room log content clears the complete header")
	check(log_latest != null and log_scroll != null and log_latest.size.y >= 44.0 and log_latest.get_global_rect().end.y + 8.0 <= log_scroll.get_global_rect().position.y, "latest-log action keeps its independent forty-four-pixel header target")
	await save_reading_capture(scene, output_dir, "lobby_full_unready", {"feedback": feedback.text, "font_size": feedback.get_theme_font_size("font_size")})
	for feedback_state in [
		{"name": "lobby_long_server_error", "text": "服务器拒绝：当前房间已关闭，请重新连接并向房主索取新的房间号后再加入"},
		{"name": "lobby_long_sync_failure", "text": "房间同步失败：无法确认所有玩家准备状态，请检查网络连接后重新同步房间"},
	]:
		scene.online_feedback = feedback_state["text"]
		scene.refresh_online_lobby_action_states()
		await settle()
		check(feedback.text == feedback_state["text"] and feedback.tooltip_text.contains(feedback_state["text"]), "%s preserves the full server reason and accessible tooltip" % feedback_state["name"])
		check(feedback.get_theme_font_size("font_size") >= scene.accessibility_font_size(12), "%s retains the requested accessible feedback size" % feedback_state["name"])
		check(feedback.clip_text and feedback.text_overrun_behavior == TextServer.OVERRUN_TRIM_ELLIPSIS, "%s uses explicit ellipsis instead of shrinking long feedback" % feedback_state["name"])
		check(feedback.get_global_rect().end.y + 8.0 <= button_row.get_global_rect().position.y + 0.01, "%s retains an eight-pixel gap above the action row" % feedback_state["name"])
		await save_reading_capture(scene, output_dir, feedback_state["name"], {"feedback": feedback.text, "font_size": feedback.get_theme_font_size("font_size"), "tooltip": feedback.tooltip_text, "feedback_rect": str(feedback.get_global_rect()), "action_row_rect": str(button_row.get_global_rect())})
	scene.online_room.clear()
	scene.selected_room = ""
	scene.online_room_edit.text = ""
	scene.online_feedback = ""
	scene.refresh_online_lobby_state()
	await settle()
	check(feedback.text.contains("创建可用") and feedback.text.contains("加入需房号") and feedback.get_theme_font_size("font_size") >= scene.accessibility_font_size(12), "compact empty-room hint distinguishes create and join at the requested accessible size")
	await save_reading_capture(scene, output_dir, "lobby_empty_room", {"feedback": feedback.text, "font_size": feedback.get_theme_font_size("font_size")})


func run() -> void:
	print("=== ui reading evidence smoke START ===")
	if DisplayServer.get_name().to_lower() == "headless":
		quit(1)
		return
	OS.set_environment("YUNZHUO_UI_CAPTURE", "1")
	var viewport_size := Vector2i(960, 540)
	var arguments := OS.get_cmdline_user_args()
	var large_contrast := arguments.size() > 1 and arguments[1] == "large_contrast"
	if not arguments.is_empty():
		var dimensions := arguments[0].split("x")
		if dimensions.size() == 2:
			viewport_size = Vector2i(int(dimensions[0]), int(dimensions[1]))
	DisplayServer.window_set_size(viewport_size)
	root.size = viewport_size
	root.content_scale_size = viewport_size
	var profile_suffix := "_large_contrast" if large_contrast else ""
	var output_dir := ProjectSettings.globalize_path("res://build/qa/reading_evidence_%dx%d%s" % [viewport_size.x, viewport_size.y, profile_suffix])
	check(DirAccess.make_dir_recursive_absolute(output_dir) == OK, "reading evidence directory is writable")
	var scene = load("res://Main.tscn").instantiate()
	scene.music_enabled = false
	scene.sfx_enabled = false
	scene.tts_enabled = false
	scene.voice_enabled = false
	scene.fx_enabled = false
	root.add_child(scene)
	await settle(0.10)
	var snapshot := capture_smoke_state(scene)
	scene.large_text_enabled = large_contrast
	scene.high_contrast_enabled = large_contrast
	await check_rules_reading(scene, output_dir)
	await check_compact_lobby_feedback(scene, output_dir)
	if scene.has_method("shutdown_runtime"):
		scene.shutdown_runtime()
	restore_smoke_state(scene, snapshot)
	scene.queue_free()
	await process_frame
	print("=== RESULT: %s ===" % ("FAIL" if failed else "OK"))
	quit(1 if failed else 0)
