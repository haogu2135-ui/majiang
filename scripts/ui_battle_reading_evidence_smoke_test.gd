extends "res://scripts/ui_reading_evidence_smoke_test.gd"


func prepare_offline_reading_fixture(scene: Node) -> void:
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.offline_turn_needs_draw = false
	scene.offline_self_draw_ready.clear()
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.offline_ai_active = false
	scene.offline_ai_run_queued = false
	scene.offline_sim_quiet = false
	scene.offline_pending_claim.clear()
	scene.offline_claim_discard_bans.clear()
	scene.offline_passed_win_tiles.clear()
	scene.settings_panel_open = false
	scene.chat_panel_open = false
	scene.advisor_detail_open = false
	scene.table_log_archive_open = false
	scene.clear_pending_danger_discard()
	scene.players = []
	for seat in range(4):
		scene.players.append({"name": "座位%d" % seat, "hand": [], "discards": [], "melds": [], "flowers": 0, "flower_tiles": [], "score": 25000, "bot": seat != 0})
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "2T", "3T", "4T", "7B", "8B", "9B", "E", "E"]
	scene.wall = scene.make_wall()
	scene.last_discard = ""
	scene.last_discard_seat = -1
	scene.current_human_advice.clear()
	scene.clear_ai_report_cache()
	scene.ai_assist_enabled = true
	scene.render_game()
	await settle(0.08)


func check_table_reading(scene: Node, output_dir: String) -> void:
	await prepare_offline_reading_fixture(scene)
	# This reading fixture must overflow on a fresh 1920px profile too. Do not
	# depend on persisted round-history rows to create the native scroll range.
	scene.round_history.clear()
	var logs: Array[String] = []
	for event_index in range(20):
		logs.append("事件%02d：%s" % [event_index, "玩家摸牌、出牌后等待下一家行动；点击历史可以读取完整的牌桌记录。".repeat(3)])
	scene.table_logs = logs
	check(scene.commit_discard(0, "9B"), "ledger fixture records a real production discard event")
	scene.render_game()
	await settle(0.08)
	var compact := root.size.y <= 560
	var title := scene.find_child("TableLogLedgerTitle", true, false) as Label
	var count := scene.find_child("TableLogLedgerCount", true, false) as Label
	var latest := scene.find_child("TableLogLedgerBody_0", true, false) as Label
	check(title != null and count != null and latest != null, "table ledger exposes a header and the latest-event text")
	if title != null and count != null and latest != null:
		var wide := root.size.x >= 1600 and root.size.y >= 900
		check(title.get_theme_font_size("font_size") >= scene.accessibility_font_size(10 if compact else 12) and count.get_theme_font_size("font_size") >= scene.accessibility_font_size(8 if compact else 10), "ledger header preserves the requested accessible font sizes")
		check(latest.get_theme_font_size("font_size") >= scene.accessibility_font_size(11 if compact else 10), "ledger latest event preserves the requested accessible font size")
		if wide:
			check(title.get_theme_font_size("font_size") >= scene.accessibility_font_size(16) and count.get_theme_font_size("font_size") >= scene.accessibility_font_size(14) and latest.get_theme_font_size("font_size") >= scene.accessibility_font_size(15), "wide ledger uses readable title, count and latest-event sizes")
		for label in [title, count, latest]:
			check(label.get_theme_color("font_color").get_luminance() < 0.3, "ledger %s uses dark ink on its paper surface" % label.name)
		check(latest.text == scene.table_log_display_text(scene.table_logs.back()), "ledger latest-event row shows the latest event rather than a single-line merge of older events")
		check(latest.size.y >= latest.get_minimum_size().y and title.get_global_rect().end.y + 2.0 <= latest.get_global_rect().position.y and count.get_global_rect().end.y + 2.0 <= latest.get_global_rect().position.y, "ledger latest event has a complete line below its header")
	await save_reading_capture(scene, output_dir, "table_ledger", {"latest_event": scene.table_logs.back(), "visible_event": latest.text if latest != null else "", "latest_font_size": latest.get_theme_font_size("font_size") if latest != null else 0})
	var archive_button := scene.find_child("TableLogArchiveButton", true, false) as Button
	var hand_before: Array = scene.get_self_hand().duplicate()
	await activate_button(archive_button, "mouse")
	await settle(0.08)
	var archive := scene.find_child("TableLogArchivePanel", true, false) as Control
	var archive_title := scene.find_child("TableLogArchiveTitle", true, false) as Label
	var archive_scroll := scene.find_child("TableLogArchiveScroll", true, false) as ScrollContainer
	var archive_close := scene.find_child("TableLogArchiveCloseButton", true, false) as Button
	check(scene.table_log_archive_open and archive != null and archive_scroll != null and archive_close != null and archive_close.has_focus() and scene.get_self_hand() == hand_before, "mouse history action opens a read-only focused archive without discarding")
	if archive_scroll != null and archive_title != null and archive_close != null:
		check(archive_title.get_theme_font_size("font_size") >= scene.accessibility_font_size(16), "archive title preserves its accessible size")
		check(archive_title.get_global_rect().end.y + 4.0 <= archive_scroll.get_global_rect().position.y and archive_close.get_global_rect().end.y + 4.0 <= archive_scroll.get_global_rect().position.y, "archive scroll clears the full title and close-button header")
		var scrollbar := archive_scroll.get_v_scroll_bar()
		check(scrollbar.max_value > scrollbar.page, "archive has a real scroll range for long records")
		var last_row := scene.find_child("TableLogArchiveRow_%d" % (scene.table_logs.size() - 1), true, false) as Label
		check(last_row != null and last_row.text.contains(scene.table_log_display_text(scene.table_logs.back())) and last_row.get_global_rect().end.y <= archive_scroll.get_global_rect().end.y + 1.0, "archive initially reaches the complete latest event")
		await save_reading_capture(scene, output_dir, "table_archive_end", {"scroll_value": scrollbar.value, "scroll_range": scrollbar.max_value - scrollbar.page, "latest_row_rect": advisor_reading_rect(last_row), "scroll_rect": advisor_reading_rect(archive_scroll)})
		scrollbar.value = 0.0
		await settle()
		await send_wheel_down(archive_scroll.get_global_rect().get_center())
		check(scrollbar.value > 0.0, "real wheel input advances the archive reading position")
		await save_reading_capture(scene, output_dir, "table_archive_scrolled", {"scroll_value": scrollbar.value})
		# Exercise a navigation event while the production initial-follow chain is
		# queued, so a late reflow cannot pull a reader back to the tail.
		scene.scroll_table_log_archive_to_end()
		archive_scroll.grab_focus()
		await send_key(KEY_HOME, 0)
		await settle(0.08)
		check(not bool(archive_scroll.get_meta("initial_tail_follow", true)) and scrollbar.value <= 1.0, "native Home cancels queued initial-tail following and preserves the reader's position")
	await send_key(KEY_ESCAPE, 0)
	await settle(0.08)
	check(not scene.table_log_archive_open and scene.get_self_hand() == hand_before, "Esc closes the archive without changing the hand")
	await prepare_offline_reading_fixture(scene)
	set_offline_pending_claim_fixture(scene, "peng")
	await settle()
	var pending_ledger := scene.find_child("TableLogLedgerPanel", true, false) as Control
	check(pending_ledger != null and not pending_ledger.is_visible_in_tree(), "pending-response context suppresses the secondary ledger")
	await save_reading_capture(scene, output_dir, "table_pending", {"phase": scene.offline_phase})


