extends "res://scripts/ui_battle_reading_evidence_smoke_test.gd"


func toast_rect_data(control: Control) -> Array:
	var rect := control.get_global_rect()
	return [rect.position.x, rect.position.y, rect.size.x, rect.size.y]


func toast_capture_state(scene: Node) -> Dictionary:
	var state := {"mode": scene.mode, "queue_count": scene.toast_queue_pending_count, "queue_bytes": scene.toast_queue_pending_bytes, "queue_entries": scene.toast_queue.size(), "obstacles": []}
	var toast := scene.toast_current as Control
	if toast == null:
		return state
	state["toast_rect"] = toast_rect_data(toast)
	state["toast_visible"] = toast.is_visible_in_tree()
	state["toast_scale"] = [toast.scale.x, toast.scale.y]
	state["toast_alpha"] = toast.modulate.a
	state["dwell_running"] = scene.toast_tween != null and scene.toast_tween.is_valid() and scene.toast_tween.is_running()
	state["toast_text"] = toast.get_meta("toast_text", "")
	state["surface"] = toast.get_meta("reading_surface_key", "")
	state["full_text_route"] = toast.get_meta("full_text_route", "")
	state["minimum_dwell_msec"] = scene.toast_active_minimum_dwell_msec
	state["detail_open"] = scene.toast_detail_panel != null
	state["safe_layout_waiting"] = toast.get_meta("safe_layout_waiting", false)
	state["pending_layout"] = toast.get_meta("pending_layout", "")
	for node_name in ["ToastMessageLabel", "ToastPendingLabel"]:
		var label := toast.get_node(node_name) as Label
		state[node_name] = {"rect": toast_rect_data(label), "text": label.text, "full_text": label.get_meta("ui_full_text", ""), "tooltip": label.tooltip_text, "font_size": label.get_theme_font_size("font_size"), "minimum_height": label.get_minimum_size().y, "visible": label.is_visible_in_tree(), "native_lines": label.get_line_count(), "visible_lines": label.get_visible_line_count()}
	var detail := toast.get_node("ToastDetailButton") as Button
	state["detail_button_rect"] = toast_rect_data(detail)
	state["detail_button_visible"] = detail.visible
	for obstacle in scene.toast_reading_obstacles():
		var visual: Rect2 = scene.toast_obstacle_rect(obstacle)
		state["obstacles"].append({"name": str(obstacle.name), "rect": [visual.position.x, visual.position.y, visual.size.x, visual.size.y], "host_rect": toast_rect_data(obstacle)})
	var detail_body := scene.find_child("ToastDetailText", true, false) as RichTextLabel
	var detail_scroll := scene.find_child("ToastDetailScroll", true, false) as ScrollContainer
	if detail_body != null and detail_scroll != null:
		state["detail_text"] = detail_body.text
		state["detail_body_rect"] = toast_rect_data(detail_body)
		state["detail_scroll_rect"] = toast_rect_data(detail_scroll)
		state["detail_scroll_value"] = detail_scroll.scroll_vertical
		state["detail_scroll_max"] = detail_scroll.get_v_scroll_bar().max_value
	return state


