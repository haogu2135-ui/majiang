extends "res://scripts/ui_battle_reading_evidence_smoke_test.gd"


func settlement_state(scene: Node) -> Dictionary:
	var facts: Dictionary = {}
	for node_name in ["RoundSummaryPanel", "RoundSummaryTitle", "WinDetailPanel", "WinDetailWinnerLabel", "WinDetailScoreLabel", "WinDetailTile", "WinDetailYakuScroll", "WinDetailYakuStatus", "RoundSummaryBodyScroll", "RoundSummaryBody", "RoundSummaryBodyStatus", "RoundSummaryRankHeader", "RoundSummaryNextDealer", "RoundSummaryActionRow"]:
		var control := scene.find_child(node_name, true, false) as Control
		if control != null:
			var r := control.get_global_rect()
			var entry := {"rect": [r.position.x, r.position.y, r.size.x, r.size.y], "z_index": control.z_index}
			if control is Label:
				entry["text"] = (control as Label).text
				entry["font_size"] = (control as Label).get_theme_font_size("font_size")
			if node_name == "RoundSummaryBody":
				var body := control as Label
				var last_glyph := body.get_character_bounds(body.text.length() - 1)
				last_glyph.position += body.global_position
				entry["last_character_rect"] = [last_glyph.position.x, last_glyph.position.y, last_glyph.size.x, last_glyph.size.y]
				entry["native_line_count"] = body.get_line_count()
				entry["custom_minimum_height"] = body.custom_minimum_size.y
				entry["native_minimum_height"] = body.get_minimum_size().y
			if control is ScrollContainer:
				entry["scroll_value"] = (control as ScrollContainer).get_v_scroll_bar().value
				entry["scroll_range"] = (control as ScrollContainer).get_v_scroll_bar().max_value - (control as ScrollContainer).get_v_scroll_bar().page
			facts[node_name] = entry
	var rows: Array[Dictionary] = []
	for seat in range(4):
		var row := scene.find_child("RoundSummaryRankRow_%d" % seat, true, false) as Control
		if row == null:
			continue
		rows.append({"seat": seat, "rect": str(row.get_global_rect()), "total": (row.find_child("RoundSummaryScoreLabel", true, false) as Label).text, "delta": (row.find_child("RoundSummaryDeltaLabel", true, false) as Label).text})
	return {"facts": facts, "rank_rows": rows, "result_kind": scene.round_result_kind, "hand_number": scene.offline_hand_number, "score_data": scene.last_win_score, "summary": scene.round_summary, "deltas": scene.last_score_deltas}