func advisor_reading_rect(control: Control) -> Array:
	var bounds := control.get_global_rect()
	return [bounds.position.x, bounds.position.y, bounds.size.x, bounds.size.y]


func advisor_reading_state(scene: Node, extra: Dictionary = {}) -> Dictionary:
	var state := extra.duplicate(true)
	var compact := scene.find_child("AdvisorPanel", true, false) as Control
	var detail := scene.find_child("AdvisorDetailPanel", true, false) as Control
	state["advisor_surface"] = compact.get_meta("guofeng_surface_key", "") if compact != null else ""
	state["compact_visible"] = compact != null and compact.is_visible_in_tree()
	state["compact_layout_mode"] = compact.get_meta("advisor_layout_mode", "") if compact != null else ""
	state["cards"] = []
	var conclusion := scene.find_child("AdvisorPanelTitle", true, false) as Label
	var context := scene.find_child("AdvisorPanelContext", true, false) as Label
	state["compact_conclusion"] = conclusion.text if conclusion != null else ""
	state["compact_context"] = context.text if context != null else ""
	state["compact_context_full"] = context.get_meta("ui_full_text", "") if context != null else ""
	if compact != null:
		for card in compact.get_children():
			if not str(card.name).begins_with("AdvisorInfoCard_"):
				continue
			var heading := card.find_child("AdvisorCardHeading_*", true, false) as Label
			var primary := card.find_child("AdvisorCardPrimary_*", true, false) as Label
			var secondary := card.find_child("AdvisorCardSecondary_*", true, false) as Label
			state["cards"].append({"heading": heading.text, "primary": primary.text, "primary_full": primary.get_meta("ui_full_text", ""), "primary_line_count": primary.get_line_count(), "primary_visible_lines": primary.get_visible_line_count(), "primary_wrap_mode": primary.autowrap_mode, "primary_font_size": primary.get_theme_font_size("font_size"), "secondary_font_size": secondary.get_theme_font_size("font_size"), "heading_font_size": heading.get_theme_font_size("font_size"), "secondary": secondary.text, "secondary_full": secondary.get_meta("ui_full_text", ""), "secondary_tooltip": secondary.tooltip_text, "rect": advisor_reading_rect(card), "primary_rect": advisor_reading_rect(primary), "secondary_rect": advisor_reading_rect(secondary), "visual_descendants": card.find_children("*", "TextureRect", true, false).size()})
	if detail != null:
		var text := detail.find_child("AdvisorDetailText", true, false) as RichTextLabel
		var hint := detail.find_child("AdvisorDetailHint", true, false) as Label
		var scroll := detail.find_child("AdvisorDetailScroll", true, false) as ScrollContainer
		state["detail_surface"] = detail.get_meta("guofeng_surface_key", "")
		state["detail_text"] = text.get_parsed_text()
		state["detail_source"] = scene.advisor_detail_text()
		state["detail_tooltip"] = text.tooltip_text
		state["detail_fields"] = text.get_meta("advisor_structured_fields", [])
		state["detail_hint"] = hint.text
		state["detail_rect"] = advisor_reading_rect(detail)
		state["body_rect"] = advisor_reading_rect(scroll)
		state["reading_value"] = scroll.get_v_scroll_bar().value
		state["reading_range"] = maxf(0.0, scroll.get_v_scroll_bar().max_value - scroll.get_v_scroll_bar().page)
	return state


