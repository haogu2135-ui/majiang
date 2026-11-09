extends "res://scripts/ui_reading_evidence_smoke_test.gd"


func reading_node(scene: Node, node_name: String) -> Control:
	var node := scene.find_child(node_name, true, false) as Control
	check(node != null, "native reading/control exists: " + node_name)
	return node


func check_paper(scene: Node, node_name: String) -> void:
	var paper := reading_node(scene, node_name) as TextureRect
	if paper == null:
		return
	var texture := paper.texture
	if texture is AtlasTexture:
		texture = (texture as AtlasTexture).atlas
	check(texture == scene.optional_gpt_illustration_texture("settings_readable_gpt") and paper.modulate == Color.WHITE, node_name + " uses fully opaque authored paper")


func check_reading_lanes(scene: Node, panel_name: String, names: Array) -> void:
	var panel := reading_node(scene, panel_name)
	if panel == null:
		return
	var previous: Control = null
	for node_name in names:
		var node := reading_node(scene, str(node_name))
		if node == null or not node.is_visible_in_tree():
			continue
		check(panel.get_global_rect().grow(1.0).encloses(node.get_global_rect()), str(node_name) + " stays on its paper")
		if previous != null:
			check(previous.get_global_rect().end.y + 1.0 <= node.get_global_rect().position.y, str(previous.name) + " clears " + str(node_name))
		if node is Label:
			var label := node as Label
			var font := label.get_theme_font("font")
			check(label.size.y + 0.5 >= font.get_height(label.get_theme_font_size("font_size")), str(node_name) + " reserves a complete native font line")
			if label.autowrap_mode == TextServer.AUTOWRAP_OFF:
				check(label_text_width(label, label.text) <= label.size.x + 1.0, str(node_name) + " exposes its complete visible text")
		previous = node


func auxiliary_capture(scene: Node, output: String, name: String, state: Dictionary = {}) -> void:
	var labels := {}
	for node in scene.find_children("*", "Label", true, false):
		var label := node as Label
		if label.is_visible_in_tree():
			var rect := label.get_global_rect()
			labels[str(label.name)] = {"text": label.text, "rect": [rect.position.x, rect.position.y, rect.size.x, rect.size.y], "font_size": label.get_theme_font_size("font_size"), "color": label.get_theme_color("font_color").to_html()}
	state["native_labels"] = labels
	await save_reading_capture(scene, output, name, state)


