extends "res://scripts/ui_reading_evidence_smoke_test.gd"


func achievement_range_state(scene: Node) -> Dictionary:
	var scroll := scene.find_child("AchievementsScroll", true, false) as ScrollContainer
	var status := scene.find_child("AchievementsBrowseStatusLabel", true, false) as Label
	var visible: Array[String] = []
	var readable: Array[String] = []
	for child in scene.find_children("AchievementRow_*", "Control", true, false):
		var row := child as Control
		if row.get_global_rect().intersection(scroll.get_global_rect()).size.y > 1.0:
			visible.append(str(row.name))
		var title := row.find_child("AchievementRowName_*", true, false) as Label
		var title_rect := title.get_global_rect()
		var line_height := minf(title_rect.size.y, title.get_theme_font("font").get_height(title.get_theme_font_size("font_size")))
		var line_rect := Rect2(Vector2(title_rect.position.x, title_rect.get_center().y - line_height * 0.5), Vector2(title_rect.size.x, line_height))
		if scroll.get_global_rect().grow(0.5).encloses(line_rect):
			readable.append(str(row.name))
	var final_row := scene.find_children("AchievementRow_*", "Control", true, false).back() as Control
	return {"status": status.text, "first": status.get_meta("visible_first_item", 0), "last": status.get_meta("visible_last_item", 0), "visible_rows": visible, "readable_title_rows": readable, "scroll_value": scroll.scroll_vertical, "scroll_end": scroll.get_v_scroll_bar().max_value - scroll.get_v_scroll_bar().page, "focused_item": status.get_meta("focused_item", 0), "final_row_fully_visible": final_row.get_global_rect().end.y <= scroll.get_global_rect().end.y + 1.0}


func check_secondary_paper_surface(scene: Node, prefix: String) -> void:
	var paper := scene.find_child(prefix + "GuofengPaperSurface", true, false) as TextureRect
	check(paper != null and paper.texture == scene.optional_gpt_illustration_texture("settings_readable_gpt") and paper.modulate == Color.WHITE, prefix + " uses opaque authored paper")
	var garden := scene.find_child(prefix + "GuofengGardenBackdrop", true, false) as TextureRect
	check(garden != null and garden.texture == scene.optional_gpt_illustration_texture("menu_guofeng_moonlit"), prefix + " uses the shared authored garden")