func check_toast_geometry(scene: Node, context: String) -> void:
	var toast := scene.toast_current as Control
	check(toast != null and toast.is_visible_in_tree(), "%s notice is mounted in a visible safe slot" % context)
	if toast == null:
		return
	check(toast.scale == Vector2.ONE and scene.toast_container.get_global_rect().encloses(toast.get_global_rect()), "%s complete authored surface remains inside the safe container without bounce" % context)
	var inline_shop := bool(toast.get_meta("shop_inline_feedback", false))
	var face := toast.get_node("ToastGptFacePlate") as TextureRect
	check(face != null and face.visible == not inline_shop and face.texture is AtlasTexture and face.texture.atlas == scene.optional_gpt_illustration_texture("settings_readable_gpt"), "%s uses only the existing quiet opaque paper or shop footer" % context)
	var labels: Array[Label] = []
	for node_name in ["ToastMessageLabel", "ToastPendingLabel"]:
		var label := toast.get_node(node_name) as Label
		if not label.visible:
			continue
		labels.append(label)
		var color := label.get_theme_color("font_color")
		check(color.r < 0.25 and color.g < 0.35 and label.get_theme_constant("shadow_offset_x") == 0, "%s %s uses native dark text without a compensating shadow" % [context, node_name])
		check(label.size.y >= label.get_minimum_size().y and label.get_visible_line_count() == 1 and label.get_line_count() == 1, "%s %s retains a complete native line height" % [context, node_name])
		check(toast.get_global_rect().grow(-5.99 if not inline_shop else 0.0).encloses(label.get_global_rect()), "%s %s has a measured six-pixel paper inset" % [context, node_name])
		if node_name == "ToastPendingLabel":
			check(label_text_width(label, label.text) <= label.size.x + 0.1, "%s complete pending count fits its independent native column" % context)
	if labels.size() == 2:
		check(not labels[0].get_global_rect().intersects(labels[1].get_global_rect()), "%s main message and pending state do not overlap" % context)
	var detail := toast.get_node("ToastDetailButton") as Button
	var message := toast.get_node("ToastMessageLabel") as Label
	if detail.visible:
		check(detail.size.x >= 44.0 and detail.size.y >= 44.0 and toast.get_global_rect().grow(-5.99).encloses(detail.get_global_rect()), "%s explicit full-text action retains a complete touch target inside the notice" % context)
		check(not detail.get_global_rect().intersects(message.get_global_rect()), "%s full-text action does not cover the native message" % context)
	else:
		check(label_text_width(message, message.text) <= message.size.x + 0.1, "%s short message is complete without ellipsis" % context)
	if scene.mode == "offline" or scene.mode == "online_game":
		for obstacle in scene.toast_reading_obstacles():
			check(not toast.get_global_rect().intersects(scene.toast_obstacle_rect(obstacle).grow(5.99)), "%s clears %s by at least six pixels" % [context, obstacle.name])
	for retired in ["ToastEntryFeedback", "ToastEntryAckGlyph", "ToastGPTBannerTexture", "ToastMessageRoute", "ToastRewardBridge", "ToastNoticeWaveTexture"]:
		check(toast.find_child(retired, true, false) == null, "%s does not reinstate %s" % [context, retired])