func check_daily(scene: Node, output: String) -> void:
	scene.last_login_date = Time.get_date_string_from_system()
	scene.login_reward_claimed_date = ""
	scene.consecutive_login_days = 5
	scene.show_daily_login_panel({"consecutive_days": 5, "claimed_today": false})
	await settle(0.15)
	check_paper(scene, "DailyLoginGuofengPaperSurface")
	for day in range(1, 8):
		check_reading_lanes(scene, "DailyLoginDayNode_%d" % day, ["DailyLoginDayLabel_%d" % day, "DailyLoginDayStateLabel_%d" % day, "DailyLoginRewardLabel_%d" % day])
		var target := reading_node(scene, "DailyLoginDayDetailProxy_%d" % day)
		check(target != null and target.size.x >= 44 and target.size.y >= 44, "daily detail has a native touch target")
	check_reading_lanes(scene, "DailyLoginPanel", ["DailyLoginDayIndicators", "DailyLoginRewardPanel", "DailyLoginProgressPanel", "DailyLoginClaimButton", "DailyLoginForecastPanel"])
	check_reading_lanes(scene, "DailyLoginRewardPanel", ["DailyLoginCurrentRewardLabel", "DailyLoginRewardTextLabel"])
	check_reading_lanes(scene, "DailyLoginForecastPanel", ["DailyLoginForecastTitle", "DailyLoginForecastBody"])
	await auxiliary_capture(scene, output, "daily_available", {"claim_state": "available", "day": 5})
	var before_coins := int(scene.currency.get("coins", 0))
	var claim := reading_node(scene, "DailyLoginClaimButton") as Button
	await activate_button(claim, "mouse")
	await settle(0.10)
	check(int(scene.currency.get("coins", 0)) == before_coins + 100 and claim.disabled and claim.text == "已领取", "native daily claim credits exactly one reward and shows its disabled state")
	var disabled_ink := claim.get_theme_color("font_disabled_color")
	check(disabled_ink.r > 0.75 and disabled_ink.g > 0.75 and disabled_ink.b > 0.65, "claimed action keeps readable ivory text on its ink face")
	claim.pressed.emit()
	check(int(scene.currency.get("coins", 0)) == before_coins + 100, "the claim guard prevents a second credit")
	check_reading_lanes(scene, "DailyLoginPanel", ["DailyLoginClaimButton", "DailyLoginClaimedStatusSurface", "DailyLoginForecastPanel"])
	if scene.toast_current != null and scene.toast_current.is_visible_in_tree():
		for obstacle in scene.toast_reading_obstacles():
			check(not scene.toast_current.get_global_rect().intersects(scene.toast_obstacle_rect(obstacle).grow(5.99)), "claim feedback clears the native reading lane " + str(obstacle.name))
	var progress_rect := reading_node(scene, "DailyLoginProgressPanel").get_global_rect()
	var toast := scene.toast_current as Control
	var toast_visible := toast != null and toast.is_visible_in_tree()
	var toast_rect := toast.get_global_rect() if toast_visible else Rect2()
	await auxiliary_capture(scene, output, "daily_claimed", {"claim_state": "claimed", "coins_added": int(scene.currency.get("coins", 0)) - before_coins, "toast_visible": toast_visible, "toast_rect": [toast_rect.position.x, toast_rect.position.y, toast_rect.size.x, toast_rect.size.y], "progress_rect": [progress_rect.position.x, progress_rect.position.y, progress_rect.size.x, progress_rect.size.y]})


func check_loading(scene: Node, output: String) -> void:
	scene.show_loading_screen({"status": "正在同步牌局资源", "progress_ratio": 0.43, "tip": "提示：注意观察对手弃牌，判断危险牌"})
	await settle(0.10)
	check_paper(scene, "LoadingCenterPanel")
	check_reading_lanes(scene, "LoadingCenterPanel", ["LoadingTitleLabel", "LoadingSubtitleLabel", "LoadingShuffleArt", "LoadingStatusLabel", "LoadingProgressFeedback", "LoadingTipLabel", "LoadingVersionLabel"])
	var fill := reading_node(scene, "LoadingProgressFill")
	check(absf(fill.anchor_right - 0.43) < 0.001, "loading bitmap progress equals the real forty-three-percent state")
	var loading_paper := reading_node(scene, "LoadingCenterPanel")
	if scene.toast_current != null and is_instance_valid(scene.toast_current) and scene.toast_current.visible:
		check(not scene.toast_current.get_global_rect().intersects(loading_paper.get_global_rect()), "queued feedback clears the loading reading surface")
	await auxiliary_capture(scene, output, "loading_progress", {"progress_ratio": 0.43})
	scene.show_loading_screen({"status": "资源读取失败，请检查网络后重试", "progress_ratio": -1.0, "error": true})
	await settle(0.10)
	var retry := scene.find_child("LoadingRetryButton", true, false) as Button
	var back := scene.find_child("LoadingReturnButton", true, false) as Button
	check(retry != null and back != null and retry.size.y >= 44 and back.size.y >= 44, "loading failure keeps two real recovery actions")
	await auxiliary_capture(scene, output, "loading_error", {"error": true})
	if back != null:
		await activate_button(back, "touch")
		await settle(0.10)
		check(scene.mode == "menu", "native loading return restores the menu")