func check_settlement_paper(scene: Node) -> void:
	var panel := scene.find_child("RoundSummaryPanel", true, false) as TextureRect
	var shield := scene.find_child("RoundSummaryModalInputShield", true, false) as Control
	var actions := scene.find_child("RoundSummaryActionRow", true, false) as Control
	check(panel != null and panel.texture is AtlasTexture and (panel.texture as AtlasTexture).atlas == scene.optional_gpt_illustration_texture("settings_readable_gpt") and panel.self_modulate == Color.WHITE, "settlement uses one opaque authored paper")
	if panel == null or shield == null or actions == null:
		check(false, "settlement has its actual panel shield and external actions")
		return
	var panel_rect := panel.get_global_rect()
	check(panel_rect.position.x >= 12.0 and panel_rect.position.y >= 10.0 and panel_rect.end.x <= root.size.x - 12.0, "the complete account page stays inside the viewport")
	check(shield.z_index < panel.z_index and actions.z_index > panel.z_index, "modal shield paper and external actions retain correct stacking")
	var marker := scene.find_child("LastDiscardFocusMarker", true, false) as Control
	check(marker == null or marker.z_index < shield.z_index, "the latest-discard marker stays behind the modal instead of leaking through the paper")
	for retired in ["RoundSummaryAmbience", "RoundSummaryScoreFlowBus", "RoundSummaryDeltaBar", "SummaryVictoryRibbon", "WinDetailScoreConstellation", "WinDetailResolutionBridge", "WinDetailShowcaseRoute", "WinDetailSeal", "WinDetailScrollTexture"]:
		check(panel.find_child(retired, true, false) == null, "settlement removes retired decoration %s" % retired)
	var labels: Array[Label] = []
	for node in panel.find_children("*", "Label", true, false):
		var label := node as Label
		labels.append(label)
		check(label.get_theme_color("font_color").get_luminance() <= 0.24 and label.get_theme_constant("outline_size") == 0, "%s has opaque dark ink without outline compensation" % label.name)
		check(label.get_theme_color("font_color").a >= 0.99 and label.size.y + 0.5 >= label.get_minimum_size().y, "%s has its complete native font height" % label.name)
		if label.name != "RoundSummaryBody":
			check(panel_rect.grow(0.5).encloses(label.get_global_rect()), "%s remains fully within the account paper" % label.name)
		if label.name in ["WinDetailWinnerLabel", "WinDetailScoreLabel", "WinDetailYakuStatus", "RoundSummaryScoreLabel", "RoundSummaryDeltaLabel", "RoundSummaryFlowersLabel", "RoundSummaryNextDealer"]:
			check(label_text_width(label, label.text.split("\n")[0]) <= label.size.x + 0.5, "%s keeps the full fact at its accessible font size" % label.name)
	for seat in range(4):
		var row := scene.find_child("RoundSummaryRankRow_%d" % seat, true, false) as Control
		check(row != null and panel_rect.encloses(row.get_global_rect()), "rank row %d fits inside the paper" % seat)
		if row != null:
			var total := row.find_child("RoundSummaryScoreLabel", true, false) as Label
			var delta := row.find_child("RoundSummaryDeltaLabel", true, false) as Label
			check(total.text == str(int(scene.players[seat]["score"])) and delta.text == "%+d" % scene.round_summary_score_delta(seat), "rank row %d shows exact total and signed delta" % seat)
			for other in range(seat):
				var preceding := scene.find_child("RoundSummaryRankRow_%d" % other, true, false) as Control
				check(not row.get_global_rect().intersects(preceding.get_global_rect()), "rank rows %d and %d keep independent heights" % [seat, other])
	var winner := scene.find_child("WinDetailWinnerLabel", true, false) as Label
	var score := scene.find_child("WinDetailScoreLabel", true, false) as Label
	var basis := scene.find_child("WinDetailYakuStatus", true, false) as Label
	if score != null:
		check(score.text == "本局 %+d分" % scene.round_summary_score_delta(0) and score.get_theme_font_size("font_size") >= scene.accessibility_font_size(22), "the primary score shows the actual signed local round delta at prominent native size")
		check(basis != null and basis.text.begins_with("%d番 · 基础分%d分 · 番种%d项" % [int(scene.last_win_score.get("fan", 0)), int(scene.last_win_score.get("points", 0)), scene.last_win_score.get("reasons", []).size()]) and basis.get_theme_font_size("font_size") >= scene.accessibility_font_size(13), "the secondary score explicitly identifies the independent fan/base/count facts")
	var yaku_scroll := scene.find_child("WinDetailYakuScroll", true, false) as ScrollContainer
	var body_scroll := scene.find_child("RoundSummaryBodyScroll", true, false) as ScrollContainer
	var body := scene.find_child("RoundSummaryBody", true, false) as Label
	check(body != null and str(body.get_meta("ui_full_text", "")).contains(scene.round_summary) and body.text.contains(scene.round_summary_body_text()) and body_scroll.size.y >= float(body.get_line_height()) * 2.0 + float(body.get_theme_constant("line_spacing")), "settlement keeps the complete source and two scrollable reading lines for consequences")
	if basis != null and yaku_scroll != null and yaku_scroll.get_v_scroll_bar().max_value - yaku_scroll.get_v_scroll_bar().page <= 0.5:
		check(not basis.text.contains("已到末尾") and not basis.text.contains("可滚动"), "fitting settlement reasons do not show scroll diagnostics")
	if winner != null and score != null and yaku_scroll != null:
		check(winner.get_global_rect().end.y + 3.5 <= score.get_global_rect().position.y and score.get_global_rect().end.y + 3.5 <= yaku_scroll.get_global_rect().position.y, "winner score and reasons own separate measured lanes")
		check(yaku_scroll.get_global_rect().end.y < body_scroll.get_global_rect().position.y, "all reasons clear the independent full settlement source")
		var tile := scene.find_child("WinDetailTile", true, false) as Control
		check(tile != null and not tile.get_global_rect().intersects(winner.get_global_rect()) and not tile.get_global_rect().intersects(score.get_global_rect()) and not tile.get_global_rect().intersects(yaku_scroll.get_global_rect()), "authored winning tile clears the winner score and complete reasons")
	for button in actions.find_children("*", "Button", true, false):
		check((button as Button).size.y >= 44.0, "settlement action %s keeps a native touch target" % button.name)