func check_advisor_paper_cards(scene: Node) -> void:
	var panel := scene.find_child("AdvisorPanel", true, false) as Control
	var paper := scene.find_child("AdvisorPanelPaper", true, false) as TextureRect
	var context := scene.find_child("AdvisorPanelContext", true, false) as Label
	var detail_button := scene.find_child("AdvisorDetailButton", true, false) as Button
	check(panel != null and paper != null and context != null and detail_button != null, "advisor exposes one paper, native context and its real detail action")
	if panel == null or paper == null or context == null or detail_button == null:
		return
	check(panel.get_meta("guofeng_surface_key", "") == "settings_readable_gpt" and paper.modulate == Color.WHITE and paper.self_modulate == Color.WHITE, "advisor uses unchanged opaque authored paper rather than tinted visual stacks")
	check(paper.texture is AtlasTexture and (paper.texture as AtlasTexture).atlas == scene.optional_gpt_illustration_texture("settings_readable_gpt"), "advisor paper crops the registered opaque readable bitmap")
	check(detail_button.size.x >= 44.0 and detail_button.size.y >= 44.0 and panel.get_global_rect().encloses(detail_button.get_global_rect()), "advisor detail action has a bounded native forty-four-pixel hit target")
	var panel_id := panel.get_instance_id()
	var payloads: Array = scene.advisor_panel_card_payloads()
	scene.refresh_advisor_panel_cards(panel)
	check(panel.get_instance_id() == panel_id, "advisor refresh retains the actual reading surface")
	if panel.get_meta("advisor_layout_mode", "") == "detail_only":
		var conclusion := panel.find_child("AdvisorPanelTitle", true, false) as Label
		check(conclusion != null and conclusion.text == scene.advisor_narrow_conclusion_text(), "occupied advisor channel shows its live hand state instead of a generic heading")
		if conclusion != null:
			check(conclusion.get_theme_font_size("font_size") >= scene.accessibility_font_size(16) and label_text_width(conclusion, conclusion.text) <= conclusion.size.x + 0.5 and conclusion.size.y >= conclusion.get_minimum_size().y, "narrow advisor displays its entire state at the accessible font size")
			check(panel.get_global_rect().grow(0.5).encloses(conclusion.get_global_rect()) and not conclusion.get_global_rect().intersects(detail_button.get_global_rect()), "narrow conclusion clears its real analysis button")
			check(conclusion.get_meta("ui_full_text", "") == scene.advisor_compact_conclusion_text() and context.get_meta("ui_full_text", "") == scene.advisor_detail_text(), "narrow state preserves the current complete conclusion and analysis on its real detail route")
		return
	if panel.get_meta("advisor_layout_mode", "") == "compact_summary":
		var conclusion := panel.find_child("AdvisorPanelTitle", true, false) as Label
		check(conclusion != null and panel.find_children("AdvisorInfoCard_*", "", true, false).is_empty(), "default advisor owns one conclusion instead of three resident analysis cards")
		if conclusion != null:
			check(conclusion.get_theme_font_size("font_size") >= scene.accessibility_font_size(16) and context.get_theme_font_size("font_size") >= scene.accessibility_font_size(13), "compact conclusion and evidence preserve their accessible font sizes")
			for label in [conclusion, context]:
				check(panel.get_global_rect().grow(0.5).encloses(label.get_global_rect()) and not label.get_global_rect().intersects(detail_button.get_global_rect()) and label.size.y >= label.get_minimum_size().y, "compact native text has a complete measured lane beside the real detail action")
			check(not conclusion.get_global_rect().intersects(context.get_global_rect()) and context.get_meta("ui_full_text", "") == scene.advisor_detail_text(), "summary retains the entire current analysis behind its real detail route without text overlap")
		return
	for payload in payloads:
		var heading := str(payload["heading"])
		var card := panel.find_child("AdvisorInfoCard_%s" % heading, true, false) as Control
		check(card != null, "advisor keeps the real %s conclusion lane" % heading)
		if card == null:
			continue
		var heading_label := card.find_child("AdvisorCardHeading_*", true, false) as Label
		var primary := card.find_child("AdvisorCardPrimary_*", true, false) as Label
		var secondary := card.find_child("AdvisorCardSecondary_*", true, false) as Label
		check(heading_label != null and primary != null and secondary != null, "advisor %s has three native text roles" % heading)
		if heading_label == null or primary == null or secondary == null:
			continue
		check(card.find_children("*", "TextureRect", true, false).is_empty(), "advisor %s has no fake meter or decorative texture behind its text" % heading)
		if panel.get_meta("advisor_layout_mode", "") == "sidebar":
			check(card.get_global_rect().position.x >= maxf(context.get_global_rect().end.x, detail_button.get_global_rect().end.x) + 5.5, "advisor %s keeps a six-pixel horizontal gap after the native sidebar" % heading)
		else:
			check(card.get_global_rect().position.y >= maxf(context.get_global_rect().end.y, detail_button.get_global_rect().end.y) + 5.5, "advisor %s keeps a six-pixel gap below header text and the real button hit lane" % heading)
		for label in [heading_label, primary, secondary]:
			check(card.get_global_rect().grow(0.5).encloses(label.get_global_rect()), "advisor %s bounds %s inside its actual card" % [heading, label.name])
			check(label.get_theme_font_size("font_size") >= scene.accessibility_font_size(16 if label == primary else (14 if label == secondary else 12)), "advisor %s preserves %s accessible font size" % [heading, label.name])
			var color: Color = label.get_theme_color("font_color")
			check(color.r <= 0.25 and color.g <= 0.35 and color.b <= 0.30 and label.get_theme_constant("outline_size") == 0, "advisor %s reads in native dark ink without outlined duplicate text" % label.name)
		check(heading_label.get_global_rect().end.y <= primary.get_global_rect().position.y and primary.get_global_rect().end.y <= secondary.get_global_rect().position.y, "advisor %s separates heading, conclusion and evidence by full text rows" % heading)
		check(primary.text.replace("\n", "").replace("·", "").replace(" ", "") == str(payload["main"]).replace(" · ", "") and primary.tooltip_text == str(payload["main"]), "advisor %s preserves both primary clauses without changing the AI conclusion" % heading)
		check(primary.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART and primary.get_line_count() == primary.text.split("\n").size() and primary.get_visible_line_count() == primary.get_line_count(), "advisor %s shapes and displays every conclusion line after shared UI contract passes" % heading)
		for primary_line in primary.text.split("\n"):
			check(primary.get_theme_font("font").get_string_size(primary_line, HORIZONTAL_ALIGNMENT_LEFT, -1, primary.get_theme_font_size("font_size")).x <= primary.size.x + 0.5, "advisor %s fully fits its core conclusion line %s" % [heading, primary_line])
		var full_evidence := str(payload["sub"]) if str(payload["sub"]) != "" else "暂无"
		check(secondary.size.y >= secondary.get_theme_font("font").get_height(secondary.get_theme_font_size("font_size")) and secondary.tooltip_text == full_evidence and str(secondary.get_meta("ui_full_text", "")) == full_evidence, "advisor %s keeps a complete evidence row and its entire live detail text" % heading)
		if full_evidence == "防守待评估":
			check(secondary.text == "待评估" and secondary.get_line_count() == 1 and label_text_width(secondary, secondary.text) <= secondary.size.x, "pending defense reads as a complete short state without an orphan character")
		if payload.has("summary"):
			check(secondary.text == str(payload["summary"]) and secondary.get_line_count() == secondary.text.split("\n").size() and secondary.get_visible_line_count() == secondary.get_line_count(), "advisor statistics keep each count and unit on a complete visible row")
			for summary_line in secondary.text.split("\n"):
				check(secondary.get_theme_font("font").get_string_size(summary_line, HORIZONTAL_ALIGNMENT_LEFT, -1, secondary.get_theme_font_size("font_size")).x <= secondary.size.x + 0.5, "advisor statistics fit the real card width without splitting a number from its unit")


func check_advisor_restriction_reading(scene: Node, output_dir: String) -> void:
	await prepare_offline_reading_fixture(scene)
	scene.players[0]["hand"] = ["1T", "2T", "3T", "4T", "5T", "6T", "7B", "8B", "9B", "E", "E", "4W", "5W", "9T"]
	for restricted in [true, false]:
		scene.players[0]["discards"] = ["6W"] if restricted else ["N"]
		scene.wall = scene.make_wall()
		for tile in scene.players[0]["hand"] + scene.players[0]["discards"]:
			scene.wall.erase(str(tile))
		scene.wall.resize(64)
		scene.clear_ai_report_cache()
		var reports: Array = scene.get_ai_discard_reports(0)
		var candidate_index := -1
		for index in range(reports.size()):
			if str(reports[index].get("tile", "")) == "9T":
				candidate_index = index
		check(candidate_index >= 0, "restriction fixture has a real nine-bamboo discard analysis")
		if candidate_index < 0:
			continue
		var candidate: Dictionary = reports[candidate_index]
		check(int(candidate.get("shanten", 8)) == 0 and bool(candidate.get("wait_discard_furiten", false)) == restricted, "the actual ready-hand analysis independently establishes the expected ron restriction")
		reports.remove_at(candidate_index)
		reports.push_front(candidate)
		scene.current_human_advice = reports
		scene.ai_advice_hand_signature = scene.hand_identity_fingerprint(scene.get_self_hand())
		if restricted:
			scene.render_game()
		else:
			scene.refresh_ai_advisor_panel()
		await settle()
		check_advisor_paper_cards(scene)
		var primary := scene.find_child("AdvisorPanelTitle", true, false) as Label
		check(primary != null and primary.text.contains("仅自摸") == restricted and primary.get_visible_line_count() == primary.get_line_count(), "the real primary conclusion shows the full self-draw-only limit and removes it on a clean live refresh")
		check(scene.advisor_detail_text().contains("整手所有听口均仅可自摸，不可接炮") == restricted, "the full rationale agrees with the visible restriction without losing its explanation")
		await save_reading_capture(scene, output_dir, "advisor_restricted" if restricted else "advisor_unrestricted", advisor_reading_state(scene, {"restricted": restricted, "candidate_tile": "9T"}))