func check_toast_queue_semantics(scene: Node) -> void:
	scene.dismiss_active_toast()
	scene.show_toast("普通通知A", 12000)
	var owner_id: int = scene.toast_current.get_instance_id()
	scene.show_toast("普通通知B", 12000)
	check(scene.toast_current.get_instance_id() == owner_id and scene.toast_queue.size() == 1, "default notifications preserve active dwell and FIFO")
	scene.dismiss_active_toast()
	scene.show_toast("定位旧牌", 12000, "locator")
	owner_id = scene.toast_current.get_instance_id()
	scene.show_toast("操作失败：重要提示", 12000)
	scene.show_toast("任务完成：+30金币", 12000)
	scene.show_toast("定位新牌", 12000, "locator")
	var replacement_id: int = scene.toast_current.get_instance_id()
	check(replacement_id != owner_id and scene.toast_queue.size() == 2 and scene.toast_queue_pending_count == 2, "explicit latest-status replacement preserves queued errors and rewards")
	scene.cleanup_toast_by_id(owner_id, scene.toast_container.get_instance_id())
	check(scene.toast_current.get_instance_id() == replacement_id and scene.toast_container.visible and scene.toast_queue.size() == 2, "stale cleanup cannot dismiss the newer status owner or its important queue")
	scene.dismiss_active_toast()
	scene.show_toast("操作失败：先读此条", 12000, "locator")
	owner_id = scene.toast_current.get_instance_id()
	scene.show_toast("定位旧牌", 12000, "locator")
	scene.show_toast("任务完成：+30金币", 12000)
	scene.show_toast("定位新牌", 12000, "locator")
	check(scene.toast_current.get_instance_id() == owner_id and scene.toast_queue.size() == 2 and not scene.toast_queue_text_index.has("定位旧牌") and scene.toast_queue_text_index.has("定位新牌"), "coalescing replaces only explicitly keyed ordinary queued state, never the active error")
	check(scene.toast_queue_pending_bytes == "任务完成：+30金币".to_utf8_buffer().size() + "定位新牌".to_utf8_buffer().size(), "queued replacement maintains the exact byte and count budgets")
	scene.dismiss_active_toast()
	scene.show_toast("普通通知A", 12000)
	for index in range(scene.TOAST_QUEUE_MAX_ENTRIES):
		scene.show_toast("操作失败：%02d" % index, 12000)
	scene.show_toast("无关状态", 12000, "locator")
	check(scene.toast_queue.size() == scene.TOAST_QUEUE_MAX_ENTRIES and not scene.toast_queue_text_index.has("无关状态"), "ordinary latest-state feedback cannot evict a full important queue")
	check(scene.toast_queue_pending_bytes <= scene.TOAST_QUEUE_MAX_BYTES and scene.toast_queue_pending_count <= scene.TOAST_QUEUE_MAX_ENTRIES * scene.TOAST_QUEUE_MAX_REPEAT_COUNT, "priority retention keeps entry, byte and repeat budgets bounded")
	scene.dismiss_active_toast()
	scene.show_toast("队列占位", 12000)
	for index in range(scene.TOAST_QUEUE_MAX_REPEAT_COUNT + 10):
		scene.enqueue_toast_message("重复通知", 12000)
	check(scene.toast_queue.size() == 1 and scene.toast_queue_pending_count == scene.TOAST_QUEUE_MAX_REPEAT_COUNT, "duplicate accumulation caps repeats without an unbounded queue")
	scene.dismiss_active_toast()
	scene.show_toast("队列占位", 12000)
	for index in range(40):
		scene.enqueue_toast_message("长通知%02d：" % index + "正文".repeat(72), 12000)
	check(scene.toast_queue_pending_bytes <= scene.TOAST_QUEUE_MAX_BYTES and scene.toast_queue.size() <= scene.TOAST_QUEUE_MAX_ENTRIES, "long-message eviction respects the byte budget as well as the entry limit")
	scene.dismiss_active_toast()
	scene.show_toast("首条通知", 12000)
	scene.show_toast("重复通知", 12000)
	scene.show_toast("重复通知", 12000)
	scene.show_toast("最后通知", 12000)
	scene.cleanup_toast_by_id(scene.toast_current.get_instance_id(), scene.toast_container.get_instance_id())
	check(scene.toast_current.get_meta("toast_text", "") == "重复通知（×2）" and scene.toast_queue_pending_count == 1 and scene.toast_queue_pending_bytes == "最后通知".to_utf8_buffer().size(), "FIFO dequeue keeps repeat meaning and exact remaining counters")
	scene.dismiss_active_toast()
	scene.show_toast("定位：1万", 12000, "locator")
	scene.render_game()
	await settle()
	check(scene.toast_current != null and scene.toast_queue.is_empty(), "same-page redraw keeps the ordinary status owner without duplicating the queue")
	check_toast_geometry(scene, "redraw")
	scene.dismiss_active_toast()
	scene.show_toast("同页计时不能被销毁", 100)
	scene.render_game()
	await settle(0.25)
	check(scene.toast_current == null, "same-page redraw cannot kill notification expiry or strand the queue owner")