func check_settlement_final_line(scene: Node) -> void:
	var body := scene.find_child("RoundSummaryBody", true, false) as Label
	var scroll := scene.find_child("RoundSummaryBodyScroll", true, false) as ScrollContainer
	var last_glyph := body.get_character_bounds(body.text.length() - 1)
	last_glyph.position += body.global_position
	check(last_glyph.size.x > 0.0 and last_glyph.size.y > 0.0 and scroll.get_global_rect().grow(0.5).encloses(last_glyph), "the actual final shaped character is completely visible at the native scroll end (glyph=%s viewport=%s)" % [last_glyph, scroll.get_global_rect()])


func seed_settlement(scene: Node) -> void:
	await prepare_offline_reading_fixture(scene)
	scene.offline_phase = "ended"
	scene.round_result_kind = "win"
	scene.offline_hand_number = 3
	scene.offline_last_winner = 0
	scene.offline_dealer_repeat = false
	scene.dealer_seat = 0
	scene.players[0]["name"] = "你"
	scene.players[1]["name"] = "青竹道人"
	scene.players[2]["name"] = "南山客"
	scene.players[3]["name"] = "扶摇散人"
	var deltas: Array[int] = [76800, -25600, -25600, -25600]
	scene.last_score_deltas = deltas
	for seat in range(4):
		scene.players[seat]["score"] = 25000 + deltas[seat]
		scene.players[seat]["flowers"] = seat
	scene.refresh_score_delta_cache()
	scene.last_discard = "9B"
	scene.last_discard_seat = 3
	scene.players[3]["discards"] = ["9B"]
	scene.last_win_score = {"winner": 0, "fan": 8, "points": 25600, "self_draw": true, "win_tile": "9W", "limit_name": "封顶", "reasons": ["清一色", "门清", "一条龙", "杠上开花", "海底捞月", "自摸", "花牌加番", "边张", "单钓将", "无字", "幺九刻", "连六", "碰碰胡", "混一色", "三色三步高", "三色三同顺", "混幺九", "双同刻", "全求人", "不求人", "喜相逢", "老少副", "缺一门", "明杠"]}
	scene.round_summary = "你自摸9万，8番 25600分。庄家下庄。" + "本局四家得分已记录，按当前规则结算，下一局从新的庄家开始。".repeat(24) + "结算说明最后一行。"
	scene.active_round_id = "UI-GUOFENG-SETTLEMENT"
	scene.round_event_history = valid_replay_events(scene, scene.active_round_id)
	scene.ai_state_revision += 1
	scene.render_game()
	await settle()