func check_exit(scene: Node, output: String) -> void:
	scene.start_offline(true)
	await settle(0.20)
	scene.show_exit_confirm()
	await settle(0.10)
	check_paper(scene, "ExitConfirmDialog")
	check_reading_lanes(scene, "ExitConfirmDialog", ["ExitConfirmTitle", "ExitConfirmMessage", "ExitConfirmSaveStatus", "ExitConfirmContinueButton"])
	var keep := reading_node(scene, "ExitConfirmContinueButton") as Button
	var leave := reading_node(scene, "ExitConfirmLeaveButton") as Button
	check(keep.has_focus() and keep.size.y >= 44 and leave.size.y >= 44, "exit opens on the safe native decision with two full targets")
	await auxiliary_capture(scene, output, "exit_confirm", {"safe_focus": keep.has_focus(), "mode": scene.mode})
	await activate_button(keep, "touch")
	await settle(0.25)
	check(scene.mode == "offline" and scene.exit_confirm_panel == null, "native continue closes the modal and retains the live game")
	scene.show_exit_confirm()
	await settle(0.20)
	leave = reading_node(scene, "ExitConfirmLeaveButton") as Button
	await activate_button(leave, "key")
	await settle(0.25)
	check(scene.mode == "menu" and scene.offline_progress_last_save_ok, "native exit saves the actual game before returning to the menu")


func check_update(scene: Node, output: String) -> void:
	scene.show_menu(true)
	scene.update_state = "downloading"
	scene.update_message = "远端版本 v1.0.181 · 当前版本 v1.0.180"
	scene.update_remote_version = "1.0.181"
	scene.update_downloaded_bytes = 430
	scene.update_total_bytes = 1000
	scene.update_release_notes = "改进国风页面、牌局操作与文字可读性。\n".repeat(24) + "发布说明最后一行。"
	scene.ensure_update_dialog()
	await settle(0.20)
	check_paper(scene, "UpdateDialogPanel")
	check_reading_lanes(scene, "UpdateDialogPanel", ["UpdateDialogTitle", "UpdateStatusLabel", "UpdateProgressGptTrack", "UpdateProgressLabel", "UpdateDialogStageMap", "UpdateReleaseNotesArt", "UpdateDialogButtonRow"])
	var primary := reading_node(scene, "UpdatePrimaryButton") as Button
	check(primary.disabled and primary.text == "下载中", "update downloading state explains the unavailable primary action")
	var disabled_ink := primary.get_theme_color("font_disabled_color")
	check(disabled_ink.r > 0.75 and disabled_ink.g > 0.75 and disabled_ink.b > 0.65, "disabled update action keeps readable ivory text on its ink face")
	await auxiliary_capture(scene, output, "update_downloading", {"state": "downloading", "progress_ratio": 0.43})
	var hit := reading_node(scene, "UpdateReleaseNotesScrollHitTarget")
	var scroll := reading_node(scene, "UpdateReleaseNotesScroll") as ScrollContainer
	hit.grab_focus()
	await send_key(KEY_END, 0)
	await settle(0.05)
	check(scroll.scroll_vertical >= scroll.get_v_scroll_bar().max_value - scroll.get_v_scroll_bar().page - 1.0, "native End reaches the complete release notes")
	var notes := reading_node(scene, "UpdateReleaseNotesLabel") as Label
	var notes_rect := notes.get_global_rect()
	var scroll_rect := scroll.get_global_rect()
	check(notes_rect.end.y <= scroll_rect.end.y + 1.0 and notes_rect.end.y > scroll_rect.position.y + notes.get_theme_font("font").get_height(notes.get_theme_font_size("font_size")), "the final complete release-note line remains inside the native viewport")
	await auxiliary_capture(scene, output, "update_notes_end", {"state": "downloading", "notes_end": true, "scroll_value": scroll.scroll_vertical, "notes_rect": [notes_rect.position.x, notes_rect.position.y, notes_rect.size.x, notes_rect.size.y], "scroll_rect": [scroll_rect.position.x, scroll_rect.position.y, scroll_rect.size.x, scroll_rect.size.y]})
	scene.update_release_notes = "改善页面文字。"
	scene.refresh_update_dialog()
	await settle(0.10)
	var short_status := reading_node(scene, "UpdateReleaseNotesStatus") as Label
	check(short_status.text.contains("已全部显示") and not short_status.text.contains("阅读0%") and not short_status.tooltip_text.contains("进度0%"), "one-screen release notes expose a consistent fully-visible state")
	scene.update_state = "error"
	scene.update_message = "更新服务器暂时不可用，请稍后重试。"
	scene.refresh_update_dialog()
	await settle(0.10)
	check(not primary.disabled and primary.text == "重试", "update failure exposes a usable retry command")
	await auxiliary_capture(scene, output, "update_error", {"state": "error"})
	await activate_button(reading_node(scene, "UpdateSecondaryButton") as Button, "keyboard")
	await settle(0.10)
	check(scene.update_dialog == null, "native update close restores the underlying page")