func check_toast_matrix(scene: Node, output_dir: String) -> void:
	await prepare_offline_reading_fixture(scene)
	scene.toast_container.set_anchors_preset(Control.PRESET_TOP_LEFT)
	scene.toast_container.size = Vector2.ZERO
	scene.show_toast("布局未就绪时保留通知", 1000)
	scene.show_toast("恢复后续通知", 12000)
	var waiting_id: int = scene.toast_current.get_instance_id()
	await settle(1.25)
	check(scene.toast_current.get_instance_id() == waiting_id and not scene.toast_current.visible and not scene.toast_tween.is_running() and scene.toast_queue_pending_count == 1, "zero-sized container safely holds the current notification, dwell and queue without negative rectangles")
	scene.toast_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	scene.apply_safe_area_offsets(scene.toast_container)
	await settle(0.15)
	check(scene.toast_current.get_instance_id() == waiting_id and scene.toast_current.visible and scene.toast_tween.is_running(), "native container resize restores the same notice without per-frame polling")
	await settle(1.25)
	check(scene.toast_current != null and scene.toast_current.get_meta("toast_text", "") == "恢复后续通知" and scene.toast_queue_pending_count == 0, "post-resize dwell completes before the preserved queued successor is promoted")
	scene.dismiss_active_toast()
	await check_toast_queue_semantics(scene)
	var long_text := "检查原因并重试。\n".repeat(17).left(scene.TOAST_MAX_TEXT_LENGTH).strip_edges()
	for entry in [["short_0", "已定位：1万", 0], ["short_1", "已定位：1万", 1], ["short_12", "已定位：1万", 12], ["short_99plus", "已定位：1万", 100], ["long_0", long_text, 0], ["long_99plus", long_text, 100]]:
		scene.dismiss_active_toast()
		scene.show_toast(str(entry[1]), 12000)
		for index in range(int(entry[2])):
			scene.enqueue_toast_message("后续通知", 12000)
		scene.refresh_toast_queue_indicator()
		await settle()
		check_toast_geometry(scene, str(entry[0]))
		if str(entry[0]).begins_with("short_"):
			var message := scene.toast_current.get_node("ToastMessageLabel") as Label
			var full_text_action := scene.toast_current.get_node("ToastDetailButton") as Button
			check(message.text == str(entry[1]) and label_text_width(message, message.text) <= message.size.x + 0.1 and not full_text_action.visible, "%s shows the actual located tile in complete native text without requiring details" % entry[0])
		check(scene.toast_queue_pending_count == int(entry[2]), "%s queue count comes from actual bounded pending entries" % entry[0])
		await save_reading_capture(scene, output_dir, str(entry[0]), toast_capture_state(scene))
	var detail := scene.toast_current.get_node("ToastDetailButton") as Button
	check(detail.visible, "long message exposes an explicit detail action instead of silently truncating its only route")
	await activate_button(detail, "mouse")
	await settle()
	check(scene.toast_detail_panel != null and not scene.toast_tween.is_running() and not scene.game_keyboard_input_allowed(), "explicit notification reading pauses dwell and blocks underlying table keyboard shortcuts")
	var body := scene.find_child("ToastDetailText", true, false) as RichTextLabel
	var scroll := scene.find_child("ToastDetailScroll", true, false) as ScrollContainer
	check(body != null and body.text == long_text and scroll != null and body.fit_content, "native details retain the complete bounded multiline notification")
	var close := scene.find_child("ToastDetailCloseButton", true, false) as Button
	check(close != null and close.get_meta("guofeng_button_face_key", "") == "menu_ink_primary" and close.get_theme_color("font_color").get_luminance() >= 0.70 and close.get_theme_color("font_focus_color").get_luminance() >= 0.70, "notification detail close pairs its actual ink face with legible ivory text in idle and focus states")
	await save_reading_capture(scene, output_dir, "detail_top", toast_capture_state(scene))
	if scroll != null:
		scroll.grab_focus()
		await send_key(KEY_PAGEDOWN, 0)
		check(scroll.scroll_vertical > 0, "native keyboard paging reads full notification text without dispatching a table action")
		await send_key(KEY_HOME, 0)
		check(scroll.scroll_vertical == 0, "notification keyboard Home restores the actual first reading line")
		await send_key(KEY_END, 0)
		check(scroll.scroll_vertical > 0, "notification keyboard End reaches the final reading page")
		await send_key(KEY_TAB, 0)
		check(root.gui_get_focus_owner() == scene.find_child("ToastDetailCloseButton", true, false), "notification reading keeps keyboard navigation inside its explicit modal scope")
	var hand_before: Array = scene.get_self_hand().duplicate()
	await activate_button(scene.hand_tile_button_for_source_index(0), "mouse")
	check(scene.get_self_hand() == hand_before and scene.toast_detail_panel != null, "native reading shield prevents clicks from submitting a hand tile")
	if scroll != null:
		scroll.get_v_scroll_bar().value = scroll.get_v_scroll_bar().max_value
		await settle()
		check(body.get_global_rect().end.y <= scroll.get_global_rect().end.y + 1.0, "notification scroll exposes the actual complete final line")
	await save_reading_capture(scene, output_dir, "detail_end", toast_capture_state(scene))
	await send_key(KEY_ESCAPE, 0)
	check(scene.toast_detail_panel == null and scene.toast_tween.is_running() and root.gui_get_focus_owner() == detail and scene.toast_queue_pending_count == 100, "Esc closes only notification details, resumes dwell and restores the exact invoking action without clearing important queued feedback")
	for modality in ["key", "touch"]:
		await activate_button(detail, modality)
		check(scene.toast_detail_panel != null and not scene.toast_tween.is_running(), "%s can explicitly open full notification text" % modality)
		if scene.toast_detail_panel != null:
			await activate_button(scene.find_child("ToastDetailCloseButton", true, false) as Button, modality)
		check(scene.toast_detail_panel == null, "%s can close native notification reading" % modality)
	scene.dismiss_active_toast()
	scene.show_toast("通知将过期", 100)
	await settle(0.25)
	check(scene.toast_current == null, "reduced-motion ordinary notice expires after its actual dwell")
	scene.show_toast("操作失败：请检查连接", 1)
	scene.show_toast("重要通知之后的消息", 12000)
	await settle(0.35)
	check(scene.toast_current != null and scene.toast_active_minimum_dwell_msec >= 2600, "reduced motion preserves minimum reading dwell for important errors")
	check_toast_geometry(scene, "error_minimum_dwell")
	await save_reading_capture(scene, output_dir, "error_minimum_dwell", toast_capture_state(scene))
	await settle(2.4)
	check(scene.toast_current != null and scene.toast_current.get_meta("toast_text", "") == "重要通知之后的消息" and scene.toast_queue_pending_count == 0, "important minimum dwell completes before its queued successor is promoted")
	scene.dismiss_active_toast()
	scene.reduce_motion_enabled = false
	scene.show_toast("动效采样：提示不穿过顶部事实", 12000)
	var initial_rect: Rect2 = scene.toast_current.get_global_rect()
	for index in range(8):
		await settle(0.04)
		check(scene.toast_current != null and scene.toast_current.get_global_rect() == initial_rect and scene.toast_current.scale == Vector2.ONE, "animation sample %d retains static safe visual bounds" % index)
	check_toast_geometry(scene, "animation_entry")
	await save_reading_capture(scene, output_dir, "animation_entry", toast_capture_state(scene))
	scene.dismiss_active_toast()
	scene.show_toast("动效退场：保持静态边界", 300)
	await settle(0.58)
	check(scene.toast_current != null and scene.toast_current.modulate.a < 1.0 and scene.toast_current.modulate.a > 0.0, "exit animation sample is a real partially visible fading owner")
	if scene.toast_current != null:
		check_toast_geometry(scene, "animation_exit")
		await save_reading_capture(scene, output_dir, "animation_exit", toast_capture_state(scene))
	await settle(0.4)
	check(scene.toast_current == null, "animated notice cleans up after fade without a second duplicated dwell")
	scene.reduce_motion_enabled = true
	scene.settings_panel_open = true
	scene.render_game()
	await settle()
	scene.show_toast("背景音乐已关闭", 12000, "setting_music")
	await settle()
	var held_id: int = scene.toast_current.get_instance_id()
	if scene.toast_current.visible:
		check_toast_geometry(scene, "settings")
	else:
		check(scene.toast_current.get_meta("safe_layout_waiting", false) and not scene.toast_tween.is_running(), "modal with no safe exterior slot holds notification and full dwell instead of obscuring reading or expiring unseen")
	await save_reading_capture(scene, output_dir, "settings", toast_capture_state(scene))
	scene.settings_panel_open = false
	scene.render_game()
	await settle()
	check(scene.toast_current.get_instance_id() == held_id and scene.toast_tween.is_running(), "closing a reading modal restores the same held owner and its complete dwell")
	check_toast_geometry(scene, "settings_released")
	await save_reading_capture(scene, output_dir, "settings_released", toast_capture_state(scene))
	scene.dismiss_active_toast()
	scene.tutorial_step = 0
	scene.show_menu(true)
	await settle()
	scene.show_toast("欢迎入座，请先体验教学", 12000)
	await settle()
	var banner := scene.find_child("MenuTutorialEntryBanner", true, false) as Control
	var title := scene.find_child("MenuTitleLabel", true, false) as Control
	check_toast_geometry(scene, "menu")
	for owner in [banner, title, scene.find_child("MenuTutorialStartButton", true, false) as Control]:
		check(owner == null or not scene.toast_current.get_global_rect().intersects(owner.get_global_rect()), "menu notification preserves the actual title and first-run tutorial lanes")
	await save_reading_capture(scene, output_dir, "menu", toast_capture_state(scene))
	scene.dismiss_active_toast()
	scene.tutorial_step = scene.TUTORIAL_STEP_COMPLETE
	scene._show_shop_screen_impl()
	await settle()
	scene.show_toast("购买成功：获得换牌卡", 12000)
	await settle()
	check_toast_geometry(scene, "shop")
	check(scene.toast_current.get_meta("shop_inline_feedback", false), "shop retains inline feedback instead of floating a notification over currency")
	for owner_name in ["ShopCurrencyValue_coins", "ShopCurrencyValue_gems", "ShopItemsScroll", "ShopCabinetFooterInventoryBadge"]:
		var owner := scene.find_child(owner_name, true, false) as Control
		check(owner != null and not owner.get_global_rect().intersects(scene.toast_current.get_global_rect()), "inline shop feedback preserves %s" % owner_name)
	await save_reading_capture(scene, output_dir, "shop", toast_capture_state(scene))
	scene.show_toast("详情内容\n".repeat(25), 12000)
	scene.dismiss_active_toast()
	scene.show_toast("详情内容\n".repeat(25), 12000)
	scene.open_toast_detail()
	scene.show_menu(true)
	await settle()
	check(scene.toast_current == null and scene.toast_detail_panel == null and scene.toast_queue.is_empty() and not scene.toast_container.visible, "mode change removes both notification and reading modal without a stale focus owner")