func check_advisor_live_refresh(scene: Node, reports: Array) -> void:
	check(reports.size() > 1, "advisor has a real alternate report for delayed-result refresh coverage")
	if reports.size() <= 1:
		return
	var original_advice: Array = scene.current_human_advice.duplicate(true)
	var original_signature: String = scene.ai_advice_hand_signature
	var delayed_advice := reports.duplicate(true)
	var first_report = delayed_advice[0]
	delayed_advice[0] = delayed_advice[1]
	delayed_advice[1] = first_report
	var detail := scene.find_child("AdvisorDetailPanel", true, false) as Control
	var text := scene.find_child("AdvisorDetailText", true, false) as RichTextLabel
	var recommendation := scene.find_child("AdvisorDetailRecommendedTileButton", true, false) as Button
	var scroll := scene.find_child("AdvisorDetailScroll", true, false) as ScrollContainer
	var hand_before: Array = scene.get_self_hand().duplicate()
	scroll.grab_focus()
	scene.current_human_advice = delayed_advice
	scene.ai_advice_hand_signature = scene.hand_identity_fingerprint(hand_before)
	scene.refresh_ai_advisor_panel()
	await settle()
	var expected_tile := str(delayed_advice[0]["tile"])
	var expected_index: int = scene.hand_tile_index_for_advice(hand_before, expected_tile)
	check(detail == scene.find_child("AdvisorDetailPanel", true, false) and recommendation == scene.find_child("AdvisorDetailRecommendedTileButton", true, false) and scroll.has_focus(), "delayed advisor results update the actual modal in place without stealing reading focus")
	check(text.get_parsed_text() == scene.advisor_detail_text() and recommendation.get_meta("advisor_recommended_tile", "") == expected_tile and recommendation.get_meta("advisor_recommended_index", -1) == expected_index, "delayed advisor body and native locator describe the same current report")
	await activate_button(recommendation, "touch")
	await settle()
	check(scene.hand_keyboard_selection == expected_index and scene.get_self_hand() == hand_before and scene.advisor_detail_open and not scene.has_pending_danger_discard(), "the refreshed native locator selects the delayed recommendation without submitting it")
	text = scene.find_child("AdvisorDetailText", true, false) as RichTextLabel
	recommendation = scene.find_child("AdvisorDetailRecommendedTileButton", true, false) as Button
	scene.current_human_advice = original_advice
	scene.ai_advice_hand_signature = original_signature
	scene.refresh_ai_advisor_panel()
	await settle()
	check(text.get_parsed_text() == scene.advisor_detail_text() and recommendation.get_meta("advisor_recommended_tile", "") == str(reports[0]["tile"]), "restoring the original report updates both full rationale and locator without a stale callback")


func check_advisor_reading(scene: Node, output_dir: String) -> void:
	await check_advisor_restriction_reading(scene, output_dir)
	await prepare_offline_reading_fixture(scene)
	# Read all three compact cards in a genuinely available channel. Full-wall
	# and occupied-meld opener behavior is exercised by the battle input gate.
	scene.wall.resize(64)
	scene.show_hand_hint = true
	scene.tutorial_step = scene.TUTORIAL_STEP_DISCARD
	scene.render_game()
	await settle()
	check_advisor_paper_cards(scene)
	var reports: Array = scene.ai_discard_reports_for_render().duplicate(true)
	check(not reports.is_empty(), "advisor uses actual AI discard reports for the live hand")
	var expected_index: int = scene.hand_tile_index_for_advice(scene.get_self_hand(), str(reports[0].get("tile", ""))) if not reports.is_empty() else -1
	var advisor_button := scene.find_child("AdvisorDetailButton", true, false) as Button
	check(advisor_button != null and not advisor_button.disabled, "advisor has a real detail action")
	var hand_before: Array = scene.get_self_hand().duplicate()
	await activate_button(advisor_button, "mouse")
	await settle(0.08)
	var title := scene.find_child("AdvisorDetailTitle", true, false) as Label
	var context := scene.find_child("AdvisorDetailContext", true, false) as Label
	var recommendation := scene.find_child("AdvisorDetailRecommendedTileButton", true, false) as Button
	var close := scene.find_child("AdvisorDetailCloseButton", true, false) as Button
	var scroll := scene.find_child("AdvisorDetailScroll", true, false) as ScrollContainer
	var compact := scene.find_child("AdvisorPanel", true, false) as Control
	var detail_panel := scene.find_child("AdvisorDetailPanel", true, false) as Control
	var hint := scene.find_child("AdvisorDetailHint", true, false) as Label
	var detail_paper := scene.find_child("AdvisorDetailPaper", true, false) as TextureRect
	var tutorial_prompt := scene.find_child("HandTrayTutorialHint", true, false) as Control
	var tutorial_action := scene.find_child("HandTutorialSkipButton", true, false) as Button
	var tutorial_dock := scene.find_child("ActionButtonDock", true, false) as Control
	check(tutorial_prompt != null and tutorial_prompt.is_visible_in_tree() and tutorial_action != null and tutorial_dock != null and not tutorial_prompt.get_global_rect().grow(-0.5).intersects(tutorial_dock.get_global_rect().grow(-0.5)), "advisor detail keeps the visible tutorial clear of the action dock")
	check(scene.advisor_detail_open and close != null and close.has_focus() and scene.get_self_hand() == hand_before, "detail opens with real close focus and a read-only hand")
	check(compact != null and not compact.is_visible_in_tree() and detail_paper != null, "detail becomes the single visible advisor owner while the compact instance stays mounted")
	if title != null and context != null and recommendation != null and close != null and scroll != null and detail_panel != null and hint != null:
		check(title.size.y >= title.get_minimum_size().y and context.size.y >= context.get_minimum_size().y and title.get_global_rect().end.y + 2.0 <= context.get_global_rect().position.y, "advisor title and context occupy separate complete font-height rows")
		check(recommendation.size.y >= 44.0 and close.size.y >= 44.0 and recommendation.get_global_rect().end.y + 4.0 <= scroll.get_global_rect().position.y and context.get_global_rect().end.y + 4.0 <= scroll.get_global_rect().position.y, "advisor native actions and full context clear the actual body without a fake route")
		check(recommendation.get_theme_font_size("font_size") >= scene.accessibility_font_size(10), "recommended action preserves the requested accessible font size")
		var dock := scene.find_child("ActionButtonDock", true, false) as Control
		var hand := scene.find_child("HandTray", true, false) as Control
		check(dock != null and hand != null and detail_panel.get_global_rect().end.y + 6.0 <= dock.get_global_rect().position.y and not detail_panel.get_global_rect().intersects(hand.get_global_rect()), "advisor expanded reading surface clears the real action dock and hand tray")
		var text := scene.find_child("AdvisorDetailText", true, false) as RichTextLabel
		check(text != null and text.get_parsed_text() == scene.advisor_detail_text() and text.tooltip_text == scene.advisor_detail_text() and text.get_theme_font_size("normal_font_size") >= scene.accessibility_font_size(13), "advisor structured body retains the exact full rationale and requested font size")
		check(text != null and text.fit_content and not text.scroll_active and text.size.x <= scroll.size.x and text.get_meta("advisor_structured_fields", []).has("振听限制"), "advisor uses the actual native wrapping width and keeps the real self-draw-only restriction")
		await activate_button(scene.hand_tile_button_for_source_index(0), "mouse")
		await settle()
		check(scene.advisor_detail_open and scene.get_self_hand() == hand_before and not scene.has_pending_danger_discard(), "the native read-only modal shield prevents a table click from submitting a hand tile")
		await check_advisor_live_refresh(scene, reports)
		recommendation = scene.find_child("AdvisorDetailRecommendedTileButton", true, false) as Button
		close = scene.find_child("AdvisorDetailCloseButton", true, false) as Button
		scroll = scene.find_child("AdvisorDetailScroll", true, false) as ScrollContainer
		hint = scene.find_child("AdvisorDetailHint", true, false) as Label
		text = scene.find_child("AdvisorDetailText", true, false) as RichTextLabel
		tutorial_prompt = scene.find_child("HandTrayTutorialHint", true, false) as Control
		check(tutorial_prompt != null and tutorial_prompt.is_visible_in_tree(), "advisor capture retains the visible tutorial after live refresh")
		await save_reading_capture(scene, output_dir, "advisor_top", advisor_reading_state(scene, {"recommendation": recommendation.tooltip_text, "scroll_value": scroll.get_v_scroll_bar().value, "tutorial_visible": tutorial_prompt != null and tutorial_prompt.is_visible_in_tree()}))
		var scrollbar := scroll.get_v_scroll_bar()
		scrollbar.value = scrollbar.max_value
		await settle()
		check(text != null and text.get_global_rect().end.y <= scroll.get_global_rect().end.y + 1.0, "advisor body can reach its complete final line")
		check(hint.text.begins_with("已到底"), "advisor last reading position has an accurate native end hint")
		await save_reading_capture(scene, output_dir, "advisor_end", advisor_reading_state(scene, {"scroll_value": scrollbar.value, "scroll_range": scrollbar.max_value - scrollbar.page}))
		await activate_button(recommendation, "touch")
		await settle()
		check(scene.advisor_detail_open and scene.get_self_hand() == hand_before and not scene.has_pending_danger_discard(), "touch recommendation locates a tile without discarding or opening danger confirmation")
		var modal_focus := scene.get_viewport().gui_get_focus_owner() as Control
		var advisor_panel := scene.find_child("AdvisorDetailPanel", true, false) as Control
		check(modal_focus != null and advisor_panel != null and advisor_panel.is_ancestor_of(modal_focus), "locating a recommendation retains keyboard focus inside the read-only detail modal (focus=%s)" % (modal_focus.name if modal_focus != null else "none"))
		await save_reading_capture(scene, output_dir, "advisor_located", advisor_reading_state(scene, {"expected_index": expected_index, "selected_index": scene.hand_keyboard_selection, "focused_control": str(modal_focus.name) if modal_focus != null else ""}))
	await send_key(KEY_ESCAPE, 0)
	await settle(0.08)
	check(not scene.advisor_detail_open and scene.get_self_hand() == hand_before, "Esc closes advisor details without changing the hand")
	var focus := scene.get_viewport().gui_get_focus_owner() as Control
	check(expected_index >= 0 and focus != null and focus == scene.hand_tile_button_for_source_index(expected_index), "closing a located recommendation restores the exact AI-recommended hand-tile focus")
	await save_reading_capture(scene, output_dir, "advisor_restored", advisor_reading_state(scene, {"expected_index": expected_index, "selected_index": scene.hand_keyboard_selection, "focused_control": str(focus.name) if focus != null else "", "focused_hand_source_index": focus.get_parent().get_meta("hand_source_index", -1) if focus != null else -1}))
	await prepare_offline_reading_fixture(scene)
	scene.current_seat = 1
	scene.render_game()
	await settle()
	var pending_hand: Array = scene.get_self_hand().duplicate()
	await activate_button(scene.find_child("AdvisorDetailButton", true, false) as Button, "mouse")
	await settle()
	var unavailable := scene.find_child("AdvisorDetailRecommendedTileButton", true, false) as Button
	check(unavailable != null and unavailable.disabled and unavailable.text == "暂无推荐", "other-player-turn analysis exposes an explicitly disabled no-recommendation action")
	await save_reading_capture(scene, output_dir, "advisor_no_recommendation", advisor_reading_state(scene, {"phase": scene.offline_phase, "recommendation_disabled": unavailable.disabled if unavailable != null else false}))
	await send_key(KEY_ESCAPE, 0)
	await settle(0.08)
	check(not scene.advisor_detail_open and scene.get_self_hand() == pending_hand and not scene.has_pending_danger_discard(), "closing no-recommendation analysis preserves the other-player-turn hand")