func check_diagnostic(scene: Node, output: String) -> void:
	var lines: Array = ["【本地诊断报告】", "✓ 音频设备已连接", "⚠ 当前网络连接需要重试"]
	for index in range(24):
		lines.append("诊断第%d项：原生文本换行后仍可读，复制操作保留完整报告。" % (index + 1))
	lines.append("诊断报告最后一行。")
	scene.show_diagnostic_dialog(lines)
	await settle(0.20)
	check_paper(scene, "DiagnosticDialogPanel")
	check_reading_lanes(scene, "DiagnosticDialogPanel", ["DiagnosticDialogTitle", "DiagnosticPrimarySummary", "DiagnosticContentScroll", "DiagnosticContentStatusLabel", "DiagnosticCopyButton"])
	var diagnostic_scroll := reading_node(scene, "DiagnosticContentScroll") as ScrollContainer
	var visible_rows: Array[int] = []
	for index in range(lines.size()):
		var row := reading_node(scene, "DiagnosticContentLine_%02d" % index)
		if diagnostic_scroll.get_global_rect().grow(0.5).encloses(row.get_global_rect()):
			visible_rows.append(index + 1)
	var range_text := (reading_node(scene, "DiagnosticContentStatusLabel") as Label).text
	check(not visible_rows.is_empty() and range_text.contains("%d-%d" % [visible_rows.front(), visible_rows.back()]), "diagnostic range matches the actual complete native rows")
	await auxiliary_capture(scene, output, "diagnostic_top", {"lines": lines.size(), "visible_rows": visible_rows, "range_text": range_text})
	var scroll := reading_node(scene, "DiagnosticContentScroll") as ScrollContainer
	scroll.grab_focus()
	await send_key(KEY_END, 0)
	await settle(0.05)
	await activate_button(reading_node(scene, "DiagnosticCopyButton") as Button, "touch")
	check(DisplayServer.clipboard_get().contains("诊断报告最后一行。"), "native copy retains the complete diagnostic report")
	var feedback := reading_node(scene, "DiagnosticCopyFeedbackLabel") as Label
	check(feedback.text == "已复制%d行" % lines.size() and label_text_width(feedback, feedback.text) <= feedback.size.x and feedback.size.y >= feedback.get_theme_font("font").get_height(feedback.get_theme_font_size("font_size")), "touch copy exposes its complete persistent success state at the native font size")
	check(feedback.tooltip_text == "复制结果：已复制 %d 行诊断内容" % lines.size() and str(feedback.get_meta("accessible_name", "")) == feedback.tooltip_text and str(feedback.get_meta("full_feedback_text", "")) == feedback.tooltip_text, "compact copy feedback retains the complete line count for assistive reading")
	await auxiliary_capture(scene, output, "diagnostic_end", {"lines": lines.size(), "copied_complete": true, "copy_feedback": feedback.text, "copy_feedback_complete": true, "scroll_value": scroll.scroll_vertical})
	await activate_button(reading_node(scene, "DiagnosticCloseButton") as Button, "keyboard")
	await settle(0.10)
	scene.show_diagnostic_dialog(lines)
	await settle(0.10)
	feedback = reading_node(scene, "DiagnosticCopyFeedbackLabel") as Label
	check(feedback.text == "已复制%d行" % lines.size() and label_text_width(feedback, feedback.text) <= feedback.size.x, "reopening diagnostics preserves the complete compact copy result")
	await activate_button(reading_node(scene, "DiagnosticCloseButton") as Button, "key")
	await settle(0.10)