func check_achievement_range_inputs(scene: Node, output: String) -> void:
	var index := 0
	for key in scene.achievements:
		scene.achievements[key] = index < 5
		index += 1
	scene._show_achievements_screen_impl()
	await settle(0.20)
	check_secondary_paper_surface(scene, "Achievements")
	var scroll := scene.find_child("AchievementsScroll", true, false) as ScrollContainer
	var hit := scene.find_child("AchievementsScrollHitTarget", true, false) as Control
	var state := achievement_range_state(scene)
	check(int(state.first) == 1 and int(state.last) == state.readable_title_rows.size() and int(state.last) < scene.achievements.size() and not state.status.contains("已到末尾"), "first achievement range describes readable titles after VBox sorting")
	if root.size == Vector2i(1280, 720) and not scene.large_text_enabled:
		check(int(state.last) == 5 and state.status.contains("余12"), "the 1280 first page counts five readable titles and excludes the sixth paper sliver")
	await save_reading_capture(scene, output, "achievements_top", state)
	var next_row := scene.find_children("AchievementRow_*", "Control", true, false)[int(state.last)] as Control
	var next_title := next_row.find_child("AchievementRowName_*", true, false) as Label
	var next_index := int(state.last) + 1
	scroll.scroll_vertical += maxi(0, int(ceil(next_title.get_global_rect().end.y - scroll.get_global_rect().end.y))) + 4
	await settle(0.05)
	state = achievement_range_state(scene)
	check(scroll.get_global_rect().grow(0.5).encloses(next_title.get_global_rect()) and int(state.last) >= next_index, "the next item enters the range once its complete title is exposed")
	await save_reading_capture(scene, output, "achievements_title_enters", state)
	hit.grab_focus()
	await send_key(KEY_HOME, 0)
	await send_key(KEY_PAGEDOWN, 0)
	await settle(0.05)
	state = achievement_range_state(scene)
	check(int(state.first) > 1 and int(state.last) - int(state.first) + 1 == state.readable_title_rows.size(), "PageDown updates both ends of the readable title range")
	await save_reading_capture(scene, output, "achievements_page_down", state)
	await send_key(KEY_END, 0)
	await settle(0.05)
	state = achievement_range_state(scene)
	check(int(state.last) == scene.achievements.size() and state.status.contains("余0") and state.status.contains("已到末尾") and not state.status.contains("已完成"), "End reaches the final row and distinguishes reading completion from achievement unlocks")
	await save_reading_capture(scene, output, "achievements_end", state)
	await send_key(KEY_HOME, 0)
	var final_row := scene.find_children("AchievementRow_*", "Control", true, false).back() as Control
	var target := final_row.find_child("AchievementRowFocusTarget", true, false) as Button
	target.grab_focus()
	await settle(0.10)
	state = achievement_range_state(scene)
	check(state.visible_rows.has(str(final_row.name)) and int(state.focused_item) == scene.achievements.size(), "keyboard focus reveals the final row and updates its position")
	check(state.final_row_fully_visible and state.status.contains("已到末尾") and not state.status.contains("尚未读完"), "a fully revealed final row completes reading before the empty safety spacer")
	check((final_row.find_child("AchievementRowFocusMarker", true, false) as Label).visible, "the focused achievement has one native ink marker")
	await save_reading_capture(scene, output, "achievements_focus_last", state)
	# Resize the existing controls, forcing another container sort and cache refresh.
	hit.grab_focus()
	await send_key(KEY_HOME, 0)
	var original_size := root.size
	root.size = original_size - Vector2i(48, 24)
	await settle(0.10)
	state = achievement_range_state(scene)
	check(int(state.last) - int(state.first) + 1 == state.readable_title_rows.size() and int(state.last) < scene.achievements.size(), "resize invalidates the previous title geometry without claiming all items are visible")
	root.size = original_size
	await settle(0.10)


func check_secondary_stats(scene: Node, output: String) -> void:
	scene.game_stats = {"games": 3, "wins": 1, "score": -8800, "best_score": 1200, "total_hands": 18, "fan_total": 12, "by_rule": {"yangzhou": {"games": 3, "wins": 1, "score": -8800, "fan_total": 12, "self_draws": 1}}}
	scene.stats_selected_rule = ""
	scene._show_stats_screen_impl()
	await settle(0.20)
	check_secondary_paper_surface(scene, "Stats")
	check(scene.find_child("StatsSummaryNarrativeBody", true, false) == null, "statistics shows its trend once")
	var score := scene.find_child("StatsRowValueLabel_累计净分", true, false) as Label
	check(score != null and score.get_meta("ui_full_text", "").contains("8800"), "statistics retains the complete negative score")
	await save_reading_capture(scene, output, "stats_overview", {"score": score.text, "summary": (scene.find_child("StatsSummaryValue_best", true, false) as Label).text})
	(scene.find_child("StatsRuleFilterButton", true, false) as Button).pressed.emit()
	await settle(0.20)
	check(scene.stats_selected_rule == "yangzhou" and scene.find_child("StatsRow_累计番数", true, false) != null, "the native statistics filter still opens the actual rule data")
	await save_reading_capture(scene, output, "stats_rule", {"selected_rule": scene.stats_selected_rule})