func check_chat_reading(scene: Node, output_dir: String) -> void:
	scene.tcp = ConnectedLobbyTransport.new()
	scene.mode = "online_game"
	scene.online_game = online_pending_game_fixture()
	scene.online_game["phase"] = "awaitDiscard"
	scene.online_game["pending"] = {}
	scene.online_waiting_for_server = false
	scene.online_resume_pending = false
	scene.online_feedback = ""
	scene.online_last_chat_sent_msec = 0
	scene.sent_hello = true
	scene.chat_panel_open = false
	scene.show_hand_hint = true
	scene.tutorial_step = scene.TUTORIAL_STEP_DISCARD
	var messages: Array[String] = []
	for message_index in range(20):
		messages.append("云桌道友：消息%02d，点击聊天可查看完整记录，输入文字后发送给当前房间。" % message_index)
	scene.chat_messages = messages
	scene.render_game()
	await settle(0.08)
	var chat_button := scene.find_child("ChatActionButton", true, false) as Button
	await activate_button(chat_button, "mouse")
	await settle(0.08)
	var panel := scene.find_child("ChatPanel", true, false) as Control
	var quick_title := scene.find_child("ChatPanelQuickMessagesLabel", true, false) as Label
	var quick_row := scene.find_child("ChatPanelQuickMessages", true, false) as Control
	var custom_title := scene.find_child("ChatPanelCustomMessageLabel", true, false) as Label
	var close := scene.find_child("ChatPanelCloseButton", true, false) as Button
	var send := scene.find_child("ChatSendButton", true, false) as Button
	var history := scene.find_child("ChatPanelTableLogButton", true, false) as Button
	var scroll := scene.find_child("ChatPanelMessageScroll", true, false) as ScrollContainer
	var tutorial_prompt := scene.find_child("HandTrayTutorialHint", true, false) as Control
	var tutorial_action := scene.find_child("HandTutorialSkipButton", true, false) as Button
	check(tutorial_prompt != null and tutorial_prompt.is_visible_in_tree() and tutorial_action != null and chat_button != null and not tutorial_prompt.get_global_rect().grow(-0.5).intersects(chat_button.get_global_rect().grow(-0.5)), "open chat keeps the visible tutorial clear of the chat entry")
	check(scene.chat_panel_open and panel != null and close != null and close.has_focus(), "chat opens through its real button with close focus")
	var initial_body := scene.find_child("ChatPanelBodyScroll", true, false) as ScrollContainer
	var latest_preview := scene.find_child("ChatPanelLatestPreview", true, false) as Label
	var message_text := scene.find_child("ChatPanelMessageText", true, false) as Label
	var range_label := scene.find_child("ChatPanelMessageRangeLabel", true, false) as Label
	check(initial_body != null and latest_preview != null and latest_preview.text == str(scene.chat_messages.back()) and initial_body.get_global_rect().grow(0.5).encloses(latest_preview.get_global_rect()) and scene.chat_input != null and send != null and initial_body.get_global_rect().grow(0.5).encloses(scene.chat_input.get_global_rect()) and initial_body.get_global_rect().grow(0.5).encloses(send.get_global_rect()), "chat opens with the latest message preview and complete input and send controls visible")
	for paper_label in [message_text, range_label, quick_title, custom_title]:
		check(paper_label != null and paper_label.get_theme_color("font_color").get_luminance() < 0.3, "chat paper reading label uses a dark, legible ink color")
	var legacy_art := scene.find_child("ChatPanelArt", true, false) as Control
	var count_badge := scene.find_child("ChatPanelCountBadge", true, false) as Control
	check(legacy_art != null and not legacy_art.is_visible_in_tree() and count_badge != null and count_badge.is_visible_in_tree(), "chat keeps the message count while fixed-position legacy art stays out of the scrolling reading lanes")

	check(quick_title != null and quick_row != null and custom_title != null and scene.chat_input != null and send != null and scroll != null and history != null, "chat exposes every reading and composing lane")
	if quick_title != null and quick_row != null and custom_title != null and scene.chat_input != null and close != null and send != null and scroll != null and history != null:
		check(quick_title.size.y >= quick_title.get_minimum_size().y and quick_title.get_global_rect().end.y + 2.0 <= quick_row.get_global_rect().position.y, "quick-message title has a complete line above its actions")
		check(custom_title.size.y >= custom_title.get_minimum_size().y and scene.chat_input.get_global_rect().end.y + 2.0 <= custom_title.get_global_rect().position.y, "custom-message counter has a complete line below the input")
		check(close.size.y >= 44.0 and history.size.y >= 44.0 and scene.chat_input.size.y >= 44.0 and send.size.y >= 44.0, "chat close history input and send retain forty-four-pixel targets")
		check(close.get_global_rect().end.y + 2.0 <= scroll.get_global_rect().position.y and history.get_global_rect().end.y + 2.0 <= scroll.get_global_rect().position.y, "chat message scroll clears the complete header action lane")
		check(scene.chat_input.get_global_rect().end.x + 8.0 <= send.get_global_rect().position.x, "chat input and clear controls keep an eight-pixel gap from send")
		await save_reading_capture(scene, output_dir, "chat_open", {"route": scene.chat_panel_route_name(), "drawer_rect": str(panel.get_global_rect()), "message_scroll_rect": str(scroll.get_global_rect()), "quick_title_rect": str(quick_title.get_global_rect()), "input_title_rect": str(custom_title.get_global_rect())})
		var body := scene.find_child("ChatPanelBodyScroll", true, false) as ScrollContainer
		check(body != null and body.follow_focus and body.clip_contents, "chat has a real scrollable composing surface with native focus following")
		if body != null:
			body.ensure_control_visible(scroll)
			await settle()
			var message_bar := scroll.get_v_scroll_bar()
			check(body.get_global_rect().grow(1.0).encloses(scroll.get_global_rect()) and message_bar.max_value > message_bar.page, "the complete message viewport is reachable and has real history to scroll")
			scroll.grab_focus()
			await send_key(KEY_HOME, 0)
			await settle()
			check(message_bar.value <= 1.0, "native Home reaches the first chat message")
			check(range_label.text.contains("历史") and range_label.text.contains("20"), "history status reports the message total without inventing a visible range")
			await save_reading_capture(scene, output_dir, "chat_history_first", {"body_scroll_value": body.scroll_vertical, "message_scroll_value": message_bar.value})
			await send_key(KEY_END, 0)
			await settle()
			check(message_bar.value + 1.0 >= message_bar.max_value - message_bar.page, "native End reaches the latest chat message")
			check(message_text != null and bool(message_text.get_meta("native_wrapped_height", false)) and message_text.custom_minimum_size.y == 0.0 and absf(message_text.get_global_rect().end.y - scroll.get_global_rect().end.y) <= 2.0, "latest message reaches the viewport bottom without estimated blank space")
			check(range_label.text.contains("最新") and range_label.text.contains("20"), "latest status reports the message total and actual scroll end")
			await save_reading_capture(scene, output_dir, "chat_history_latest", {"body_scroll_value": body.scroll_vertical, "message_scroll_value": message_bar.value})
			body.grab_focus()
			await send_key(KEY_END, 0)
			await settle()
			var body_bar := body.get_v_scroll_bar()
			check(body_bar.value + 1.0 >= body_bar.max_value - body_bar.page, "keyboard End reaches the end of the real chat body")
			await send_key(KEY_HOME, 0)
			await settle()
			check(body.get_global_rect().grow(1.0).encloses(scene.chat_input.get_global_rect()) and body.get_global_rect().grow(1.0).encloses(send.get_global_rect()), "keyboard Home returns to the complete input and send targets at the start of the drawer")
			await save_reading_capture(scene, output_dir, "chat_compose", {"body_scroll_value": body.get_v_scroll_bar().value, "input_rect": str(scene.chat_input.get_global_rect()), "send_rect": str(send.get_global_rect()), "tutorial_visible": tutorial_prompt != null and tutorial_prompt.is_visible_in_tree()})
			var last_quick := scene.find_child("ChatQuickMessageButton_%d" % (scene.CHAT_QUICK_MESSAGES.size() - 1), true, false) as Button
			if last_quick != null:
				last_quick.grab_focus()
				await settle()
				check(body.get_global_rect().grow(1.0).encloses(last_quick.get_global_rect()), "native focus reveals the complete last quick-message target")
				await save_reading_capture(scene, output_dir, "chat_quick", {"body_scroll_value": body.scroll_vertical, "last_quick": last_quick.text})
			scene.chat_input.text = "测".repeat(scene.CHAT_MESSAGE_MAX_LENGTH)
			scene.chat_input.text_changed.emit(scene.chat_input.text)
			scene.chat_input.grab_focus()
			await settle()
			check(custom_title.text.contains("%d/%d" % [scene.CHAT_MESSAGE_MAX_LENGTH, scene.CHAT_MESSAGE_MAX_LENGTH]) and label_text_width(custom_title, custom_title.text) <= custom_title.size.x + 1.0, "maximum-length custom-message count remains fully readable")
			await save_reading_capture(scene, output_dir, "chat_max_count", {"counter": custom_title.text, "body_scroll_value": body.get_v_scroll_bar().value})
			var clear_proxy := scene.find_child("ChatInputClearButton", true, false) as Button
			check(clear_proxy != null and body.is_ancestor_of(clear_proxy) and clear_proxy.is_visible_in_tree() and body.get_global_rect().grow(1.0).encloses(clear_proxy.get_global_rect()) and scene.chat_input.get_global_rect().grow(1.0).encloses(clear_proxy.get_global_rect()) and clear_proxy.get_global_rect().end.x + 8.0 <= send.get_global_rect().position.x, "the full clear target scrolls with the input and preserves the actual send gutter")
			await activate_button(clear_proxy, "touch")
			await settle()
			check(scene.chat_input.text.is_empty() and scene.chat_input.has_focus() and custom_title.text.contains("0/%d" % scene.CHAT_MESSAGE_MAX_LENGTH), "touch clear empties the native input, resets its counter and restores its focus")
		scene.chat_input.text = "可读性验证"
		scene.chat_input.grab_focus()
		var writes_before: int = scene.tcp.writes.size()
		var hand_before: Array = scene.get_self_hand().duplicate()
		await send_key(KEY_ENTER, 0)
		await settle(0.08)
		var chat_writes := 0
		var table_writes := 0
		for payload_text in scene.tcp.writes.slice(writes_before):
			var payload: Variant = JSON.parse_string(payload_text)
			if typeof(payload) == TYPE_DICTIONARY:
				chat_writes += 1 if payload.get("type", "") == "chat" else 0
				table_writes += 1 if payload.get("type", "") in ["discard", "claim"] else 0
		check(chat_writes == 1 and table_writes == 0 and scene.get_self_hand() == hand_before and scene.chat_messages.back().contains("可读性验证"), "native input Enter sends the message once without a table action")
		check(latest_preview != null and latest_preview.text == str(scene.chat_messages.back()), "latest-message preview updates after the real send")
		await save_reading_capture(scene, output_dir, "chat_sent", {"transport_writes": scene.tcp.writes.size(), "chat_writes": chat_writes, "table_writes": table_writes, "latest_message": scene.chat_messages.back()})
		var quick_send := scene.find_child("ChatQuickMessageButton_0", true, false) as Button
		if quick_send != null:
			scene.online_last_chat_sent_msec = 0
			scene.update_chat_send_cooldown()
			quick_send.grab_focus()
			await settle()
			var quick_writes_before: int = scene.tcp.writes.size()
			await activate_button(quick_send, "mouse")
			await settle(0.08)
			var quick_payload: Variant = JSON.parse_string(str(scene.tcp.writes.back())) if scene.tcp.writes.size() > quick_writes_before else null
			check(scene.tcp.writes.size() == quick_writes_before + 1 and typeof(quick_payload) == TYPE_DICTIONARY and quick_payload.get("type", "") == "chat" and scene.get_self_hand() == hand_before, "native quick message sends one chat request without a table action")
	await send_key(KEY_ESCAPE, 0)
	await settle(0.08)
	check(not scene.chat_panel_open, "Esc closes the real chat drawer")
	for meld_seat in [2, 1]:
		await check_chat_meld_reading(scene, output_dir, meld_seat)