func check_privacy(scene: Node, output: String) -> void:
	scene.show_menu(true)
	scene.toggle_settings_panel()
	await settle(0.10)
	scene.telemetry_consent = false
	scene.telemetry_consent_decided = false
	scene.telemetry_outbox = []
	scene.telemetry_event_sequence = 0
	scene.show_telemetry_data_sheet()
	await settle(0.15)
	check_paper(scene, "TelemetryDataSheetCard")
	check_reading_lanes(scene, "TelemetryDataSheetCard", ["TelemetryDataSheetTitle", "TelemetryDataBodyScroll", "TelemetryDataStatus", "TelemetryPermissionSummary", "TelemetryConsentButton", "TelemetryClearConfirmHint", "TelemetryExportStatus", "TelemetryDataSheetCloseButton"])
	var background_close := reading_node(scene, "SettingsCloseButton")
	check(not background_close.is_visible_in_tree(), "privacy sheet hides the locked background exit")
	var empty_clear := reading_node(scene, "TelemetryClearButton") as Button
	check(empty_clear.disabled and (reading_node(scene, "TelemetryClearConfirmHint") as Label).text.contains("暂无本地诊断数据"), "empty privacy state explains its unavailable clear action")
	await auxiliary_capture(scene, output, "privacy_default", {"consent": false})
	await activate_button(reading_node(scene, "TelemetryConsentButton") as Button, "mouse")
	await settle(0.15)
	check(scene.telemetry_consent, "native privacy consent changes the actual state")
	check((reading_node(scene, "TelemetryConsentButton") as Button).text.contains("清空"), "revocation visibly explains the loss of existing queued diagnostics before activation")
	await auxiliary_capture(scene, output, "privacy_consented", {"consent": true})
	await activate_button(reading_node(scene, "TelemetryExportButton") as Button, "touch")
	await settle(0.10)
	check(DisplayServer.clipboard_get().contains("events"), "native privacy export copies the diagnostic data")
	await auxiliary_capture(scene, output, "privacy_exported", {"exported": true})
	await activate_button(reading_node(scene, "TelemetryClearButton") as Button, "keyboard")
	await settle(0.10)
	check(scene.telemetry_clear_confirming, "the first native clear opens confirmation")
	await auxiliary_capture(scene, output, "privacy_clear_confirm", {"confirming": true})
	await activate_button(reading_node(scene, "TelemetryDataSheetCloseButton") as Button, "keyboard")
	await settle(0.10)
	scene.close_settings_panel()


func native_archive_range(scene: Node) -> Dictionary:
	var scroll := reading_node(scene, "ReplayArchiveScroll") as ScrollContainer
	var list := reading_node(scene, "ReplayArchiveList") as VBoxContainer
	var count := reading_node(scene, "ReplayArchiveCount") as Label
	var visible_rows: Array[int] = []
	var row_count := 0
	for child in list.get_children():
		var row := child as Control
		if row == null or not str(row.name).begins_with("ReplayArchiveRow_"):
			continue
		row_count += 1
		if row.get_global_rect().intersection(scroll.get_global_rect()).size.y > 0.01:
			visible_rows.append(row_count)
	check(row_count > 0 and not visible_rows.is_empty() and count.text == "显示 %d-%d/%d 条" % [visible_rows.front(), visible_rows.back(), row_count], "archive range matches the actual sorted native rows without a manual refresh")
	return {"archive_visible_rows": visible_rows, "archive_range_text": count.text, "archive_total": row_count}