func check_normal_settlements(scene: Node, output_dir: String) -> void:
	# Use the production legality, scoring and payment branches; no invented deltas.
	for result in ["self_draw", "ron_win", "deal_in", "uninvolved"]:
		await prepare_offline_reading_fixture(scene)
		scene.offline_sim_quiet = true
		scene.offline_hand_number = 3
		scene.dealer_seat = 0
		scene.offline_claim_counts.clear()
		scene.offline_package_liability.clear()
		scene.last_score_deltas.clear()
		scene.offline_last_draw.clear()
		scene.players[0]["name"] = "你"
		scene.players[1]["name"] = "青竹道人"
		scene.players[2]["name"] = "南山客"
		scene.players[3]["name"] = "扶摇散人"
		var winner := 0 if result in ["self_draw", "ron_win"] else 1
		var payer := 0 if result == "deal_in" else 2
		var self_draw: bool = result == "self_draw"
		var complete: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "2T", "3T", "4T", "7B", "8B", "9B", "E", "E"]
		scene.players[winner]["hand"] = complete.duplicate()
		scene.current_seat = winner
		if self_draw:
			scene.offline_last_draw = {"seat": winner, "tile": "E", "source": "normal", "wall_empty": false, "serial": 9501}
			scene.offline_self_draw_ready = {"seat": winner, "tile": "E", "serial": 9501}
		else:
			scene.players[winner]["hand"].erase("E")
			scene.players[payer]["discards"] = ["E"]
			scene.last_discard = "E"
			scene.last_discard_seat = payer
			scene.offline_phase = "resolving"
		check(scene.can_finish_offline_round(winner, "E", self_draw, -1 if self_draw else payer), "normal %s fixture passes the actual production win boundary" % result)
		scene.finish_offline_round(winner, "E", self_draw, -1 if self_draw else payer)
		scene.offline_sim_quiet = false
		scene.render_game()
		await settle()
		check(scene.offline_phase == "ended" and scene.round_result_kind == "win", "normal %s reaches the production settlement" % result)
		var points := int(scene.last_win_score.get("points", 0))
		var expected_local := points * 3 if winner == 0 else (-points * 3 if payer == 0 else 0)
		check(points > 0 and scene.round_summary_score_delta(0) == expected_local, "normal %s independently verifies the actual local payment" % result)
		var displayed_body := scene.find_child("RoundSummaryBody", true, false) as Label
		var repeated_reasons := "、".join(scene.last_win_score.get("reasons", []))
		check(displayed_body != null and (repeated_reasons == "" or not displayed_body.text.contains(repeated_reasons)) and displayed_body.text.contains("庄家"), "normal %s keeps dealer consequences without repeating structured reasons" % result)
		check_settlement_paper(scene)
		await save_reading_capture(scene, output_dir, "normal_" + result, settlement_state(scene))
		scene.offline_sim_quiet = false