func check_chat_meld_reading(scene: Node, output_dir: String, meld_seat: int) -> void:
	var player: Dictionary = {}
	for player_value in scene.online_game.get("players", []):
		if int(player_value.get("seat", -1)) == meld_seat:
			player = player_value
	check(not player.is_empty(), "chat reading fixture finds meld seat %d" % meld_seat)
	if player.is_empty():
		return
	var previous_melds: Array = player.get("melds", []).duplicate(true)
	player["melds"] = [["1W", "1W", "1W"]]
	scene.online_last_chat_sent_msec = 0
	scene.render_game()
	await settle()
	await activate_button(scene.find_child("ChatActionButton", true, false) as Button, "mouse")
	await settle()
	var panel := scene.find_child("ChatPanel", true, false) as Control
	var body := scene.find_child("ChatPanelBodyScroll", true, false) as ScrollContainer
	var send := scene.find_child("ChatSendButton", true, false) as Button
	check(panel != null and body != null and send != null and scene.chat_panel_route_name() != "upper_meld_safe_drawer", "active meld seat %d selects an unobstructed alternate chat route" % meld_seat)
	if panel != null and body != null and send != null:
		for seat in range(4):
			for lane_name in ["MeldArea_%d" % seat, "DiscardGrid_%d" % seat, "SeatPanel_%d" % seat]:
				var lane := scene.find_child(lane_name, true, false) as Control
				check(lane == null or not panel.get_global_rect().grow(-1.0).intersects(lane.get_global_rect()), "meld chat seat %d clears %s" % [meld_seat, lane_name])
		scene.chat_input.grab_focus()
		await settle()
		check(body.get_global_rect().grow(1.0).encloses(send.get_global_rect()) and body.get_global_rect().grow(1.0).encloses(scene.chat_input.get_global_rect()), "meld chat seat %d exposes full composing targets through native focus" % meld_seat)
		await save_reading_capture(scene, output_dir, "chat_meld_%d" % meld_seat, {"route": scene.chat_panel_route_name(), "meld_seat": meld_seat, "body_scroll_value": body.scroll_vertical})
	await send_key(KEY_ESCAPE, 0)
	await settle()
	player["melds"] = previous_melds