func check_replay(scene: Node, output: String) -> void:
	scene.replay_archive = []
	for index in range(3):
		var round_id := "AUX-ARCHIVE-%d" % index
		var events: Array = valid_replay_events(scene, round_id)
		var entry := {"round_id": round_id, "rule_variant": "yangzhou", "result_kind": "win", "summary": "回放%d" % index, "seed": index + 1, "events": events, "replay_digest": scene.round_replay_digest(events), "saved_at": index + 1, "archived_at": index + 1, "favorite": false, "source": "local"}
		scene.replay_archive.append(scene.normalize_replay_archive_entry(entry))
	scene.replay_archive_generation += 1
	scene.replay_search_query = ""
	scene.show_replay_import_screen(true)
	await settle(0.15)
	check_paper(scene, "ReplayGuofengPaperSurface")
	var archive_scroll := reading_node(scene, "ReplayArchiveScroll") as ScrollContainer
	var archive_rows := scene.find_children("ReplayArchiveRow_*", "Control", true, false)
	if scene.ui_is_compact() and archive_rows.size() >= 2:
		var first_row := archive_rows[0] as Control
		var next_row := archive_rows[1] as Control
		if archive_scroll.size.y + 0.5 >= first_row.size.y:
			check(archive_scroll.get_global_rect().grow(1.0).encloses(first_row.get_global_rect()) and next_row.get_global_rect().position.y >= archive_scroll.get_global_rect().end.y - 0.5, "compact archive initially shows a complete row without clipping the next")
	var search := reading_node(scene, "ReplayArchiveSearchInput") as LineEdit
	check(search.get_theme_font_size("font_size") >= (18 if scene.large_text_enabled else 14) and search.size.y >= 44.0, "archive search inherits the native readable font profile and full touch height")
	check_reading_lanes(scene, "ReplayImportPanel", ["ReplayImportTitle", "ReplayImportInputLabel", "ReplayImportCodeInput", "ReplayImportStatus", "ReplayImportCodeSummary", "ReplayArchivePane"])
	await auxiliary_capture(scene, output, "replay_empty", {"events": 0})
	scene.active_round_id = "AUXILIARY-REPLAY"
	scene.round_event_history.clear()
	scene.round_event_sequence = 0
	scene.record_round_event("round_start", {"dealer": 0})
	for index in range(40):
		scene.record_round_event("draw", {"seat": index % 4})
		scene.record_round_event("discard", {"seat": index % 4, "tile": "3W"})
	var code: String = scene.round_replay_share_code()
	scene.set_replay_import_input_text(code)
	await activate_button(reading_node(scene, "ReplayImportButton") as Button, "touch")
	await settle(0.20)
	var list := reading_node(scene, "ReplayImportEventList") as VBoxContainer
	check(list.get_child_count() == 81 and not (reading_node(scene, "ReplayImportCodeInput") as LineEdit).clear_button_enabled, "native import verifies all events and keeps one explicit clear action")
	var archive_state := native_archive_range(scene)
	archive_state["events"] = list.get_child_count()
	await auxiliary_capture(scene, output, "replay_verified", archive_state)
	var last := list.get_child(list.get_child_count() - 1) as Button
	last.grab_focus()
	await settle(0.10)
	var scroll := reading_node(scene, "ReplayImportTimelineScroll") as ScrollContainer
	check(last.get_global_rect().end.y <= scroll.get_global_rect().end.y + 1.0 and int(scene.replay_timeline_selected_index) == 80, "native focus reveals the final replay event and retains its selected index")
	var visible_rows: Array[int] = []
	for index in range(list.get_child_count()):
		var row := list.get_child(index) as Control
		if row.get_global_rect().intersection(scroll.get_global_rect()).size.y > 0.01:
			visible_rows.append(index + 1)
	var range_text := (reading_node(scene, "ReplayImportTimelinePosition") as Label).text
	check(not visible_rows.is_empty() and range_text.contains("显示 %d-%d /" % [visible_rows.front(), visible_rows.back()]), "replay range follows the actual native rows after focus scroll without a manual refresh")
	var end_state := {"events": list.get_child_count(), "selected_index": scene.replay_timeline_selected_index, "scroll_value": scroll.scroll_vertical, "last_row_top": last.get_global_rect().position.y, "last_row_bottom": last.get_global_rect().end.y, "viewport_bottom": scroll.get_global_rect().end.y, "visible_rows": visible_rows, "range_text": range_text}
	end_state.merge(native_archive_range(scene))
	await auxiliary_capture(scene, output, "replay_end", end_state)
	await activate_button(reading_node(scene, "ReplayImportCopyCodeButton") as Button, "mouse")
	check(DisplayServer.clipboard_get() == code, "native replay copy retains the exact complete verified code")