func check_settlement_inputs(scene: Node, output_dir: String) -> void:
	await seed_settlement(scene)
	check_settlement_paper(scene)
	await save_reading_capture(scene, output_dir, "win_top", settlement_state(scene))
	var hand: Array = scene.get_self_hand().duplicate()
	var scores: Array = scene.players.map(func(player): return player["score"])
	var body_scroll := scene.find_child("RoundSummaryBodyScroll", true, false) as ScrollContainer
	var yaku_scroll := scene.find_child("WinDetailYakuScroll", true, false) as ScrollContainer
	for scroll in [body_scroll, yaku_scroll]:
		scroll.grab_focus()
		await send_key(KEY_END, 0)
		await settle()
		var bar: VScrollBar = scroll.get_v_scroll_bar()
		check(bar.max_value - bar.page > 0.0 and bar.value >= bar.max_value - bar.page - 0.5, "%s reaches its real final content through keyboard input" % scroll.name)
	check(scene.get_self_hand() == hand and scene.players.map(func(player): return player["score"]) == scores, "reading either scroll cannot submit a tile or change scores")
	check_settlement_final_line(scene)
	await save_reading_capture(scene, output_dir, "win_end", settlement_state(scene))
	var panel := scene.find_child("RoundSummaryPanel", true, false) as Control
	var panel_id := panel.get_instance_id()
	var scroll_id := body_scroll.get_instance_id()
	var scroll_value := body_scroll.scroll_vertical
	scene.render_game()
	await settle()
	panel = scene.find_child("RoundSummaryPanel", true, false) as Control
	body_scroll = scene.find_child("RoundSummaryBodyScroll", true, false) as ScrollContainer
	check(panel.get_instance_id() == panel_id and body_scroll.get_instance_id() == scroll_id and body_scroll.scroll_vertical == scroll_value, "unchanged settlement redraw retains the real paper and reading position")
	check_settlement_paper(scene)
	check_settlement_final_line(scene)
	await save_reading_capture(scene, output_dir, "retained", settlement_state(scene))
	var replay := scene.find_child("CopyReplayCodeButton", true, false) as Button
	DisplayServer.clipboard_set("")
	await activate_button(replay, "mouse")
	check(DisplayServer.clipboard_get() == scene.round_replay_share_code() and scene.get_self_hand() == hand, "mouse replay copies the actual verified current round without playing a tile")
	scene.dismiss_active_toast()
	var next := first_button_with_text(scene.action_bar, "下一局")
	await activate_button(next, "key")
	await settle()
	check(scene.offline_phase != "ended" and scene.offline_hand_number == 4 and scene.find_child("RoundSummaryPanel", true, false) == null, "keyboard next-hand leaves the settlement and advances exactly one round")
	await seed_settlement(scene)
	scene.offline_hand_number = scene.MATCH_MAX_HANDS
	scene.round_summary = "全场结束。冠军：你（101800分）。"
	scene.ai_state_revision += 1
	scene.render_game()
	await settle()
	check((scene.find_child("RoundSummaryTitle", true, false) as Label).text == "全场结算" and first_button_with_text(scene.action_bar, "下一局") == null, "the actual final hand uses match completion rather than a next-hand route")
	check_settlement_paper(scene)
	await save_reading_capture(scene, output_dir, "match_complete", settlement_state(scene))
	await seed_settlement(scene)
	scene.round_result_kind = "wall_draw"
	scene.last_win_score = {"wall_draw": true}
	var no_penalty_deltas: Array[int] = [0, 0, 0, 0]
	scene.last_score_deltas = no_penalty_deltas
	for seat in range(4):
		scene.players[seat]["score"] = 25000
	scene.refresh_score_delta_cache()
	scene.offline_dealer_repeat = true
	scene.wall.clear()
	scene.round_summary = "荒庄，牌墙已空。庄家连庄。四家未听，不罚符。"
	scene.ai_state_revision += 1
	scene.render_game()
	await settle()
	check(scene.find_child("WinDetailPanel", true, false) == null and (scene.find_child("RoundSummaryTitle", true, false) as Label).text == "荒庄结算", "wall draw displays its own result without a stale winning tile or fan count")
	check_settlement_paper(scene)
	await save_reading_capture(scene, output_dir, "wall_draw", settlement_state(scene))
	var menu := scene.find_child("SummaryMenuSecondaryButton", true, false) as Button
	await activate_button(menu, "touch")
	await settle(0.72)
	check(scene.mode == "menu" and scene.find_child("RoundSummaryPanel", true, false) == null, "touch menu leaves the ended table through the real secondary action")


func run() -> void:
	print("=== guofeng settlement UI smoke START ===")
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
	var capture_root := OS.get_environment("YUNZHUO_GUOFENG_SETTLEMENT_CAPTURE_DIR")
	if capture_root.is_empty():
		capture_root = "res://build/qa/guofeng_settlement"
	var output_dir := ProjectSettings.globalize_path("%s/%dx%d%s" % [capture_root, viewport_size.x, viewport_size.y, "_large_contrast" if large_contrast else ""])
	check(DirAccess.make_dir_recursive_absolute(output_dir) == OK, "settlement evidence directory is writable")
	var scene = load("res://Main.tscn").instantiate()
	if scene.get_script() == null:
		check(false, "runtime must compile before settlement evidence")
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
	await check_normal_settlements(scene, output_dir)
	await check_settlement_inputs(scene, output_dir)
	scene.shutdown_runtime()
	restore_smoke_state(scene, user_state)
	scene.queue_free()
	await process_frame
	print("=== RESULT: %s ===" % ("FAIL" if failed else "OK"))
	quit(1 if failed else 0)