func check_lobby_chat_reading(scene: Node, output_dir: String) -> void:
	scene.tcp = ConnectedLobbyTransport.new()
	scene.tcp_status = StreamPeerTCP.STATUS_CONNECTED
	scene.selected_room = "ROOM7"
	scene.online_room = connected_room_fixture()
	scene.online_waiting_for_server = false
	scene.online_resume_pending = false
	scene.sent_hello = true
	scene._show_online_lobby_impl()
	await settle(0.08)
	scene.show_chat_panel()
	await settle()
	var panel := scene.find_child("ChatPanel", true, false) as Control
	var body := scene.find_child("ChatPanelBodyScroll", true, false) as ScrollContainer
	var send := scene.find_child("ChatSendButton", true, false) as Button
	check(panel != null and body != null and send != null and not bool(panel.get_meta("compact_chat", true)), "connected lobby uses the shared noncompact scrollable chat lanes")
	if panel != null and body != null and send != null:
		await save_reading_capture(scene, output_dir, "lobby_chat_open", {"route": scene.chat_panel_route_name(), "body_scroll_value": body.scroll_vertical})
		scene.chat_input.grab_focus()
		await settle()
		check(body.get_global_rect().grow(1.0).encloses(scene.chat_input.get_global_rect()) and body.get_global_rect().grow(1.0).encloses(send.get_global_rect()), "lobby native focus exposes full input and send targets")
		check(scene.chat_input.get_global_rect().end.x + 8.0 <= send.get_global_rect().position.x, "lobby chat composing targets preserve the real eight-pixel gutter")
		await save_reading_capture(scene, output_dir, "lobby_chat_compose", {"body_scroll_value": body.scroll_vertical})
	await send_key(KEY_ESCAPE, 0)
	await settle()
	check(not scene.chat_panel_open, "Esc closes the connected-lobby chat drawer")


func redraw_chat_page(scene: Node) -> void:
	if scene.mode == "online_game":
		scene.render_game()
	else:
		scene._show_online_lobby_impl()