func check_replay_resize(scene: Node) -> void:
	if root.size != Vector2i(960, 540):
		return
	DisplayServer.window_set_size(Vector2i(1280, 720))
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1280, 720)
	await settle(0.20)
	var wide_scroll := scene.find_child("ReplayArchiveScroll", true, false) as ScrollContainer
	check(not scene.ui_is_compact() and wide_scroll != null and is_zero_approx(wide_scroll.offset_bottom), "replay archive restores its full viewport after resizing to desktop")
	DisplayServer.window_set_size(Vector2i(960, 540))
	root.size = Vector2i(960, 540)
	root.content_scale_size = Vector2i(960, 540)
	await settle(0.20)
	var compact_scroll := scene.find_child("ReplayArchiveScroll", true, false) as ScrollContainer
	var compact_rows := scene.find_children("ReplayArchiveRow_*", "Control", true, false)
	if compact_scroll != null:
		compact_scroll.scroll_vertical = 0
		await settle()
	var first := compact_rows[0] as Control if compact_rows.size() >= 2 else null
	var next := compact_rows[1] as Control if compact_rows.size() >= 2 else null
	check(scene.ui_is_compact() and compact_scroll != null and first != null and next != null and compact_scroll.get_global_rect().grow(1.0).encloses(first.get_global_rect()) and next.get_global_rect().position.y >= compact_scroll.get_global_rect().end.y - 0.5, "replay archive restores a complete first row without clipping the next after resizing back")


func run() -> void:
	print("=== guofeng auxiliary START ===")
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
	var capture_root := OS.get_environment("YUNZHUO_GUOFENG_AUXILIARY_CAPTURE_DIR")
	if capture_root.is_empty():
		capture_root = "res://build/qa/guofeng_auxiliary_20261014/development"
	var output := ProjectSettings.globalize_path("%s/%dx%d%s" % [capture_root, viewport_size.x, viewport_size.y, "_large_contrast" if large else ""])
	DirAccess.make_dir_recursive_absolute(output)
	var scene = load("res://Main.tscn").instantiate()
	if scene.get_script() == null:
		check(false, "actual runtime compiles")
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
	await check_daily(scene, output)
	await check_loading(scene, output)
	await check_exit(scene, output)
	await check_update(scene, output)
	await check_diagnostic(scene, output)
	await check_privacy(scene, output)
	await check_replay(scene, output)
	await check_replay_resize(scene)
	scene.shutdown_runtime()
	restore_smoke_state(scene, snapshot)
	scene.queue_free()
	await process_frame
	print("=== RESULT: %s ===" % ("FAIL" if failed else "OK"))
	quit(1 if failed else 0)