func run() -> void:
	print("=== guofeng toast UI smoke START ===")
	if DisplayServer.get_name().to_lower() == "headless":
		quit(1)
		return
	OS.set_environment("YUNZHUO_UI_CAPTURE", "1")
	var arguments := OS.get_cmdline_user_args()
	var viewport_size := Vector2i(1280, 720)
	if not arguments.is_empty():
		var dimensions := arguments[0].split("x")
		viewport_size = Vector2i(int(dimensions[0]), int(dimensions[1]))
	var large_contrast := arguments.size() > 1 and arguments[1] == "large_contrast"
	DisplayServer.window_set_size(viewport_size)
	root.size = viewport_size
	root.content_scale_size = viewport_size
	var capture_root := OS.get_environment("YUNZHUO_GUOFENG_TOAST_CAPTURE_DIR")
	if capture_root.is_empty():
		capture_root = "res://build/qa/guofeng_toast"
	var output_dir := ProjectSettings.globalize_path("%s/%dx%d%s" % [capture_root, viewport_size.x, viewport_size.y, "_large_contrast" if large_contrast else ""])
	check(DirAccess.make_dir_recursive_absolute(output_dir) == OK, "toast capture directory is writable")
	var scene = load("res://Main.tscn").instantiate()
	if scene.get_script() == null:
		check(false, "runtime must compile before toast evidence")
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
	await check_toast_matrix(scene, output_dir)
	scene.dismiss_active_toast()
	scene.shutdown_runtime()
	restore_smoke_state(scene, user_state)
	scene.queue_free()
	await process_frame
	print("=== RESULT: %s ===" % ("FAIL" if failed else "OK"))
	quit(1 if failed else 0)