func lobby_state(scene: Node) -> Dictionary:
	var state := {"feedback": scene.online_feedback, "retry_visible": (scene.find_child("OnlineLobbyConnectionRetryButton", true, false) as Button).visible, "return_disabled": (scene.find_child("OnlineLobbySecondaryReturnButton", true, false) as Button).disabled, "return_modulate": str((scene.find_child("OnlineLobbySecondaryReturnButton", true, false) as Button).modulate)}
	if (scene.find_child("OnlineLobbyRosterPanel", true, false) as Control).visible:
		var log := scene.find_child("OnlineLobbyLogListText", true, false) as RichTextLabel
		var scroll := scene.find_child("OnlineLobbyLogScroll", true, false) as ScrollContainer
		var visible_entries: Array[int] = []
		# This fixture has four single-line entries. Measure native line boxes,
		# independently of the production paragraph-range calculation.
		for index in range(4):
			var line_top := log.get_global_rect().position.y + log.get_line_offset(index)
			if line_top + log.get_line_height(index) > scroll.get_global_rect().position.y + 1.0 and line_top < scroll.get_global_rect().end.y - 1.0:
				visible_entries.append(index + 1)
		state["visible_log_entries"] = visible_entries
		state["log_range"] = (scene.find_child("OnlineLobbyLogRangeLabel", true, false) as Label).text
		state["log_font_size"] = log.get_theme_font_size("normal_font_size")
		state["range_font_size"] = (scene.find_child("OnlineLobbyLogRangeLabel", true, false) as Label).get_theme_font_size("font_size")
		state["roster_name_font_size"] = (scene.find_child("OnlineLobbyRosterName_0", true, false) as Label).get_theme_font_size("font_size")
		state["roster_state_font_size"] = (scene.find_child("OnlineLobbyRosterState_0", true, false) as Label).get_theme_font_size("font_size")
	return state


func check_lobby_roster_readability(scene: Node) -> void:
	var title := scene.find_child("OnlineLobbyTitle", true, false) as Label
	var subtitle := scene.find_child("OnlineLobbySubtitle", true, false) as Label
	var form := scene.find_child("OnlineLobbyFormPanel", true, false) as Control
	check(title != null and subtitle != null and form != null and title.get_global_rect().end.y + 3.5 <= subtitle.get_global_rect().position.y and subtitle.get_global_rect().end.y + 7.5 <= form.get_global_rect().position.y, "lobby title, complete subtitle and form occupy separate native-height rows")
	for node_name in ["OnlineLobbyTitle", "OnlineLobbySubtitle", "OnlineLobbyLogRangeLabel", "OnlineLobbyLogCountLabel"]:
		var label := scene.find_child(node_name, true, false) as Label
		check(label != null and label.size.y >= label.get_minimum_size().y, "%s preserves every native text row" % node_name)
		if label != null:
			for line in label.text.split("\n"):
				check(label_text_width(label, line) <= label.size.x + 0.5, "%s displays its complete factual line %s" % [node_name, line])
	var roster := scene.find_child("OnlineLobbyRosterPanel", true, false) as Control
	var log := scene.find_child("OnlineLobbyLogListPanel", true, false) as Control
	var previous_bottom := 0.0
	for slot in range(4):
		var row := scene.find_child("OnlineLobbyRosterRow_%d" % slot, true, false) as Control
		var name := scene.find_child("OnlineLobbyRosterName_%d" % slot, true, false) as Label
		var state := scene.find_child("OnlineLobbyRosterState_%d" % slot, true, false) as Label
		var target := scene.find_child("OnlineLobbyRosterTouchTarget_%d" % slot, true, false) as Button
		for label in [name, state]:
			check(label.get_theme_font_size("font_size") >= scene.accessibility_font_size(16), "roster %s keeps its readable native font including live refresh" % label.name)
			check(label.size.y + 0.5 >= label.get_minimum_size().y and row.get_global_rect().grow(0.5).encloses(label.get_global_rect()), "roster %s has a complete native line inside its row" % label.name)
		check(label_text_width(state, state.text) <= state.size.x + 0.5, "roster state %d fits its complete short readiness label" % slot)
		check(row.get_global_rect().position.y >= previous_bottom - 0.5 and roster.get_global_rect().grow(0.5).encloses(row.get_global_rect()), "roster row %d has a separate fully bounded reading lane" % slot)
		check(target != null and str(name.get_meta("full_name_route", "")) == str(target.name) and name.tooltip_text == name.text, "roster name %d retains the real full-name detail route" % slot)
		previous_bottom = row.get_global_rect().end.y
	check(previous_bottom + 3.0 <= log.get_global_rect().position.y, "larger roster rows leave a real gutter before room logs")