func check_chat_live_redraw(scene: Node, output_dir: String = "") -> void:
	var page_mode: String = scene.mode
	scene.show_chat_panel()
	await settle()
	var input := scene.chat_input as LineEdit
	var body := scene.find_child("ChatPanelBodyScroll", true, false) as ScrollContainer
	var messages := scene.find_child("ChatPanelMessageScroll", true, false) as ScrollContainer
	check(input != null and body != null and messages != null, "%s live chat exposes native editing and reading state" % page_mode)
	if input == null or body == null or messages == null:
		return
	input.text = "动态草稿甲乙丙"
	input.text_changed.emit(input.text)
	input.grab_focus()
	input.caret_column = 4
	input.select(1, 4)
	await settle(0.18)
	var draft := input.text
	var caret := input.caret_column
	var body_scroll := body.scroll_vertical
	var writes_before: int = scene.tcp.writes.size()
	scene.add_chat_message("道友: 编辑时收到的新消息")
	await settle(0.18)
	check(input.text == draft and input.has_focus() and body.scroll_vertical == body_scroll, "%s incoming chat preserves the focused draft and outer scroll" % page_mode)
	redraw_chat_page(scene)
	redraw_chat_page(scene)
	await settle(0.18)
	input = scene.chat_input as LineEdit
	body = scene.find_child("ChatPanelBodyScroll", true, false) as ScrollContainer
	messages = scene.find_child("ChatPanelMessageScroll", true, false) as ScrollContainer
	check(input != null and input.text == draft, "%s repeated live page redraw preserves the unsent draft" % page_mode)
	if input != null and body != null and messages != null:
		check(input.has_focus() and body.get_global_rect().grow(1.0).encloses(input.get_global_rect()), "%s repeated live page redraw restores the complete focused input" % page_mode)
		var selection_from := input.get_selection_from_column() if input.has_selection() else -1
		var selection_to := input.get_selection_to_column() if input.has_selection() else -1
		check(input.caret_column == caret and selection_from == 1 and selection_to == 4, "%s repeated live page redraw preserves native caret and selection (caret %d/%d, selection %d..%d)" % [page_mode, input.caret_column, caret, selection_from, selection_to])
		check(absi(body.scroll_vertical - body_scroll) <= 1, "%s repeated live page redraw preserves the composing scroll position (%d/%d)" % [page_mode, body.scroll_vertical, body_scroll])
		var counter := scene.find_child("ChatPanelCustomMessageLabel", true, false) as Label
		check(counter != null and counter.text.contains("%d/%d" % [draft.length(), scene.CHAT_MESSAGE_MAX_LENGTH]), "%s restored chat draft updates the visible character counter" % page_mode)
		if output_dir != "":
			await save_reading_capture(scene, output_dir, "chat_redraw_compose" if page_mode == "online_game" else "lobby_chat_redraw_compose", {"draft": input.text, "focused_control": str(scene.get_viewport().gui_get_focus_owner().name), "caret": input.caret_column, "selection_from": selection_from, "selection_to": selection_to, "body_scroll_value": body.scroll_vertical, "expected_body_scroll": body_scroll, "counter": counter.text if counter != null else ""})
		var close := scene.find_child("ChatPanelCloseButton", true, false) as Button
		if close != null:
			close.grab_focus()
		body.scroll_vertical = 0
		messages.scroll_vertical = 0
		await settle()
		redraw_chat_page(scene)
		await settle(0.18)
		body = scene.find_child("ChatPanelBodyScroll", true, false) as ScrollContainer
		messages = scene.find_child("ChatPanelMessageScroll", true, false) as ScrollContainer
		check(body != null and messages != null and body.scroll_vertical == 0 and messages.scroll_vertical == 0, "%s live page redraw keeps independently scrolled message history at its reading position" % page_mode)
		scene.chat_input.grab_focus()
		await settle(0.18)
		redraw_chat_page(scene)
		var chosen_close := scene.find_child("ChatPanelCloseButton", true, false) as Button
		var chosen_body := scene.find_child("ChatPanelBodyScroll", true, false) as ScrollContainer
		if chosen_close != null and chosen_body != null:
			chosen_close.grab_focus()
			chosen_body.scroll_vertical = 0
		await settle(0.18)
		check(chosen_close != null and chosen_close.has_focus() and chosen_body != null and chosen_body.scroll_vertical == 0, "%s redraw restoration respects a newer user focus and reading position" % page_mode)
	var user_writes := 0
	for payload_text in scene.tcp.writes.slice(writes_before):
		var payload: Variant = JSON.parse_string(payload_text)
		if typeof(payload) == TYPE_DICTIONARY and payload.get("type", "") in ["chat", "discard", "claim"]:
			user_writes += 1
	check(user_writes == 0, "%s restoring a chat draft never transmits it or a table action" % page_mode)
	scene.close_chat_panel()
	scene.show_chat_panel()
	await settle()
	check(scene.chat_input != null and scene.chat_input.text.is_empty(), "%s explicitly reopening chat cannot revive a closed draft" % page_mode)
	scene.chat_input.text = "不得复活的草稿"
	scene.chat_input.grab_focus()
	redraw_chat_page(scene)
	scene.close_chat_panel(false)
	scene.show_chat_panel()
	await settle(0.18)
	var reopened_close := scene.find_child("ChatPanelCloseButton", true, false) as Button
	check(scene.chat_input != null and scene.chat_input.text.is_empty() and reopened_close != null and reopened_close.has_focus(), "%s stale redraw callbacks cannot repopulate or steal focus from reopened chat" % page_mode)
	scene.chat_input.text = "不能带到下一连接的草稿"
	scene.online_session_id += 1
	redraw_chat_page(scene)
	await settle(0.18)
	check(scene.chat_input != null and scene.chat_input.text.is_empty(), "%s a new connection session cannot reuse the previous chat draft" % page_mode)
	var selected_room_before: String = scene.selected_room
	var room_code_before: String = scene.online_room.get("code", "")
	var game_room_before: String = scene.online_game.get("roomCode", "")
	scene.chat_input.text = "不能带到下一房间的草稿"
	scene.selected_room = "REDRAW_OTHER"
	scene.online_room["code"] = "REDRAW_OTHER"
	scene.online_game["roomCode"] = "REDRAW_OTHER"
	redraw_chat_page(scene)
	await settle(0.18)
	check(scene.chat_input != null and scene.chat_input.text.is_empty(), "%s a different room cannot inherit the previous chat draft" % page_mode)
	scene.chat_input.text = "弹层期间保留草稿"
	scene.chat_input.grab_focus()
	redraw_chat_page(scene)
	scene.show_exit_confirm()
	await settle(0.18)
	var exit_continue := scene.find_child("ExitConfirmContinueButton", true, false) as Button
	check(exit_continue != null and exit_continue.has_focus(), "%s delayed chat restoration cannot steal a higher-priority confirmation focus" % page_mode)
	scene.hide_exit_confirm()
	await settle(0.18)
	scene.close_chat_panel()
	scene.selected_room = selected_room_before
	scene.online_room["code"] = room_code_before
	scene.online_game["roomCode"] = game_room_before
	await settle()


func run() -> void:
	print("=== ui battle reading evidence smoke START ===")
	if DisplayServer.get_name().to_lower() == "headless":
		quit(1)
		return
	OS.set_environment("YUNZHUO_UI_CAPTURE", "1")
	var arguments := OS.get_cmdline_user_args()
	var viewport_size := Vector2i(960, 540)
	if not arguments.is_empty():
		var dimensions := arguments[0].split("x")
		if dimensions.size() == 2:
			viewport_size = Vector2i(int(dimensions[0]), int(dimensions[1]))
	var large_contrast := arguments.size() > 1 and arguments[1] == "large_contrast"
	DisplayServer.window_set_size(viewport_size)
	root.size = viewport_size
	root.content_scale_size = viewport_size
	var output_dir := ProjectSettings.globalize_path("res://build/qa/battle_reading_evidence_%dx%d%s" % [viewport_size.x, viewport_size.y, "_large_contrast" if large_contrast else ""])
	if OS.get_environment("YUNZHUO_BATTLE_READING_OUTPUT_DIR") != "":
		output_dir = ProjectSettings.globalize_path(OS.get_environment("YUNZHUO_BATTLE_READING_OUTPUT_DIR"))
	check(DirAccess.make_dir_recursive_absolute(output_dir) == OK, "battle reading evidence directory is writable")
	var scene = load("res://Main.tscn").instantiate()
	root.add_child(scene)
	await settle(0.10)
	var snapshot := capture_smoke_state(scene)
	scene.large_text_enabled = large_contrast
	scene.high_contrast_enabled = large_contrast
	scene.reduce_motion_enabled = true
	scene.music_enabled = false
	scene.sfx_enabled = false
	scene.voice_enabled = false
	scene.tts_enabled = false
	scene.fx_enabled = false
	await check_table_reading(scene, output_dir)
	await check_advisor_reading(scene, output_dir)
	await check_chat_reading(scene, output_dir)
	await check_chat_live_redraw(scene, output_dir)
	await check_lobby_chat_reading(scene, output_dir)
	await check_chat_live_redraw(scene, output_dir)
	if scene.has_method("shutdown_runtime"):
		scene.shutdown_runtime()
	restore_smoke_state(scene, snapshot)
	scene.queue_free()
	await process_frame
	print("=== RESULT: %s ===" % ("FAIL" if failed else "OK"))
	quit(1 if failed else 0)