func check_secondary_lobby(scene: Node, output: String) -> void:
	scene.mode = "menu"
	scene.tcp = StreamPeerTCP.new()
	scene.tcp_status = StreamPeerTCP.STATUS_NONE
	scene.online_waiting_for_server = false
	scene.online_retry_available = false
	scene.online_feedback = ""
	scene.online_player_name = "云桌道友"
	scene.online_connection_host = "127.0.0.1"
	scene.selected_room = ""
	scene._show_online_lobby_impl()
	await settle(0.20)
	check_secondary_paper_surface(scene, "Lobby")
	check(not (scene.find_child("OnlineLobbyConnectionRetryButton", true, false) as Button).visible and scene.find_child("LobbyRoomGateTokenTexture", true, false) == null, "initial lobby has one connect entry and no empty room token")
	for field in ["OnlineLobbyNameEdit", "OnlineLobbyHostEdit", "OnlineLobbyRoomEdit"]:
		var edit := scene.find_child(field, true, false) as LineEdit
		scene.configure_line_edit_input(edit, edit.get_meta("ui_input_field", ""))
		check(not edit.clear_button_enabled and edit.find_child("LobbyFieldPaperFace", true, false) != null, "reapplying input accessibility preserves the single authored clear proxy for " + field)
	var name_clear := scene.find_child("LobbyFieldClearButton_昵称", true, false) as Button
	check(name_clear != null and name_clear.size.x >= 44 and name_clear.size.y >= 44, "lobby clear has a native forty-four-pixel target")
	name_clear.pressed.emit()
	await settle(0.05)
	check(scene.online_name_edit.text.is_empty() and scene.online_name_edit.has_focus() and not name_clear.visible, "clearing the nickname empties the field, removes the icon and restores text focus")
	scene.online_name_edit.text = "云桌道友"
	scene.online_name_edit.text_changed.emit(scene.online_name_edit.text)
	await save_reading_capture(scene, output, "lobby_initial", lobby_state(scene))
	scene.online_feedback = "连接已断开，请重新连接。"
	scene.refresh_online_lobby_state()
	scene.refresh_online_feedback_art()
	await settle(0.15)
	check((scene.find_child("OnlineLobbyConnectionRetryButton", true, false) as Button).visible, "observed disconnection exposes the recovery entry")
	var reason := scene.find_child("OnlineFeedbackReasonAndNextStep", true, false) as Label
	check(reason != null and reason.text.contains("断开") and reason.text.contains("下一步"), "recovery retains its actual cause and next action")
	await save_reading_capture(scene, output, "lobby_recovery", lobby_state(scene))
	scene.tcp = ConnectedLobbyTransport.new()
	scene.tcp_status = StreamPeerTCP.STATUS_CONNECTED
	scene.selected_room = "ROOM7"
	scene.online_room = connected_room_fixture()
	scene.online_feedback = "房间同步完成。"
	scene._show_online_lobby_impl()
	await settle(0.20)
	check(not (scene.find_child("OnlineLobbyConnectionRetryButton", true, false) as Button).visible and (scene.find_child("OnlineLobbyRosterPanel", true, false) as Control).visible, "connected lobby shows current room data and hides retry")
	var connected_state := lobby_state(scene)
	var log := scene.find_child("OnlineLobbyLogListText", true, false) as RichTextLabel
	var log_scroll := scene.find_child("OnlineLobbyLogScroll", true, false) as ScrollContainer
	check(log_scroll.size.y >= log.get_line_height(0), "the lobby viewport can reveal a complete native log line")
	var visible_entries: Array = connected_state.visible_log_entries
	check(not visible_entries.is_empty() and connected_state.log_range.contains("%d-%d/4" % [visible_entries.front(), visible_entries.back()]), "lobby range agrees with the actual visible native log lines")
	check(connected_state.log_font_size >= scene.accessibility_font_size(13) and connected_state.range_font_size >= scene.accessibility_font_size(12) and connected_state.roster_name_font_size >= scene.accessibility_font_size(16) and connected_state.roster_state_font_size >= scene.accessibility_font_size(16), "live lobby refresh preserves accessible roster, log and range font sizes")
	for slot in range(3):
		var name := scene.find_child("OnlineLobbyRosterName_%d" % slot, true, false) as Label
		var next_name := scene.find_child("OnlineLobbyRosterName_%d" % (slot + 1), true, false) as Label
		check(name.get_global_rect().end.y <= next_name.get_global_rect().position.y + 1.0, "accessible roster names occupy separate row lanes")
	check_lobby_roster_readability(scene)
	await save_reading_capture(scene, output, "lobby_connected", connected_state)
	var roster_id: int = scene.find_child("OnlineLobbyRosterPanel", true, false).get_instance_id()
	var full_name := "南山听雨观云道友完整昵称"
	var next_room: Dictionary = scene.online_room.duplicate(true)
	next_room["players"][2]["name"] = full_name
	next_room["players"][2]["ready"] = true
	scene.handle_online_message(JSON.stringify({"type": "roomState", "room": next_room}))
	await settle(0.10)
	check(scene.find_child("OnlineLobbyRosterPanel", true, false).get_instance_id() == roster_id, "changed readiness and long nickname refresh the real roster in place")
	check_lobby_roster_readability(scene)
	check((scene.find_child("OnlineLobbyRosterState_2", true, false) as Label).text.contains("已准备"), "live room readiness changes appear in the readable status column")
	var name_target := scene.find_child("OnlineLobbyRosterTouchTarget_2", true, false) as Button
	await activate_button(name_target, "touch")
	check(scene.toast_detail_panel != null, "the real touch route opens a focused player detail sheet")
	var detail_label := scene.toast_detail_panel.find_child("ToastDetailText", true, false) as RichTextLabel
	check(detail_label.is_visible_in_tree() and detail_label.text == "玩家 3：" + full_name, "the full player identity is visibly presented after the native touch")
	var detail_panel := scene.toast_detail_panel.find_child("ToastDetailPanel", true, false) as Control
	var original_detail_id: int = scene.toast_detail_panel.get_instance_id()
	var detail_close := scene.toast_detail_panel.find_child("ToastDetailCloseButton", true, false) as Button
	check(detail_panel.get_global_rect().encloses(detail_label.get_global_rect()) and detail_close.has_focus() and detail_close.size.x >= 44.0 and detail_close.size.y >= 44.0, "player details keep the complete identity and focused close action within one reading sheet")
	var focus_marker := scene.find_child("OnlineLobbyRosterFocusMarker_2", true, false) as Label
	var focused_name := scene.find_child("OnlineLobbyRosterName_2", true, false) as Label
	check(focus_marker.get_global_rect().end.x <= focused_name.get_global_rect().position.x and name_target.get_node_or_null("ButtonFocusPlate") == null, "the detail target keeps its native marker outside the readable roster text")
	var detail_state := lobby_state(scene)
	detail_state["full_name"] = focused_name.text
	detail_state["detail_text"] = detail_label.text
	detail_state["detail_font_size"] = detail_label.get_theme_font_size("normal_font_size")
	detail_state["detail_kind"] = "focused_reading_sheet"
	var detail_rect: Rect2 = detail_panel.get_global_rect()
	detail_state["detail_rect"] = [detail_rect.position.x, detail_rect.position.y, detail_rect.size.x, detail_rect.size.y]
	detail_state["focus_marker_visible"] = focus_marker.visible
	detail_state["focus_marker_before_name"] = focus_marker.get_global_rect().end.x <= focused_name.get_global_rect().position.x
	await save_reading_capture(scene, output, "lobby_long_name_detail", detail_state)
	scene.show_toast("房间同步提示", 1000)
	check(scene.toast_queue_pending_count == 1 and scene.toast_detail_panel != null and detail_label.text == "玩家 3：" + full_name, "a notice arriving during player details queues without replacing the requested identity")
	await activate_button(detail_close, "touch")
	await settle(0.05)
	var restored_focus := root.gui_get_focus_owner()
	var remaining_title := scene.toast_detail_panel.find_child("ToastDetailTitle", true, false) as Label if scene.toast_detail_panel != null else null
	check(scene.toast_detail_panel == null and name_target.has_focus() and focus_marker.visible, "closing player details restores the originating roster target without changing the room (focus=%s marker=%s original=%s remaining=%s title=%s)" % [restored_focus.name if restored_focus != null else "none", focus_marker.visible, original_detail_id, scene.toast_detail_panel.get_instance_id() if scene.toast_detail_panel != null else 0, remaining_title.text if remaining_title != null else "none"])
	check(scene.toast_current != null and str(scene.toast_current.get_meta("toast_text", "")) == "房间同步提示" and scene.toast_queue_pending_count == 0, "closing a standalone reading sheet resumes its queued notice exactly once")
	scene.dismiss_active_toast()

	var back := scene.find_child("OnlineLobbySecondaryReturnButton", true, false) as Button
	check(not back.disabled and back.modulate == Color.WHITE and back.size.y >= 44, "return remains an opaque native action in a connected room")
	back.pressed.emit()
	await settle(0.10)
	check(scene.mode == "menu", "lobby return navigates to the main menu")


func run() -> void:
	print("=== guofeng secondary pages START ===")
	if DisplayServer.get_name().to_lower() == "headless":
		quit(1)
		return
	OS.set_environment("YUNZHUO_UI_CAPTURE", "1")
	var args := OS.get_cmdline_user_args()
	var dimensions := (args[0] if not args.is_empty() else "960x540").split("x")
	var viewport_size := Vector2i(int(dimensions[0]), int(dimensions[1]))
	var large := args.size() > 1 and args[1] == "large_contrast"
	DisplayServer.window_set_size(viewport_size)
	root.size = viewport_size
	root.content_scale_size = viewport_size
	var capture_root := OS.get_environment("YUNZHUO_GUOFENG_SECONDARY_CAPTURE_DIR")
	if capture_root.is_empty():
		capture_root = "res://build/qa/guofeng_secondary_pages_20261014/interaction"
	var output := ProjectSettings.globalize_path("%s/%dx%d%s" % [capture_root, viewport_size.x, viewport_size.y, "_large_contrast" if large else ""])
	DirAccess.make_dir_recursive_absolute(output)
	var scene = load("res://Main.tscn").instantiate()
	if scene.get_script() == null:
		check(false, "the actual runtime must compile")
		scene.free()
		quit(1)
		return
	root.add_child(scene)
	await settle(0.10)
	var snapshot := capture_smoke_state(scene)
	scene.set_process(false)
	scene.music_enabled = false
	scene.sfx_enabled = false
	scene.tts_enabled = false
	scene.fx_enabled = false
	scene.reduce_motion_enabled = true
	scene.large_text_enabled = large
	scene.high_contrast_enabled = large
	scene.tutorial_step = scene.TUTORIAL_STEP_COMPLETE
	await check_rules_reading(scene, output)
	await check_achievement_range_inputs(scene, output)
	await check_secondary_stats(scene, output)
	await check_secondary_lobby(scene, output)
	scene.shutdown_runtime()
	restore_smoke_state(scene, snapshot)
	scene.queue_free()
	await process_frame
	print("=== RESULT: %s ===" % ("FAIL" if failed else "OK"))
	quit(1 if failed else 0)
